targetScope='subscription'

param projectLocation string = 'canadacentral'
param projectName string = 'CraftedSpecially'
param environment string = 'staging'

@description('AKS node resource group name (MC_*). Run: az aks show -g CraftedSpecially -n CraftedSpecially-aks --query nodeResourceGroup -o tsv')
param chaosNodeResourceGroup string = 'MC_${projectName}_${projectName}-aks_${projectLocation}'

@description('VMSS names to enroll as Chaos Studio targets. Run: az vmss list -g <NODE_RG> --query "[].name" -o tsv')
param chaosVmssNames array = [
  'aks-workloadpool-94760578-vmss'
]

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: projectName
  location: projectLocation
}

// Service group
resource root_service_group 'Microsoft.Management/serviceGroups@2024-02-01-preview' existing = {
  scope: tenant()
  name: 'health_model_test_tomb' // Root service group ID
}

resource service_group 'Microsoft.Management/serviceGroups@2024-02-01-preview' = {
  scope: tenant()
  kind: 'ServiceGroup'
  name: '${projectName}-servicegroup'
  properties: {
    displayName: '${projectName} Service Group'
    parent: {
      resourceId: root_service_group.id
    }
  }
}

module management_governance './modules/management_governance/management_governance.bicep' = {
  name: 'deployManagementGovernance'
  scope: rg
  params: {
    location: projectLocation
    projectName: projectName
  }
}

module runtime_infrastructure './modules/runtime_infrastructure/runtime_infrastructure.bicep' = {
  name: 'deployRuntimeInfrastructure'
  scope: rg
  params: {
    projectLocation: projectLocation
    projectName: projectName
    environment: environment
    containerRegistryName: management_governance.outputs.containerRegistryName
  }
}

module continuous_validation './modules/continuous_validation/continuous_validation.bicep' = {
  name: 'deployContinuousValidation'
  scope: rg
  params: {
    location: projectLocation
    environment: environment
    chaosNodeResourceGroup: chaosNodeResourceGroup
    chaosVmssNames: chaosVmssNames
  }
  dependsOn: [
    runtime_infrastructure
  ]
}
