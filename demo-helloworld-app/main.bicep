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

// @description('Key Vault name')
// param keyVaultName string

// @description('Log Analytics workspace name')
// param logAnalyticsName string

// Resource group info module (returns current RG properties)
module resourceGroupDeploy './modules/resourcegroup.bicep' = {
  name: 'resourceGroup'
}

// Deploy Log Analytics
// module logAnalytics './modules/loganalytics.bicep' = {
//   name: 'logAnalyticsDeploy'
//   params: {
//     name: logAnalyticsName
//     location: resourceGroupDeploy.outputs.resourceGroupLocation
//   }
// }

// Deploy Managed Environment
module managedEnvironmentDeploy './modules/managedEnvironment.bicep' = {
  name: 'managedEnvironmentDeploy'
  params: {
    name: containerAppEnvName
    location: resourceGroupDeploy.outputs.resourceGroupLocation
    // logAnalyticsCustomerId: logAnalytics.outputs.workspaceCustomerId
  }
}

// Deploy Key Vault
// module keyVault './modules/keyvault.bicep' = {
//   name: 'keyVaultDeploy'
//   params: {
//     name: keyVaultName
//     location: location
//   }
// }

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
    // logAnalyticsId: logAnalytics.outputs.workspaceCustomerId
    // keyVaultId: keyVault.outputs.vaultId
    dockerHubUsername: dockerHubUsername
    dockerHubToken: dockerHubToken
  }
}
