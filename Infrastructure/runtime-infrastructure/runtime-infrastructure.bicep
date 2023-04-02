param location string
param clusterPrefix string

module law 'monitoring/analytisch-workspace.bicep' = {
  name: 'law'
  params: {
    location: location
  }
}

module aks 'aks/aks.bicep' = {
  name: 'aks'
  params: {
    location: location
    clusterPrefix: clusterPrefix
  }
}

output aksClusterName string = aks.outputs.aksClusterName

