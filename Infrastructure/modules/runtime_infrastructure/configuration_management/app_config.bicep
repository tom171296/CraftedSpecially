targetScope = 'resourceGroup'

param location string
param appConfigName string

resource configStore 'Microsoft.AppConfiguration/configurationStores@2025-02-01-preview' = {
  name: appConfigName
  location: location
  sku: {
    name: 'Standard'
  }
}

output appConfigEndpoint string = configStore.properties.endpoint
output appConfigId string = configStore.id
