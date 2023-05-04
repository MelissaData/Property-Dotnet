# Name:    Property
# Purpose: Execute the PropertyCloudAPI program

######################### Parameters ##########################
param(
    $fips = '',  
    $apn = '',  
    $license = '', 
    [switch]$quiet = $false
    )

# Uses the location of the .ps1 file 
# Modify this if you want to use 
$CurrentPath = $PSScriptRoot
Set-Location $CurrentPath
$ProjectPath = "$CurrentPath\Property"
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

dotnet publish -f="net7.0" -c Release -o $BuildPath Property\Property.csproj

# Run project
if ([string]::IsNullOrEmpty($fips) -and [string]::IsNullOrEmpty($apn)) {
  dotnet $BuildPath\Property.dll --license $license 
}
else {
  dotnet $BuildPath\Property.dll --license $license --fips $fips --apn $apn
}
