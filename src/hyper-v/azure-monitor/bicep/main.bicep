targetScope = 'resourceGroup'

param location string = resourceGroup().location

@minLength(3)
@maxLength(44)
param monitorAccountName string

@minLength(3)
@maxLength(44)
param healthModelName string

@description('Full ARM resource ID of the Arc-enabled SCVMM VMM server.')
param vmmServerResourceId string

@description('Full Microsoft.HybridCompute/machines resource IDs for Arc-enabled Hyper-V hosts.')
param hyperVHostResourceIds array

@description('Log Analytics workspace resource ID receiving AMA data from all participating hosts.')
param logAnalyticsWorkspaceResourceId string

@description('Action Group resource IDs for Health Model state alerts.')
param actionGroupIds array = []

@description('Development CPU Degraded threshold.')
param cpuDegradedThreshold int = 80

@description('Development CPU Unhealthy threshold.')
param cpuUnhealthyThreshold int = 90

@description('Minutes without a heartbeat before Degraded health.')
param heartbeatDegradedMinutes int = 10

@description('Minutes without a heartbeat before Unhealthy health.')
param heartbeatUnhealthyMinutes int = 20

param tags object = {}

resource monitorAccount 'Microsoft.Monitor/accounts@2025-10-03' = {
  name: monitorAccountName
  location: location
  tags: tags
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: '${healthModelName}-windows'
  location: location
  kind: 'Windows'
  tags: tags
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'hyperVHostPerformance'
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\Hyper-V Hypervisor Logical Processor(_Total)\\% Total Run Time'
            '\\Memory\\Available MBytes'
            '\\Processor(_Total)\\% Processor Time'
          ]
        }
      ]
      windowsEventLogs: [
        {
          name: 'hyperVAndClusterEvents'
          streams: [
            'Microsoft-WindowsEvent'
          ]
          xPathQueries: [
            'Microsoft-Windows-FailoverClustering/Operational!*[System[(Level=1 or Level=2)]]'
            'Microsoft-Windows-Hyper-V-VMMS-Admin!*[System[(Level=1 or Level=2)]]'
            'Microsoft-Windows-Hyper-V-Worker-Admin!*[System[(Level=1 or Level=2)]]'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: 'hyperVWorkspace'
          workspaceResourceId: logAnalyticsWorkspaceResourceId
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Perf'
          'Microsoft-WindowsEvent'
        ]
        destinations: [
          'hyperVWorkspace'
        ]
      }
    ]
  }
}

module healthModel 'modules/health-model.bicep' = {
  name: 'hyperVHealthModel'
  params: {
    location: location
    monitorAccountName: monitorAccount.name
    healthModelName: healthModelName
    vmmServerResourceId: vmmServerResourceId
    hyperVHostResourceIds: hyperVHostResourceIds
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    actionGroupIds: actionGroupIds
    cpuDegradedThreshold: cpuDegradedThreshold
    cpuUnhealthyThreshold: cpuUnhealthyThreshold
    heartbeatDegradedMinutes: heartbeatDegradedMinutes
    heartbeatUnhealthyMinutes: heartbeatUnhealthyMinutes
    tags: union(tags, {
      dataCollectionRuleId: dataCollectionRule.id
    })
  }
}

output healthModelResourceId string = healthModel.outputs.healthModelResourceId
output healthModelPrincipalId string = healthModel.outputs.healthModelPrincipalId
output dataCollectionRuleResourceId string = dataCollectionRule.id
output hostResourceIdsRequiringAssociation array = hyperVHostResourceIds

