param(
    [Alias("t")]
    [string] $tagName = "service-family",

    [Alias("h")]
    [switch] $help = $false
)

if ($help) {
    Write-Output ("`t aws_get_service_familes.ps1 retrieves the list of service families running in your configured AWS region based on specified tag name.")
    Write-Output ("`t Prerequisites: Powershell, AWS CLI, AWS.Tools for Powershell")
    Write-Output ("`t ")
    Write-Output ("`t Parameters:")
    Write-Output ("`t ")
    Write-Output ("`t tagName")
    Write-Output ("`t     The name of the tag that holds the service family value.")
    Write-Output ("`t     Default: {0}" -f $tagName)
    Write-Output ("`t     Alias: s")
    Write-Output ("`t     Example: .\aws_get_service_familes.ps1 -tagName {0}" -f $tagName)
    Write-Output ("`t     Example: .\aws_get_service_familes.ps1 -t {0}" -f $tagName)

	return
}

# navigate to library root
cd $PSScriptRoot

# load necessary modules
.\aws_load_default_modules.ps1

# Prompt for name if not specified
if ($tagName -eq "") {
	$tagName = Read-Host "Enter the name of the tag"
}
$tagName = $tagName.ToLower()

$resourceGroupName = ("{0}-{1}" -f $tagName, "resources")

try {
    $resources = Get-RGGroupResourceList -GroupName $resourceGroupName
} catch {
    Write-Debug "`t Resource group doesn't exist, will create new RG."
    $tags = @($tagName)
    $tagValues = @("$null")
    $result = .\aws_create_resourcegroup.ps1 -name $resourceGroupName -description "created for querying service resources" -tags $tagName -tagValues $tagValues
    $resources = Get-RGGroupResourceList -GroupName $resourceGroupName
}

if($resources -eq $null) {
    Write-Debug "`t Failed to find or create RG."
    return $false
}

.\aws_get_tag_values.ps1 -resources $resources.ResourceIdentifiers -tagName $tagName