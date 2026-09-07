# Cisco UCS Manager As Built Report - Default Document Style (e360 branded)

# Configure document options
DocumentOption -EnableSectionNumbering -PageSize A4 -DefaultFont Arial -MarginLeftAndRight 71 -MarginTopAndBottom 71 -Orientation $Orientation

# Configure Heading and Font Styles
Style -Name 'Title' -Size 24 -Color '004BAF' -Align Center
Style -Name 'Title 2' -Size 18 -Color '049FD9' -Align Center
Style -Name 'Title 3' -Size 12 -Color '049FD9' -Align Left
Style -Name 'Heading 1' -Size 16 -Color '004BAF'
Style -Name 'Heading 2' -Size 14 -Color '004BAF'
Style -Name 'Heading 3' -Size 12 -Color '004BAF'
Style -Name 'Heading 4' -Size 11 -Color '004BAF'
Style -Name 'Heading 5' -Size 10 -Color '58585B' -Italic
Style -Name 'H1 Exclude TOC' -Size 16 -Color '004BAF'
Style -Name 'Normal' -Size 10 -Color '565656' -Default
Style -Name 'TOC' -Size 16 -Color '004BAF'
Style -Name 'TableDefaultHeading' -Size 10 -Color 'FFFFFF' -BackgroundColor '58585B'
Style -Name 'TableDefaultRow' -Size 10
Style -Name 'TableDefaultAltRow' -Size 10 -BackgroundColor 'E8EBF1'
Style -Name 'Critical' -Size 10 -BackgroundColor 'FFB38F'
Style -Name 'Warning' -Size 10 -BackgroundColor 'FFE860'
Style -Name 'Info' -Size 10 -BackgroundColor 'A6D8E7'
Style -Name 'OK' -Size 10 -BackgroundColor 'AADB1E'

# Configure Table Styles
TableStyle -Id 'TableDefault' -HeaderStyle 'TableDefaultHeading' -RowStyle 'TableDefaultRow' -AlternateRowStyle 'TableDefaultAltRow' -BorderColor '58585B' -Align Left -BorderWidth 0.5 -Default
TableStyle -Id 'Borderless' -BorderWidth 0

# ---------------------------------------------------------------------------
# e360 COMPANY LOGO (cover page)
# ---------------------------------------------------------------------------
# Paste the Base64 string of your e360 logo (PNG, transparent background) between
# the quotes below. Generate it with:
#   [Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME/logos/e360-logo.png"))
#
# NOTE: PScribo image embedding relies on System.Drawing, which is not available
# on macOS/Linux. The logo renders when the report is generated on Windows; on
# macOS the report still builds and the logo is skipped with a warning.
$e360LogoBase64 = ''

# Cisco / e360 Cover Page Layout
# Set position of report titles and information based on page orientation
if ($Orientation -eq 'Portrait') {
    BlankLine -Count 11
    $LineCount = 30
} else {
    BlankLine -Count 7
    $LineCount = 20
}

# Add e360 logo to the cover page (if provided)
if ($e360LogoBase64) {
    try {
        Image -Base64 $e360LogoBase64 -Align Center -Percent 40 -Text 'e360'
        BlankLine -Count 2
        $LineCount = $LineCount - 3
    } catch {
        Write-PScriboMessage -IsWarning "Unable to render e360 cover logo (System.Drawing may be unavailable on this platform): $($_.Exception.Message)"
    }
}

# Add Report Name
Paragraph -Style Title $ReportConfig.Report.Name

if ($AsBuiltConfig.Company.FullName) {
    # Add Company Name if specified
    Paragraph -Style Title2 $AsBuiltConfig.Company.FullName
    BlankLine -Count $LineCount
} else {
    BlankLine -Count ($LineCount + 1)
}
Table -Name 'Cover Page' -List -Style Borderless -Width 0 -Hashtable ([Ordered] @{
        'Author:' = $AsBuiltConfig.Report.Author
        'Date:' = Get-Date -Format 'dd MMMM yyyy'
        'Version:' = $ReportConfig.Report.Version
    })
PageBreak

# Add Table of Contents
TOC -Name 'Table of Contents'
PageBreak
