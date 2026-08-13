#Requires -Version 7.0
<#
.SYNOPSIS
    Verifies generated Hyper-V Management Packs with the Microsoft Operations Manager SDK.

.DESCRIPTION
    Loads each generated XML Management Pack through Microsoft.EnterpriseManagement.Core and
    executes TryVerify. Supply the official sealed dependency Management Packs exported from the
    target SCOM release. Any missing dependency, schema error, or verification error fails the run.

.PARAMETER InputPath
    Directory containing the generated Hyper-V Management Pack XML files.

.PARAMETER DependencyPath
    One or more directories containing the official sealed Microsoft dependency MPs.

.PARAMETER SdkAssemblyPath
    Path to Microsoft.EnterpriseManagement.Core.dll from the installed Management Pack tools.

.NOTES
    Author: Kristopher Turner
    Contact: kris@hybridsolutions.cloud
    Version: 1.0.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$InputPath,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string[]]$DependencyPath,

    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$SdkAssemblyPath = 'C:\Program Files\Microsoft System Center\Management Pack Tools\Microsoft.EnterpriseManagement.Core.dll'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -Path (Resolve-Path -LiteralPath $SdkAssemblyPath).Path

$resolvedInput = (Resolve-Path -LiteralPath $InputPath).Path
$storePaths = @($resolvedInput) + @($DependencyPath | ForEach-Object { (Resolve-Path -LiteralPath $_).Path })
$store = [Microsoft.EnterpriseManagement.Configuration.IO.ManagementPackFileStore]::new([string[]]$storePaths)
$artifactOrder = @(
    'HybridSolutionsCloud.HyperV.Library.xml',
    'HybridSolutionsCloud.HyperV.Discovery.xml',
    'HybridSolutionsCloud.HyperV.Monitoring.xml',
    'HybridSolutionsCloud.HyperV.Presentation.xml',
    'HybridSolutionsCloud.HyperV.Reporting.xml'
)

$verified = [System.Collections.Generic.List[string]]::new()
foreach ($artifactName in $artifactOrder) {
    $artifactPath = Join-Path $resolvedInput $artifactName
    if (-not (Test-Path -LiteralPath $artifactPath -PathType Leaf)) {
        continue
    }

    $managementPack = [Microsoft.EnterpriseManagement.Configuration.ManagementPack]::new($artifactPath, $store)
    $results = @($managementPack.TryVerify())
    $errors = @($results | Where-Object Category -eq 'Error')
    if ($errors.Count -gt 0) {
        $details = $errors | ForEach-Object { "[$($_.Code)] $($_.Message)" }
        throw "Microsoft SDK verification failed for '$artifactName':`n$($details -join "`n")"
    }

    $verified.Add($artifactName)
}

if ($verified.Count -eq 0) {
    throw "No Hyper-V Management Pack XML files were found in '$resolvedInput'."
}

Write-Output "Microsoft SDK verification passed for $($verified.Count) Hyper-V Management Pack artifact(s)."
