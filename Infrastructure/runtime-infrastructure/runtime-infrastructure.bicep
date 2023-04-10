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
    location: location
    targetName: 'westeurope'
  }
}

module northEuropeServerfarm 'serverfarm/serverfarm.bicep' = {
  name: 'northeuropeServerfarm'
  params: {
    location: location
    targetName: 'northeurope'
  }
}
