targetScope = 'resourceGroup'

param oidcIssuerUrl string
param appWorkloadIdentityName string
param esoWorkloadIdentityName string

resource existingAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: appWorkloadIdentityName
}

resource existingEsoIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: esoWorkloadIdentityName
}

resource appFederatedCred 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: existingAppIdentity
  name: 'aks-craftedspecially-api'
  properties: {
    issuer: oidcIssuerUrl
    subject: 'system:serviceaccount:craftedspecially:craftedspecially-api'
    audiences: ['api://AzureADTokenExchange']
  }
}

resource esoFederatedCred 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: existingEsoIdentity
  name: 'aks-eso-controller'
  properties: {
    issuer: oidcIssuerUrl
    subject: 'system:serviceaccount:external-secrets:external-secrets'
    audiences: ['api://AzureADTokenExchange']
  }
}
