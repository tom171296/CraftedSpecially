targetScope='resourceGroup'

param projectName string

@description('Location for the health model. Microsoft.CloudHealth/healthmodels is only available in a subset of regions.')
@allowed(['uksouth', 'canadacentral', 'centralus', 'swedencentral', 'southeastasia'])
param healthModelLocation string = 'canadacentral'

param law_id string

resource health_model 'Microsoft.CloudHealth/healthmodels@2026-01-01-preview' = {
  location: healthModelLocation
  name: '${projectName}-healthmodel'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

resource reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(health_model.id, 'reader-role-assignment')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7') // Reader role
    principalId: health_model.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource monitoring_reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(health_model.id, 'monitoring-reader-role-assignment')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '43d0d8ad-25c7-4714-9337-8ba259a9fe05') // Monitoring Reader role
    principalId: health_model.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource authentication_settings 'Microsoft.CloudHealth/healthmodels/authenticationsettings@2026-01-01-preview' = {
  parent: health_model
  name: 'default-authentication-settings'
  properties: {
    displayName: 'Default Authentication Settings'
    authenticationKind: 'ManagedIdentity'
    managedIdentityName: 'SystemAssigned'
  }
}

resource health_model_discovery_rule 'Microsoft.CloudHealth/healthmodels/discoveryrules@2026-01-01-preview' = {
  parent: health_model
  name: 'default-discovery-rule'
  properties: {
    displayName: 'runtime-infrastructure'
    authenticationSetting: 'default-authentication-settings'
    discoverRelationships: 'Enabled'
    addRecommendedSignals: 'Enabled'
    specification: {
      kind: 'ResourceGraphQuery'
      resourceGraphQuery: 'resources\n| where tags["health-model-entity"] =~ "true"'
    }
  }
}

resource order_products_entity 'microsoft.cloudhealth/healthmodels/entities@2026-01-01-preview' = {
  parent: health_model
  name: 'order-products-entity'
  properties: {
    displayName: 'Get Beers'
    icon: {
      iconName: 'UserFlow'
    }
    healthObjective: json('99.99')
    impact: 'Standard'
    tags: {}
    signalGroups: {
      azureLogAnalytics: {
        authenticationSetting: authentication_settings.name
        logAnalyticsWorkspaceResourceId: law_id
        signals: [
          {
            signalKind: 'LogAnalyticsQuery'
            queryText: 'AppMetrics \n| where Name == "catalog.beers.result_by_availability_count" \n| extend has_beers = tostring(Properties.has_beers) \n| summarize good_events = sumif(Sum, has_beers == "True"), total_events = sum(Sum) \n| extend sli = todouble(good_events) / todouble(total_events) \n| project sli'
            timeGrain: 'PT30M'
            displayName: 'Empty beer results'
            refreshInterval: 'PT1M'
            dataUnit: 'Percentage'
            evaluationRules: {
              degradedRule: {
                operator: 'GreaterThan'
                threshold: json('0')
              }
              unhealthyRule: {
                operator: 'GreaterThan'
                threshold: json('0')
              }
            }
            name: 'failed-beer-results'
          }
        ]
      }
    }
    alerts: {
      unhealthy: {
        severity: 'Sev0'
        description: 'There is a critical issue with the order checkout flow'
      }
      degraded: {
        severity: 'Sev2'
        description: 'There is something wrong with the order checkout flow'
      }
    }
  }
}

resource health_model_order_products_relationship 'Microsoft.CloudHealth/healthmodels/relationships@2026-01-01-preview' = {
  parent: health_model
  name: 'order-products-relationship'
  properties: {
    parentEntityName: health_model.name
    childEntityName: order_products_entity.name
  }
}

resource order_products_discovery_rule_relationship 'Microsoft.CloudHealth/healthmodels/relationships@2026-01-01-preview' = {
  parent: health_model
  name: 'order-products-discovery-rule-relationship'
  properties: {
    parentEntityName: order_products_entity.name
    childEntityName: health_model_discovery_rule.name
  }
}
