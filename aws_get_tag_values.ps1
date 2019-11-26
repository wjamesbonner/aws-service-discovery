param(
    [Alias("r")]
    [System.Collections.Generic.List`1[Amazon.ResourceGroups.Model.ResourceIdentifier]] $resources = @(),

    [Alias("t")]
    [string] $tagName = "",

    [Alias("h")]
    [switch] $help = $false
)

if ($help) {
	Write-Host "aws_get_service_familes retrieves the list of service families running in your configured AWS region."
	Write-Host "Prerequisites: Powershell, AWS CLI, AWS.Tools.ResourceGroups"
	Write-Host ""
	Write-Host "Parameters:"
    Write-Host ""
	Write-Host "resources"
	Write-Host "    The resources to scrape"
	Write-Host "    Default: @()"
    Write-Host "    Alias: r"
	Write-Host "    Example: ./aws_get_service_familes.ps1 -resourceGroupName `"service-resources`""
    Write-Host "    Example: ./aws_get_service_familes.ps1 -r `"service-resources`""

    Write-Host ""
	Write-Host "tagName"
	Write-Host "    The name of the tag used to scrape values from."
	Write-Host "    Default: service-family"
    Write-Host "    Alias: t"
	Write-Host "    Example: ./aws_get_service_familes.ps1 -tagName service-family"
    Write-Host "    Example: ./aws_get_service_familes.ps1 -t service-family"
	return
}

$values = @()
foreach($resource in $resources) {

    if($resource.ResourceType -eq "AWS::EC2::Instance") {
        $result = Get-EC2Instance -InstanceId $resource.ResourceArn.Split("/")[1]
        $tags = $result.Instances[0].Tags
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $values += $tag.Value
            }
        }

        $sgs = $result.Instances[0].SecurityGroups
        foreach($sg in $sgs) {
            $group = Get-EC2SecurityGroup -GroupId $sg.GroupId
            $tags = $group.Tags
            foreach($tag in $tags) {
                if($tag.Key -eq $tagName) {
                    $values += $tag.Value
                }
            }
        }

    } elseif($resource.ResourceType -eq "AWS::ECS::Cluster") {
        $tags = Get-ECSTagsForResource -ResourceArn $resource.ResourceArn
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $values += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::ECS::Task") {
        $tags = Get-ECSTagsForResource -ResourceArn $resource.ResourceArn
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $values += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::ECS::TaskDefinition") {
        $tags = Get-ECSTagsForResource -ResourceArn $resource.ResourceArn
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $values += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::ECR::Repository") {
        $tags = Get-ECRResourceTag -ResourceArn $resource.ResourceArn
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $values += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::RDS::DBInstance") {
        $tags = Get-RDSTagForResource -ResourceName $resource.ResourceArn
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $values += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::S3::Bucket") {
        $tags = Get-S3BucketTagging -BucketName $resource.ResourceArn.Split(":")[$resource.ResourceArn.Split(":").Count-1]
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $values += $tag.Value
            }
        }
    } elseif($resource.ResourceType -eq "AWS::EFS::FileSystem") {
        $tags = Get-EFSTag -FileSystemId $resource.ResourceArn.Split("/")[1]
        
        foreach($tag in $tags) {
            if($tag.Key -eq $tagName) {
                $values += $tag.Value
            }
        }
    }
}

return ($values | Sort-Object | Get-Unique);