targetScope = 'resourceGroup'

param domainNameLabel string
param location string
param envoyInternalIp string = '10.0.1.200'

var lbName = '${domainNameLabel}-lb'

// Virtual Network — provides a user-managed address space so the Bicep-managed
// public load balancer can reference the Envoy internal LB's private IP via
// an IP-based backend pool in the same VNet.
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: '${domainNameLabel}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
  }
}

// AKS nodes subnet — all node pools share this subnet.
// 10.0.1.0/24 gives 251 usable host IPs. The reserved Envoy internal LB IP
// (envoyInternalIp, default 10.0.1.200) sits at the high end of the range,
// well above typical auto-assigned node IPs for a small cluster.
resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: 'aks-nodes'
  properties: {
    addressPrefix: '10.0.1.0/24'
  }
}

// Static public IP — the internet-facing address resolved by the public FQDN.
resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${domainNameLabel}-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: domainNameLabel
    }
  }
}

// Public Azure Standard Load Balancer — bridges the static public IP (internet
// entry point) to the Envoy proxy via an IP-based backend pool that targets the
// Envoy internal LB private IP in the VNet.
resource publicLb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'PublicFrontend'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'EnvoyInternalLBPool'
        properties: {
          loadBalancerBackendAddresses: [
            {
              name: 'envoy-ilb'
              properties: {
                ipAddress: envoyInternalIp
                virtualNetwork: {
                  id: vnet.id
                }
              }
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: 'EnvoyHttpProbe'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'HttpRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'PublicFrontend')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'EnvoyInternalLBPool')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'EnvoyHttpProbe')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          disableOutboundSnat: true
        }
      }
      {
        name: 'HttpsRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'PublicFrontend')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'EnvoyInternalLBPool')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'EnvoyHttpProbe')
          }
          protocol: 'Tcp'
          frontendPort: 443
          backendPort: 443
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          disableOutboundSnat: true
        }
      }
    ]
  }
}

output ipAddress string = publicIp.properties.ipAddress
output fqdn string = publicIp.properties.dnsSettings.fqdn
output aksSubnetId string = aksSubnet.id
output envoyInternalIp string = envoyInternalIp
