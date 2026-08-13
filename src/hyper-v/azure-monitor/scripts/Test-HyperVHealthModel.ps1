#Requires -Version 7.0

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$solutionRoot = Split-Path -Parent $PSScriptRoot
$mainTemplate = Join-Path $solutionRoot 'bicep/main.bicep'
$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) "hcs-hyperv-health-model-$([guid]::NewGuid().ToString('N'))"

try {
    New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null
    & az bicep build --file $mainTemplate --outfile (Join-Path $temporaryRoot 'main.json')
    if ($LASTEXITCODE -ne 0) { throw "Bicep build failed with exit code $LASTEXITCODE." }

    $source = Get-ChildItem -Path $solutionRoot -Recurse -File |
        ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }
    $allSource = $source -join "`n"
    foreach ($requiredText in @(
        'Microsoft.ScVmm/vmmServers',
        'Microsoft.HybridCompute/machines',
        'Microsoft-WindowsEvent',
        'Heartbeat',
        'Hyper-V Hypervisor Logical Processor',
        'monitoring-pipeline-component'
    )) {
        if ($allSource -notmatch [regex]::Escape($requiredText)) { throw "Required Hyper-V contract text is missing: $requiredText" }
    }

    foreach ($prohibitedText in @( ('HybridSolutionsCloud.' + 'AzureLocal'), ('client' + 'Secret'), ('tenant' + 'Id =') )) {
        if ($allSource -match [regex]::Escape($prohibitedText)) { throw "Prohibited Hyper-V content detected: $prohibitedText" }
    }

    Get-Content -LiteralPath (Join-Path $solutionRoot 'workbooks/hyper-v-health.workbook.json') -Raw |
        ConvertFrom-Json | Out-Null
    Write-Output 'Hyper-V Azure Monitor Health Model contract tests passed.'
}
finally {
    if (Test-Path -LiteralPath $temporaryRoot) { Remove-Item -LiteralPath $temporaryRoot -Recurse -Force }
}
