targetScope='subscription'

param projectLocation string
param projectName string

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: projectName
  location: projectLocation
}

// Service group
resource service_group 'Microsoft.Management/serviceGroups@2024-02-01-preview' = {
  scope: tenant()
  kind: 'ServiceGroup'
  name: '${projectName}-servicegroup'
  properties: {
    displayName: '${projectName} Service Group'
  }
}

resource health_model 'Microsoft.CloudHealth/healthmodels@2025-05-01-preview' = {
  location: projectLocation
  name: '${projectName}-healthmodel'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    discovery: {
      addRecommendedSignals: true
      scope: service_group.id
    }
  }
}
