targetScope = 'resourceGroup'

param projectLocation string
param projectName string
param serviceGroupId string

param environment string
param containerRegistryName string


module public_ip './networking/public_ip.bicep' = {
  name: 'deployPublicIp'
  scope: resourceGroup()
  params: {
    location: projectLocation
    publicIpName: '${projectName}-pip'
  }
}

module configuration_management './configuration_management/app_config.bicep' = {
  name: 'deployAppConfig'
  scope: resourceGroup()
  params: {
    location: projectLocation
    appConfigName: '${projectName}-appconfig'
    serviceGroupId: serviceGroupId
  }
}

module log_analytics_workspace './observability/log_analytics_workspace.bicep' = {
  name: 'deployLogAnalyticsWorkspace'
  scope: resourceGroup()
  params: {
    serviceGroupId: serviceGroupId
  }
}

module app_insights './observability/application_insights.bicep' = {
  name: 'deployApplicationInsights'
  scope: resourceGroup()
  params: {
    workspaceId: log_analytics_workspace.outputs.workspaceId
    serviceGroupId: serviceGroupId
  }
}

module aks './hosting/AKS.bicep' = {
  name: 'deployAKS'
  scope: resourceGroup()
  params: {
    aksName: '${projectName}-aks'
    location: projectLocation
    environment: environment
    logAnalyticsWorkspaceId: log_analytics_workspace.outputs.workspaceId
    containerRegistryName: containerRegistryName
    serviceGroupId: serviceGroupId 
  }
}

module health_model_module './observability/health_model.bicep' = {
  name: 'deployHealthModel'
  scope: resourceGroup()
  params: {
    projectName: projectName
    law_id: log_analytics_workspace.outputs.workspaceId
  }
}

output staticIpAddress string = public_ip.outputs.ipAddress
output staticIpName string = public_ip.outputs.publicIpName
output gatewayFqdn string = public_ip.outputs.fqdn
output appInsightsConnectionString string = app_insights.outputs.connectionString
output appInsightsInstrumentationKey string = app_insights.outputs.instrumentationKey
output appInsightsId string = app_insights.outputs.appInsightsId
