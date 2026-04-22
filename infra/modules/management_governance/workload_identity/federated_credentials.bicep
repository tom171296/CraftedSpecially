targetScope = 'resourceGroup'

param oidcIssuerUrl string
param appWorkloadIdentityName string
param esoWorkloadIdentityName string
param ciWorkloadIdentityName string

resource existingAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: appWorkloadIdentityName
}

resource existingEsoIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: esoWorkloadIdentityName
}

resource existingCiIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: ciWorkloadIdentityName
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

resource ciFederatedCred 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: existingCiIdentity
  name: 'github-actions-main'
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:tom171296/CraftedSpecially:ref:refs/heads/main'
    audiences: ['api://AzureADTokenExchange']
  }
}
