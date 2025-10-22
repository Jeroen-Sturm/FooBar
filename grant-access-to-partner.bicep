@description('Name of the existing Event Hub namespace.')
param namespaceName string

@description('Name of the Shared Access Policy to create.')
param policyName string = 'PartnerAccess'

@description('Rights to grant to the partner (Send, Listen, or both).')
@allowed([
  ['Send']
  ['Listen']
  ['Send', 'Listen']
])
param rights array = ['Listen']

@description('Location of the Event Hub namespace.')
param location string = resourceGroup().location

// Reference existing Event Hub namespace
resource namespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' existing = {
  name: namespaceName
}

// Create new Shared Access Policy (SAS rule)
resource sasPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' = {
  name: '${namespaceName}/${policyName}'
  location: location
  properties: {
    rights: rights
  }
}

// Retrieve connection string
var keys = listKeys(sasPolicy.id, sasPolicy.apiVersion)

// Output the connection string (partner will copy-paste and send to you)
output partnerInstructions string = 'Please send this connection string securely to the integration partner:'
output connectionString string = keys.primaryConnectionString
