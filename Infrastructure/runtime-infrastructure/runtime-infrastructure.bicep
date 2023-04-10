param location string

module law 'monitoring/analytisch-workspace.bicep' = {
  name: 'law'
  params: {
    location: location
  }
}

module westEuropeServerfarm 'serverfarm/serverfarm.bicep' = {
  name: 'westeuropeServerfarm'
  params: {
    location: 'westeurope'
    targetName: 'westeurope'
  }
}

module northEuropeServerfarm 'serverfarm/serverfarm.bicep' = {
  name: 'northeuropeServerfarm'
  params: {
    location: 'northeurope'
    targetName: 'northeurope'
  }
}

output westeuropeServerfarmId string = westEuropeServerfarm.outputs.serverfarmId
output northeuropeServerfarmId string = northEuropeServerfarm.outputs.serverfarmId
