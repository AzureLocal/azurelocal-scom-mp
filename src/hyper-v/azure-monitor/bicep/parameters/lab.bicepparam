using '../main.bicep'

param location = 'eastus'
param monitorAccountName = 'replace-hyper-v-monitor-account'
param healthModelName = 'replace-hyper-v-health-model'
param vmmServerResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/replace/providers/Microsoft.ScVmm/vmmServers/replace'
param hyperVHostResourceIds = [
  '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/replace/providers/Microsoft.HybridCompute/machines/replace-host-01'
  '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/replace/providers/Microsoft.HybridCompute/machines/replace-host-02'
]
param logAnalyticsWorkspaceResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/replace/providers/Microsoft.OperationalInsights/workspaces/replace'
param actionGroupIds = []
param cpuDegradedThreshold = 90
param cpuUnhealthyThreshold = 95
param heartbeatDegradedMinutes = 15
param heartbeatUnhealthyMinutes = 30
param tags = { environment: 'lab', status: 'DevelopmentBaseline' }

