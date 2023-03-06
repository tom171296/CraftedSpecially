targetScope='subscription'

// Parameters
param projectLocation string = 'westeurope'


// Variables
var projectName = 'CraftedSpecially'

// Infrastructure Resources

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: projectName
  location: projectLocation
}

// Runtime infrastructure
module runtimeInfrastructure 'runtime-infrastructure/runtime-infrastructure.bicep' = {
  name: 'RuntimeInfrastructure'
  scope: rg
  params: {
    location: rg.location
  }
}

// Application infrastructure
module applicationInfrastructure 'application-infrastructure/application-infrastructure.bicep' = {
  name: 'ApplicationInfrastructure'
  scope: rg
  params: {
    location: rg.location
    containerEnvId: runtimeInfrastructure.outputs.containerAppEnvironmentId
  }
}

// Continous validation
module continuousValidation 'ContinuousValidation/ContinuousValidation.bicep' = {
  name: 'ContinuousValidation'
  scope: rg
  params: {
    location: rg.location
  }
}
