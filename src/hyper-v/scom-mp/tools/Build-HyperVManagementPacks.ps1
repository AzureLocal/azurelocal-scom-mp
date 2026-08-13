#Requires -Version 7.0

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

$sourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$manifestPath = Join-Path $sourceRoot 'build/build-manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

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
