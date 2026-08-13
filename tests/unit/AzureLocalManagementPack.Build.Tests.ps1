#Requires -Version 7.0
<#
.SYNOPSIS
    Tests the Azure Local SCOM Management Pack development build.

.DESCRIPTION
    Validates product boundaries, local topology, workflows, Distributed Application rollups,
    presentation, and customer-owned override generation.

.NOTES
    Author: Kristopher Turner
    Contact: kris@hybridsolutions.cloud
    Version: 1.0.0
#>

BeforeAll {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    $script:RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
    $script:SourceRoot = Join-Path $script:RepositoryRoot 'src/azure-local/scom-mp'
    $script:BuildScript = Join-Path $script:SourceRoot 'tools/Build-AzureLocalManagementPacks.ps1'
    $script:ContractScript = Join-Path $script:SourceRoot 'tools/Test-AzureLocalManagementPacks.ps1'
    $script:OverrideScript = Join-Path $script:SourceRoot 'tools/New-AzureLocalOverrideManagementPacks.ps1'
}

Describe 'Azure Local Management Pack development build' {
    It 'passes the repository contract suite' {
        (& $script:ContractScript) | Should -Contain 'Azure Local Management Pack contract tests passed.'
    }

    It 'generates the five intended product projects without release claims' {
        $inventoryPath = & $script:BuildScript -Version '0.1.0.0' -PublicKeyToken '0123456789abcdef' -OutputPath $TestDrive -IncludeReporting
        $inventory = Get-Content -LiteralPath $inventoryPath -Raw | ConvertFrom-Json
        $inventory.artifacts.Count | Should -Be 5
        $inventory.releaseReady | Should -BeFalse
        $inventory.artifacts.id | Should -Contain 'HybridSolutionsCloud.AzureLocal.Library'
        $inventory.artifacts.id | Should -Contain 'HybridSolutionsCloud.AzureLocal.Discovery'
        $inventory.artifacts.id | Should -Contain 'HybridSolutionsCloud.AzureLocal.Monitoring'
        $inventory.artifacts.id | Should -Contain 'HybridSolutionsCloud.AzureLocal.Presentation'
        $inventory.artifacts.id | Should -Contain 'HybridSolutionsCloud.AzureLocal.Reporting'
    }

    It 'rejects an invalid public key token' {
        { & $script:BuildScript -PublicKeyToken 'not-a-token' -OutputPath $TestDrive } | Should -Throw
    }

    It 'implements independent Azure Local topology and DA identity' {
        $output = Join-Path $TestDrive 'topology'
        & $script:BuildScript -PublicKeyToken '0123456789abcdef' -OutputPath $output | Out-Null
        [xml]$library = Get-Content -LiteralPath (Join-Path $output 'HybridSolutionsCloud.AzureLocal.Library.xml') -Raw
        @($library.SelectNodes('/ManagementPack/TypeDefinitions/EntityTypes/ClassTypes/ClassType')).Count | Should -Be 17
        @($library.SelectNodes('/ManagementPack/TypeDefinitions/EntityTypes/RelationshipTypes/RelationshipType')).Count | Should -Be 28
        $library.OuterXml | Should -Not -Match 'HybridSolutionsCloud\.HyperV'
    }

    It 'implements local health, collection, alerts, tasks, and DA rollup' {
        $output = Join-Path $TestDrive 'monitoring'
        & $script:BuildScript -PublicKeyToken '0123456789abcdef' -OutputPath $output | Out-Null
        [xml]$monitoring = Get-Content -LiteralPath (Join-Path $output 'HybridSolutionsCloud.AzureLocal.Monitoring.xml') -Raw
        @($monitoring.SelectNodes('/ManagementPack/Monitoring/Monitors/UnitMonitor')).Count | Should -Be 14
        @($monitoring.SelectNodes('/ManagementPack/Monitoring/Monitors/AggregateMonitor')).Count | Should -Be 6
        @($monitoring.SelectNodes('/ManagementPack/Monitoring/Monitors/DependencyMonitor')).Count | Should -Be 12
        @($monitoring.SelectNodes('/ManagementPack/Monitoring/Rules/Rule')).Count | Should -Be 16
        @($monitoring.SelectNodes('/ManagementPack/Monitoring/Tasks/Task')).Count | Should -Be 1
    }

    It 'implements operator views for service health, inventory, alerts, events, and performance' {
        $output = Join-Path $TestDrive 'presentation'
        & $script:BuildScript -PublicKeyToken '0123456789abcdef' -OutputPath $output | Out-Null
        [xml]$presentation = Get-Content -LiteralPath (Join-Path $output 'HybridSolutionsCloud.AzureLocal.Presentation.xml') -Raw
        @($presentation.SelectNodes('/ManagementPack/Presentation/Views/View')).Count | Should -Be 14
        @($presentation.SelectNodes('/ManagementPack/Presentation/Folders/Folder')).Count | Should -Be 4
    }

    It 'renders separate customer-owned Discovery and Monitoring override MPs for every starter profile' {
        foreach ($profileName in @('Lab','Standard','Strict')) {
            $output = Join-Path $TestDrive "overrides-$profileName"
            & $script:OverrideScript -TuningProfile $profileName -OrganizationId Contoso -OrganizationName Contoso -Version '0.1.0.0' -PublicKeyToken '0123456789abcdef' -OutputPath $output
            [xml]$discovery = Get-Content -LiteralPath (Join-Path $output 'Contoso.HybridSolutionsCloud.AzureLocal.Discovery.Overrides.xml') -Raw
            [xml]$monitoring = Get-Content -LiteralPath (Join-Path $output 'Contoso.HybridSolutionsCloud.AzureLocal.Monitoring.Overrides.xml') -Raw
            @($discovery.SelectNodes('/ManagementPack/Monitoring/Overrides/*')).Count | Should -BeGreaterThan 0
            @($monitoring.SelectNodes('/ManagementPack/Monitoring/Overrides/*')).Count | Should -BeGreaterThan 0
        }
    }
}
