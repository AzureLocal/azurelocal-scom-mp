#Requires -Version 7.0

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$solutionRoot = Split-Path -Parent $PSScriptRoot
$bicepRoot = Join-Path $solutionRoot 'bicep'
$mainTemplate = Join-Path $bicepRoot 'main.bicep'
$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) "hcs-azure-local-health-model-$([guid]::NewGuid().ToString('N'))"

try {
    New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null

    $bicepCommand = Get-Command bicep -ErrorAction SilentlyContinue
    if ($null -ne $bicepCommand) {
        & $bicepCommand.Source build $mainTemplate --outfile (Join-Path $temporaryRoot 'main.json')
    }
    elseif (Get-Command az -ErrorAction SilentlyContinue) {
        & az bicep build --file $mainTemplate --outfile (Join-Path $temporaryRoot 'main.json')
    }
    else {
        throw 'Bicep CLI or Azure CLI with Bicep is required.'
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Bicep build failed with exit code $LASTEXITCODE."
    }

    $source = Get-ChildItem -Path $solutionRoot -Recurse -File |
        Where-Object { $_.Extension -in @('.bicep', '.bicepparam', '.json', '.kql', '.md', '.ps1') } |
        ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }
    $allSource = $source -join "`n"

    foreach ($requiredText in @(
        'Microsoft.Monitor/accounts/healthmodels@2025-05-03-preview',
        'Microsoft.Monitor/accounts/healthmodels/entities@2025-05-03-preview',
        'Microsoft.Monitor/accounts/healthmodels/relationships@2025-05-03-preview',
        'SystemAssigned',
        'Percentage CPU',
        'Cluster node Storage Degraded',
        'monitoring-pipeline-component'
    )) {
        if ($allSource -notmatch [regex]::Escape($requiredText)) {
            throw "Required Azure Local Health Model contract text is missing: $requiredText"
        }
    }

    $prohibitedValues = @(
        ('HybridSolutionsCloud.' + 'HyperV'),
        ('client' + 'Secret'),
        ('tenant' + 'Id ='),
        ('subscription' + 'Id =')
    )
    foreach ($prohibitedText in $prohibitedValues) {
        if ($allSource -match [regex]::Escape($prohibitedText)) {
            throw "Prohibited Azure Local Health Model content detected: $prohibitedText"
        }
    }

    Get-Content -LiteralPath (Join-Path $solutionRoot 'workbooks/azure-local-health.workbook.json') -Raw |
        ConvertFrom-Json | Out-Null

    Write-Output 'Azure Local Azure Monitor Health Model contract tests passed.'
}
finally {
    if (Test-Path -LiteralPath $temporaryRoot) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
}
