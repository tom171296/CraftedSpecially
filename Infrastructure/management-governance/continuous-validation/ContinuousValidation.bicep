// Parameters
param location string = resourceGroup().location
param existingAKsName string

// Resources
module loadTesting 'load-testing/LoadTesting.bicep' = {
  name: 'loadTesting'
  params: {
    location: location
  }
}

module chaosExperiments 'chaos-experiments/pod-chaos-experiment.bicep' = {
  name: 'chaosExperiments'
  params: {
    location: location
    existingAksName: existingAKsName
  }
}
