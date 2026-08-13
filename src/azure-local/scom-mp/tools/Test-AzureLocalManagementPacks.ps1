#Requires -Version 7.0
<#
.SYNOPSIS
    Runs structural and product-boundary checks against the Azure Local Management Pack source.

.DESCRIPTION
    Builds all development artifacts in an isolated temporary directory and asserts identities,
    dependencies, topology, workflows, Distributed Application rollup, views, override ownership,
    and release-safety metadata.

.NOTES
    Author: Kristopher Turner
    Contact: kris@hybridsolutions.cloud
    Version: 1.0.0
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$tempRoot = [System.IO.Path]::GetFullPath((Join-Path ([System.IO.Path]::GetTempPath()) "hcs-azurelocal-mp-$([Guid]::NewGuid().ToString('N'))"))
$expectedTempParent = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())

function Assert-True {
    param([Parameter(Mandatory)][bool]$Condition, [Parameter(Mandatory)][string]$Message)
    if (-not $Condition) { throw $Message }
}

try {
    [System.IO.Directory]::CreateDirectory($tempRoot) | Out-Null
    $buildScript = Join-Path $PSScriptRoot 'Build-AzureLocalManagementPacks.ps1'
    $inventoryPath = & $buildScript -Version '0.1.0.0' -PublicKeyToken '0123456789abcdef' -OutputPath $tempRoot -IncludeReporting
    $inventory = Get-Content -LiteralPath $inventoryPath -Raw | ConvertFrom-Json

    Assert-True ($inventory.releaseReady -eq $false) 'Development output must never claim release readiness.'
    Assert-True ($inventory.artifacts.Count -eq 5) 'The development build must contain five product artifacts.'

    $expectedIds = @(
        'HybridSolutionsCloud.AzureLocal.Library',
        'HybridSolutionsCloud.AzureLocal.Discovery',
        'HybridSolutionsCloud.AzureLocal.Monitoring',
        'HybridSolutionsCloud.AzureLocal.Presentation',
        'HybridSolutionsCloud.AzureLocal.Reporting'
    )

    foreach ($artifact in $inventory.artifacts) {
        Assert-True ($expectedIds -contains $artifact.id) "Unexpected artifact ID: $($artifact.id)"
        $filePath = Join-Path $tempRoot $artifact.output
        Assert-True (Test-Path -LiteralPath $filePath -PathType Leaf) "Missing generated file: $filePath"
        [xml]$xml = Get-Content -LiteralPath $filePath -Raw
        Assert-True ($xml.ManagementPack.SchemaVersion -eq '2.0') "Wrong schema version in $filePath"
        Assert-True ($xml.ManagementPack.Manifest.Identity.ID -eq $artifact.id) "Identity mismatch in $filePath"
        Assert-True ($xml.ManagementPack.Manifest.Identity.Version -eq '0.1.0.0') "Version mismatch in $filePath"
        $text = Get-Content -LiteralPath $filePath -Raw
        Assert-True (-not ($text -match 'Default Management Pack')) "Prohibited Default Management Pack reference in $filePath"
        Assert-True (-not ($text -match 'HybridSolutionsCloud\.HyperV')) "Prohibited Hyper-V product dependency in $filePath"
        Assert-True (-not ($text -match '\{\{[A-Z_]+\}\}')) "Unresolved token in $filePath"
    }

    [xml]$library = Get-Content -LiteralPath (Join-Path $tempRoot 'HybridSolutionsCloud.AzureLocal.Library.xml') -Raw
    $classes = @($library.SelectNodes('/ManagementPack/TypeDefinitions/EntityTypes/ClassTypes/ClassType'))
    $relationships = @($library.SelectNodes('/ManagementPack/TypeDefinitions/EntityTypes/RelationshipTypes/RelationshipType'))
    Assert-True ($classes.Count -eq 17) 'Library must contain 17 Azure Local classes.'
    Assert-True ($relationships.Count -eq 28) 'Library must contain 28 typed relationships.'
    Assert-True ($library.SelectSingleNode("//ClassType[@ID='HybridSolutionsCloud.AzureLocal.Service']").Base -match 'ServiceDesigner') 'DA root must derive from the Service Designer service class.'
    foreach ($classId in @('NodeRole','Deployment','StoragePool','Volume','PhysicalDisk','NetworkAtcIntent','UpdateState','ArcIntegration','ResourceBridge','MonitoringPipeline','Service')) {
        Assert-True ($null -ne $library.SelectSingleNode("//ClassType[@ID='HybridSolutionsCloud.AzureLocal.$classId']")) "Missing Azure Local class: $classId"
    }
    foreach ($publicElement in $library.SelectNodes('//*[@Accessibility="Public"]')) {
        $id = $publicElement.GetAttribute('ID')
        if (-not [string]::IsNullOrWhiteSpace($id)) {
            Assert-True ($null -ne $library.SelectSingleNode("//DisplayString[@ElementID='$id']")) "Missing display string for public library element $id."
        }
    }

    [xml]$discovery = Get-Content -LiteralPath (Join-Path $tempRoot 'HybridSolutionsCloud.AzureLocal.Discovery.xml') -Raw
    Assert-True (@($discovery.SelectNodes('/ManagementPack/Monitoring/Discoveries/Discovery')).Count -eq 2) 'Discovery MP must contain role-seed and topology discoveries.'
    $discoveryText = $discovery.OuterXml
    foreach ($required in @('Get-AzureStackHCI','Get-Cluster','Get-StoragePool','Get-Volume','Get-PhysicalDisk','Get-NetIntentStatus','Get-SolutionUpdate','HybridSolutionsCloud.AzureLocal.Service')) {
        Assert-True ($discoveryText.Contains($required)) "Discovery is missing required local source or DA element: $required"
    }
    Assert-True (-not $discoveryText.Contains('Connect-AzAccount')) 'Local Azure Local discovery must not require an interactive Azure sign-in.'

    [xml]$monitoring = Get-Content -LiteralPath (Join-Path $tempRoot 'HybridSolutionsCloud.AzureLocal.Monitoring.xml') -Raw
    $unitMonitors = @($monitoring.SelectNodes('/ManagementPack/Monitoring/Monitors/UnitMonitor'))
    $aggregateMonitors = @($monitoring.SelectNodes('/ManagementPack/Monitoring/Monitors/AggregateMonitor'))
    $dependencyMonitors = @($monitoring.SelectNodes('/ManagementPack/Monitoring/Monitors/DependencyMonitor'))
    $rules = @($monitoring.SelectNodes('/ManagementPack/Monitoring/Rules/Rule'))
    $performanceRules = @($rules | Where-Object Category -eq 'PerformanceCollection')
    $alertRules = @($rules | Where-Object Category -eq 'Alert')
    $tasks = @($monitoring.SelectNodes('/ManagementPack/Monitoring/Tasks/Task'))

    Assert-True ($unitMonitors.Count -eq 14) 'Monitoring MP must contain 14 local health monitors.'
    Assert-True ($aggregateMonitors.Count -eq 6) 'Monitoring MP must contain six domain aggregate monitors.'
    Assert-True ($dependencyMonitors.Count -eq 12) 'Monitoring MP must contain 12 DA dependency rollups.'
    Assert-True ($performanceRules.Count -eq 12) 'Monitoring MP must contain 12 performance collection rules.'
    Assert-True ($alertRules.Count -eq 4) 'Monitoring MP must contain four high-confidence event-alert rules.'
    Assert-True ($tasks.Count -eq 1) 'Monitoring MP must contain one read-only diagnostic task.'
    $alertSettings = @($monitoring.SelectNodes('/ManagementPack/Monitoring/Monitors/UnitMonitor/AlertSettings'))
    Assert-True ($alertSettings.Count -eq 11) 'Only the 11 curated state monitors should generate alerts.'
    Assert-True (@($alertSettings | Where-Object AutoResolve -ne 'true').Count -eq 0) 'Every stateful monitor alert must auto-resolve.'

    foreach ($shortId in @('ClusterService','ClusterNode','Quorum','Cpu','Memory','HealthFault','StoragePool','Volume','PhysicalDisk','NetworkATC','Registration','PlatformServices','Update','Pipeline')) {
        Assert-True ($null -ne $monitoring.SelectSingleNode("//UnitMonitor[@ID='HybridSolutionsCloud.AzureLocal.Node.$shortId.Monitor']")) "Missing node health monitor: $shortId"
    }

    $disabledRuleIds = @($performanceRules | Where-Object Enabled -eq 'false' | ForEach-Object ID)
    foreach ($id in @(
            'HybridSolutionsCloud.AzureLocal.Node.NetworkOutputQueue.Collection.Rule',
            'HybridSolutionsCloud.AzureLocal.Node.PhysicalDiskQueue.Collection.Rule',
            'HybridSolutionsCloud.AzureLocal.Node.ClusterCsvReadBytes.Collection.Rule',
            'HybridSolutionsCloud.AzureLocal.Node.ClusterCsvWriteBytes.Collection.Rule'
        )) {
        Assert-True ($disabledRuleIds -contains $id) "High-cardinality or availability-dependent collection must be disabled by default: $id"
    }

    $knowledge = @($monitoring.SelectNodes('/ManagementPack/LanguagePacks/LanguagePack/KnowledgeArticles/KnowledgeArticle'))
    Assert-True ($knowledge.Count -eq 18) 'Every health monitor and event-alert rule must include operational knowledge.'
    foreach ($publicElement in $monitoring.SelectNodes('//*[@Accessibility="Public"]')) {
        $id = $publicElement.GetAttribute('ID')
        if (-not [string]::IsNullOrWhiteSpace($id)) {
            Assert-True ($null -ne $monitoring.SelectSingleNode("//DisplayString[@ElementID='$id']")) "Missing display string for public monitoring element $id."
        }
    }

    [xml]$presentation = Get-Content -LiteralPath (Join-Path $tempRoot 'HybridSolutionsCloud.AzureLocal.Presentation.xml') -Raw
    Assert-True (@($presentation.SelectNodes('/ManagementPack/Presentation/Views/View')).Count -eq 14) 'Presentation MP must contain 14 service, inventory, alert, event, and performance views.'
    Assert-True (@($presentation.SelectNodes('/ManagementPack/Presentation/Folders/Folder')).Count -eq 4) 'Presentation MP must contain four operator folders.'
    foreach ($publicElement in $presentation.SelectNodes('//*[@Accessibility="Public"]')) {
        $id = $publicElement.GetAttribute('ID')
        if (-not [string]::IsNullOrWhiteSpace($id)) {
            Assert-True ($null -ne $presentation.SelectSingleNode("//DisplayString[@ElementID='$id']")) "Missing display string for public presentation element $id."
        }
    }

    $profileRoot = Join-Path $sourceRoot 'templates/overrides'
    foreach ($profileName in @('lab','standard','strict')) {
        $manifestPath = Join-Path $profileRoot "$profileName/profile.json"
        $tuningProfile = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        Assert-True ($tuningProfile.profile.ToLowerInvariant() -eq $profileName) "Profile name mismatch in $manifestPath"
        Assert-True ($tuningProfile.status -eq 'DevelopmentStarter') "Profile must remain a development starter: $manifestPath"
        Assert-True ($tuningProfile.discoverySettings.Count -gt 0) "Profile must define discovery settings: $manifestPath"
        Assert-True ($tuningProfile.monitoringSettings.Count -gt 0) "Profile must define monitoring settings: $manifestPath"

        $overrideOutput = Join-Path $tempRoot "overrides-$profileName"
        & (Join-Path $PSScriptRoot 'New-AzureLocalOverrideManagementPacks.ps1') -TuningProfile $profileName -OrganizationId Contoso -OrganizationName Contoso -Version '0.1.0.0' -PublicKeyToken '0123456789abcdef' -OutputPath $overrideOutput
        [xml]$discoveryOverrides = Get-Content -LiteralPath (Join-Path $overrideOutput 'Contoso.HybridSolutionsCloud.AzureLocal.Discovery.Overrides.xml') -Raw
        [xml]$monitoringOverrides = Get-Content -LiteralPath (Join-Path $overrideOutput 'Contoso.HybridSolutionsCloud.AzureLocal.Monitoring.Overrides.xml') -Raw
        Assert-True (@($discoveryOverrides.SelectNodes('/ManagementPack/Monitoring/Overrides/*')).Count -gt 0) "Generated $profileName Discovery Overrides MP is empty."
        Assert-True (@($monitoringOverrides.SelectNodes('/ManagementPack/Monitoring/Overrides/*')).Count -gt 0) "Generated $profileName Monitoring Overrides MP is empty."
    }

    Write-Output 'Azure Local Management Pack contract tests passed.'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Assert-True ($tempRoot.StartsWith($expectedTempParent, [StringComparison]::OrdinalIgnoreCase)) 'Refusing to remove an unexpected path.'
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
