#Requires -Version 7.0
<#
.SYNOPSIS
    Tests the Hyper-V SCOM Management Pack development build.

.DESCRIPTION
    Validates product boundaries, topology identity, workflows, Distributed Application rollups,
    presentation, and customer-owned override generation.

.NOTES
    Author: Kristopher Turner
    Contact: kris@hybridsolutions.cloud
    Version: 1.1.0
#>

BeforeAll {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    $script:RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
    $script:SourceRoot = Join-Path $script:RepositoryRoot 'src/hyper-v/scom-mp'
    $script:BuildScript = Join-Path $script:SourceRoot 'tools/Build-HyperVManagementPacks.ps1'
    $script:ContractScript = Join-Path $script:SourceRoot 'tools/Test-HyperVManagementPacks.ps1'
    $script:OverrideScript = Join-Path $script:SourceRoot 'tools/New-HyperVOverrideManagementPacks.ps1'
}

Describe 'Hyper-V Management Pack development build' {
    It 'passes the repository contract suite' {
        $result = & $script:ContractScript
        $result | Should -Contain 'Hyper-V Management Pack contract tests passed.'
    }

    It 'generates the five intended product projects' {
        $inventoryPath = & $script:BuildScript `
            -Version '0.1.0.0' `
            -PublicKeyToken '0123456789abcdef' `
            -OutputPath $TestDrive `
            -IncludeReporting

        $inventory = Get-Content -LiteralPath $inventoryPath -Raw | ConvertFrom-Json
        $inventory.artifacts.Count | Should -Be 5
        $inventory.releaseReady | Should -BeFalse
        $inventory.artifacts.id | Should -Contain 'HybridSolutionsCloud.HyperV.Library'
        $inventory.artifacts.id | Should -Contain 'HybridSolutionsCloud.HyperV.Discovery'
        $inventory.artifacts.id | Should -Contain 'HybridSolutionsCloud.HyperV.Monitoring'
        $inventory.artifacts.id | Should -Contain 'HybridSolutionsCloud.HyperV.Presentation'
        $inventory.artifacts.id | Should -Contain 'HybridSolutionsCloud.HyperV.Reporting'
    }

    It 'rejects an invalid public key token' {
        {
            & $script:BuildScript `
                -PublicKeyToken 'not-a-token' `
                -OutputPath $TestDrive
        } | Should -Throw
    }

    It 'implements stable Hyper-V topology identities' {
        $outputPath = Join-Path $TestDrive 'topology'
        & $script:BuildScript -PublicKeyToken '0123456789abcdef' -OutputPath $outputPath | Out-Null
        [xml]$library = Get-Content (Join-Path $outputPath 'HybridSolutionsCloud.HyperV.Library.xml') -Raw

        @($library.SelectNodes('/ManagementPack/TypeDefinitions/EntityTypes/ClassTypes/ClassType')).Count | Should -Be 13
        @($library.SelectNodes('/ManagementPack/TypeDefinitions/EntityTypes/RelationshipTypes/RelationshipType')).Count | Should -Be 20
        $vmClass = $library.SelectSingleNode("//ClassType[@ID='HybridSolutionsCloud.HyperV.VirtualMachine']")
        $vmClass.Hosted | Should -Be 'false'
        @($vmClass.Property | Where-Object Key -eq 'true').ID | Should -Be @('BoundaryId', 'VMId')
        @($library.SelectNodes("//ClassType[contains(@ID, 'Component')]") | ForEach-Object Base | Sort-Object -Unique) | Should -Be @('ServiceDesigner!Microsoft.SystemCenter.ServiceDesigner.ServiceComponentGroup')
    }

    It 'implements staged discovery and Distributed Application population' {
        $outputPath = Join-Path $TestDrive 'discovery'
        & $script:BuildScript -PublicKeyToken '0123456789abcdef' -OutputPath $outputPath | Out-Null
        [xml]$discovery = Get-Content (Join-Path $outputPath 'HybridSolutionsCloud.HyperV.Discovery.xml') -Raw

        @($discovery.SelectNodes('/ManagementPack/Monitoring/Discoveries/Discovery')).Count | Should -Be 2
        $discovery.OuterXml | Should -Match 'HybridSolutionsCloud\.HyperV\.Service'
        $discovery.OuterXml | Should -Match 'Get-ClusterSharedVolume'
        $discovery.OuterXml | Should -Match 'Get-NetIntent'
        $discovery.OuterXml | Should -Not -Match '\$(?:data|target)\b(?!/)'
    }

    It 'implements health, collection, alert, task, and rollup workflows' {
        $outputPath = Join-Path $TestDrive 'monitoring'
        & $script:BuildScript -PublicKeyToken '0123456789abcdef' -OutputPath $outputPath | Out-Null
        [xml]$monitoring = Get-Content (Join-Path $outputPath 'HybridSolutionsCloud.HyperV.Monitoring.xml') -Raw

        @($monitoring.SelectNodes('/ManagementPack/Monitoring/Monitors/UnitMonitor')).Count | Should -Be 9
        @($monitoring.SelectNodes('/ManagementPack/Monitoring/Monitors/DependencyMonitor')).Count | Should -Be 10
        $rules = @($monitoring.SelectNodes('/ManagementPack/Monitoring/Rules/Rule'))
        $rules.Count | Should -Be 16
        @($rules | Where-Object Category -eq 'PerformanceCollection').Count | Should -Be 12
        @($rules | Where-Object Category -eq 'Alert').Count | Should -Be 4
        @($monitoring.SelectNodes('/ManagementPack/Monitoring/Tasks/Task')).Count | Should -Be 1
        @($monitoring.SelectNodes('/ManagementPack/LanguagePacks/LanguagePack/KnowledgeArticles/KnowledgeArticle')).Count | Should -Be 13
        @($monitoring.SelectNodes("//*[local-name()='section']") | Where-Object { @($_.SelectNodes("./*[local-name()='title']")).Count -ne 1 }).Count | Should -Be 0
        foreach ($unitMonitor in @($monitoring.SelectNodes('/ManagementPack/Monitoring/Monitors/UnitMonitor'))) {
            $healthStates = @($unitMonitor.OperationalStates.OperationalState.HealthState)
            @($healthStates | Sort-Object -Unique).Count | Should -Be $healthStates.Count
        }
    }

    It 'implements operator views for services, inventory, alerts, events, and performance' {
        $outputPath = Join-Path $TestDrive 'presentation'
        & $script:BuildScript -PublicKeyToken '0123456789abcdef' -OutputPath $outputPath | Out-Null
        [xml]$presentation = Get-Content (Join-Path $outputPath 'HybridSolutionsCloud.HyperV.Presentation.xml') -Raw

        @($presentation.SelectNodes('/ManagementPack/Presentation/Views/View')).Count | Should -Be 10
        @($presentation.SelectNodes('/ManagementPack/Presentation/Folders/Folder')).Count | Should -Be 4
        @($presentation.SelectNodes('/ManagementPack/Presentation/FolderItems/FolderItem')).Count | Should -Be 10
    }

    It 'renders separate customer-owned Discovery and Monitoring override MPs for every starter profile' {
        foreach ($tuningProfile in @('Lab', 'Standard', 'Strict')) {
            $outputPath = Join-Path $TestDrive "overrides-$tuningProfile"
            & $script:OverrideScript -TuningProfile $tuningProfile -OrganizationId Contoso -OrganizationName Contoso -Version '0.1.0.0' -PublicKeyToken '0123456789abcdef' -OutputPath $outputPath

            [xml]$discoveryOverrides = Get-Content (Join-Path $outputPath 'Contoso.HybridSolutionsCloud.HyperV.Discovery.Overrides.xml') -Raw
            [xml]$monitoringOverrides = Get-Content (Join-Path $outputPath 'Contoso.HybridSolutionsCloud.HyperV.Monitoring.Overrides.xml') -Raw
            @($discoveryOverrides.SelectNodes('/ManagementPack/Monitoring/Overrides/*')).Count | Should -BeGreaterThan 0
            @($monitoringOverrides.SelectNodes('/ManagementPack/Monitoring/Overrides/*')).Count | Should -BeGreaterThan 0
        }
    }
}
