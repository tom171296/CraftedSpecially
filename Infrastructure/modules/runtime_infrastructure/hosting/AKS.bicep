targetScope = 'resourceGroup'

param aksName string
param location string

param logAnalyticsWorkspaceId string
param containerRegistryName string

resource existingACR 'Microsoft.ContainerRegistry/registries@2025-05-01-preview' existing = {
  name: containerRegistryName
  scope: resourceGroup()
}

resource aks 'Microsoft.ContainerService/managedClusters@2025-07-02-preview' = {
  name: aksName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  properties: {
    bootstrapProfile: {
      containerRegistryId: existingACR.id
    }
    dnsPrefix: 'dns-prefix'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 3
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
      }
      {
        name: 'workloadpool'
        count: 2
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'User'
      }
    ]
    azureMonitorProfile: {
      containerInsights: {
        enabled: true
        logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceId
      }
    }
  }
}

// Role assignment for AKS to pull images from ACR
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(aks.id, existingACR.id, 'acrpull-role-assignment')
  scope: existingACR
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role
    principalId: aks.identity.principalId
    principalType: 'ServicePrincipal'
  }
} 
