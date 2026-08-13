targetScope = 'resourceGroup'

param location string
param monitorAccountName string
param healthModelName string
param azureLocalClusterResourceId string
param actionGroupIds array
param cpuDegradedThreshold int
param cpuUnhealthyThreshold int
param storageDegradedThreshold int
param storageUnhealthyThreshold int
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

resource cpuSignal 'Microsoft.Monitor/accounts/healthmodels/signaldefinitions@2025-05-03-preview' = {
  parent: model
  name: 'azure-local-cluster-cpu'
  properties: {
    displayName: 'Azure Local cluster CPU'
    signalKind: 'AzureResourceMetric'
    metricNamespace: 'Microsoft.AzureStackHCI/clusters'
    metricName: 'Percentage CPU'
    aggregationType: 'Maximum'
    timeGrain: 'PT5M'
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
    tags: {
      status: 'DevelopmentDefault'
    }
  }
}

resource storageSignal 'Microsoft.Monitor/accounts/healthmodels/signaldefinitions@2025-05-03-preview' = {
  parent: model
  name: 'azure-local-storage-degraded'
  properties: {
    displayName: 'Azure Local degraded storage count'
    signalKind: 'AzureResourceMetric'
    metricNamespace: 'Microsoft.AzureStackHCI/clusters'
    metricName: 'Cluster node Storage Degraded'
    aggregationType: 'Maximum'
    timeGrain: 'PT5M'
    refreshInterval: 'PT5M'
    dataUnit: 'Count'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThanOrEqual'
        threshold: string(storageDegradedThreshold)
      }
      unhealthyRule: {
        operator: 'GreaterThanOrEqual'
        threshold: string(storageUnhealthyThreshold)
      }
    }
    tags: {
      status: 'DevelopmentDefault'
    }
  }
}

var domainEntities = [
  {
    name: 'compute-component'
    displayName: 'Compute'
    x: 200
    y: 250
  }
  {
    name: 'storage-component'
    displayName: 'Storage'
    x: 420
    y: 250
  }
  {
    name: 'network-component'
    displayName: 'Network'
    x: 640
    y: 250
  }
  {
    name: 'azure-integration-component'
    displayName: 'Azure Integration'
    x: 860
    y: 250
  }
  {
    name: 'lifecycle-component'
    displayName: 'Lifecycle'
    x: 1080
    y: 250
  }
  {
    name: 'monitoring-pipeline-component'
    displayName: 'Monitoring Pipeline'
    x: 1300
    y: 250
  }
]

resource deployment 'Microsoft.Monitor/accounts/healthmodels/entities@2025-05-03-preview' = {
  parent: model
  name: 'azure-local-deployment'
  properties: {
    displayName: 'Azure Local deployment'
    kind: 'AzureLocalDeployment'
    impact: 'Standard'
    healthObjective: 99
    canvasPosition: {
      x: 750
      y: 80
    }
    signals: {
      dependencies: {
        aggregationType: 'WorstOf'
      }
    }
    alerts: {
      degraded: {
        severity: 'Sev3'
        description: 'The Azure Local deployment health model is degraded.'
        actionGroupIds: actionGroupIds
      }
      unhealthy: {
        severity: 'Sev1'
        description: 'The Azure Local deployment health model is unhealthy.'
        actionGroupIds: actionGroupIds
      }
    }
    tags: {
      platform: 'AzureLocal'
      solution: 'AzureMonitorHealthModel'
    }
  }
}

resource domains 'Microsoft.Monitor/accounts/healthmodels/entities@2025-05-03-preview' = [for domain in domainEntities: {
  parent: model
  name: domain.name
  properties: {
    displayName: domain.displayName
    kind: 'AzureLocalDomain'
    impact: 'Standard'
    canvasPosition: {
      x: domain.x
      y: domain.y
    }
    signals: {
      dependencies: {
        aggregationType: 'WorstOf'
      }
    }
    tags: {
      platform: 'AzureLocal'
      domain: domain.name
    }
  }
}]

resource clusterCompute 'Microsoft.Monitor/accounts/healthmodels/entities@2025-05-03-preview' = {
  parent: model
  name: 'azure-local-cluster-compute'
  properties: {
    displayName: 'Azure Local cluster compute'
    kind: 'Microsoft.AzureStackHCI/clusters'
    impact: 'Standard'
    canvasPosition: {
      x: 310
      y: 430
    }
    signals: {
      azureResource: {
        authenticationSetting: authentication.name
        azureResourceId: azureLocalClusterResourceId
        signalAssignments: [
          {
            signalDefinitions: [
              cpuSignal.name
            ]
          }
        ]
      }
    }
    tags: {
      platform: 'AzureLocal'
      source: 'AzureResourceMetrics'
    }
  }
}

resource clusterStorage 'Microsoft.Monitor/accounts/healthmodels/entities@2025-05-03-preview' = {
  parent: model
  name: 'azure-local-cluster-storage'
  properties: {
    displayName: 'Azure Local cluster storage'
    kind: 'Microsoft.AzureStackHCI/clusters'
    impact: 'Standard'
    canvasPosition: {
      x: 530
      y: 430
    }
    signals: {
      azureResource: {
        authenticationSetting: authentication.name
        azureResourceId: azureLocalClusterResourceId
        signalAssignments: [
          {
            signalDefinitions: [
              storageSignal.name
            ]
          }
        ]
      }
    }
    tags: {
      platform: 'AzureLocal'
      source: 'AzureResourceMetrics'
      domain: 'Storage'
    }
  }
}

resource rootRelationship 'Microsoft.Monitor/accounts/healthmodels/relationships@2025-05-03-preview' = {
  parent: model
  name: 'root-to-azure-local-deployment'
  properties: {
    displayName: 'Azure Local service health'
    parentEntityName: 'root'
    childEntityName: deployment.name
  }
}

resource domainRelationships 'Microsoft.Monitor/accounts/healthmodels/relationships@2025-05-03-preview' = [for (domain, index) in domainEntities: {
  parent: model
  name: 'deployment-to-${domain.name}'
  properties: {
    displayName: '${domain.displayName} dependency'
    parentEntityName: deployment.name
    childEntityName: domains[index].name
  }
}]

resource computeRelationship 'Microsoft.Monitor/accounts/healthmodels/relationships@2025-05-03-preview' = {
  parent: model
  name: 'compute-to-cluster-resource'
  properties: {
    displayName: 'Cluster resource dependency'
    parentEntityName: domains[0].name
    childEntityName: clusterCompute.name
  }
}

resource storageRelationship 'Microsoft.Monitor/accounts/healthmodels/relationships@2025-05-03-preview' = {
  parent: model
  name: 'storage-to-cluster-resource'
  properties: {
    displayName: 'Cluster storage dependency'
    parentEntityName: domains[1].name
    childEntityName: clusterStorage.name
  }
}

output healthModelResourceId string = model.id
output healthModelPrincipalId string = model.identity.principalId
output deploymentEntityName string = deployment.name
