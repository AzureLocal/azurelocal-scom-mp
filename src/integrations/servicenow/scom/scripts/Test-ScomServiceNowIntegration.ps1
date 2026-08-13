#Requires -Version 7.0

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$integrationRoot = Split-Path -Parent $PSScriptRoot
$repositoryRoot = (Resolve-Path (Join-Path $integrationRoot '../../../..')).Path

function Assert-Contract {
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

$profiles = Get-ChildItem -Path (Join-Path $integrationRoot 'config') -Filter '*.connector-profile.json'
Assert-Contract ($profiles.Count -eq 2) 'Exactly two product-specific connector profiles are required.'

foreach ($profileFile in $profiles) {
    $connectorProfile = Get-Content -LiteralPath $profileFile.FullName -Raw | ConvertFrom-Json
    Assert-Contract ($connectorProfile.status -eq 'DevelopmentBaseline') "Profile must remain a development baseline: $($profileFile.Name)"
    Assert-Contract ($connectorProfile.connectorDefinition -eq 'SCOM') "Only the SCOM Events connector belongs in this profile: $($profileFile.Name)"
    Assert-Contract ($connectorProfile.collectionDirection -eq 'Pull') "Initial direction must be Pull: $($profileFile.Name)"
    Assert-Contract (-not $connectorProfile.bidirectionalEnabled) "Bidirectional integration must start disabled: $($profileFile.Name)"
    Assert-Contract (-not $connectorProfile.containsCredentials) "Profiles must not contain credentials: $($profileFile.Name)"
    Assert-Contract (-not $connectorProfile.connectorParameters.debugEnabled) "Debug logging must default off: $($profileFile.Name)"
    Assert-Contract (-not $connectorProfile.connectorParameters.rawPayloadLoggingEnabled) "Raw payload logging must default off: $($profileFile.Name)"
    Assert-Contract ($connectorProfile.allowList.managementPackPrefixes.Count -eq 1) "Each profile needs one product allow-list: $($profileFile.Name)"
}

$mapping = Get-Content -LiteralPath (Join-Path $integrationRoot 'mappings/scom-event-contract.json') -Raw | ConvertFrom-Json
Assert-Contract ($mapping.identity.sourceEventId -eq 'AlertId') 'SCOM AlertId must be the source event identity.'
Assert-Contract ($mapping.lifecycle.replay -eq 'IdempotentByAlertId') 'Replay must be idempotent by AlertId.'
Assert-Contract ($mapping.fields.Where({ $_.required }).Count -ge 8) 'The event contract must define the required normalized context.'

$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) "hcs-scom-servicenow-$([guid]::NewGuid().ToString('N'))"
try {
    $developmentKey = ('0' * 16)
    & (Join-Path $repositoryRoot 'src/azure-local/scom-mp/tools/Build-AzureLocalManagementPacks.ps1') -PublicKeyToken $developmentKey -OutputPath (Join-Path $temporaryRoot 'azure-local') | Out-Null
    & (Join-Path $repositoryRoot 'src/hyper-v/scom-mp/tools/Build-HyperVManagementPacks.ps1') -PublicKeyToken $developmentKey -OutputPath (Join-Path $temporaryRoot 'hyper-v') | Out-Null

    foreach ($monitoringFile in Get-ChildItem -Path $temporaryRoot -Recurse -Filter '*Monitoring*.xml') {
        [xml]$managementPack = Get-Content -LiteralPath $monitoringFile.FullName -Raw
        $monitorAlerts = @($managementPack.SelectNodes('//UnitMonitor/AlertSettings'))
        Assert-Contract ($monitorAlerts.Count -gt 0) "Monitoring MP has no stateful alerts: $($monitoringFile.FullName)"
        Assert-Contract (@($monitorAlerts | Where-Object AutoResolve -ne 'true').Count -eq 0) "Every forwarded monitor alert must auto-resolve: $($monitoringFile.FullName)"

        $eventRules = @($managementPack.SelectNodes('//Rule[Category="Alert"]'))
        Assert-Contract ($eventRules.Count -gt 0) "Monitoring MP has no event alert rules: $($monitoringFile.FullName)"
        foreach ($eventRule in $eventRules) {
            Assert-Contract ($null -ne $eventRule.SelectSingleNode('.//Suppression/SuppressionValue')) "Event alert lacks a suppression key: $($eventRule.ID)"
            Assert-Contract ($null -ne $managementPack.SelectSingleNode("//DisplayString[@ElementID='$($eventRule.ID)']")) "Event alert lacks public localization: $($eventRule.ID)"
        }
    }
}
finally {
    if (Test-Path -LiteralPath $temporaryRoot) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
}

$allIntegrationText = Get-ChildItem -Path $integrationRoot -Recurse -File |
    ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw } |
    Join-String -Separator "`n"
$secretPatterns = @(
    ('pass' + 'word\s*[:=]\s*[^<\s]'),
    ('client_' + 'secret'),
    ('-----BEGIN .* ' + 'PRIVATE KEY-----')
)
foreach ($secretPattern in $secretPatterns) {
    Assert-Contract ($allIntegrationText -notmatch $secretPattern) "Potential secret material detected by pattern: $secretPattern"
}

Write-Output 'SCOM to ServiceNow integration contract tests passed.'
