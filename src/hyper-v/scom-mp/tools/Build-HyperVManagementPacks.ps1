#Requires -Version 7.0
<#
.SYNOPSIS
    Builds development Hyper-V SCOM Management Pack XML artifacts.

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

function Get-HyperVHostMonitorContent {
    [CmdletBinding()]
    param()

    $monitorDefinitions = @(
        [pscustomobject]@{ Id = 'VMMS'; Property = 'VMMSState'; Name = 'Hyper-V Virtual Machine Management service health'; Parent = 'AvailabilityState'; Category = 'AvailabilityHealth'; Impact = 'Error'; Summary = 'Tracks whether the VMMS service is running. A stopped VMMS service prevents normal Hyper-V management and VM operations.'; Action = 'Verify the vmms service state, recent VMMS events, dependent services, host maintenance, and whether a restart or escalation is appropriate.' },
        [pscustomobject]@{ Id = 'Cluster'; Property = 'ClusterState'; Name = 'Hyper-V failover cluster node health'; Parent = 'AvailabilityState'; Category = 'AvailabilityHealth'; Impact = 'Error'; Summary = 'Tracks failover-cluster node membership for clustered Hyper-V hosts. Standalone hosts report Not Applicable and remain healthy.'; Action = 'Review cluster node state, quorum, networks, event 1135, maintenance and drain status before returning a node to service.' },
        [pscustomobject]@{ Id = 'VirtualMachines'; Property = 'VirtualMachineState'; Name = 'Hyper-V expected virtual machine state'; Parent = 'AvailabilityState'; Category = 'AvailabilityHealth'; Impact = 'Error'; Summary = 'Detects VMs configured to start automatically that are in an unexpected stopped or failed state. Policy-dependent VMs do not create an availability failure.'; Action = 'Confirm the VM expected-state policy, clustered role state, current owner, recent failover or migration, and VMMS operational events.' },
        [pscustomobject]@{ Id = 'Replication'; Property = 'ReplicationState'; Name = 'Hyper-V Replica health'; Parent = 'AvailabilityState'; Category = 'AvailabilityHealth'; Impact = 'Warning'; Summary = 'Tracks the worst reported Hyper-V Replica relationship health on the host.'; Action = 'Inspect Get-VMReplication output, replication connectivity, authentication, storage, backlog, and the last successful replication time.' },
        [pscustomobject]@{ Id = 'NetworkATC'; Property = 'NetworkAtcState'; Name = 'Network ATC intent health'; Parent = 'ConfigurationState'; Category = 'ConfigurationHealth'; Impact = 'Error'; Summary = 'Tracks Network ATC intent configuration status when Network ATC is present. Manual and externally managed networking report Not Applicable.'; Action = 'Review Get-NetIntent and Get-NetIntentStatus, adapter state, intent overrides, remediation state, and whether SCVMM or SDN is the selected authority.' },
        [pscustomobject]@{ Id = 'Memory'; Property = 'MemoryState'; Name = 'Hyper-V host available memory'; Parent = 'PerformanceState'; Category = 'PerformanceHealth'; Impact = 'Error'; Summary = 'Tracks absolute memory available to the host management partition. Defaults are provisional, sustained by the polling interval, and fully overrideable.'; Action = 'Review available memory, Dynamic Memory pressure, paging, VM demand, NUMA placement, host reserve, and capacity trends before changing thresholds.' },
        [pscustomobject]@{ Id = 'Cpu'; Property = 'CpuState'; Name = 'Hyper-V hypervisor processor pressure'; Parent = 'PerformanceState'; Category = 'PerformanceHealth'; Impact = 'Error'; Summary = 'Tracks sustained Hyper-V hypervisor logical-processor runtime, falling back to host processor load only if the Hyper-V counter is unavailable.'; Action = 'Review hypervisor logical and virtual processor counters, root/guest split, oversubscription, NUMA, interrupts, DPCs, and workload placement.' },
        [pscustomobject]@{ Id = 'Csv'; Property = 'CsvState'; Name = 'Hyper-V Cluster Shared Volume health and capacity'; Parent = 'AvailabilityState'; Category = 'AvailabilityHealth'; Impact = 'Error'; Summary = 'Tracks CSV online state, redirected access, and the lowest free-space percentage. Standalone hosts report Not Applicable.'; Action = 'Inspect CSV state and ownership, redirected I/O reason, storage paths, events 5120/5142, latency, free space, and maintenance activity.' },
        [pscustomobject]@{ Id = 'Pipeline'; Property = 'PipelineState'; Name = 'Hyper-V monitoring pipeline health'; Parent = 'AvailabilityState'; Category = 'AvailabilityHealth'; Impact = 'Error'; Summary = 'Tracks whether the shared Hyper-V health probe completed and returned a valid property bag.'; Action = 'Review Operations Manager event 8201, workflow initialization, module availability, permissions, timeouts, and HealthService health.' }
    )

    $monitorXml = [System.Text.StringBuilder]::new()
    $resourceXml = [System.Text.StringBuilder]::new()
    $displayXml = [System.Text.StringBuilder]::new()
    $knowledgeXml = [System.Text.StringBuilder]::new()

    foreach ($definition in $monitorDefinitions) {
        $monitorId = "HybridSolutionsCloud.HyperV.Host.$($definition.Id).Monitor"
        $messageId = "$monitorId.Message"
        $alertState = if ($definition.Impact -eq 'Warning') { 'Warning' } else { 'Error' }
        $criticalHealth = 'Error'

        [void]$monitorXml.AppendLine(@"
      <UnitMonitor ID="$monitorId" Accessibility="Public" Enabled="true" Target="HCSHyperVLibrary!HybridSolutionsCloud.HyperV.HostRole" ParentMonitorID="Health!System.Health.$($definition.Parent)" Remotable="true" Priority="Normal" TypeID="HybridSolutionsCloud.HyperV.PropertyBag.ThreeState.MonitorType" ConfirmDelivery="true">
        <Category>$($definition.Category)</Category>
        <AlertSettings AlertMessage="$messageId"><AlertOnState>$alertState</AlertOnState><AutoResolve>true</AutoResolve><AlertPriority>Normal</AlertPriority><AlertSeverity>MatchMonitorHealth</AlertSeverity><AlertParameters><AlertParameter1>`$Data/Context/Property[@Name='$($definition.Property)Detail']`$</AlertParameter1></AlertParameters></AlertSettings>
        <OperationalStates><OperationalState ID="Good" MonitorTypeStateID="Good" HealthState="Success" /><OperationalState ID="Warning" MonitorTypeStateID="Warning" HealthState="Warning" /><OperationalState ID="Critical" MonitorTypeStateID="Critical" HealthState="$criticalHealth" /></OperationalStates>
        <Configuration><PropertyName>$($definition.Property)</PropertyName><IntervalSeconds>300</IntervalSeconds><SyncTime /><TimeoutSeconds>120</TimeoutSeconds><CpuWarningPercent>80</CpuWarningPercent><CpuCriticalPercent>90</CpuCriticalPercent><MemoryWarningMB>4096</MemoryWarningMB><MemoryCriticalMB>2048</MemoryCriticalMB><CsvWarningPercentFree>15</CsvWarningPercentFree><CsvCriticalPercentFree>10</CsvCriticalPercentFree></Configuration>
      </UnitMonitor>
"@)
        [void]$resourceXml.AppendLine("<StringResource ID=`"$messageId`" />")
        [void]$displayXml.AppendLine("<DisplayString ElementID=`"$monitorId`"><Name>$($definition.Name)</Name><Description>$($definition.Summary)</Description></DisplayString>")
        [void]$displayXml.AppendLine("<DisplayString ElementID=`"$monitorId`" SubElementID=`"Good`"><Name>Healthy</Name></DisplayString>")
        [void]$displayXml.AppendLine("<DisplayString ElementID=`"$monitorId`" SubElementID=`"Warning`"><Name>Warning</Name></DisplayString>")
        [void]$displayXml.AppendLine("<DisplayString ElementID=`"$monitorId`" SubElementID=`"Critical`"><Name>Critical</Name></DisplayString>")
        [void]$displayXml.AppendLine("<DisplayString ElementID=`"$messageId`"><Name>$($definition.Name)</Name><Description>$($definition.Summary) Detail: {0}</Description></DisplayString>")
        [void]$knowledgeXml.AppendLine(@"
<KnowledgeArticle ElementID="$monitorId" Visible="true"><MamlContent><maml:section xmlns:maml="http://schemas.microsoft.com/maml/2004/10"><maml:title>Summary</maml:title><maml:para>$($definition.Summary)</maml:para></maml:section><maml:section xmlns:maml="http://schemas.microsoft.com/maml/2004/10"><maml:title>Operator response</maml:title><maml:para>$($definition.Action)</maml:para></maml:section><maml:section xmlns:maml="http://schemas.microsoft.com/maml/2004/10"><maml:title>Tuning</maml:title><maml:para>Confirm the effective configuration, topology, maintenance state, duration, and recovery behavior. Store active settings only in the dedicated customer-owned Hyper-V Monitoring Overrides Management Pack.</maml:para></maml:section></MamlContent></KnowledgeArticle>
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

    $leaf = $Value -replace '^HybridSolutionsCloud\.HyperV\.', ''
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
$monitorContent = Get-HyperVHostMonitorContent

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
    if ($artifact.id -eq 'HybridSolutionsCloud.HyperV.Library') {
        [xml]$librarySourceXml = $content
        $content = $content.Replace(
            '{{LIBRARY_ELEMENT_DISPLAY_STRINGS}}',
            (Get-LibraryElementDisplayStringContent -LibraryXml $librarySourceXml)
        )
    }
    if ($artifact.id -eq 'HybridSolutionsCloud.HyperV.Monitoring') {
        $content = $content.Replace(
            'HybridSolutionsCloud.HyperV.Host.VirtualProcessor.Collection.Rule" Enabled="true"',
            'HybridSolutionsCloud.HyperV.Host.VirtualProcessor.Collection.Rule" Enabled="false"'
        )
        $content = $content.Replace('{{HOST_MONITORS}}', $monitorContent.Monitors)
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
