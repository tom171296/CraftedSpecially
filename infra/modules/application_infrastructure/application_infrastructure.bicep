targetScope = 'resourceGroup'

param location string = resourceGroup().location
param projectName string
param appWorkloadIdentityPrincipalId string

module appConfig './configuration_management/app_config.bicep' = {
  name: 'appConfigDeployment'
  params: {
    appConfigName: '${projectName}AppConfig'
    location: location
    appWorkloadIdentityPrincipalId: appWorkloadIdentityPrincipalId
  }
}

output appConfigEndpoint string = appConfig.outputs.appConfigEndpoint
output appConfigId string = appConfig.outputs.appConfigId
