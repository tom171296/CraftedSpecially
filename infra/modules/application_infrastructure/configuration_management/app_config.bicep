targetScope = 'resourceGroup'

param location string
param appConfigName string
param appWorkloadIdentityPrincipalId string

resource configStore 'Microsoft.AppConfiguration/configurationStores@2025-02-01-preview' = {
  name: appConfigName
  location: location
  sku: {
    name: 'Standard'
  }
}

// App Configuration Data Reader role for the application workload identity
resource appConfigDataReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(configStore.id, appWorkloadIdentityPrincipalId, 'app-config-data-reader')
  scope: configStore
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071') // App Configuration Data Reader
    principalId: appWorkloadIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output appConfigEndpoint string = configStore.properties.endpoint
output appConfigId string = configStore.id
