targetScope = 'resourceGroup'

param workspaceId string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'app-insights-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 30
    WorkspaceResourceId: workspaceId
  }
}

output connectionString string = appInsights.properties.ConnectionString
