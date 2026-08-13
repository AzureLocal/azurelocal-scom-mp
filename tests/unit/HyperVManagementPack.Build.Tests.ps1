#Requires -Version 7.0

BeforeAll {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    $script:RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
    $script:SourceRoot = Join-Path $script:RepositoryRoot 'src/hyper-v/scom-mp'
    $script:BuildScript = Join-Path $script:SourceRoot 'tools/Build-HyperVManagementPacks.ps1'
    $script:ContractScript = Join-Path $script:SourceRoot 'tools/Test-HyperVManagementPacks.ps1'
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
}
