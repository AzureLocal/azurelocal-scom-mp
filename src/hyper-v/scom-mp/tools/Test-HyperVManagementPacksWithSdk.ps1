#Requires -Version 7.0
<#
.SYNOPSIS
    Verifies generated Hyper-V Management Packs with Microsoft VSAE and the Operations Manager SDK.

.DESCRIPTION
    Runs the VSAE VerifyMergedManagementPack task in Visual Studio 2022's full-framework MSBuild
    host. This is required because sealed SCOM dependency MPs are CLR-v2 assemblies and cannot be
    loaded reliably inside the PowerShell 7 runtime. Any missing dependency, schema error, or
    verification error fails the run.

    Supply the official sealed dependency MPs from the target SCOM release. Downstream product
    artifacts additionally require the already sealed product MPs they reference in InputPath.

.PARAMETER InputPath
    Directory containing generated Hyper-V Management Pack XML and sealed product MP files.

.PARAMETER DependencyPath
    One or more directories containing official sealed Microsoft dependency MPs.

.PARAMETER MsBuildPath
    Optional explicit path to Visual Studio 2022 MSBuild.exe. When omitted, vswhere resolves it.

.PARAMETER VsacTasksPath
    Path to Microsoft.SystemCenter.Authoring.Build.dll installed by VSAE.

.NOTES
    Author: Kristopher Turner
    Contact: kris@hybridsolutions.cloud
    Version: 1.1.0
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
    [ValidateScript({ [string]::IsNullOrWhiteSpace($_) -or (Test-Path -LiteralPath $_ -PathType Leaf) })]
    [string]$MsBuildPath,

    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$VsacTasksPath = 'C:\Program Files (x86)\MSBuild\Microsoft\VSAC\Microsoft.SystemCenter.Authoring.Build.dll'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($MsBuildPath)) {
    $vswherePath = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -LiteralPath $vswherePath -PathType Leaf)) {
        throw 'Visual Studio Installer vswhere.exe was not found. Supply -MsBuildPath explicitly.'
    }

    $installationPath = (& $vswherePath -latest -products * -version '[17.0,18.0)' -requires Microsoft.Component.MSBuild -property installationPath | Select-Object -First 1)
    if ([string]::IsNullOrWhiteSpace($installationPath)) {
        throw 'A complete Visual Studio 2022 installation with MSBuild was not found.'
    }

    $MsBuildPath = Join-Path $installationPath 'MSBuild\Current\Bin\MSBuild.exe'
}

if (-not (Test-Path -LiteralPath $MsBuildPath -PathType Leaf)) {
    throw "MSBuild was not found at '$MsBuildPath'."
}

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
$verificationProject = Join-Path $repositoryRoot 'tools/scom/VerifyManagementPack.proj'
$resolvedInput = (Resolve-Path -LiteralPath $InputPath).Path
$referenceFiles = @(
    $DependencyPath | ForEach-Object {
        Get-ChildItem -LiteralPath (Resolve-Path -LiteralPath $_).Path -Filter '*.mp' -File -Recurse
    }
    Get-ChildItem -LiteralPath $resolvedInput -Filter '*.mp' -File
) | Sort-Object FullName -Unique

if ($referenceFiles.Count -eq 0) {
    throw 'No sealed dependency MP files were found.'
}

$verificationWorkingPath = Join-Path $resolvedInput 'obj/sdk-verify'
$referenceListPath = Join-Path $verificationWorkingPath 'reference-files.txt'
New-Item -ItemType Directory -Path $verificationWorkingPath -Force | Out-Null
[System.IO.File]::WriteAllLines($referenceListPath, [string[]]$referenceFiles.FullName)
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

    $arguments = @(
        $verificationProject,
        '/nologo',
        '/t:Verify',
        '/verbosity:minimal',
        "/p:VerificationTargetFile=$artifactPath",
        "/p:ReferenceListPath=$referenceListPath",
        "/p:VsacTasksPath=$VsacTasksPath",
        "/p:VerificationWorkingPath=$verificationWorkingPath\"
    )

    $output = @(& $MsBuildPath @arguments 2>&1)
    $output | Write-Output
    if ($LASTEXITCODE -ne 0) {
        throw "Microsoft VSAE/SDK verification failed for '$artifactName'."
    }

    $verified.Add($artifactName)
}

if ($verified.Count -eq 0) {
    throw "No Hyper-V Management Pack XML files were found in '$resolvedInput'."
}

Write-Output "Microsoft VSAE/SDK verification passed for $($verified.Count) Hyper-V Management Pack artifact(s)."
