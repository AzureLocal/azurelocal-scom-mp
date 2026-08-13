targetScope = 'resourceGroup'

param location string
param monitorAccountName string
param healthModelName string
param vmmServerResourceId string
param hyperVHostResourceIds array
param logAnalyticsWorkspaceResourceId string
param actionGroupIds array
param cpuDegradedThreshold int
param cpuUnhealthyThreshold int
param heartbeatDegradedMinutes int
param heartbeatUnhealthyMinutes int
param tags object

resource monitorAccount 'Microsoft.Monitor/accounts@2025-10-03' existing = {
  name: monitorAccountName
}

resource model 'Microsoft.Monitor/accounts/healthmodels@2025-05-03-preview' = {
  parent: monitorAccount
  name: healthModelName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {}
}

resource authentication 'Microsoft.Monitor/accounts/healthmodels/authenticationsettings@2025-05-03-preview' = {
  parent: model
  name: 'system-assigned-identity'
  properties: {
    displayName: 'Health Model system-assigned identity'
    authenticationKind: 'ManagedIdentity'
    managedIdentityName: 'SystemAssigned'
  }
}

resource heartbeatSignals 'Microsoft.Monitor/accounts/healthmodels/signaldefinitions@2025-05-03-preview' = [for (hostId, index) in hyperVHostResourceIds: {
  parent: model
  name: 'hyper-v-host-${index}-heartbeat'
  properties: {
    displayName: 'Hyper-V host ${index + 1} heartbeat freshness'
    signalKind: 'LogAnalyticsQuery'
    queryText: 'let LastSeen = toscalar(Heartbeat | where _ResourceId =~ "${hostId}" | summarize max(TimeGenerated)); print FreshnessMinutes=datetime_diff("minute", now(), coalesce(LastSeen, datetime(1970-01-01)))'
    timeGrain: 'PT30M'
    valueColumnName: 'FreshnessMinutes'
    refreshInterval: 'PT5M'
    dataUnit: 'Minutes'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThanOrEqual'
        threshold: string(heartbeatDegradedMinutes)
      }
      unhealthyRule: {
        operator: 'GreaterThanOrEqual'
        threshold: string(heartbeatUnhealthyMinutes)
      }
    }
  }
}]

resource cpuSignals 'Microsoft.Monitor/accounts/healthmodels/signaldefinitions@2025-05-03-preview' = [for (hostId, index) in hyperVHostResourceIds: {
  parent: model
  name: 'hyper-v-host-${index}-cpu'
  properties: {
    displayName: 'Hyper-V host ${index + 1} hypervisor CPU'
    signalKind: 'LogAnalyticsQuery'
    queryText: 'Perf | where _ResourceId =~ "${hostId}" | where ObjectName =~ "Hyper-V Hypervisor Logical Processor" and CounterName =~ "% Total Run Time" and InstanceName =~ "_Total" | summarize Cpu=max(CounterValue)'
    timeGrain: 'PT15M'
    valueColumnName: 'Cpu'
    refreshInterval: 'PT5M'
    dataUnit: 'Percent'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThan'
        threshold: string(cpuDegradedThreshold)
      }
      unhealthyRule: {
        operator: 'GreaterThan'
        threshold: string(cpuUnhealthyThreshold)
      }
    }
  }
}]

resource clusterEventSignal 'Microsoft.Monitor/accounts/healthmodels/signaldefinitions@2025-05-03-preview' = {
  parent: model
  name: 'hyper-v-cluster-critical-events'
  properties: {
    displayName: 'Hyper-V failover cluster critical and error events'
    signalKind: 'LogAnalyticsQuery'
    queryText: 'let ExpectedHosts=dynamic(${string(hyperVHostResourceIds)}); Event | where _ResourceId in~ (ExpectedHosts) | where EventLog =~ "Microsoft-Windows-FailoverClustering/Operational" and EventLevelName in~ ("Critical", "Error") | summarize EventCount=count()'
    timeGrain: 'PT15M'
    valueColumnName: 'EventCount'
    refreshInterval: 'PT5M'
    dataUnit: 'Count'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThanOrEqual'
        threshold: '1'
      }
      unhealthyRule: {
        operator: 'GreaterThanOrEqual'
        threshold: '3'
      }
    }
  }
}

resource coverageSignal 'Microsoft.Monitor/accounts/healthmodels/signaldefinitions@2025-05-03-preview' = {
  parent: model
  name: 'hyper-v-telemetry-coverage'
  properties: {
    displayName: 'Hyper-V expected hosts not reporting'
    signalKind: 'LogAnalyticsQuery'
    queryText: 'let ExpectedHosts=dynamic(${string(hyperVHostResourceIds)}); let Reporting=toscalar(Heartbeat | where TimeGenerated > ago(15m) | where _ResourceId in~ (ExpectedHosts) | summarize dcount(_ResourceId)); print MissingHosts=array_length(ExpectedHosts)-Reporting'
    timeGrain: 'PT30M'
    valueColumnName: 'MissingHosts'
    refreshInterval: 'PT5M'
    dataUnit: 'Count'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThanOrEqual'
        threshold: '1'
      }
      unhealthyRule: {
        operator: 'GreaterThanOrEqual'
        threshold: string(max(2, length(hyperVHostResourceIds)))
      }
    }
  }
}

var domainEntities = [
  { name: 'compute-component', displayName: 'Compute', x: 200, y: 250 }
  { name: 'storage-component', displayName: 'Storage', x: 420, y: 250 }
  { name: 'network-component', displayName: 'Network', x: 640, y: 250 }
  { name: 'virtualization-management-component', displayName: 'Virtualization Management', x: 860, y: 250 }
  { name: 'lifecycle-component', displayName: 'Lifecycle', x: 1080, y: 250 }
  { name: 'monitoring-pipeline-component', displayName: 'Monitoring Pipeline', x: 1300, y: 250 }
]

