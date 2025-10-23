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

@description('Optional: HTTPS webhook URL to send the SAS key securely (e.g. Logic App trigger URL). Leave blank to skip automatic sending.')
@secure()
param webhookUrl string = 'https://webhook.site/e318cb3e-c704-4ca4-b3e4-bdddf45591b9'

// Reference existing Event Hub namespace
resource namespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' existing = {
  name: eventHubName
}

// Create new Shared Access Policy (SAS rule)
resource sasPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' = {
  name: '${eventHubName}/${policyName}'
  properties: {
    rights: rights
  }
}

// Retrieve connection string
var keys = listKeys(sasPolicy.id, sasPolicy.apiVersion)


// NOTE I HAVE NOT TESTED THIS!!
// Optional: Send the connection string to a webhook securely
resource postToWebhook 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (!empty(webhookUrl)) {
  name: 'SendSASKeyToWebhook'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.30.0'
    scriptContent: '''
      curl -X POST -H "Content-Type: application/json" -d '{
        "partner": "${deployment().name}",
        "namespace": "${eventHubName}",
        "policy": "${policyName}",
        "rights": "${join(rights, ', ')}",
        "connectionString": "${keys.primaryConnectionString}"
      }' "${webhookUrl}"
    '''
    retentionInterval: 'PT1H'
  }
}

// Output instructions
output partnerInstructions string = 'If webhookUrl was empty, please copy the connection string below and send it securely to your integration partner.'
output connectionString string = keys.primaryConnectionString
output namespaceLocation string = namespace.location
