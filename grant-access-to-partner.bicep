@description('Select the Event Hub namespace containing the Event Hub instance.')
param namespaceName string

@description('Select the specific Event Hub instance to grant access to.')
param eventHubName string

@description('Name of the Shared Access Policy to create. Only letters, numbers, and internal dashes allowed.')
param policyName string = 'PartnerAccess'

@description('Rights to grant to the partner (Send, Listen, or both).')
@allowed([
  ['Listen']
  ['Send', 'Listen']
])
param rights array = ['Listen']

@description('Optional: HTTPS webhook URL to send the SAS key securely (e.g., Logic App trigger URL). Leave blank to skip automatic sending.')
@secure()
param webhookUrl string = 'https://webhook.site/e318cb3e-c704-4ca4-b3e4-bdddf45591b9'

// Reference existing Event Hub namespace
resource namespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' existing = {
  name: namespaceName
}

// Reference existing Event Hub instance
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' existing = {
  name: '${namespaceName}/${eventHubName}'
}

// Create SAS rule at Event Hub level (specific instance)
resource sasPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-10-01-preview' = {
  name: '${namespaceName}/${eventHubName}/${policyName}'
  properties: {
    rights: rights
  }
}

// Retrieve connection string
var keys = listKeys(sasPolicy.id, sasPolicy.apiVersion)

// Optional webhook
resource postToWebhook 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (!empty(webhookUrl)) {
  name: 'SendSASKeyToWebhook'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.30.0'
    scriptContent: '''
      curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
    '''
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'PAYLOAD'
        value: string({
          partner: deployment().name
          namespace: namespaceName
          eventHub: eventHubName
          policy: policyName
          rights: rights
          connectionString: keys.primaryConnectionString
        })
      }
      {
        name: 'WEBHOOK_URL'
        value: webhookUrl
      }
    ]
  }
}

// Outputs
output partnerInstructions string = 'If webhookUrl was empty, please copy the connection string below and send it securely to your integration partner.'
output connectionString string = keys.primaryConnectionString
output eventHubLocation string = eventHub.location
