targetScope = 'resourceGroup'

param projectLocation string
param projectName string
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
  }
}

module log_analytics_workspace './observability/log_analytics_workspace.bicep' = {
  name: 'deployLogAnalyticsWorkspace'
  scope: resourceGroup()
}

module app_insights './observability/application_insights.bicep' = {
  name: 'deployApplicationInsights'
  scope: resourceGroup()
  params: {
    workspaceId: log_analytics_workspace.outputs.workspaceId
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
  }
}


module health_model_module './observability/health_model.bicep' = {
  name: 'deployHealthModel'
  scope: resourceGroup()
  params: {
    projectLocation: projectLocation
    projectName: projectName
  }
}

output staticIpAddress string = public_ip.outputs.ipAddress
output staticIpName string = public_ip.outputs.publicIpName
output gatewayFqdn string = public_ip.outputs.fqdn
