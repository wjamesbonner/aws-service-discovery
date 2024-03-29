param(
    [Alias("s")]
    [string] $serviceId = "",

    [Alias("t")]
    [string] $tagName = "service-id",

    [Alias("h")]
    [switch] $help = $false
)

if ($help) {
	Write-Host "aws_get_service_resources retrieves the list of service families running in your configured AWS region."
	Write-Host "Prerequisites: Powershell, AWS CLI, AWS.Tools.ResourceGroups"
	Write-Host ""
	Write-Host "Parameters:"
    Write-Host ""
	Write-Host "serviceId"
	Write-Host "    The id of the service to query."
	Write-Host "    Default: "
    Write-Host "    Alias: s"
	Write-Host "    Example: ./aws_get_service_resources.ps1 -serviceId `"n91bet54`""
    Write-Host "    Example: ./aws_get_service_resources.ps1 -s `"n91bet54`""

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
if ($serviceId -eq "") {
	$serviceId = Read-Host "Enter the id of the service"
}
$serviceId = $serviceId.ToLower()
$resourceGroupName = $serviceId + "-list"

try {
    $resources = Get-RGGroupResourceList -GroupName $resourceGroupName
} catch {
    Write-Debug "`t Resource group doesn't exist, will create new RG."
    $tags = @($tagName)
    $tagValues = @($serviceId)
    $result = .\aws_create_resourcegroup.ps1 -name $resourceGroupName -description "created for querying service resources" -tags $tags -tagValues $tagValues
    $resources = Get-RGGroupResourceList -GroupName $resourceGroupName
}

if($resources -eq $null) {
    Write-Debug "`t Failed to find or create RG."
    return $false
}

return $resources.ResourceIdentifiers;