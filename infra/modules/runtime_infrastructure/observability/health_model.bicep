targetScope='resourceGroup'

param projectName string

@description('Location for the health model. Microsoft.CloudHealth/healthmodels is only available in a subset of regions.')
@allowed(['uksouth', 'canadacentral', 'centralus', 'swedencentral', 'southeastasia'])
param healthModelLocation string = 'canadacentral'

resource health_model 'Microsoft.CloudHealth/healthmodels@2026-01-01-preview' = {
  location: healthModelLocation
  name: '${projectName}-healthmodel'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}
