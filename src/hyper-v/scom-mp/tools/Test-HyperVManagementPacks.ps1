#Requires -Version 7.0

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

    $profileRoot = Join-Path $sourceRoot 'templates/overrides'
    foreach ($profileName in @('lab', 'standard', 'strict')) {
        $profilePath = Join-Path $profileRoot $profileName
        $manifestPath = Join-Path $profilePath 'profile.json'
        Assert-True (Test-Path -LiteralPath $manifestPath -PathType Leaf) "Missing $profileName profile manifest."

        $profileManifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        Assert-True ($profileManifest.profile.ToLowerInvariant() -eq $profileName) "Profile name mismatch in $manifestPath"
        Assert-True ($profileManifest.status -eq 'AwaitingEvidence') "Profile must remain evidence-gated: $manifestPath"

        foreach ($kind in @('Discovery', 'Monitoring')) {
            $examplePath = Join-Path $profilePath "$kind.Overrides.xml.example"
            Assert-True (Test-Path -LiteralPath $examplePath -PathType Leaf) "Missing override example: $examplePath"
            $exampleText = Get-Content -LiteralPath $examplePath -Raw
            Assert-True ($exampleText -match '\{\{ORGANIZATION_ID\}\}') "Override example must retain the customer-owned ID placeholder: $examplePath"
            Assert-True ($exampleText -match '\{\{PUBLIC_KEY_TOKEN\}\}') "Override example must retain the signing-token placeholder: $examplePath"
            Assert-True (-not ($exampleText -match 'Default Management Pack')) "Override example references the Default Management Pack: $examplePath"
        }
    }

    Write-Output 'Hyper-V Management Pack contract tests passed.'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Assert-True ($tempRoot.StartsWith($expectedTempParent, [StringComparison]::OrdinalIgnoreCase)) 'Refusing to remove an unexpected path.'
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
