$ErrorActionPreference = 'Stop'
$pluginExe = Join-Path $PSScriptRoot 'plugin/bin/CodexQuotaBattery.exe'
if (-not (Test-Path -LiteralPath $pluginExe)) { throw 'Run build-batteries.ps1 first.' }
$backup = Join-Path $env:USERPROFILE ('.codex/backups/quota-plugin-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
$config = Join-Path $env:USERPROFILE '.codex/config.toml'
if (Test-Path -LiteralPath $config) { Copy-Item -LiteralPath $config -Destination (Join-Path $backup 'config.before.toml') }
& codex plugin marketplace add $PSScriptRoot --json
if ($LASTEXITCODE -ne 0) { throw 'Local marketplace registration failed.' }
& codex plugin add 'codex-quota-battery@codex-quota-tools' --json
if ($LASTEXITCODE -ne 0) { throw 'Plugin installation failed.' }
# Remove only this utility's legacy login item. Codex owns plugin startup now.
$migration = Start-Process -FilePath $pluginExe -ArgumentList '--disable-startup' -WindowStyle Hidden -PassThru -Wait
if ($migration.ExitCode -ne 0) { throw 'Could not remove the legacy utility startup item.' }
$migration.Dispose()
Write-Output 'Installed. Restart Codex once to load the native plugin process.'
