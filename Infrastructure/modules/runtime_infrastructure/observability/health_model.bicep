targetScope='resourceGroup'

param projectLocation string
param projectName string

param serviceGroupName string

resource service_group 'Microsoft.Management/serviceGroups@2024-02-01-preview' existing = {
  name: serviceGroupName
  scope: tenant()
}

resource health_model 'Microsoft.CloudHealth/healthmodels@2025-05-01-preview' = {
  location: projectLocation
  name: '${projectName}-healthmodel'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    discovery: {
      addRecommendedSignals: 'Enabled'
      scope: service_group.id
      identity: 'SystemAssigned'
    }
  }
}

// role assignment for health model to read from service group
// TODO - fix role assignment, for now done manually
// resource healthModelReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(service_group.id, health_model.name, 'HealthModelReader')
//   scope: service_group
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'de754d53-652d-4c75-a67f-1e48d8b49c97') // Service group reader
//     principalId: health_model.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

// // monitoring reader for resource group
resource monitoringReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(health_model.id, 'MonitoringReaderRoleAssignment')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '43d0d8ad-25c7-4714-9337-8ba259a9fe05') // Monitoring Reader
    principalId: health_model.identity.principalId
    principalType: 'ServicePrincipal'
  }
} 
