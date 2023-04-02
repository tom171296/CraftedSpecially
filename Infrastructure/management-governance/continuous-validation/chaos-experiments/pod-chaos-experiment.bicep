
param location string
param existingAksName string

var aksClusterAdminRole = '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8'

resource existingAks 'Microsoft.ContainerService/managedClusters@2022-11-02-preview' existing = {
  name: existingAksName
}

resource aksChaosTarget 'Microsoft.Chaos/targets@2022-10-01-preview' = {
  name: 'aksChaosTarget'
  scope: existingAks
  properties: {
    // can be empty?
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
                    value: '{"action":"pod-failure","mode":"all","duration":"600s","selector":{"namespaces":["default"]}}'
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
  name: guid(aksChaosPodExperiment.name, aksClusterAdminRole, 'experiment')
  properties: {
    roleDefinitionId: aksClusterAdminRole
    principalId: aksChaosPodExperiment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}