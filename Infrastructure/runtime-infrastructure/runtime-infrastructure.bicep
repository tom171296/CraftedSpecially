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

// module cae 'container-app-environment/container-app-environment.bicep' = {
//   name: 'cae'
//   params: {
//     location: location
//     lawClientId: law.outputs.clientId
//     lawClientSecret: law.outputs.clientSecret
//   }
// }

// output containerAppEnvironmentId string = cae.outputs.containerEnvId
