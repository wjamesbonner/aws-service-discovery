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

# Check for necessary module
if (Get-Module -ListAvailable -Name AWS.Tools.Common) {
    Import-Module AWS.Tools.Common
} 
else {
    Write-Host "Module Import-Module AWS.Tools.Common has not been installed.  Please run this libraries setup script."
    return;
}

# Check for necessary module
if (Get-Module -ListAvailable -Name AWS.Tools.ResourceGroups) {
    Import-Module AWS.Tools.ResourceGroups
} 
else {
    Write-Host "Module Import-Module AWS.Tools.ResourceGroups has not been installed.  Please run this libraries setup script."
    return;
}

# Check for necessary module
if (Get-Module -ListAvailable -Name AWS.Tools.EC2) {
    Import-Module AWS.Tools.EC2
} 
else {
    Write-Host "Module Import-Module AWS.Tools.EC2 has not been installed.  Please run this libraries setup script."
    return;
}

# Check for necessary module
if (Get-Module -ListAvailable -Name AWS.Tools.ECS) {
    Import-Module AWS.Tools.ECS
} 
else {
    Write-Host "Module Import-Module AWS.Tools.ECS has not been installed.  Please run this libraries setup script."
    return;
}

# Check for necessary module
if (Get-Module -ListAvailable -Name AWS.Tools.ECR) {
    Import-Module AWS.Tools.ECR
} 
else {
    Write-Host "Module Import-Module AWS.Tools.ECR has not been installed.  Please run this libraries setup script."
    return;
}

# Check for necessary module
if (Get-Module -ListAvailable -Name AWS.Tools.RDS) {
    Import-Module AWS.Tools.RDS
} 
else {
    Write-Host "Module Import-Module AWS.Tools.RDS has not been installed.  Please run this libraries setup script."
    return;
}

# Check for necessary module
if (Get-Module -ListAvailable -Name AWS.Tools.S3) {
    Import-Module AWS.Tools.S3
} 
else {
    Write-Host "Module Import-Module AWS.Tools.S3 has not been installed.  Please run this libraries setup script."
    return;
}

# Check for necessary module
if (Get-Module -ListAvailable -Name AWS.Tools.ElasticFileSystem) {
    Import-Module AWS.Tools.ElasticFileSystem
} 
else {
    Write-Host "Module Import-Module AWS.Tools.ElasticFileSystem has not been installed.  Please run this libraries setup script."
    return;
}

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

$services = @()

foreach($resource in $resources.ResourceIdentifiers) {

    if($resource.ResourceType -eq "AWS::EC2::Instance") {
        $result = Get-EC2Instance -InstanceId $resource.ResourceArn.Split("/")[1]
        $tags = $result.Instances[0].Tags
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $services += $tag.Value
            }
        }

        $sgs = $result.Instances[0].SecurityGroups
        foreach($sg in $sgs) {
            $group = Get-EC2SecurityGroup -GroupId $sg.GroupId
            $tags = $group.Tags
            foreach($tag in $tags) {
                if($tag.Key -eq $tagName) {
                    $services += $tag.Value
                }
            }
        }

    } elseif($resource.ResourceType -eq "AWS::ECS::Cluster") {
        $tags = Get-ECSTagsForResource -ResourceArn $resource.ResourceArn
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $services += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::ECS::Task") {
        $tags = Get-ECSTagsForResource -ResourceArn $resource.ResourceArn
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $services += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::ECS::TaskDefinition") {
        $tags = Get-ECSTagsForResource -ResourceArn $resource.ResourceArn
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $services += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::ECR::Repository") {
        $tags = Get-ECRResourceTag -ResourceArn $resource.ResourceArn
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $services += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::RDS::DBInstance") {
        $tags = Get-RDSTagForResource -ResourceName $resource.ResourceArn
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $services += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::S3::Bucket") {
        $tags = Get-S3BucketTagging -BucketName $resource.ResourceArn.Split(":")[$resource.ResourceArn.Split(":").Count-1]
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $services += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::EFS::FileSystem") {
        $tags = Get-EFSTag -FileSystemId $resource.ResourceArn.Split("/")[1]
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $services += $tag.Value
            }
        }
    }
}

$services | Sort-Object | Get-Unique