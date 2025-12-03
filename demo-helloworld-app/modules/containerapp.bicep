
param name string
param location string
param image string
param cpu string
param memory string
param environmentVariables array = []
param envName string
// param logAnalyticsId string
// param keyVaultId string
param dockerHubUsername string
@secure()
param dockerHubToken string

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: envName
}

resource containerApp 'Microsoft.App/containerapps@2025-02-02-preview' = {
  name: name
  location: location
  kind: 'containerapps'
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    workloadProfileName: 'Consumption'
    configuration: {
      registries: [
        {
          server: 'registry.hub.docker.com'
          username: dockerHubUsername
          passwordSecretRef: 'dockerhub-token'
        }
      ]
      secrets: [
        {
          name: 'dockerhub-token'
          value: dockerHubToken
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 3000
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: true
        clientCertificateMode: 'Ignore'
        stickySessions: {
          affinity: 'none'
        }
      }
      identitySettings: []
      maxInactiveRevisions: 100
    }
    template: {
      containers: [
        {
          name: 'app'
          image: image
          resources: {
            cpu: json(cpu)
            memory: '${memory}Gi'
          }
          env: environmentVariables
        }
      ]
    }
  }
}
