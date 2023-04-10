
param location string
param clusterPrefix string
param osDiskSize int = 30
param agentCount int = 2
param agentVmSize string = 'Standard_DS2_v2'

resource aks 'Microsoft.ContainerService/managedClusters@2022-11-02-preview' = {
  name: 'aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSize
        count: agentCount
        vmSize: agentVmSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
  }
}

output aksClusterName string = aks.name
