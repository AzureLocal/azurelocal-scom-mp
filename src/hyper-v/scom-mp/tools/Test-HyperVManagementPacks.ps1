#Requires -Version 7.0
<#
.SYNOPSIS
    Runs structural and product-boundary checks against the Hyper-V Management Pack source.

.DESCRIPTION
    Builds all development artifacts in an isolated temporary directory and asserts identities,
    dependencies, workflow coverage, override ownership, and release-safety metadata.

.NOTES
    Author: Kristopher Turner
    Contact: kris@hybridsolutions.cloud
    Version: 1.1.0
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$tempRoot = [System.IO.Path]::GetFullPath((Join-Path ([System.IO.Path]::GetTempPath()) "hcs-hyperv-mp-$([Guid]::NewGuid().ToString('N'))"))
$expectedTempParent = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())

function Assert-True {
    param(
        [Parameter(Mandatory)]
        [bool]$Condition,

        [Parameter(Mandatory)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

try {
    [System.IO.Directory]::CreateDirectory($tempRoot) | Out-Null

    $buildScript = Join-Path $PSScriptRoot 'Build-HyperVManagementPacks.ps1'
    $inventoryPath = & $buildScript `
        -Version '0.1.0.0' `
        -PublicKeyToken '0123456789abcdef' `
        -OutputPath $tempRoot `
        -IncludeReporting

    $inventory = Get-Content -LiteralPath $inventoryPath -Raw | ConvertFrom-Json
    Assert-True ($inventory.releaseReady -eq $false) 'Development output must never claim release readiness.'
    Assert-True ($inventory.artifacts.Count -eq 5) 'The development build must contain five product artifacts.'

    $expectedIds = @(
        'HybridSolutionsCloud.HyperV.Library',
        'HybridSolutionsCloud.HyperV.Discovery',
        'HybridSolutionsCloud.HyperV.Monitoring',
        'HybridSolutionsCloud.HyperV.Presentation',
        'HybridSolutionsCloud.HyperV.Reporting'
    )

    foreach ($artifact in $inventory.artifacts) {
        Assert-True ($expectedIds -contains $artifact.id) "Unexpected artifact ID: $($artifact.id)"
        $filePath = Join-Path $tempRoot $artifact.output
        Assert-True (Test-Path -LiteralPath $filePath -PathType Leaf) "Missing generated file: $filePath"

        [xml]$xml = Get-Content -LiteralPath $filePath -Raw
        Assert-True ($xml.ManagementPack.SchemaVersion -eq '2.0') "Wrong schema version in $filePath"
        Assert-True ($xml.ManagementPack.Manifest.Identity.ID -eq $artifact.id) "Identity mismatch in $filePath"
        Assert-True ($xml.ManagementPack.Manifest.Identity.Version -eq '0.1.0.0') "Version mismatch in $filePath"

        $sourceText = Get-Content -LiteralPath $filePath -Raw
        Assert-True (-not ($sourceText -match 'Default Management Pack')) "Prohibited Default Management Pack reference in $filePath"
        Assert-True (-not ($sourceText -match 'Microsoft\.Windows\.HyperV\.2019')) "Prohibited legacy Hyper-V dependency in $filePath"
        Assert-True (-not ($sourceText -match 'HybridSolutionsCloud\.AzureLocal')) "Prohibited Azure Local dependency in $filePath"
        Assert-True (-not ($sourceText -match '\{\{[A-Z_]+\}\}')) "Unresolved token in $filePath"
    }

    [xml]$libraryXml = Get-Content -LiteralPath (Join-Path $tempRoot 'HybridSolutionsCloud.HyperV.Library.xml') -Raw
    $classTypes = @($libraryXml.SelectNodes('/ManagementPack/TypeDefinitions/EntityTypes/ClassTypes/ClassType'))
    $relationshipTypes = @($libraryXml.SelectNodes('/ManagementPack/TypeDefinitions/EntityTypes/RelationshipTypes/RelationshipType'))
    Assert-True ($classTypes.Count -eq 13) 'The Library MP must define the thirteen approved development classes.'
    Assert-True ($relationshipTypes.Count -eq 20) 'The Library MP must define the twenty topology and DA relationships.'
    $libraryDisplayStrings = @($libraryXml.SelectNodes('/ManagementPack/LanguagePacks/LanguagePack/DisplayStrings/DisplayString'))
    foreach ($classType in $classTypes) {
        foreach ($property in @($classType.Property)) {
            $localizedProperty = @($libraryDisplayStrings | Where-Object {
                    $_.GetAttribute('ElementID') -eq $classType.ID -and
                    $_.GetAttribute('SubElementID') -eq $property.ID
                })
            Assert-True ($localizedProperty.Count -eq 1) "Missing display string for $($classType.ID).$($property.ID)."
        }
    }
    foreach ($relationshipType in $relationshipTypes) {
        $localizedRelationship = @($libraryDisplayStrings | Where-Object ElementID -eq $relationshipType.ID)
        Assert-True ($localizedRelationship.Count -eq 1) "Missing display string for relationship $($relationshipType.ID)."
    }

    $vmClass = $libraryXml.SelectSingleNode("/ManagementPack/TypeDefinitions/EntityTypes/ClassTypes/ClassType[@ID='HybridSolutionsCloud.HyperV.VirtualMachine']")
    Assert-True ($null -ne $vmClass) 'The boundary-scoped virtual machine class is missing.'
    Assert-True ($vmClass.Hosted -eq 'false') 'Virtual machines must not be hosted by their current Hyper-V host.'
    $vmKeys = @($vmClass.Property | Where-Object Key -eq 'true' | ForEach-Object ID)
    Assert-True ($vmKeys.Count -eq 2 -and $vmKeys -contains 'BoundaryId' -and $vmKeys -contains 'VMId') 'Virtual machine identity must use BoundaryId plus VMId.'

    [xml]$discoveryXml = Get-Content -LiteralPath (Join-Path $tempRoot 'HybridSolutionsCloud.HyperV.Discovery.xml') -Raw
    $discoveries = @($discoveryXml.SelectNodes('/ManagementPack/Monitoring/Discoveries/Discovery'))
    Assert-True ($discoveries.Count -eq 2) 'Discovery MP must contain the host seed and staged topology discoveries.'
    $discoveryText = $discoveryXml.OuterXml
    foreach ($requiredCommand in @('Get-VMHost', 'Get-VM', 'Get-ClusterSharedVolume', 'Get-VMSwitch', 'Get-NetIntent')) {
        Assert-True ($discoveryText.Contains($requiredCommand)) "Topology discovery is missing required provider command: $requiredCommand"
    }
    Assert-True ($discoveryText.Contains('HybridSolutionsCloud.HyperV.Service')) 'Topology discovery must create Hyper-V Distributed Application service roots.'
    $discoveryDisplayStrings = @($discoveryXml.SelectNodes('/ManagementPack/LanguagePacks/LanguagePack/DisplayStrings/DisplayString'))
    foreach ($publicElement in $discoveryXml.SelectNodes('//*[@Accessibility="Public"]')) {
        $publicId = $publicElement.GetAttribute('ID')
        if (-not [string]::IsNullOrWhiteSpace($publicId)) {
            Assert-True (@($discoveryDisplayStrings | Where-Object ElementID -eq $publicId).Count -eq 1) "Missing display string for public discovery element $publicId."
        }
    }

    [xml]$monitoringXml = Get-Content -LiteralPath (Join-Path $tempRoot 'HybridSolutionsCloud.HyperV.Monitoring.xml') -Raw
    $unitMonitors = @($monitoringXml.SelectNodes('/ManagementPack/Monitoring/Monitors/UnitMonitor'))
    $dependencyMonitors = @($monitoringXml.SelectNodes('/ManagementPack/Monitoring/Monitors/DependencyMonitor'))
    $rules = @($monitoringXml.SelectNodes('/ManagementPack/Monitoring/Rules/Rule'))
    $tasks = @($monitoringXml.SelectNodes('/ManagementPack/Monitoring/Tasks/Task'))
    Assert-True ($unitMonitors.Count -eq 9) 'Monitoring MP must contain nine host health monitors.'
    Assert-True ($dependencyMonitors.Count -eq 10) 'Monitoring MP must contain ten topology-aware DA dependency monitors.'
    $performanceRules = @($rules | Where-Object Category -eq 'PerformanceCollection')
    $alertRules = @($rules | Where-Object Category -eq 'Alert')
    Assert-True ($rules.Count -eq 16) 'Monitoring MP must contain the sixteen approved development rules.'
    Assert-True ($performanceRules.Count -eq 12) 'Monitoring MP must contain twelve performance-collection rules.'
    Assert-True ($alertRules.Count -eq 4) 'Monitoring MP must contain four high-confidence event-alert rules.'
    Assert-True ($tasks.Count -eq 1) 'Monitoring MP must contain the read-only diagnostic summary task.'
    Assert-True (@($unitMonitors | Where-Object { $_.AlertSettings.AutoResolve -ne 'true' }).Count -eq 0) 'Every stateful monitor alert must auto-resolve.'
    $knowledgeArticles = @($monitoringXml.SelectNodes('/ManagementPack/LanguagePacks/LanguagePack/KnowledgeArticles/KnowledgeArticle'))
    Assert-True ($knowledgeArticles.Count -eq 13) 'Every health monitor and event-alert rule must contain operational knowledge.'
    foreach ($alertRule in $alertRules) {
        Assert-True (@($knowledgeArticles | Where-Object ElementID -eq $alertRule.ID).Count -eq 1) "Missing operational knowledge for $($alertRule.ID)."
    }
    $monitoringDisplayStrings = @($monitoringXml.SelectNodes('/ManagementPack/LanguagePacks/LanguagePack/DisplayStrings/DisplayString'))
    foreach ($publicElement in $monitoringXml.SelectNodes('//*[@Accessibility="Public"]')) {
        $publicId = $publicElement.GetAttribute('ID')
        if (-not [string]::IsNullOrWhiteSpace($publicId)) {
            Assert-True (@($monitoringDisplayStrings | Where-Object ElementID -eq $publicId).Count -ge 1) "Missing display string for public monitoring element $publicId."
        }
    }
    $disabledCollectionIds = @($performanceRules | Where-Object Enabled -eq 'false' | ForEach-Object ID)
    foreach ($disabledId in @(
            'HybridSolutionsCloud.HyperV.Host.VirtualProcessor.Collection.Rule',
            'HybridSolutionsCloud.HyperV.Host.RootVirtualProcessor.Collection.Rule',
            'HybridSolutionsCloud.HyperV.Host.VirtualNetworkBytes.Collection.Rule',
            'HybridSolutionsCloud.HyperV.Host.PhysicalDiskReadQueue.Collection.Rule',
            'HybridSolutionsCloud.HyperV.Host.PhysicalDiskWriteQueue.Collection.Rule'
        )) {
        Assert-True ($disabledCollectionIds -contains $disabledId) "High-cardinality collection must be disabled by default: $disabledId"
    }

    $unitMonitorIds = @($unitMonitors | ForEach-Object ID)
    foreach ($shortId in @('VMMS', 'Cluster', 'VirtualMachines', 'Replication', 'NetworkATC', 'Memory', 'Cpu', 'Csv', 'Pipeline')) {
        Assert-True ($unitMonitorIds -contains "HybridSolutionsCloud.HyperV.Host.$shortId.Monitor") "Missing host health monitor: $shortId"
    }

    [xml]$presentationXml = Get-Content -LiteralPath (Join-Path $tempRoot 'HybridSolutionsCloud.HyperV.Presentation.xml') -Raw
    $views = @($presentationXml.SelectNodes('/ManagementPack/Presentation/Views/View'))
    Assert-True ($views.Count -eq 10) 'Presentation MP must contain ten health, inventory, alert, event, and performance views.'
    $presentationDisplayStrings = @($presentationXml.SelectNodes('/ManagementPack/LanguagePacks/LanguagePack/DisplayStrings/DisplayString'))
    foreach ($publicElement in $presentationXml.SelectNodes('//*[@Accessibility="Public"]')) {
        $publicId = $publicElement.GetAttribute('ID')
        if (-not [string]::IsNullOrWhiteSpace($publicId)) {
            Assert-True (@($presentationDisplayStrings | Where-Object ElementID -eq $publicId).Count -eq 1) "Missing display string for public presentation element $publicId."
        }
    }

    $profileRoot = Join-Path $sourceRoot 'templates/overrides'
    foreach ($profileName in @('lab', 'standard', 'strict')) {
        $profilePath = Join-Path $profileRoot $profileName
        $manifestPath = Join-Path $profilePath 'profile.json'
        Assert-True (Test-Path -LiteralPath $manifestPath -PathType Leaf) "Missing $profileName profile manifest."

        $profileManifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        Assert-True ($profileManifest.profile.ToLowerInvariant() -eq $profileName) "Profile name mismatch in $manifestPath"
        Assert-True ($profileManifest.status -eq 'DevelopmentStarter') "Profile must be identified as a development starter: $manifestPath"
        Assert-True ($profileManifest.discoverySettings.Count -gt 0) "Profile must define discovery settings: $manifestPath"
        Assert-True ($profileManifest.monitoringSettings.Count -gt 0) "Profile must define monitoring settings: $manifestPath"

        foreach ($kind in @('Discovery', 'Monitoring')) {
            $examplePath = Join-Path $profilePath "$kind.Overrides.xml.example"
            Assert-True (Test-Path -LiteralPath $examplePath -PathType Leaf) "Missing override example: $examplePath"
            $exampleText = Get-Content -LiteralPath $examplePath -Raw
            Assert-True ($exampleText -match '\{\{ORGANIZATION_ID\}\}') "Override example must retain the customer-owned ID placeholder: $examplePath"
            Assert-True ($exampleText -match '\{\{PUBLIC_KEY_TOKEN\}\}') "Override example must retain the signing-token placeholder: $examplePath"
            Assert-True (-not ($exampleText -match 'Default Management Pack')) "Override example references the Default Management Pack: $examplePath"
        }

        $overrideOutput = Join-Path $tempRoot "overrides-$profileName"
        $overrideGenerator = Join-Path $PSScriptRoot 'New-HyperVOverrideManagementPacks.ps1'
        & $overrideGenerator -TuningProfile $profileName -OrganizationId 'Contoso' -OrganizationName 'Contoso' -Version '0.1.0.0' -PublicKeyToken '0123456789abcdef' -OutputPath $overrideOutput
        $generatedDiscovery = Join-Path $overrideOutput 'Contoso.HybridSolutionsCloud.HyperV.Discovery.Overrides.xml'
        $generatedMonitoring = Join-Path $overrideOutput 'Contoso.HybridSolutionsCloud.HyperV.Monitoring.Overrides.xml'
        [xml]$discoveryOverridesXml = Get-Content -LiteralPath $generatedDiscovery -Raw
        [xml]$monitoringOverridesXml = Get-Content -LiteralPath $generatedMonitoring -Raw
        Assert-True (@($discoveryOverridesXml.SelectNodes('/ManagementPack/Monitoring/Overrides/*')).Count -gt 0) "Generated $profileName Discovery Overrides MP is empty."
        Assert-True (@($monitoringOverridesXml.SelectNodes('/ManagementPack/Monitoring/Overrides/*')).Count -gt 0) "Generated $profileName Monitoring Overrides MP is empty."
    }

    Write-Output 'Hyper-V Management Pack contract tests passed.'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Assert-True ($tempRoot.StartsWith($expectedTempParent, [StringComparison]::OrdinalIgnoreCase)) 'Refusing to remove an unexpected path.'
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
