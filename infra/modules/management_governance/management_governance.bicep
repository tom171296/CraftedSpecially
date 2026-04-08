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
