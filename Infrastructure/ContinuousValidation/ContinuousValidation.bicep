// Parameters
param location string = resourceGroup().location

// Resources
module loadTesting 'LoadTesting/LoadTesting.bicep' = {
  name: 'loadTesting'
  params: {
    location: location
  }
}
