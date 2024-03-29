﻿param(
    [Alias("n")]
    [string] $name = "",

    [Alias("d")]
    [string] $description = "",

    [Alias("rt")]
    [String[]] $resourceTypes = @("AWS::AllSupported"),

    [Alias("t")]
    [String[]] $tags = @(""),

    [Alias("tv")]
    [String[]] $tagValues = @(""),

    [Alias("q")]
    [String] $query = "",

    [Alias("h")]
    [switch] $help = $false
)

if ($help) {
	Write-Host "aws_create_resourcegroup is a script to create a resource group in AWS.  Resource groups are collections of resources based on tag filters and resource types, or by stack formation templates."
	Write-Host "Prerequisites: Powershell, AWS CLI, AWS.Tools.ResourceGroups"
	Write-Host ""
	Write-Host "Parameters:"
	Write-Host ""
	Write-Host "name"
	Write-Host "    The name for the new resource group."
	Write-Host "    Default: "
    Write-Host "    Alias: n"
	Write-Host "    Example: ./aws_create_resourcegroup.ps1 -name MyResourceGroupName"
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -n MyResourceGroupName"
	
	Write-Host ""
	Write-Host "description"
	Write-Host "    The description to apply to the new resource group."
	Write-Host "    Default: "
    Write-Host "    Alias: d"
	Write-Host "    Example: ./aws_create_resourcegroup.ps1 -description `"A default collection of cost objects.`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -d `"A default collection of cost objects.`""

	Write-Host ""
	Write-Host "resourceTypes"
	Write-Host "    The types of resources to include in the resource groups.  Allows for multiple values.  Find resource ID's in AWS docs https://docs.aws.amazon.com/index.html."
	Write-Host ("    Default: {0}" -f [string]$resourceTypes)
    Write-Host "    Alias: rt"
	Write-Host "    Example: ./aws_create_resourcegroup.ps1 -resourceTypes `"AWS::EC2::Instance`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -resourceTypes `"AWS::EC2::Instance`", `"AWS::ECS::Cluster`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -rt `"AWS::EC2::Instance`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -rt `"AWS::EC2::Instance`", `"AWS::ECS::Cluster`""

    Write-Host ""
	Write-Host "tags"
	Write-Host "    The tags used to filter resource group membership.  May or may not specify a value (see tagValues)."
	Write-Host "    Default: "
    Write-Host "    Alias: t"
	Write-Host "    Example: ./aws_create_resourcegroup.ps1 -tags `"service-family`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -tags `"service-family`", `"env`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -t `"service-family`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -t `"service-family`", `"env`""

    Write-Host ""
	Write-Host "tagValues"
	Write-Host "    The values that coorespond to the specified tags.  Only one value per tag is supported via this tag.  If more advanced filtering is needed, see the query parameter.  Number of values must match tags."
	Write-Host "    Default: "
    Write-Host "    Alias: tv"
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -tagValues `"`""
	Write-Host "    Example: ./aws_create_resourcegroup.ps1 -tagValues `"wp-container`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -tagValues `"wp-container`", `"production`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -tagValues `"wp-container`", `"`", `"production`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -tv `"wp-container`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -tv `"wp-container`", `"production`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -tv `"wp-container`", `"`", `"production`""

    Write-Host ""
	Write-Host "query"
	Write-Host "    The raw JSON formatted resource group filter query.  If this parameter is specified then resrouceTypes, tags and tagValues values are ignored."
    Write-Host "    Note: PowerShell's handling of quotes makes quotes tricky at the CLI.  Running the bash version of this utility may ease that."
	Write-Host "    Default: "
    Write-Host "    Alias: q"
	Write-Host "    Example: ./aws_create_resourcegroup.ps1 -query `"{`"ResourceTypeFilters`":[`"AWS::EC2::Instance`",`"AWS::ECS::Cluster`",`"AWS::RDS::DBInstance`",`"AWS::S3::Bucket`"],`"TagFilters`":[{`"Key`":`"created-by`",`"Values`":[`"aws-rg-create`"]}]}`""
    Write-Host "    Example: ./aws_create_resourcegroup.ps1 -q `"{`"ResourceTypeFilters`":[`"AWS::EC2::Instance`",`"AWS::ECS::Cluster`",`"AWS::RDS::DBInstance`",`"AWS::S3::Bucket`"],`"TagFilters`":[{`"Key`":`"created-by`",`"Values`":[`"aws-rg-create`"]}]}`""
	return
}

# navigate to library root
cd $PSScriptRoot

# Check for necessary module
if (Get-Module -ListAvailable -Name AWS.Tools.ResourceGroups) {
    Import-Module AWS.Tools.ResourceGroups
} 
else {
    Write-Host "Module Import-Module AWS.Tools.ResourceGroups has not been installed.  Please run this libraries setup script."
    return;
}

# Make sure tag and value count match.
if($tags.Count -ne $tagValues.Count) {
    Write-Host "The number of tags passed does not match the number of tag values passed.  Did you remember to include empty values like `"`" for tags with no values?  See -help for me details."
    return;
}

# Prompt for name if not specified
if ($name -eq "") {
	$name = Read-Host "Enter the name of the resource group"
}
$name = $name.ToLower()

# Prompt for description if not specified
if ($description -eq "") {
	$description = Read-Host "Enter the description of the resource group"
}
$description = $description.ToLower()

# Build array of tags and values to filter on
$tagFilters = @()
for($i = 0; $i -le $tags.Count-1;$i++){
    # Create hashtable with the required AWS structure for tag filters
    if($tagValues[$i] -ne "") {
        $tagFilterHashtable = @{
            Key = $tags[$i].ToLower();
            Values = @($tagValues[$i].ToLower());
        }
    } else {
        $tagFilterHashtable = @{
            Key = $tags[$i].ToLower();
        }
    }

    # Cast hashtable to PS object, and add to filter array
    $tagFilters += [PSCustomObject]$tagFilterHashtable;
}

# Create hashtable in the structure of the AWS query object
$queryHashtable = @{
    ResourceTypeFilters=$resourceTypes;
    TagFilters=$tagFilters;
}

# Convert the hashtable to a PS object, and create a json string
$queryObject = [PSCustomObject]$queryHashtable;
$queryJson = ConvertTo-Json $queryObject -Depth 5 -Compress

# Create the resource group object
$resourceQuery = New-Object -TypeName Amazon.ResourceGroups.Model.ResourceQuery
$resourceQuery.Type = "TAG_FILTERS_1_0"
$resourceQuery.Query = $queryJson

# Send the create request to AWS
$result = New-RGGroup -Name $name -ResourceQuery $resourceQuery -Description $description

return $result