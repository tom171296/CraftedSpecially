targetScope= 'resourceGroup'

param location string = resourceGroup().location

resource loadtest 'Microsoft.LoadTestService/loadTests@2022-12-01' = {
  name: 'loadtest'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}
