targetScope='resourceGroup'

param projectLocation string
param projectName string

param service_groupId string

resource health_model 'Microsoft.CloudHealth/healthmodels@2025-05-01-preview' = {
  location: projectLocation
  name: '${projectName}-healthmodel'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    discovery: {
      addRecommendedSignals: 'Enabled'
      scope: service_groupId
    }
  }
}
