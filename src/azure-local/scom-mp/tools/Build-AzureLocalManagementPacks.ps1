#Requires -Version 7.0
<#
.SYNOPSIS
    Builds development Azure Local SCOM Management Pack XML artifacts.

.DESCRIPTION
    Applies version and public-key-token values, expands the monitoring catalog into Management
    Pack workflows, verifies structural contracts, and writes deterministic development XML.

.PARAMETER Version
    Four-part Management Pack version.

.PARAMETER PublicKeyToken
    Sixteen-character public key token used by references between product Management Packs.

.PARAMETER OutputPath
    Destination directory for generated development XML.

.PARAMETER IncludeReporting
    Includes the optional Reporting Management Pack.

.NOTES
    Author: Kristopher Turner
    Contact: kris@hybridsolutions.cloud
    Version: 1.1.0
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidatePattern('^\d+\.\d+\.\d+\.\d+$')]
    [string]$Version = '0.1.0.0',

    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9a-fA-F]{16}$')]
    [string]$PublicKeyToken,

    [Parameter()]
    [string]$OutputPath,

    [Parameter()]
    [switch]$IncludeReporting
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-AzureLocalNodeMonitorContent {
    [CmdletBinding()]
    param()

    $monitorDefinitions = @(
        [pscustomobject]@{ Id = 'ClusterService'; Property = 'ClusterServiceState'; Name = 'Cluster service health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Compute.Aggregate.Monitor'; Category = 'AvailabilityHealth'; Impact = 'Error'; Alert = $true; Summary = 'Tracks whether the local Cluster Service is running.'; Action = 'Confirm maintenance state, Cluster Service dependencies, recent clustering events, and whether service recovery or escalation is appropriate.' },
        [pscustomobject]@{ Id = 'ClusterNode'; Property = 'ClusterNodeState'; Name = 'Cluster node membership health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Compute.Aggregate.Monitor'; Category = 'AvailabilityHealth'; Impact = 'Error'; Alert = $true; Summary = 'Tracks all deployment nodes and reports when any node is not Up.'; Action = 'Review node state, drain or pause intent, cluster network connectivity, event 1135, and fault-domain redundancy.' },
        [pscustomobject]@{ Id = 'Quorum'; Property = 'QuorumState'; Name = 'Cluster quorum health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Compute.Aggregate.Monitor'; Category = 'AvailabilityHealth'; Impact = 'Error'; Alert = $true; Summary = 'Tracks quorum type and witness resource availability.'; Action = 'Review Get-ClusterQuorum, witness reachability, cluster membership, votes, and recent quorum events.' },
        [pscustomobject]@{ Id = 'Cpu'; Property = 'CpuState'; Name = 'Node processor pressure'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Compute.Aggregate.Monitor'; Category = 'PerformanceHealth'; Impact = 'Error'; Alert = $false; Summary = 'Tracks sustained node processor load with provisional, overrideable thresholds.'; Action = 'Use Cluster Performance History and host-versus-guest CPU metrics to distinguish demand, imbalance, and host overhead before tuning.' },
        [pscustomobject]@{ Id = 'Memory'; Property = 'MemoryState'; Name = 'Node available memory'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Compute.Aggregate.Monitor'; Category = 'PerformanceHealth'; Impact = 'Error'; Alert = $false; Summary = 'Tracks absolute memory available to the management partition with provisional, overrideable thresholds.'; Action = 'Review available memory, host reserve, guest pressure, paging, failover reserve, and capacity trends before tuning.' },
        [pscustomobject]@{ Id = 'HealthFault'; Property = 'HealthFaultState'; Name = 'Storage Spaces Direct Health Service faults'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Storage.Aggregate.Monitor'; Category = 'AvailabilityHealth'; Impact = 'Error'; Alert = $true; Summary = 'Maps active Health Service root-cause faults into SCOM health.'; Action = 'Review Get-HealthFault reason, severity, faulting object, location, and Microsoft-recommended actions.' },
        [pscustomobject]@{ Id = 'StoragePool'; Property = 'StoragePoolState'; Name = 'Storage pool health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Storage.Aggregate.Monitor'; Category = 'AvailabilityHealth'; Impact = 'Error'; Alert = $true; Summary = 'Tracks pool health, operational status, and read-only state.'; Action = 'Review Storage Spaces Direct faults, storage jobs, pool health, capacity, enclosure and drive conditions.' },
        [pscustomobject]@{ Id = 'Volume'; Property = 'VolumeState'; Name = 'Volume and CSV health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Storage.Aggregate.Monitor'; Category = 'AvailabilityHealth'; Impact = 'Error'; Alert = $true; Summary = 'Tracks volume health, free capacity, CSV online state, and redirected access.'; Action = 'Review Get-Volume, Get-ClusterSharedVolume, redirection reason, capacity trend, latency, repair activity, and recent CSV events.' },
        [pscustomobject]@{ Id = 'PhysicalDisk'; Property = 'PhysicalDiskState'; Name = 'Physical disk health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Storage.Aggregate.Monitor'; Category = 'AvailabilityHealth'; Impact = 'Error'; Alert = $false; Summary = 'Tracks non-healthy physical disks while relying on Health Service root-cause faults for default paging.'; Action = 'Use Get-PhysicalDisk and Get-HealthFault to identify the drive, location, operational state, and supported remediation.' },
        [pscustomobject]@{ Id = 'NetworkATC'; Property = 'NetworkAtcState'; Name = 'Network ATC intent health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Network.Aggregate.Monitor'; Category = 'ConfigurationHealth'; Impact = 'Error'; Alert = $true; Summary = 'Tracks local Network ATC intent configuration and provisioning status.'; Action = 'Review Get-NetIntent and Get-NetIntentStatus, adapter state, RDMA, SET, intent overrides, and remediation progress.' },
        [pscustomobject]@{ Id = 'Registration'; Property = 'RegistrationState'; Name = 'Azure Local registration and connection health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Platform.Aggregate.Monitor'; Category = 'ConfigurationHealth'; Impact = 'Error'; Alert = $true; Summary = 'Tracks the local registration and Azure connection state returned by Get-AzureStackHCI.'; Action = 'Confirm RegistrationStatus, ConnectionStatus, LastConnected, Arc agents, DNS, proxy, firewall endpoints, and time synchronization.' },
        [pscustomobject]@{ Id = 'PlatformServices'; Property = 'PlatformServicesState'; Name = 'Arc and VM-management platform service health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Platform.Aggregate.Monitor'; Category = 'AvailabilityHealth'; Impact = 'Error'; Alert = $true; Summary = 'Tracks locally present Arc, MOC, and Azure Local VM-management services.'; Action = 'Review service states and events. Do not remove or recover Arc Resource Bridge independently; follow Microsoft support guidance.' },
        [pscustomobject]@{ Id = 'Update'; Property = 'UpdateState'; Name = 'Solution update health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Lifecycle.Aggregate.Monitor'; Category = 'ConfigurationHealth'; Impact = 'Warning'; Alert = $true; Summary = 'Tracks failed and attention-required solution update resources without treating an available update as an outage.'; Action = 'Review Get-SolutionUpdate and Get-SolutionUpdateRun state, preparation health checks, vendor content, and failed action-plan steps.' },
        [pscustomobject]@{ Id = 'Pipeline'; Property = 'PipelineState'; Name = 'Azure Local monitoring pipeline health'; Parent = 'HybridSolutionsCloud.AzureLocal.Node.Pipeline.Aggregate.Monitor'; Category = 'AvailabilityHealth'; Impact = 'Error'; Alert = $true; Summary = 'Tracks whether the shared local health probe completed and returned a valid property bag.'; Action = 'Review Operations Manager event 8401, workflow initialization, modules, permissions, timeout, and HealthService state.' }
    )

    $monitorXml = [System.Text.StringBuilder]::new()
    $resourceXml = [System.Text.StringBuilder]::new()
    $displayXml = [System.Text.StringBuilder]::new()
    $knowledgeXml = [System.Text.StringBuilder]::new()

    foreach ($definition in $monitorDefinitions) {
        $monitorId = "HybridSolutionsCloud.AzureLocal.Node.$($definition.Id).Monitor"
        $messageId = "$monitorId.Message"
        $alertState = if ($definition.Impact -eq 'Warning') { 'Warning' } else { 'Error' }
        $criticalHealth = 'Error'
        $alertXml = ''
        if ($definition.Alert) {
            $alertXml = '<AlertSettings AlertMessage="{0}"><AlertOnState>{1}</AlertOnState><AutoResolve>true</AutoResolve><AlertPriority>Normal</AlertPriority><AlertSeverity>MatchMonitorHealth</AlertSeverity><AlertParameters><AlertParameter1>$Data/Context/Property[@Name=''{2}Detail'']$</AlertParameter1></AlertParameters></AlertSettings>' -f $messageId, $alertState, $definition.Property
            [void]$resourceXml.AppendLine(('<StringResource ID="{0}" />' -f $messageId))
            [void]$displayXml.AppendLine(('<DisplayString ElementID="{0}"><Name>{1}</Name><Description>{2} Detail: {{0}}</Description></DisplayString>' -f $messageId, $definition.Name, $definition.Summary))
        }

        [void]$monitorXml.AppendLine(@"
      <UnitMonitor ID="$monitorId" Accessibility="Public" Enabled="true" Target="HCSAzureLocalLibrary!HybridSolutionsCloud.AzureLocal.NodeRole" ParentMonitorID="$($definition.Parent)" Remotable="true" Priority="Normal" TypeID="HybridSolutionsCloud.AzureLocal.PropertyBag.ThreeState.MonitorType" ConfirmDelivery="true">
        <Category>$($definition.Category)</Category>
        $alertXml
        <OperationalStates><OperationalState ID="Good" MonitorTypeStateID="Good" HealthState="Success" /><OperationalState ID="Warning" MonitorTypeStateID="Warning" HealthState="Warning" /><OperationalState ID="Critical" MonitorTypeStateID="Critical" HealthState="$criticalHealth" /></OperationalStates>
        <Configuration><PropertyName>$($definition.Property)</PropertyName><IntervalSeconds>300</IntervalSeconds><SyncTime /><TimeoutSeconds>120</TimeoutSeconds><CpuWarningPercent>80</CpuWarningPercent><CpuCriticalPercent>90</CpuCriticalPercent><MemoryWarningMB>4096</MemoryWarningMB><MemoryCriticalMB>2048</MemoryCriticalMB><VolumeWarningPercentFree>15</VolumeWarningPercentFree><VolumeCriticalPercentFree>10</VolumeCriticalPercentFree></Configuration>
      </UnitMonitor>
"@)
        [void]$displayXml.AppendLine("<DisplayString ElementID=`"$monitorId`"><Name>$($definition.Name)</Name><Description>$($definition.Summary)</Description></DisplayString>")
        [void]$displayXml.AppendLine("<DisplayString ElementID=`"$monitorId`" SubElementID=`"Good`"><Name>Healthy</Name></DisplayString>")
        [void]$displayXml.AppendLine("<DisplayString ElementID=`"$monitorId`" SubElementID=`"Warning`"><Name>Warning</Name></DisplayString>")
        [void]$displayXml.AppendLine("<DisplayString ElementID=`"$monitorId`" SubElementID=`"Critical`"><Name>Critical</Name></DisplayString>")
        [void]$knowledgeXml.AppendLine(@"
<KnowledgeArticle ElementID="$monitorId" Visible="true"><MamlContent><maml:section xmlns:maml="http://schemas.microsoft.com/maml/2004/10"><maml:title>Summary</maml:title><maml:para>$($definition.Summary)</maml:para></maml:section><maml:section xmlns:maml="http://schemas.microsoft.com/maml/2004/10"><maml:title>Operator response</maml:title><maml:para>$($definition.Action)</maml:para></maml:section><maml:section xmlns:maml="http://schemas.microsoft.com/maml/2004/10"><maml:title>Tuning</maml:title><maml:para>Confirm the effective configuration, topology, maintenance state, duration, and recovery behavior. Store active settings only in the dedicated customer-owned Azure Local Monitoring Overrides Management Pack.</maml:para></maml:section></MamlContent></KnowledgeArticle>
"@)
    }

    return [pscustomobject]@{
        Monitors = $monitorXml.ToString()
        StringResources = $resourceXml.ToString()
        DisplayStrings = $displayXml.ToString()
        KnowledgeArticles = $knowledgeXml.ToString()
    }
}

function ConvertTo-DisplayName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )

    $leaf = $Value -replace '^HybridSolutionsCloud\.AzureLocal\.', ''
    $leaf = $leaf -replace '([a-z0-9])([A-Z])', '$1 $2'
    return ($leaf -replace '\.', ' ')
}

function Get-LibraryElementDisplayStringContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [xml]$LibraryXml
    )

    $displayXml = [System.Text.StringBuilder]::new()
    foreach ($classType in $LibraryXml.SelectNodes('/ManagementPack/TypeDefinitions/EntityTypes/ClassTypes/ClassType')) {
        foreach ($property in @($classType.Property)) {
            $name = [System.Security.SecurityElement]::Escape((ConvertTo-DisplayName -Value ([string]$property.ID)))
            [void]$displayXml.AppendLine("<DisplayString ElementID=`"$($classType.ID)`" SubElementID=`"$($property.ID)`"><Name>$name</Name></DisplayString>")
        }
    }

    foreach ($relationship in $LibraryXml.SelectNodes('/ManagementPack/TypeDefinitions/EntityTypes/RelationshipTypes/RelationshipType')) {
        $name = [System.Security.SecurityElement]::Escape((ConvertTo-DisplayName -Value ([string]$relationship.ID)))
        [void]$displayXml.AppendLine("<DisplayString ElementID=`"$($relationship.ID)`"><Name>$name</Name></DisplayString>")
    }

    return $displayXml.ToString()
}

$sourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$manifestPath = Join-Path $sourceRoot 'build/build-manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$monitorContent = Get-AzureLocalNodeMonitorContent

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $sourceRoot 'out/development'
}

$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
[System.IO.Directory]::CreateDirectory($resolvedOutput) | Out-Null

$builtArtifacts = [System.Collections.Generic.List[object]]::new()

foreach ($artifact in $manifest.artifacts) {
    if (-not $artifact.required -and -not $IncludeReporting) {
        continue
    }

    $sourcePath = Join-Path $sourceRoot $artifact.source
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        throw "Management Pack source does not exist: $sourcePath"
    }

    $content = Get-Content -LiteralPath $sourcePath -Raw
    $content = $content.Replace('{{VERSION}}', $Version)
    $content = $content.Replace('{{PUBLIC_KEY_TOKEN}}', $PublicKeyToken.ToLowerInvariant())
    if ($artifact.id -eq 'HybridSolutionsCloud.AzureLocal.Library') {
        [xml]$librarySourceXml = $content
        $content = $content.Replace(
            '{{LIBRARY_ELEMENT_DISPLAY_STRINGS}}',
            (Get-LibraryElementDisplayStringContent -LibraryXml $librarySourceXml)
        )
    }
    if ($artifact.id -eq 'HybridSolutionsCloud.AzureLocal.Monitoring') {
        $content = $content.Replace('{{NODE_MONITORS}}', $monitorContent.Monitors)
        $content = $content.Replace('{{STRING_RESOURCES}}', $monitorContent.StringResources)
        $content = $content.Replace('{{MONITOR_DISPLAY_STRINGS}}', $monitorContent.DisplayStrings)
        $content = $content.Replace('{{KNOWLEDGE_ARTICLES}}', $monitorContent.KnowledgeArticles)
    }

    if ($content -match '\{\{[A-Z_]+\}\}') {
        throw "Unresolved build token in $sourcePath"
    }

    try {
        [xml]$xml = $content
    }
    catch {
        throw "Generated XML is not well formed for $($artifact.id): $($_.Exception.Message)"
    }

    $actualId = [string]$xml.ManagementPack.Manifest.Identity.ID
    $actualVersion = [string]$xml.ManagementPack.Manifest.Identity.Version
    if ($actualId -ne $artifact.id) {
        throw "Expected Management Pack ID '$($artifact.id)' but generated '$actualId'."
    }
    if ($actualVersion -ne $Version) {
        throw "Expected version '$Version' in '$actualId' but generated '$actualVersion'."
    }

    $outputFile = Join-Path $resolvedOutput $artifact.output
    [System.IO.File]::WriteAllText(
        $outputFile,
        $content,
        [System.Text.UTF8Encoding]::new($false)
    )

    $builtArtifacts.Add([pscustomobject]@{
            id = $actualId
            version = $actualVersion
            source = $artifact.source
            output = $artifact.output
            intendedReleaseForm = $artifact.releaseForm
            sdkVerified = $false
            sealed = $false
            signed = $false
            labImported = $false
        })
}

$inventory = [ordered]@{
    schemaVersion = '1.0'
    product = $manifest.namespace
    version = $Version
    buildKind = 'development-xml'
    releaseReady = $false
    publicKeyToken = $PublicKeyToken.ToLowerInvariant()
    generatedAtUtc = [DateTimeOffset]::UtcNow.ToString('o')
    artifacts = $builtArtifacts
    nextRequiredGate = 'Microsoft SDK verification, test sealing, and SCOM lab import'
}

$inventoryPath = Join-Path $resolvedOutput 'build-inventory.json'
$inventoryJson = $inventory | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText(
    $inventoryPath,
    $inventoryJson,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Output $inventoryPath
