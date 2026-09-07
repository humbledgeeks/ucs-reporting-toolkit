# AsBuiltReport.Cisco.UcsManager (e360, v0.3.0)

A PowerShell module to generate an As-Built Report of a **Cisco UCS Manager**
domain (Fabric Interconnects, chassis, blades/rack servers, LAN/SAN, pools,
policies, service profiles, firmware, faults, licensing) in Word/HTML/Text via
PScribo.

This is a **revival** of the abandoned upstream module
(`AsBuiltReport.Cisco.UcsManager` 0.2.1, last updated June 2019, delisted from the
PowerShell Gallery). The proven 2019 report logic is preserved; the framework
wiring was modernized for PowerShell 7 / Core. See "What changed" below.

> Status: builds and is wired to run, but has **not** been executed against a live
> UCS Manager during this revival. Treat the first run against your FI as the
> validation pass — see "First-run checklist."

## Platform: WINDOWS ONLY

Cisco UCS PowerTool (`Cisco.UCSManager`) is built on .NET Framework 4.5 and does
**not** load on macOS/Linux PowerShell (which runs on .NET Core) — confirmed by
Cisco. The `Cisco.Ucs.Common.Cmdlets` assembly fails to load there. Run this
report on **Windows**: Windows PowerShell 5.1 (recommended) or PowerShell 7 on
Windows. It cannot run on a Mac.

## Requirements

- Windows host (VM or physical)
- Windows PowerShell 5.1, or PowerShell 7 on Windows
- `AsBuiltReport.Core` 1.3.0+ (supports 5.1 and 7)
- `Cisco.UCSManager` 3.0.0+ (Cisco UCS PowerTool; install with `-AcceptLicense`)
- Network reachability from the Windows host to the UCSM cluster VIP
- A UCS Manager account — **read-only is sufficient**; do not use admin

## Install (on the Windows host)

First install the dependencies:

```powershell
Install-Module AsBuiltReport.Core -Scope CurrentUser -AllowClobber
Install-Module Cisco.UCSManager   -Scope CurrentUser -AllowClobber -AcceptLicense
```

Then copy this module folder into a PowerShell module path so
`New-AsBuiltReport` can discover it:

```powershell
# Windows PowerShell 5.1 module path:
$dest = "$HOME\Documents\WindowsPowerShell\Modules\AsBuiltReport.Cisco.UcsManager"
# (PowerShell 7 on Windows: use $HOME\Documents\PowerShell\Modules\ instead)
New-Item -ItemType Directory -Path $dest -Force
Copy-Item -Recurse -Force .\AsBuiltReport.Cisco.UcsManager\* $dest
Import-Module AsBuiltReport.Cisco.UcsManager -Force
Get-Module AsBuiltReport.Cisco.UcsManager    # confirm it loaded
```

## Step 0 — Prove the connection FIRST (30 seconds)

Before generating a report, confirm UCS PowerTool can reach and authenticate to
your FI from this machine. If this fails, the report will fail too.

```powershell
Import-Module Cisco.UCSManager
Set-UcsPowerToolConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$ucs = Connect-Ucs -Name <fi-cluster-vip> -Credential (Get-Credential)
Get-UcsChassis; Get-UcsBlade | Select-Object Serial, Model, Dn
Disconnect-Ucs -Ucs $ucs
```

If that returns your chassis/blades, you're clear to generate the report.

## Generate the As-Built

```powershell
$cred = Get-Credential
New-AsBuiltReport `
  -Report Cisco.UcsManager `
  -Target <fi-cluster-vip> `
  -Credential $cred `
  -Format Html,Word `
  -OutputFolderPath "$HOME/AsBuiltReports" `
  -Verbose
```

`-Target` is the UCS Manager **cluster VIP** (the address you point UCSM at), not
an individual fabric interconnect. Multiple domains: pass a comma-separated
`-Target`.

## e360 branding

The cover-page logo lives in `AsBuiltReport.Cisco.UcsManager.Style.ps1`. Paste the
Base64 of your e360 PNG into the `$e360LogoBase64` variable there:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME/logos/e360-logo.png")) | Set-Clipboard
```

PScribo image embedding uses `System.Drawing`, which is Windows-only, so the logo
renders when the report is generated on **Windows**. On macOS the report still
builds; the logo is skipped with a warning. Colours are already Cisco/e360 blue
(`004BAF` / `049FD9`) — adjust in the Style file to match the e360 brand guide.

## What changed (0.2.1 -> 0.3.0)

- **Editions:** manifest set to `CompatiblePSEditions = Core, Desktop`,
  `PowerShellVersion = 5.1` — runs on Windows PowerShell 5.1 (where UCS PowerTool
  is fully supported) and PowerShell 7 on Windows. (UCS PowerTool's .NET Framework
  assemblies do not load on macOS/Linux PowerShell.)
- **Declared the real dependency:** `Cisco.UCSManager` (UCS PowerTool) is now a
  `RequiredModule`; the 2019 manifest never declared it.
- **Bug fix — health checks now actually run:** the 2019 code referenced
  `$HealthCheck` but never assigned it from `$ReportConfig.HealthCheck`, so every
  health-state red-flag (FI state, PSU/fan/thermal, HA-ready, chassis) silently
  never fired. Wired up.
- **Bug fix — certificate handling:** UCS FIs use a self-signed cert; on
  PowerShell 7 `Connect-Ucs` fails validation by default. Added
  `Set-UcsPowerToolConfiguration -InvalidCertificateAction Ignore` and
  multiple-default support before connecting — the most likely first-run failure,
  pre-empted.
- **Styling handed to the framework:** removed the manual style dot-sourcing and
  the `$StylePath` parameter; AsBuiltReport.Core loads this module's `.Style.ps1`
  automatically, or you override with `New-AsBuiltReport -StyleFilePath`.
- **Loader:** `psm1` now also dot-sources `Src/Private` for future refactoring.

The 2,700-line report body (sections/tables) is **unchanged** from 0.2.1 on
purpose — that logic is proven, and rewriting it blind (without a live FI to test
against) would add risk, not value.

## First-run checklist (do these against your FI, in order)

1. Run **Step 0** connectivity test. Fix any connect/cert/auth error there first.
2. `Import-Module AsBuiltReport.Cisco.UcsManager -Force` — resolve any load error
   (usually a missing `AsBuiltReport.Core` or `Cisco.UCSManager`).
3. Generate with `-Format Html` only first (fastest) and `-Verbose`.
4. Expect some section/attribute errors — UCSM property names can differ across
   UCSM versions since 2019. Capture the `-Verbose` output; each error points to a
   specific `Get-Ucs*` property to adjust. That is the iteration loop.
5. Once HTML is clean, add `-Format Word` and the e360 logo (on Windows).

## Deferred improvements (do these with the FI in hand)

- Decompose the monolith into `Get-Abr*` private functions (modern convention,
  easier maintenance) — safe to do once we can re-test each section live.
- Add coverage for newer UCSM features not present in 2019.
- Proper `try/finally` around the report body to guarantee `Disconnect-Ucs` on
  error.

## Attribution / license

Original author Tim Carman (@tpcarman). MIT License (retained). Revived and
modernized for e360 by HumbledGeeks, 2026.
