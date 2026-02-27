targetScope = 'resourceGroup'

param aksName string
param location string
param environment string

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
    dnsPrefix: 'dns-prefix'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 3
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
        availabilityZones: ['1', '2', '3']
      }
      {
        name: 'workloadpool'
        count: 2
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'User'
        availabilityZones: ['1', '2', '3']
        tags: {
          'chaos-target': 'true'
          environment: environment
        }
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
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aks.id, existingACR.id, 'acrpull-role-assignment')
  scope: existingACR
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

// Network Contributor on the resource group so AKS cloud-controller-manager can claim
// the pre-provisioned static public IP and manage Load Balancer resources for Envoy Gateway.
resource networkContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aks.id, resourceGroup().id, 'network-contributor-role-assignment')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') // Network Contributor
    principalId: aks.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
