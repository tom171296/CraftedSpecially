using 'CraftedSpecially.bicep'


param projectLocation = 'eastus'
param projectName = 'CraftedSpecially'
param environment = 'staging'

// Load Testing Configuration
param enableLoadTesting = true
param apiEndpointFqdn = 'craftedspecially-pip.eastus.cloudapp.azure.com'
param apiProtocol = 'https'
param apiPort = 443
