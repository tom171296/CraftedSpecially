targetScope = 'resourceGroup'

param location string = resourceGroup().location

module appConfig './configuration_management/app_config.bicep' = {
  name: 'appConfigDeployment'
  params: {
    appConfigName: 'myAppConfigStore'
    location: location
  }
}

output appConfigEndpoint string = appConfig.outputs.appConfigEndpoint
output appConfigId string = appConfig.outputs.appConfigId
