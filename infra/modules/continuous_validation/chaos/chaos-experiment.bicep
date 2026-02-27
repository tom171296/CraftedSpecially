@description('Name of the Chaos Studio experiment')
param experimentName string

@description('Azure region')
param location string = resourceGroup().location

@description('Environment tag value used in the KQL target query (e.g. staging, prod). Matches the `environment` tag on AKS node pool VMSSes.')
param environment string

@description('Azure subscription ID scoped in the KQL selector query')
param subscriptionId string = subscription().subscriptionId

@description('Availability zone to fault (1, 2, or 3)')
@allowed([1, 2, 3])
param targetZone int = 1

@description('Duration of the fault in minutes (default 10)')
@minValue(1)
@maxValue(60)
param faultDurationMinutes int = 10

@description('Resource ID of the user-assigned managed identity used by the experiment')
param managedIdentityId string

var selectorId = 'aks-node-pools'

resource experiment 'Microsoft.Chaos/experiments@2023-11-01' = {
  name: experimentName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    selectors: [
      {
        type: 'Query'
        id: selectorId
        // KQL query resolves targets at runtime — no resource IDs baked into the template.
        // Targets VMSS resources tagged chaos-target=true in the given environment.
        queryString: 'Resources | where type == \'microsoft.compute/virtualmachinescalesets\' | where tags[\'chaos-target\'] == \'true\' and tags[\'environment\'] == \'${environment}\''
        subscriptionIds: [subscriptionId]
        filter: {
          type: 'Simple'
          parameters: {
            zones: [
              '${targetZone}'
            ]
          }
        }
      }
    ]
    steps: [
      {
        name: 'AKS Zonal Failure'
        branches: [
          {
            name: 'Shutdown Zone ${targetZone}'
            actions: [
              {
                type: 'continuous'
                name: 'urn:csci:microsoft:virtualMachineScaleSet:shutdown/2.0'
                duration: 'PT${faultDurationMinutes}M'
                parameters: [
                  {
                    key: 'abruptShutdown'
                    value: 'false'
                  }
                ]
                selectorId: selectorId
              }
            ]
          }
        ]
      }
    ]
  }
}

output experimentId string = experiment.id
output experimentName string = experiment.name
