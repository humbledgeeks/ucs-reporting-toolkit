# Cisco UCS Reporting Toolkit

Tooling for documenting **Cisco UCS Manager** domains:

| Tool | What it produces | Use it for |
|------|------------------|-----------|
| **AsBuiltReport.Cisco.UcsManager** | A formatted **Word / HTML** As-Built document (config of FIs, chassis, blades, LAN/SAN, pools, policies, service profiles, firmware, licensing) | Hand-off docs, audits, change records, archiving |

> The community "UCS Health Check" HTML dashboard script that earlier versions of this toolkit bundled is no
> longer included: its upstream reuse terms could not be established, so it is not redistributed here.

---

## ⚠️ Platform: Windows only

The module depends on **Cisco UCS PowerTool** (`Cisco.UCSManager`), which is built on **.NET Framework 4.5**. It does **not** load on macOS/Linux PowerShell (which runs on .NET Core) — the `Cisco.Ucs.Common.Cmdlets` assembly fails to load there. Run everything on **Windows**: Windows PowerShell 5.1 (built in) or PowerShell 7 on Windows.

Requirements:
- A Windows host that can reach the UCS Manager **cluster VIP** on TCP 443
- A UCS Manager account — **read-only is sufficient**; you do not need admin
- Internet access on the host (to install modules)

---

## 1. Install PowerShell

Windows PowerShell **5.1** ships with Windows and works for everything here. To also get **PowerShell 7** (recommended):

```powershell
# Option A: winget (Windows 10/11)
winget install --id Microsoft.PowerShell --accept-package-agreements --accept-source-agreements

# Option B: Microsoft's install script (any Windows)
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"
```

Check your version:
```powershell
$PSVersionTable.PSVersion
```

---

## 2. Install the modules

Run in an **Administrator** PowerShell window.

> Windows PowerShell 5.1 note: if `-AcceptLicense` errors with "parameter cannot be found," update the package manager first, then **open a new window**:
> ```powershell
> [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
> Install-Module PowerShellGet -Force -AllowClobber -Scope CurrentUser
> ```
> PowerShell 7 does not need this.

Install the framework and UCS PowerTool from the PowerShell Gallery:

```powershell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module AsBuiltReport.Core -Scope CurrentUser -AllowClobber -Force
Install-Module Cisco.UCSManager   -Scope CurrentUser -AllowClobber -AcceptLicense -Force
```

Install the **As-Built module** from this repo (it is not on the Gallery). From the `cisco/` folder:

```powershell
# PowerShell 7 module path (use \WindowsPowerShell\ for PS 5.1)
Copy-Item -Recurse -Force .\AsBuiltReport.Cisco.UcsManager "$HOME\Documents\PowerShell\Modules\"
Import-Module AsBuiltReport.Cisco.UcsManager -Force
(Get-Module AsBuiltReport.Cisco.UcsManager).Version   # confirm it loaded
```

Verify everything is present:
```powershell
Get-Module -ListAvailable AsBuiltReport.*, Cisco.UCSManager | Select-Object Name, Version
```

---

## 3. Run the As-Built report

```powershell
$cred = Get-Credential            # read-only UCSM account
New-Item -ItemType Directory C:\AsBuiltReports -Force
New-AsBuiltReport -Report Cisco.UcsManager `
  -Target <FI-CLUSTER-VIP> `
  -Credential $cred `
  -Format Word,Html `
  -OutputFolderPath C:\AsBuiltReports `
  -Verbose
```

- `-Target` is the UCS Manager **cluster VIP**, not an individual fabric interconnect.
- The output folder must exist first (`New-Item` above).
- **PDF:** open the generated `.docx` in Word and **Save As → PDF**. (Neither tool emits PDF directly.)
- **Company logo / branding:** paste your logo's Base64 into `$e360LogoBase64` in
  `AsBuiltReport.Cisco.UcsManager\AsBuiltReport.Cisco.UcsManager.Style.ps1`. It embeds on Windows.
- First run against a newer UCSM may print a few property-mismatch warnings — harmless; the report still generates.

---

## Troubleshooting

| Symptom | Cause / Fix |
|---------|-------------|
| `Could not load ... Cisco.Ucs.Common.Cmdlets` | You're on macOS/Linux PowerShell. Run on Windows. |
| "Error connecting to UCS Domain" | Cert or reachability. Cert handling is baked in now; confirm the host can reach the VIP on 443. |
| Duplicate sections in the As-Built | You're running an old module version. Check `(Get-Module AsBuiltReport.Cisco.UcsManager).Version` — should be 0.3.3+. |
| `-AcceptLicense` not recognized (PS 5.1) | Update `PowerShellGet` and open a new window (see step 2 note). |
| `OutputFolderPath is not a valid folder path` | Create the output folder first with `New-Item -ItemType Directory`. |

---

## Credits & License

- **As-Built module** — originally by Tim Carman ([@tpcarman](https://github.com/tpcarman)), part of the [AsBuiltReport](https://www.asbuiltreport.com) project. Revived and modernized for PowerShell 7 / current AsBuiltReport framework for e360 by HumbledGeeks.
- **UCS Health Check** — a community script from the `datacenter/ucs-browser` project was bundled in earlier versions; it was removed because no license could be established for it. It is not part of this repository.

The vendored As-Built module retains its upstream MIT license — see `AsBuiltReport.Cisco.UcsManager/LICENSE`.

## Provenance

Consolidated from previous local automation repositories during the 2026 LabOps repository
cleanup. This repository starts with a fresh history; earlier history is retained locally only.

## License

Repository content authored for this toolkit is licensed under the MIT License (see [LICENSE](LICENSE)). Third-party
components retain their own license notices: the included `AsBuiltReport.Cisco.UcsManager` module keeps its upstream MIT
license and attribution in `AsBuiltReport.Cisco.UcsManager/LICENSE`; no ownership of third-party code is claimed.
