targetScope = 'resourceGroup'

param workspaceId string
param serviceGroupId string

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

resource service_group_member 'Microsoft.Relationships/serviceGroupMember@2023-09-01-preview' = {
  scope: appInsights
  name: guid(appInsights.id, 'serviceGroupMember')
  properties: {
    targetId: serviceGroupId
  }
}

output connectionString string = appInsights.properties.ConnectionString
output instrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsId string = appInsights.id
output appInsightsName string = appInsights.name
