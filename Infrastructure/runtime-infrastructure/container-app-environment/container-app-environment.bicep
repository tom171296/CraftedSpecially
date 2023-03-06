param location string
param lawClientId string
param lawClientSecret string

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-06-01-preview' = {
  name: 'containerAppEnv'
  location: location
  sku: {
    name: 'Consumption'
  }
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: lawClientId
        sharedKey: lawClientSecret
      }
    }
  }
}

output containerEnvId string = containerAppEnv.id
