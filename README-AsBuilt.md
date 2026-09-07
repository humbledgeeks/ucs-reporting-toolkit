# Cisco UCS Manager — As-Built Report

Generates an As-Built document (Word + HTML) of a UCS Manager domain using
AsBuiltReport.

> Module maturity: `AsBuiltReport.Cisco.UcsManager` is an early community module
> (v0.2.x). It works, but expect less depth/polish than the VMware or NetApp
> reports.

## 1. Launch PowerShell

```bash
# macOS: install pwsh once if you don't have it
brew install --cask powershell
pwsh
```

Inside `pwsh`, trust the gallery once:

```powershell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
```

## 2. Install / update the modules

```powershell
Install-Module AsBuiltReport.Cisco.UcsManager -Scope CurrentUser -AllowClobber -SkipPublisherCheck
Install-Module Cisco.UCSManager               -Scope CurrentUser -AllowClobber -SkipPublisherCheck
# later, to update:
Update-Module AsBuiltReport.Cisco.UcsManager
Update-Module Cisco.UCSManager
```

`Cisco.UCSManager` (the UCS PowerTool) is the required dependency. Confirm it
imports on your Mac (`Import-Module Cisco.UCSManager`) — verify before relying on
it, as PowerTool has historically been Windows-oriented.

## 3. One-time global config (company info, author)

```powershell
New-AsBuiltConfig      # note the JSON path it prints; reuse it with -AsBuiltConfigFilePath
```

## 4. Generate the As-Built

```powershell
$cred = Get-Credential
New-AsBuiltReport `
  -Report Cisco.UcsManager `
  -Target 10.0.0.5 `                                        # UCSM cluster VIP / FQDN
  -Credential $cred `
  -Format Html,Word `
  -OutputFolderPath "$HOME/AsBuiltReports" `
  -StyleFilePath "$HOME/AsBuiltReports/<Company>.Style.ps1" `    # optional company branding (see note)
  -Verbose
```

Replace `10.0.0.5` with your UCS Manager cluster VIP or FQDN.

## Notes

- Target = the UCS Manager cluster VIP (the address you point UCSM at), not an
  individual fabric interconnect.
- **Company logo / branding:** `-StyleFilePath` points to `<Company>.Style.ps1` (pending
  the logo template). Cover-image embedding uses `System.Drawing` (Windows-only),
  so the logo renders reliably only when generated on Windows. Remove the
  `-StyleFilePath` line until the style script exists.
