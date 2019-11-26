param(
    [Alias("s")]
    [string] $serviceFamily = "",

    [Alias("t")]
    [string] $tagName = "service-family",

    [Alias("h")]
    [switch] $help = $false
)

if ($help) {
	Write-Host "aws_get_service_family_resources retrieves the list of service families running in your configured AWS region."
	Write-Host "Prerequisites: Powershell, AWS CLI, AWS.Tools.ResourceGroups"
	Write-Host ""
	Write-Host "Parameters:"
    Write-Host ""
	Write-Host "serviceFamily"
	Write-Host "    The name of the service family to query."
	Write-Host "    Default: "
    Write-Host "    Alias: s"
	Write-Host "    Example: ./aws_get_service_resources.ps1 -serviceId `"n91bet54`""
    Write-Host "    Example: ./aws_get_service_resources.ps1 -s `"n91bet54`""

    Write-Host ""
	Write-Host "tagName"
	Write-Host "    The name of the tag used to identify service families."
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
	$serviceFamily = Read-Host "Enter the name of the service family"
}
$serviceFamily = $serviceFamily.ToLower()

$expectedGroupName = $serviceFamily + "-list"
$resourceGroups = Get-RGGroupList
$groupArn = ""

foreach($r in $resourceGroups) {
    if($r.GroupName -eq $expectedGroupName) {
        $groupArn = $r.GroupArn
    }
}

if($groupArn -eq "") {
    # Resource group doesn't exist yet
    .\aws_create_resourcegroup.ps1 -name $expectedGroupName -description "created for querying service resources" -tags $tagName -tagValues $serviceId
}

$resources = Get-RGGroupResourceList -GroupName $expectedGroupName

return $resources.ResourceIdentifiers;