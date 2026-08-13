using '../main.bicep'

param location = 'eastus'
param monitorAccountName = 'replace-azure-local-monitor-account'
param healthModelName = 'replace-azure-local-health-model'
param azureLocalClusterResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/replace/providers/Microsoft.AzureStackHCI/clusters/replace'
param actionGroupIds = []
param cpuDegradedThreshold = 90
param cpuUnhealthyThreshold = 95
param storageDegradedThreshold = 1
param storageUnhealthyThreshold = 2
param tags = {
  environment: 'lab'
  status: 'DevelopmentBaseline'
}

