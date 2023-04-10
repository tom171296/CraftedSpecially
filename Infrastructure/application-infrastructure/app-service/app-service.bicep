targetScope='resourceGroup'

param targetName string
param location string
param serverfarmId string

resource appservice 'Microsoft.Web/sites@2021-03-01' = {
  name: '${targetName}20site'
  location: location
  kind: 'container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serverfarmId
    enabled: true
    hostNameSslStates: [
      {
        name: '${targetName}20appservice.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${targetName}20appservice.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
    ]
    siteConfig: {
      acrUseManagedIdentityCreds: true
      appSettings: [
        
      ]
    }
  }
}
