@description('Name of the VMSS backing the AKS node pool')
param vmssName string

@description('Azure region for the target resource')
param location string = resourceGroup().location

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' existing = {
  name: vmssName
}

// Register the Chaos Studio target on the VMSS
resource chaosTarget 'Microsoft.Chaos/targets@2023-11-01' = {
  name: 'Microsoft-VirtualMachineScaleSet'
  location: location
  scope: vmss
  properties: {}
}

// Enable the Shutdown capability on the target
resource shutdownCapability 'Microsoft.Chaos/targets/capabilities@2023-11-01' = {
  parent: chaosTarget
  name: 'Shutdown-2.0'
}

output targetId string = chaosTarget.id
output capabilityId string = shutdownCapability.id
