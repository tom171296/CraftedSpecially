targetScope = 'resourceGroup'

param location string = resourceGroup().location
param publicIpName string

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: publicIpName
  location: location
  tags: {
    'health-model-entity': 'true'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: toLower(publicIpName)
    }
  }
}

output ipAddress string = publicIp.properties.ipAddress
output resourceId string = publicIp.id
output publicIpName string = publicIp.name
output fqdn string = publicIp.properties.dnsSettings.fqdn
