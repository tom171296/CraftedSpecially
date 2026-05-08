targetScope = 'resourceGroup'

param location string
param appConfigName string
param serviceGroupId string

resource configStore 'Microsoft.AppConfiguration/configurationStores@2025-02-01-preview' = {
  name: appConfigName
  location: location
  tags: {
    'health-model-entity': 'true'
  }
  sku: {
    name: 'Standard'
  }
}

resource service_group_member 'Microsoft.Relationships/serviceGroupMember@2023-09-01-preview' = {
  scope: configStore
  name: guid(configStore.id, 'serviceGroupMember')
  properties: {
    targetId: serviceGroupId
  }
}

output appConfigEndpoint string = configStore.properties.endpoint
output appConfigId string = configStore.id
