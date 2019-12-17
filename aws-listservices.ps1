param(
    [Alias("s")]
    [string] $serviceFamily = "",

    [Alias("f")]
    [string] $serviceFamilyTagName = "service-family",

    [Alias("t")]
    [string] $serviceIdTagName = "service-id",

    [Alias("h")]
    [switch] $help = $false
)

if ($help) {
	Write-Host "aws_get_services retrieves the list of service families running in your configured AWS region."
	Write-Host "Prerequisites: Powershell, AWS CLI, AWS.Tools.ResourceGroups"
	Write-Host ""
	Write-Host "Parameters:"
    Write-Host ""
	Write-Host "serviceFamilyName"
	Write-Host "    The name of the service family to query."
	Write-Host "    Default: "
    Write-Host "    Alias: s"
	Write-Host "    Example: ./aws_get_services.ps1 -serviceFamilyName `"wp-containers`""
    Write-Host "    Example: ./aws_get_services.ps1 -s `"wp-containers`""

    Write-Host ""
	Write-Host "familyTagName"
	Write-Host "    The name of the tag used to identify the service family."
	Write-Host ("    Default: {0}" -f $tagName)
    Write-Host "    Alias: t"
	Write-Host "    Example: ./aws_get_services.ps1 -tagName service-id"
    Write-Host "    Example: ./aws_get_services.ps1 -t service-id"

    Write-Host ""
	Write-Host "tagName"
	Write-Host "    The name of the tag used to identify services."
	Write-Host ("    Default: {0}" -f $tagName)
    Write-Host "    Alias: t"
	Write-Host "    Example: ./aws_get_services.ps1 -tagName service-id"
    Write-Host "    Example: ./aws_get_services.ps1 -t service-id"
	return
}

# navigate to library root
cd $PSScriptRoot

# load necessary modules
.\aws_load_default_modules.ps1

# Prompt for name if not specified
if ($serviceFamily -eq "") {
	$serviceFamily = Read-Host "Enter the name of the service family, or blank for all."
}
$serviceFamily = $serviceFamily.ToLower()

$resourceGroupName = $serviceFamily + "-list"

try {
    $resources = Get-RGGroupResourceList -GroupName $resourceGroupName
} catch {
    Write-Debug "`t Resource group doesn't exist, will create new RG."
    $tags = @($serviceFamilyTagName)
    $tagValues = @($serviceFamily)
    $result = .\aws_create_resourcegroup.ps1 -name $resourceGroupName -description "created for querying service resources" -tags $tags -tagValues $tagValues
    $resources = Get-RGGroupResourceList -GroupName $resourceGroupName
}

if($resources -eq $null) {
    Write-Debug "`t Failed to find or create RG."
    return $false
}

return .\aws_get_tag_values.ps1 -resources $resources.ResourceIdentifiers -tagName $serviceIdTagName