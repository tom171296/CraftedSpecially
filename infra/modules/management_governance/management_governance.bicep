targetScope='resourceGroup'

param location string
param projectName string

module container_registry './container_registry/container_registry.bicep' = {
  name: 'deployContainerRegistry'
  scope: resourceGroup()
  params: {
    registryName: '${projectName}acr'
    location: location
  }
}

module workload_identity './workload_identity/workload_identity.bicep' = {
  name: 'deployWorkloadIdentity'
  scope: resourceGroup()
  params: {
    location: location
    projectName: projectName
  }
}

resource existingACR 'Microsoft.ContainerRegistry/registries@2025-05-01-preview' existing = {
  name: '${projectName}acr'
}

resource ciAcrPushRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(existingACR.id, '${projectName}-ci-identity', 'acrpush-ci-role-assignment')
  scope: existingACR
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8311e382-0749-4cb8-b61a-304f252e45ec') // AcrPush role
    principalId: workload_identity.outputs.ciWorkloadIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

module key_vault './key_vault/key_vault.bicep' = {
  name: 'deployKeyVault'
  scope: resourceGroup()
  params: {
    location: location
    keyVaultName: take('${toLower(projectName)}kv${uniqueString(resourceGroup().id)}', 24)
    esoIdentityPrincipalId: workload_identity.outputs.esoWorkloadIdentityPrincipalId
  }
}

output containerRegistryName string = container_registry.outputs.containerRegistryName
output keyVaultUri string = key_vault.outputs.keyVaultUri
output keyVaultName string = key_vault.outputs.keyVaultName
output appWorkloadIdentityClientId string = workload_identity.outputs.appWorkloadIdentityClientId
output appWorkloadIdentityPrincipalId string = workload_identity.outputs.appWorkloadIdentityPrincipalId
output appWorkloadIdentityName string = workload_identity.outputs.appWorkloadIdentityName
output esoWorkloadIdentityClientId string = workload_identity.outputs.esoWorkloadIdentityClientId
output esoWorkloadIdentityPrincipalId string = workload_identity.outputs.esoWorkloadIdentityPrincipalId
output esoWorkloadIdentityName string = workload_identity.outputs.esoWorkloadIdentityName
output ciWorkloadIdentityClientId string = workload_identity.outputs.ciWorkloadIdentityClientId
output ciWorkloadIdentityName string = workload_identity.outputs.ciWorkloadIdentityName
