param location string

module law 'monitoring/analytisch-workspace.bicep' = {
  name: 'law'
  params: {
    location: location
  }
}

module aks 'aks/aks.bicep' = {
  name: 'aks'
  params: {
    clusterPrefix: 'aks'
    location: location
  }
}
