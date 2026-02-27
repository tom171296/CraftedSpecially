targetScope = 'subscription'

@description('Principal ID of the Chaos Studio managed identity')
param principalId string

@description('Resource ID of the managed identity (used to make the role assignment name stable)')
param identityId string

// Reader at subscription scope — lets the KQL Query selector query Azure Resource Graph
// Reader: acdd72a7-3385-48ef-bd42-f606fba81ae7
resource readerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, identityId, 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    )
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
