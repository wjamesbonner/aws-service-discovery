#Requires -RunAsAdministrator
param(
    [Alias("f")]
    [switch] $force = $false,

    [Alias("h")]
    [switch] $help = $false
)

if ($help) {
	Write-Host "Setup is a script that performs the one time operations needed to use this library.  It should also be run on update of the library."
	Write-Host "Prerequisites: Powershell"
	Write-Host ""
	Write-Host "Parameters:"
	Write-Host ""
	Write-Host "force"
	Write-Host "    Force the reinstallation of libraries."
	Write-Host "    Default: true"
    Write-Host "    Alias: f"
	Write-Host "    Example: ./setup.ps1 -force"
    Write-Host "    Example: ./setup.ps1 -f"
	
	return
}

if((Get-PSRepository -Name "PSGallery").InstallationPolicy -ne "Trusted") {
    Write-Host "Setting PSGallery to trusted."
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if(!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host "Please re-run as administrator."
    return
}

$changesMade = $false

# Check for modules required by this library
if (!(Get-Module -ListAvailable -Name AWS.Tools.Installer) -or $force) {
    if($force) {
        Install-Module -Name AWS.Tools.Installer -AllowClobber
    } else {
        Install-Module -Name AWS.Tools.Installer
    }

    $changesMade = $true
}

# Check for modules required by this library
if (!(Get-Module -ListAvailable -Name AWS.Tools.ResourceGroups) -or $force) {
    if($force) {
        Install-Module -Name AWS.Tools.ResourceGroups -AllowClobber
    } else {
        Install-Module -Name AWS.Tools.ResourceGroups
    }

    $changesMade = $true
}

if($changesMade) {
    Write-Host "Libraries successfully installed!"
}else {
    Write-Host "All libraries are already installed, did you mean to run with -f ?"
}