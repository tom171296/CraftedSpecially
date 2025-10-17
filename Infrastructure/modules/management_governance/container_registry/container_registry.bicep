targetScope = 'resourceGroup'

param registryName string
param location string = resourceGroup().location

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-05-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
    }
  }
}

output containerRegistryName string = containerRegistry.name
