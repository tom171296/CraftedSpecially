targetScope = 'resourceGroup'

param serviceGroupId string

// TODO -> azure monitor workspace

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

resource service_group_member 'Microsoft.Relationships/serviceGroupMember@2023-09-01-preview' = {
  scope: law
  name: guid(law.id, 'serviceGroupMember')
  properties: {
    targetId: serviceGroupId
  }
}

output workspaceId string = law.id
