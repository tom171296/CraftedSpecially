targetScope = 'resourceGroup'

param location string
param projectName string

resource appWorkloadIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${projectName}-api-identity'
  location: location
}

resource esoWorkloadIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${projectName}-eso-identity'
  location: location
}

output appWorkloadIdentityClientId string = appWorkloadIdentity.properties.clientId
output appWorkloadIdentityPrincipalId string = appWorkloadIdentity.properties.principalId
output appWorkloadIdentityId string = appWorkloadIdentity.id
output appWorkloadIdentityName string = appWorkloadIdentity.name
output esoWorkloadIdentityClientId string = esoWorkloadIdentity.properties.clientId
output esoWorkloadIdentityPrincipalId string = esoWorkloadIdentity.properties.principalId
output esoWorkloadIdentityId string = esoWorkloadIdentity.id
output esoWorkloadIdentityName string = esoWorkloadIdentity.name
