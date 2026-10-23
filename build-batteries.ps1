param([string]$DotNetPath, [string]$OutputDirectory = (Join-Path $PSScriptRoot 'dist'))
$ErrorActionPreference = 'Stop'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = '1'
if (-not $DotNetPath) {
    $candidate = Join-Path $env:USERPROFILE '.cache/codex-dotnet/sdk/dotnet.exe'
    $DotNetPath = if (Test-Path -LiteralPath $candidate) { $candidate } else { 'dotnet' }
}
$project = Join-Path $PSScriptRoot 'src/CodexStatusbar/CodexStatusbar.csproj'
& $DotNetPath publish $project -c Release -r win-x64 --self-contained true --nologo -o $OutputDirectory
if ($LASTEXITCODE -ne 0) { throw "Publish failed ($LASTEXITCODE)" }
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'LICENSE') -Destination $OutputDirectory
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'LICENSE-codex-token-overlay') -Destination $OutputDirectory
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'THIRD-PARTY-NOTICES.md') -Destination $OutputDirectory
Copy-Item -LiteralPath (Join-Path $PSScriptRoot '使用说明.md') -Destination $OutputDirectory
$exe = Join-Path $OutputDirectory 'CodexQuotaBattery.exe'
$hash = (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash
Set-Content -LiteralPath (Join-Path $OutputDirectory 'SHA256.txt') -Value "$hash  CodexQuotaBattery.exe" -Encoding ascii
Write-Output $exe
Write-Output "SHA256 $hash"
$plugin = Join-Path $PSScriptRoot 'plugin'
$pluginBin = Join-Path $plugin 'bin'
New-Item -ItemType Directory -Path $pluginBin -Force | Out-Null
Copy-Item -LiteralPath $exe -Destination $pluginBin -Force
foreach ($name in @('LICENSE','LICENSE-codex-token-overlay','THIRD-PARTY-NOTICES.md','使用说明.md')) {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination $plugin -Force
}
