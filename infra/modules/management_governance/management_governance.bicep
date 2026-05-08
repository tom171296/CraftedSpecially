targetScope='resourceGroup'

param location string
param projectName string
param serviceGroupId string

module container_registry './container_registry/container_registry.bicep' = {
  name: 'deployContainerRegistry'
  scope: resourceGroup()
  params: {
    registryName: '${projectName}acr'
    location: location
    serviceGroupId: serviceGroupId
  }
}

output containerRegistryName string = container_registry.outputs.containerRegistryName
