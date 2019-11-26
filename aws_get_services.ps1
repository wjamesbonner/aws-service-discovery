param(
    [Alias("s")]
    [string] $serviceFamilyName = "",

    [Alias("t")]
    [string] $tagName = "service-id",

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
	Write-Host "tagName"
	Write-Host "    The name of the tag used to identify services."
	Write-Host ("    Default: {0}" -f $tagName)
    Write-Host "    Alias: t"
	Write-Host "    Example: ./aws_get_services.ps1 -tagName service-id"
    Write-Host "    Example: ./aws_get_services.ps1 -t service-id"
	return
}

# load necessary modules
.\aws_load_default_modules.ps1

# Prompt for name if not specified
if ($serviceFamilyName -eq "") {
	$serviceFamilyName = Read-Host "Enter the name of the service family"
}
$serviceFamilyName = $serviceFamilyName.ToLower()

$expectedGroupName = $serviceFamilyName + "-list"
$resourceGroups = Get-RGGroupList
$groupArn = ""

foreach($r in $resourceGroups) {
    if($r.GroupName -eq $expectedGroupName) {
        $groupArn = $r.GroupArn
    }
}

if($groupArn -eq "") {
    # Resource group doesn't exist yet
    .\aws_create_resourcegroup.ps1 -name $expectedGroupName -description "created for querying services" -tags "service-family" -tagValues $serviceFamilyName
}

$resourceGroup = Get-RGGroup -GroupName $resourceGroupName
$resources = Get-RGGroupResourceList -GroupName $resourceGroupName

.\aws_get_tag_values.ps1 -resources $resources.ResourceIdentifiers -tagName $tagName