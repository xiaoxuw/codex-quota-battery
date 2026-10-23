param([string]$Executable = (Join-Path $PSScriptRoot '../plugin/bin/CodexQuotaBattery.exe'))
$ErrorActionPreference = 'Stop'
function Start-Connection {
    $start = [System.Diagnostics.ProcessStartInfo]::new([System.IO.Path]::GetFullPath($Executable))
    $start.UseShellExecute = $false; $start.CreateNoWindow = $true
    $start.RedirectStandardInput = $true; $start.RedirectStandardOutput = $true; $start.RedirectStandardError = $true
    $start.ArgumentList.Add('--mcp')
    $p = [System.Diagnostics.Process]::Start($start)
    $p.StandardInput.WriteLine('{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26"}}')
    $read = $p.StandardOutput.ReadLineAsync()
    if (-not $read.Wait(5000) -or -not $read.Result) { $p.Kill($true); throw 'Handshake failed' }
    return $p
}
$a = $null; $b = $null
try {
    $a = Start-Connection
    $b = Start-Connection
    $a.StandardInput.Close()
    if (-not $a.WaitForExit(5000)) { throw 'First connection did not stop' }
    $statusPath = Join-Path $env:LOCALAPPDATA 'CodexQuotaBattery/status.json'
    $deadline = [DateTime]::UtcNow.AddSeconds(5)
    $takenOver = $false
    do {
        Start-Sleep -Milliseconds 100
        if (Test-Path -LiteralPath $statusPath) {
            try {
                $status = Get-Content -LiteralPath $statusPath -Raw | ConvertFrom-Json
                $takenOver = $status.processId -eq $b.Id
            } catch { }
        }
    } while (-not $takenOver -and [DateTime]::UtcNow -lt $deadline)
    if (-not $takenOver) { throw 'Surviving MCP instance never acquired the battery overlay' }
    $b.StandardInput.Close()
    if (-not $b.WaitForExit(5000)) { throw 'Second connection did not stop' }
    Write-Output "PASS: second MCP connection $($b.Id) took over after first connection EOF"
} finally {
    foreach ($p in @($a,$b)) { if ($null -ne $p) { if (-not $p.HasExited) { $p.Kill($true) }; $p.Dispose() } }
}
