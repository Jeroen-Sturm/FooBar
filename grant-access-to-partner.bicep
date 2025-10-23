@description('Name of the existing Event Hub namespace.')
param eventHubName string

@description('Name of the Shared Access Policy to create.')
param policyName string = 'PartnerAccess'

@description('Rights to grant to the partner (Send, Listen, or both).')
@allowed([
  ['Listen']
  ['Send', 'Listen']
])
param rights array = ['Listen']

// Reference existing Event Hub namespace
resource namespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' existing = {
  name: eventHubName
}

// Create new Shared Access Policy (SAS rule)
// Remove location: it inherits from the parent namespace automatically
resource sasPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' = {
  name: '${eventHubName}/${policyName}'
  properties: {
    rights: rights
  }
}

// Retrieve connection string
var keys = listKeys(sasPolicy.id, sasPolicy.apiVersion)

// Output instructions and the connection string
output partnerInstructions string = 'Please send this connection string securely to the integration partner:'
output connectionString string = keys.primaryConnectionString
output namespaceLocation string = namespace.location
