param location string

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'analyticsworkspace'
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

output clientId string = law.properties.customerId
output clientSecret string = law.listKeys().primarySharedKey
