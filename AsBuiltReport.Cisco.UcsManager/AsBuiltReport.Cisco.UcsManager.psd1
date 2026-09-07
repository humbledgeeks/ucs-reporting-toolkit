#
# Module manifest for module 'AsBuiltReport.Cisco.UcsManager'
#
# Original author:  Tim Carman (@tpcarman)
# Revived/modernized for PowerShell 7 / Core and current AsBuiltReport framework
# for e360 by Allen Johnson, 2026.
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'AsBuiltReport.Cisco.UcsManager.psm1'

    # Version number of this module.
    ModuleVersion        = '0.3.3'

    # Supported PSEditions
    CompatiblePSEditions = @('Core', 'Desktop')

    # ID used to uniquely identify this module
    GUID                 = 'b8e5c1a4-3f2d-4c9a-9e7b-2a1d6f0c8e33'

    # Author of this module
    Author               = 'Tim Carman (original); modernized for e360 by HumbledGeeks'

    # Company or vendor of this module
    CompanyName          = 'e360'

    # Copyright statement for this module
    Copyright            = '(c) 2019 Tim Carman; 2026 e360. MIT License.'

    # Description of the functionality provided by this module
    Description          = 'A PowerShell module to generate an As Built Report on the configuration of Cisco UCS Manager in Word/HTML/Text formats. Revived and refreshed against current AsBuiltReport.Core/PScribo. Requires Cisco UCS PowerTool, which is .NET Framework based - run on Windows (Windows PowerShell 5.1 or PowerShell 7 on Windows), NOT macOS/Linux.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @(
        @{
            ModuleName    = 'AsBuiltReport.Core'
            ModuleVersion = '1.3.0'
        },
        @{
            ModuleName    = 'Cisco.UCSManager'
            ModuleVersion = '3.0.0.0'
        }
    )

    # Functions to export from this module
    FunctionsToExport    = @('Invoke-AsBuiltReport.Cisco.UcsManager')

    # Cmdlets to export from this module
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module
    AliasesToExport      = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = @('AsBuiltReport', 'Report', 'Cisco', 'UCS', 'UCSM', 'FabricInterconnect', 'Documentation', 'PScribo', 'Windows', 'Linux', 'MacOS', 'PSEdition_Core', 'PSEdition_Desktop')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/AsBuiltReport/AsBuiltReport.Cisco.UcsManager/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/AsBuiltReport/AsBuiltReport.Cisco.UcsManager'

            # ReleaseNotes of this module
            ReleaseNotes = '0.3.3 (e360): Service profile and template queries now scoped with -Ucs $UCSM and de-duplicated (Sort-Object Dn -Unique), so duplicate sections cannot occur regardless of how many UCS sessions are open. 0.3.2: Corrected the stray-session cleanup - 0.3.1 used "Get-UcsPSSession | Disconnect-Ucs" which is invalid pipeline syntax and silently did nothing; now uses "Disconnect-Ucs -Ucs $DefaultUcs". 0.3.1: Fixed duplicate objects (service profiles, templates, VLANs, pools, etc.) caused by unscoped Get-Ucs* queries hitting multiple default connections - the report now disconnects any stray UCS sessions before connecting, guaranteeing a single connection. 0.3.0: Wired up HealthCheck config, added UCS self-signed certificate handling, declared Cisco.UCSManager dependency, framework calls refreshed for current AsBuiltReport.Core/PScribo. Targets Windows PowerShell 5.1 / PowerShell 7 on Windows. Cisco UCS PowerTool is .NET Framework based and does NOT load on macOS/Linux PowerShell - run on Windows. Report body otherwise unchanged from 0.2.1.'

        }

    }

}
