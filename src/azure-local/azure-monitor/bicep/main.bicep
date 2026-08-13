targetScope = 'resourceGroup'

@description('Azure region supported by Azure Monitor Health Models preview.')
param location string = resourceGroup().location

@minLength(3)
@maxLength(44)
@description('Name of the Azure Monitor account that owns the Health Model.')
param monitorAccountName string

@minLength(3)
@maxLength(44)
@description('Name of the Azure Local Health Model.')
param healthModelName string

@description('Full ARM resource ID of the Azure Local cluster.')
param azureLocalClusterResourceId string

@description('Action Group resource IDs notified when deployment health becomes degraded or unhealthy.')
param actionGroupIds array = []

@minValue(1)
@maxValue(100)
@description('Sustained cluster CPU threshold for Degraded health. Development default only.')
param cpuDegradedThreshold int = 80

@minValue(1)
@maxValue(100)
@description('Sustained cluster CPU threshold for Unhealthy health. Development default only.')
param cpuUnhealthyThreshold int = 90

@minValue(0)
@description('Failed or missing storage count for Degraded health. Development default only.')
param storageDegradedThreshold int = 1

@minValue(0)
@description('Failed or missing storage count for Unhealthy health. Development default only.')
param storageUnhealthyThreshold int = 2

@description('Optional resource tags.')
param tags object = {}

resource monitorAccount 'Microsoft.Monitor/accounts@2025-10-03' = {
  name: monitorAccountName
  location: location
  tags: tags
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

module healthModel 'modules/health-model.bicep' = {
  name: 'azureLocalHealthModel'
  params: {
    location: location
    monitorAccountName: monitorAccount.name
    healthModelName: healthModelName
    azureLocalClusterResourceId: azureLocalClusterResourceId
    actionGroupIds: actionGroupIds
    cpuDegradedThreshold: cpuDegradedThreshold
    cpuUnhealthyThreshold: cpuUnhealthyThreshold
    storageDegradedThreshold: storageDegradedThreshold
    storageUnhealthyThreshold: storageUnhealthyThreshold
    tags: tags
  }
}

output healthModelResourceId string = healthModel.outputs.healthModelResourceId
output healthModelPrincipalId string = healthModel.outputs.healthModelPrincipalId
output deploymentEntityName string = healthModel.outputs.deploymentEntityName

