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

output containerRegistryId string = container_registry.outputs.containerRegistryId
