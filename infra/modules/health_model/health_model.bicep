targetScope = 'resourceGroup'

param projectName string
param logAnalyticsWorkspaceId string

@description('Location for the health model. Microsoft.CloudHealth/healthmodels is only available in a subset of regions.')
@allowed([
  'uksouth'
  'canadacentral'
  'centralus'
  'swedencentral'
  'southeastasia'
])
param healthModelLocation string = 'swedencentral'

resource health_model 'Microsoft.CloudHealth/healthmodels@2026-01-01-preview' = {
  name: '${projectName}-healthmodel'
  location: healthModelLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

resource reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(health_model.id, 'reader-role-assignment')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
    principalId: health_model.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource monitoring_reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(health_model.id, 'monitoring-reader-role-assignment')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '43d0d8ad-25c7-4714-9337-8ba259a9fe05')
    principalId: health_model.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource authentication_settings 'Microsoft.CloudHealth/healthmodels/authenticationsettings@2026-01-01-preview' = {
  parent: health_model
  name: 'default-authentication-settings'
  properties: {
    displayName: 'Default Managed Identity'
    authenticationKind: 'ManagedIdentity'
    managedIdentityName: 'SystemAssigned'
  }
}

resource infrastructure_discovery_rule 'Microsoft.CloudHealth/healthmodels/discoveryrules@2026-01-01-preview' = {
  parent: health_model
  name: 'infrastructure-discovery-rule'
  properties: {
    displayName: 'CraftedSpecially Infrastructure'
    authenticationSetting: authentication_settings.name
    discoverRelationships: 'Enabled'
    addRecommendedSignals: 'Enabled'
    specification: {
      kind: 'ResourceGraphQuery'
      resourceGraphQuery: 'resources\n| where tags["health-model-entity"] =~ "true"'
    }
  }
}

resource user_flow_entity 'Microsoft.CloudHealth/healthmodels/entities@2026-01-01-preview' = {
  parent: health_model
  name: 'get-beers-user-flow'
  properties: {
    displayName: 'Get Beers User Flow'
    icon: {
      iconName: 'UserFlow'
    }
    healthObjective: json('99.9')
    impact: 'Standard'
    tags: {}
    signalGroups: {
      azureLogAnalytics: {
        authenticationSetting: authentication_settings.name
        logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceId
        signals: [
          {
            signalKind: 'LogAnalyticsQuery'
            queryText: 'AppMetrics\n| where Name == "catalog.beers.result_by_availability_count"\n| extend has_beers = tostring(Properties.has_beers)\n| summarize good_events = sumif(Sum, has_beers == "True"), total_events = sum(Sum)\n| extend sli = iff(total_events == 0, real(1), todouble(good_events) / todouble(total_events))\n| project sli'
            timeGrain: 'PT5M'
            displayName: 'Beer Availability Ratio'
            refreshInterval: 'PT1M'
            dataUnit: 'Percentage'
            evaluationRules: {
              degradedRule: {
                operator: 'LessThan'
                threshold: json('0.95')
              }
              unhealthyRule: {
                operator: 'LessThan'
                threshold: json('0.90')
              }
            }
            name: 'beer-availability-ratio'
          }
        ]
      }
    }
    alerts: {
      unhealthy: {
        severity: 'Sev0'
        description: 'The Get Beers user flow is unhealthy (too many empty results)'
      }
      degraded: {
        severity: 'Sev2'
        description: 'The Get Beers user flow is degraded (elevated rate of empty results)'
      }
    }
  }
}

resource user_flow_discovery_relationship 'Microsoft.CloudHealth/healthmodels/relationships@2026-01-01-preview' = {
  parent: health_model
  name: 'get-beers-discovery-relationship'
  properties: {
    parentEntityName: user_flow_entity.name
    childEntityName: infrastructure_discovery_rule.name
  }
}

resource health_model_user_flow_relationship 'Microsoft.CloudHealth/healthmodels/relationships@2026-01-01-preview' = {
  parent: health_model
  name: 'get-beers-user-flow-relationship'
  properties: {
    parentEntityName: health_model.name
    childEntityName: user_flow_entity.name
  }
}
