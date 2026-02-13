targetScope='subscription'

param projectLocation string = 'canadacentral'
param projectName string = 'CraftedSpecially'

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
    containerRegistryName: management_governance.outputs.containerRegistryName
    serviceGroupName: service_group.name
  }
}
