targetScope = 'resourceGroup'

param registryName string
param location string = resourceGroup().location
param serviceGroupId string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-05-01-preview' = {
  name: registryName
  location: location
  tags: {
    'health-model-entity': 'true'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
  }
}

resource service_group_member 'Microsoft.Relationships/serviceGroupMember@2023-09-01-preview' = {
  scope: containerRegistry
  name: guid(containerRegistry.id, 'serviceGroupMember')
  properties: {
    targetId: serviceGroupId
  }
}

output containerRegistryName string = containerRegistry.name
