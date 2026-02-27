@description('Name of the VMSS in the AKS node resource group')
param vmssName string

@description('Value for the environment tag — must match the KQL selector in the Chaos experiment')
param environment string

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' existing = {
  name: vmssName
}

// Microsoft.Resources/tags performs a merge-style tag update without touching
// any other VMSS properties. union() preserves all pre-existing AKS-managed tags.
resource chaosTagsUpdate 'Microsoft.Resources/tags@2021-04-01' = {
  name: 'default'
  scope: vmss
  properties: {
    tags: union(vmss.tags, {
      'chaos-target': 'true'
      environment: environment
    })
  }
}
