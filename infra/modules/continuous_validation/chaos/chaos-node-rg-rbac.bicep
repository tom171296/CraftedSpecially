@description('Principal ID of the Chaos Studio managed identity')
param principalId string

@description('Resource ID of the managed identity (used to make the role assignment name stable)')
param identityId string

// Virtual Machine Contributor on the node resource group — lets the managed identity
// execute the VMSS Shutdown fault on node pool VMSSes.
// Virtual Machine Contributor: 9980e02c-c2be-4d73-94e8-173b1dc7cf3c
resource vmssContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, identityId, '9980e02c-c2be-4d73-94e8-173b1dc7cf3c')
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
    )
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
