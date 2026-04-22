targetScope = 'resourceGroup'

param projectLocation string
param projectName string

param containerRegistryName string
param serviceGroupName string
param domainNameLabel string = '${toLower(projectName)}-api'

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
    logAnalyticsWorkspaceId: log_analytics_workspace.outputs.workspaceId
    containerRegistryName: containerRegistryName
    vnetSubnetId: networking.outputs.aksSubnetId
  }
}

module health_model_module './observability/health_model.bicep' = {
  name: 'deployHealthModel'
  scope: resourceGroup()
  params: {
    projectLocation: projectLocation
    projectName: projectName
    serviceGroupName: serviceGroupName
  }
}

module networking './networking/networking.bicep' = {
  name: 'deployNetworking'
  scope: resourceGroup()
  params: {
    domainNameLabel: domainNameLabel
    location: projectLocation
  }
}

output oidcIssuerUrl string = aks.outputs.oidcIssuerUrl
output gatewayIpAddress string = networking.outputs.ipAddress
output gatewayFqdn string = networking.outputs.fqdn
output envoyInternalIp string = networking.outputs.envoyInternalIp
