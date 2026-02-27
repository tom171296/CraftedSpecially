@description('Azure region for all chaos resources')
param location string = resourceGroup().location

@description('Short prefix used for resource naming')
param prefix string = 'cs-chaos'

@description('Name of the Chaos Studio experiment resource')
param experimentName string = '${prefix}-aks-zonal-failure'

@description('Environment tag value used in the KQL target selector query (e.g. staging, prod). Must match the `environment` tag on the AKS node pool VMSSes.')
param environment string

@description('Availability zone to fault (1, 2, or 3)')
@allowed([1, 2, 3])
param targetZone int = 1

@description('Duration of the fault in minutes')
@minValue(1)
@maxValue(60)
param faultDurationMinutes int = 10

@description('Name of the AKS node resource group (MC_*) where the VMSS resources live')
param nodeResourceGroupName string

@description('Names of the AKS user node pool VMSSes in the node resource group to enroll as Chaos Studio targets')
param vmssNames array

// ------------------------------------------------------------------
// Managed identity used by Chaos Studio to authenticate against Azure
// ------------------------------------------------------------------
resource chaosIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}-identity'
  location: location
}

// ------------------------------------------------------------------
// RBAC — Reader at subscription scope so the KQL Query selector can
// resolve targets via Azure Resource Graph at experiment runtime.
// ------------------------------------------------------------------
module subscriptionRbac './chaos-subscription-rbac.bicep' = {
  name: 'deployChaosSubscriptionRbac'
  scope: subscription()
  params: {
    principalId: chaosIdentity.properties.principalId
    identityId: chaosIdentity.id
  }
}

// ------------------------------------------------------------------
// RBAC — Virtual Machine Contributor on the AKS node resource group
// so the managed identity can execute the VMSS Shutdown fault.
// ------------------------------------------------------------------
module nodeRgRbac './chaos-node-rg-rbac.bicep' = {
  name: 'deployChaosNodeRgRbac'
  scope: resourceGroup(nodeResourceGroupName)
  params: {
    principalId: chaosIdentity.properties.principalId
    identityId: chaosIdentity.id
  }
}

// ------------------------------------------------------------------
// Register the Chaos Studio target + Shutdown-2.0 capability on each
// VMSS so the experiment's KQL selector can resolve them as valid targets.
// VMSSes are tagged via AKS agent pool tags (set in AKS.bicep).
// ------------------------------------------------------------------
module vmssCapability './chaos-capability.bicep' = [
  for vmssName in vmssNames: {
    name: 'capabilityVmss-${vmssName}'
    scope: resourceGroup(nodeResourceGroupName)
    params: {
      vmssName: vmssName
    }
  }
]

// ------------------------------------------------------------------
// Chaos Studio experiment — targets resolved at runtime via KQL query.
// ------------------------------------------------------------------
module chaosExperiment './chaos-experiment.bicep' = {
  name: 'deployChaosExperiment'
  dependsOn: [
    subscriptionRbac
    nodeRgRbac
    vmssCapability
  ]
  params: {
    experimentName: experimentName
    location: location
    environment: environment
    targetZone: targetZone
    faultDurationMinutes: faultDurationMinutes
    managedIdentityId: chaosIdentity.id
  }
}

output experimentId string = chaosExperiment.outputs.experimentId
output experimentName string = chaosExperiment.outputs.experimentName
output managedIdentityPrincipalId string = chaosIdentity.properties.principalId
