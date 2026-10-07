<#
.SYNOPSIS
    Builds and runs the Melissa Property Cloud API .NET sample.

.DESCRIPTION
    This script builds PropertyDotnet with dotnet publish, then runs the resulting
    executable, passing along the license and (if supplied) the FIPS code and APN.

    Overall flow:
      1. Resolve the license (parameter, prompt, or MD_LICENSE environment variable).
      2. Publish PropertyDotnet in Release configuration to .\PropertyDotnet\Build.
      3. Run the built executable: one-shot mode if FIPS or APN was supplied,
         otherwise interactive mode (the .NET program prompts for each field).

.PARAMETER fips
    County FIPS code to look up in one-shot mode.

.PARAMETER apn
    Assessor's Parcel Number (APN) to look up in one-shot mode.

.PARAMETER license
    License string. Resolved in this order:
      1. This parameter.
      2. An interactive prompt, if the parameter was not supplied.
      3. The MD_LICENSE environment variable, if the prompt was left blank.
    Note that the environment variable is the last resort, not the first: running
    without -license always prompts, even when MD_LICENSE is set.

.PARAMETER quiet
    Accepted for parity with other sample scripts; not currently used to suppress output.

.EXAMPLE
    .\PropertyDotnet.ps1 -license "your-license"

.EXAMPLE
    .\PropertyDotnet.ps1 -fips "06059" -apn "80505208" -license "your-license"
#>

######################### Parameters ##########################
param(
    $fips = '',
    $apn = '',
    $license = '',
    [switch]$quiet = $false
    )

# Uses the location of the .ps1 file
$CurrentPath = $PSScriptRoot
Set-Location $CurrentPath
$ProjectPath = "$CurrentPath\PropertyDotnet"
$BuildPath = "$ProjectPath\Build"

If (!(Test-Path $BuildPath)) {
  New-Item -Path $ProjectPath -Name 'Build' -ItemType "directory"
}

########################## Main ############################
Write-Host "`n======================== Melissa Property Cloud Api ===========================`n"

# Get license (either from parameters or user input)
if ([string]::IsNullOrEmpty($license) ) {
  $license = Read-Host "Please enter your license string"
}

# Check for License from Environment Variables 
if ([string]::IsNullOrEmpty($license) ) {
  $license = $env:MD_LICENSE # Get-ChildItem -Path Env:\MD_LICENSE   #[System.Environment]::GetEnvironmentVariable('MD_LICENSE')
}

if ([string]::IsNullOrEmpty($license)) {
  Write-Host "`nLicense String is invalid!"
  Exit
}

# Start program
# Build project
Write-Host "`n================================ BUILD PROJECT ================================"

dotnet publish -f="net7.0" -c Release -o $BuildPath PropertyDotnet\PropertyDotnet.csproj

# Run project
# Neither FIPS nor APN supplied -> run interactively; otherwise pass both through for one-shot mode.
if ([string]::IsNullOrEmpty($fips) -and [string]::IsNullOrEmpty($apn)) {
  dotnet $BuildPath\PropertyDotnet.dll --license $license 
}
else {
  dotnet $BuildPath\PropertyDotnet.dll --license $license --fips $fips --apn $apn
}
