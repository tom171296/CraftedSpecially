targetScope='resourceGroup'

param targetName string
param location string

resource serverfarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${targetName}_serverfarm'
  location: location
  sku: {
    name: 'P1V2'
    tier: 'PremiumV2'
    size: 'P1V2'
    family: 'P1V2'
    capacity: 1
  }
  kind: 'Linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
  }
}

output serverfarmId string = serverfarm.id
