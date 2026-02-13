targetScope = 'resourceGroup'


// log analytics workspace
resource law 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: 'log-analytics-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

output workspaceId string = law.id
