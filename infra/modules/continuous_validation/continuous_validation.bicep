targetScope='resourceGroup'

param location string
param environment string

param chaosNodeResourceGroup string  // e.g. MC_CraftedSpecially_CraftedSpecially-aks_westeurope
param chaosVmssNames array           // e.g. ['aks-workloadpool-12345678-vmss'] — get with: az vmss list -g <NODE_RG> --query "[].name" -o tsv

module chaos './chaos/chaos.bicep' = {
  name: 'deployChaos'
  params: {
    location: location
    environment: environment
    nodeResourceGroupName: chaosNodeResourceGroup
    vmssNames: chaosVmssNames
  }
}
