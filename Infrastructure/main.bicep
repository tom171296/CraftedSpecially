targetScope='subscription'

// Parameters
param projectLocation string = 'westus2'


// Variables
var projectName = 'CraftedSpecially'

// Infrastructure Resources

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: projectName
  location: projectLocation
}
