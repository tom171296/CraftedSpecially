
param location string
param existingAksName string

var clusterAdmin = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8')

resource existingAks 'Microsoft.ContainerService/managedClusters@2022-11-02-preview' existing = {
  name: existingAksName
}

resource aksChaosTarget 'Microsoft.Chaos/targets@2022-10-01-preview' = {
  name: 'microsoft-AzureKubernetesServiceChaosMesh'
  scope: existingAks
  properties: {

  }

  resource podChaos 'capabilities' = {
    name: 'PodChaos-2.1'
    properties: {
    }
  }
}

resource aksChaosPodExperiment 'Microsoft.Chaos/experiments@2022-10-01-preview' = {
  name: 'aks-pod-chaos'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    selectors: [
      {
        type: 'List'
        id: aksChaosTarget.id
        targets: [
          {
            id: aksChaosTarget.id
            type: 'ChaosTarget'
          }
        ]
      }
    ]
    steps: [
      {
        name: 'pod-chaos'
        branches: [
          {
            name: 'Branch 1'
            actions: [
              {
                type: 'continuous'
                duration: 'PT10M'
                name: 'urn:csci:microsoft:azureKubernetesServiceChaosMesh:podChaos/2.1'
                selectorId: aksChaosTarget.id
                parameters: [
                  {
                    key: 'jsonSpec'
                    value: '{"action":"pod-failure","mode":"all","duration":"120s","selector":{"namespaces":["crafted-specially"]}}'
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}

resource chaosExperimentK8sClusterAdmin 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aksChaosPodExperiment.name, clusterAdmin, 'experiment')
  properties: {
    roleDefinitionId: clusterAdmin
    principalId: aksChaosPodExperiment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
