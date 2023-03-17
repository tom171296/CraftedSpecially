// Parameters
param location string = resourceGroup().location

// Resources
module loadTesting 'load-testing/LoadTesting.bicep' = {
  name: 'loadTesting'
  params: {
    location: location
  }
}
