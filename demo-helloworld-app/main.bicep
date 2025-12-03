targetScope = 'resourceGroup'

@description('Name of the Container App Environment')
param containerAppEnvName string

@description('Name of the Container App')
param containerAppName string

@description('Docker image to deploy')
param containerImage string

@description('Docker Hub username')
param dockerHubUsername string

@secure()
@description('Docker Hub Personal Access Token')
param dockerHubToken string

@description('CPU cores for the container')
param cpuCores string = '0.5'

@description('Memory in GiB for the container')
param memoryGiB string = '1.0'

@description('Environment variables for the container app')
param environmentVariables array = []

// Resource group info module (returns current RG properties)
module resourceGroupDeploy './modules/resourcegroup.bicep' = {
  name: 'resourceGroup'
}

// Deploy Managed Environment
module managedEnvironmentDeploy './modules/managedEnvironment.bicep' = {
  name: 'managedEnvironmentDeploy'
  params: {
    name: containerAppEnvName
    location: resourceGroupDeploy.outputs.resourceGroupLocation
    // logAnalyticsCustomerId: logAnalytics.outputs.workspaceCustomerId
  }
}

// Deploy Container App
module containerApp './modules/containerapp.bicep' = {
  name: 'containerAppDeploy'
  dependsOn: [ managedEnvironmentDeploy ]
  params: {
    name: containerAppName
    location: resourceGroupDeploy.outputs.resourceGroupLocation
    image: containerImage
    cpu: cpuCores
    memory: memoryGiB
    envName: containerAppEnvName
    dockerHubUsername: dockerHubUsername
    dockerHubToken: dockerHubToken
    environmentVariables: environmentVariables
  }
}
