targetScope = 'resourceGroup'

// This module returns information about the resource group the deployment targets.
// It does NOT create a resource group. Use this to avoid hard-coded references.

output resourceGroupId string = resourceGroup().id
output resourceGroupName string = resourceGroup().name
output resourceGroupLocation string = resourceGroup().location
