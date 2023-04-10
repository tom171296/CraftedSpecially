param westEuropeServerfarmId string
param northEuropeServerfarmId string

module westEuropeAppService 'app-service/app-service.bicep' = {
  name: 'westEuropeAppService'
  params: {
    location: 'westeurope'
    serverfarmId: westEuropeServerfarmId
    targetName: 'westeurope-app-service'
  }
}

module northEuropeAppService 'app-service/app-service.bicep' = {
  name: 'northEuropeAppService'
  params: {
    location: 'northeurope'
    serverfarmId: northEuropeServerfarmId
    targetName: 'northeurope-app-service'
  }
}
