param(
    [Alias("r")]
    [string] $resourceGroupName = "service-resources",

    [Alias("t")]
    [string] $tagName = "service-family",

    [Alias("h")]
    [switch] $help = $false
)

if ($help) {
	Write-Host "aws_get_service_familes retrieves the list of service families running in your configured AWS region."
	Write-Host "Prerequisites: Powershell, AWS CLI, AWS.Tools.ResourceGroups"
	Write-Host ""
	Write-Host "Parameters:"
    Write-Host ""
	Write-Host "resourceGroupName"
	Write-Host "    The name of the resource group that encompasses the AWS resources tagged with service details."
	Write-Host "    Default: service-resources"
    Write-Host "    Alias: r"
	Write-Host "    Example: ./aws_get_service_familes.ps1 -resourceGroupName `"service-resources`""
    Write-Host "    Example: ./aws_get_service_familes.ps1 -r `"service-resources`""

    Write-Host ""
	Write-Host "tagName"
	Write-Host "    The name of the tag used to identify service familes."
	Write-Host "    Default: service-family"
    Write-Host "    Alias: t"
	Write-Host "    Example: ./aws_get_service_familes.ps1 -tagName service-family"
    Write-Host "    Example: ./aws_get_service_familes.ps1 -t service-family"
	return
}

# load necessary modules
.\aws_load_default_modules.ps1

# Prompt for name if not specified
if ($resourceGroupName -eq "") {
	$resourceGroupName = Read-Host "Enter the name of the resource group"
}
$resourceGroupName = $resourceGroupName.ToLower()

# Prompt for name if not specified
if ($tagName -eq "") {
	$tagName = Read-Host "Enter the name of the tag"
}
$tagName = $tagName.ToLower()

$resourceGroup = Get-RGGroup -GroupName $resourceGroupName

$resources = Get-RGGroupResourceList -GroupName $resourceGroupName

.\aws_get_tag_values.ps1 -resources $resources.ResourceIdentifiers -tagName $tagName