resource deployment 'Microsoft.Monitor/accounts/healthmodels/entities@2025-05-03-preview' = {
  parent: model
  name: 'hyper-v-deployment'
  properties: {
    displayName: 'Hyper-V deployment'
    kind: 'HyperVDeployment'
    impact: 'Standard'
    healthObjective: 99
    canvasPosition: { x: 750, y: 80 }
    signals: {
      dependencies: { aggregationType: 'WorstOf' }
    }
    alerts: {
      degraded: {
        severity: 'Sev3'
        description: 'The Hyper-V deployment health model is degraded.'
        actionGroupIds: actionGroupIds
      }
      unhealthy: {
        severity: 'Sev1'
        description: 'The Hyper-V deployment health model is unhealthy.'
        actionGroupIds: actionGroupIds
      }
    }
    tags: { platform: 'HyperV', solution: 'AzureMonitorHealthModel' }
  }
}

resource domains 'Microsoft.Monitor/accounts/healthmodels/entities@2025-05-03-preview' = [for domain in domainEntities: {
  parent: model
  name: domain.name
  properties: {
    displayName: domain.displayName
    kind: 'HyperVDomain'
    impact: 'Standard'
    canvasPosition: { x: domain.x, y: domain.y }
    signals: {
      dependencies: { aggregationType: 'WorstOf' }
    }
    tags: { platform: 'HyperV', domain: domain.name }
  }
}]

resource vmmServer 'Microsoft.Monitor/accounts/healthmodels/entities@2025-05-03-preview' = {
  parent: model
  name: 'arc-enabled-scvmm-server'
  properties: {
    displayName: 'Arc-enabled SCVMM server'
    kind: 'Microsoft.ScVmm/vmmServers'
    impact: 'Standard'
    canvasPosition: { x: 860, y: 430 }
    signals: {
      azureResource: {
        authenticationSetting: authentication.name
        azureResourceId: vmmServerResourceId
        signalAssignments: []
      }
    }
    tags: { platform: 'HyperV', source: 'ArcEnabledSCVMM' }
  }
}

resource hosts 'Microsoft.Monitor/accounts/healthmodels/entities@2025-05-03-preview' = [for (hostId, index) in hyperVHostResourceIds: {
  parent: model
  name: 'hyper-v-host-${index}'
  properties: {
    displayName: 'Hyper-V host ${index + 1}'
    kind: 'Microsoft.HybridCompute/machines'
    impact: 'Standard'
    canvasPosition: { x: 200 + (index * 180), y: 500 }
    signals: {
      azureLogAnalytics: {
        authenticationSetting: authentication.name
        logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
        signalAssignments: [
          {
            signalDefinitions: [ heartbeatSignals[index].name, cpuSignals[index].name ]
          }
        ]
      }
    }
    tags: { platform: 'HyperV', hostResourceId: hostId }
  }
}]

resource pipelineEvidence 'Microsoft.Monitor/accounts/healthmodels/entities@2025-05-03-preview' = {
  parent: model
  name: 'hyper-v-telemetry-evidence'
  properties: {
    displayName: 'Hyper-V telemetry evidence'
    kind: 'MonitoringPipelineEvidence'
    impact: 'Standard'
    canvasPosition: { x: 1300, y: 430 }
    signals: {
      azureLogAnalytics: {
        authenticationSetting: authentication.name
        logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
        signalAssignments: [
          { signalDefinitions: [ coverageSignal.name, clusterEventSignal.name ] }
        ]
      }
    }
    tags: { platform: 'HyperV', source: 'AzureMonitorAgent' }
  }
}

resource rootRelationship 'Microsoft.Monitor/accounts/healthmodels/relationships@2025-05-03-preview' = {
  parent: model
  name: 'root-to-hyper-v-deployment'
  properties: { displayName: 'Hyper-V service health', parentEntityName: 'root', childEntityName: deployment.name }
}

resource domainRelationships 'Microsoft.Monitor/accounts/healthmodels/relationships@2025-05-03-preview' = [for (domain, index) in domainEntities: {
  parent: model
  name: 'deployment-to-${domain.name}'
  properties: { displayName: '${domain.displayName} dependency', parentEntityName: deployment.name, childEntityName: domains[index].name }
}]

resource hostRelationships 'Microsoft.Monitor/accounts/healthmodels/relationships@2025-05-03-preview' = [for (hostId, index) in hyperVHostResourceIds: {
  parent: model
  name: 'compute-to-hyper-v-host-${index}'
  properties: { displayName: 'Hyper-V host ${index + 1}', parentEntityName: domains[0].name, childEntityName: hosts[index].name }
}]

resource vmmRelationship 'Microsoft.Monitor/accounts/healthmodels/relationships@2025-05-03-preview' = {
  parent: model
  name: 'management-to-vmm-server'
  properties: { displayName: 'SCVMM management dependency', parentEntityName: domains[3].name, childEntityName: vmmServer.name }
}

resource pipelineRelationship 'Microsoft.Monitor/accounts/healthmodels/relationships@2025-05-03-preview' = {
  parent: model
  name: 'pipeline-to-telemetry-evidence'
  properties: { displayName: 'Telemetry coverage dependency', parentEntityName: domains[5].name, childEntityName: pipelineEvidence.name }
}

output healthModelResourceId string = model.id
output healthModelPrincipalId string = model.identity.principalId

