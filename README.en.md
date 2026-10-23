# Codex Quota Battery

Transparent quota batteries and reset-credit stock beside the Help menu in Windows Codex Desktop.

[中文](README.md) · [Download](https://github.com/xiaoxuw/codex-quota-battery/releases/latest) · MIT

![Normal, low-quota, dark and unknown states](docs/images/quota-battery-preview.png)

The numbers above are synthetic examples, not live account readings.

## What it shows

- Five-hour and weekly **remaining account quota**, with centered percentages and proportional fill.
- Green above20%, amber at20% or less, red at10% or less.
- Available reset-credit inventory. The app never consumes credits.
- Reset times and refresh timestamps on hover.

The app reads the official local Codex App Server `account/rateLimits/read` endpoint every60seconds. Remaining quota is `100 - usedPercent`. It updates as your account quota changes, subject to polling and server delay. This is not a per-token counter or conversation context meter. Failed reads keep the last value visibly marked stale; missing values show `--`.

## Install

1. Download `CodexQuotaBattery-v1.1.1-win-x64.zip` from [Releases](https://github.com/xiaoxuw/codex-quota-battery/releases/latest).
2. Extract into a permanent folder. Keep the full folder, not just the EXE.
3. Run `powershell -File .\install-plugin.ps1` in that folder.
4. Fully restart Codex once to load the plugin.

Requires Windows10/11 x64, the official Codex desktop app, ChatGPT account login and the `codex` command. The release bundles the .NET runtime. Plugin ID: `codex-quota-battery@codex-quota-tools`. Disable or uninstall using Codex plugin settings.

Codex manages the local STDIO MCP process. It exits when the connection closes or the last Codex window closes, with a short window-recreation grace period. Minimizing hides the overlay. No Windows-login watcher, binary patching or shortcut changes.

## Build and verify

Requires .NET10 SDK on Windows:

```powershell
powershell -File .\build-batteries.ps1
powershell -File .\install-plugin.ps1
.\dist\CodexQuotaBattery.exe --quota-test quota-tests.json
.\dist\CodexQuotaBattery.exe --self-test .\fixtures
pwsh -File .\tests\verify-plugin.ps1
pwsh -File .\tests\verify-mcp-failover.ps1
```

34 feature checks and297 upstream checks pass. Installed-process tests cover MCP handshake, read-only status, shutdown on STDIO EOF and ownership takeover between connections. Explicitly wait for WinExe process completion when scripting tests.

## Limits and privacy

This is a separate transparent overlay managed through Codex local plugins, not an official toolbar-extension API. The current custom titlebar fallback uses measured, DPI-scaled Help-menu positioning. Future UI changes may need adaptation; narrow windows hide the overlay. Validate loading in your client after installation.

The quota entry point does not read credential files or chat content and does not invoke inference models. It asks the official executable to use its existing authentication. Local status is stored under `%LOCALAPPDATA%\CodexQuotaBattery`; do not publish real account snapshots or local logs.

## Attribution

Derived from [dongyue-19/codex-statusbar](https://github.com/dongyue-19/codex-statusbar), baseline `17f0ddd25512b9a823b56a37da325d36ca53971f`. Reuses Codex identity checks, window sampling and transparent overlay foundations. Original token-strip sources remain as reference; the published entry point runs quota batteries.

Preserves [LICENSE](LICENSE), [LICENSE-codex-token-overlay](LICENSE-codex-token-overlay) and [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md). Independent community project; not affiliated with or endorsed by OpenAI.
