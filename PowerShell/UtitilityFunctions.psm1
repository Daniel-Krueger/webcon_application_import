using module  .\MergedClasses.psm1


<# WebCon.WorkFlow.Model.Service.Import.ImportStatusEnum
public enum ImportStatusEnum
#>
enum ImportStatus 
{
    Error
    Completed
    CompletedWithError
    NotExist
    Created
    InProgress
}

$ErrorActionPreference = 'Inquire'
# Set's the global configuration information. Secret information are read from a file outside of the repository.
function Set-WEBCONTargetInformation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$filePath = ".auth\webconConfig.json"
    )    
    process {
        Write-Host "Setting up WEBCON configuration"
        $global:WEBCONConfig = New-Object WEBCONConfig
        if (!(Test-Path $filePath) ) {
            $defaultConfig = New-Object WEBCONConfig
            ConvertTo-Json $defaultConfig
            New-Item $filePath  -Value (ConvertTo-Json $defaultConfig)
            $filePath = Resolve-Path $filePath 
            explorer.exe $filePath 
            $filePath | clip
            Write-Error "The configuration file does not exist. Please update the information in file '$filePath'. It should have opened, but the path is also copied to the clipboard"
        }
        $customConfig = Get-Content -LiteralPath $filePath  -Encoding UTF8 | ConvertFrom-Json 
        $global:WEBCONConfig.UpdateFromConfig($customConfig)    
    }
} 
<#
.SYNOPSIS
Retrieves a access token using the configuration from global::WEBCONConfig and stores it in the global variable $Global::accessToken 
#

#>
function Set-AccessToken {
    Set-WEBCONTargetInformation 
    $uri = "$($global:WEBCONConfig.Hostname)/api/oauth2/token"
    Write-Host "Getting token from $uri"
    $authorization = Invoke-RestMethod `
        -Method Post `
        -Uri  $uri `
        -ContentType "application/x-www-form-urlencoded" `
        -Headers @{"accept" = "application/json" } `
        -Body "grant_type=client_credentials&client_id=$($global:WEBCONConfig.ClientId)&client_secret=$([System.Web.HttpUtility]::UrlEncode($global:WEBCONConfig.ClientSecret))"
        
   
    $Global:accessToken = $authorization.access_token;
}

function Invoke-AuthenticatedGetRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $hostRelativeUri
    )
    $uri = "$($global:WEBCONConfig.Hostname)$hostRelativeUri"
    Write-Host "Executing request against uri: $uri"    
    Return Invoke-RestMethod `
        -Method Get `
        -Uri  $uri `
        -ContentType "application/json" `
        -Headers @{"accept" = "application/json"; "Authorization" = "Bearer $($Global:accessToken) " } `

}

function Invoke-AuthenticatedPostRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $hostRelativeUri,
        [Parameter()]
        [string]
        $body
    )
    $uri = "$($global:WEBCONConfig.Hostname)$hostRelativeUri"
    Write-Host "Executing request against uri: $uri"    
    Return Invoke-RestMethod `
        -Method Post `
        -Uri  $uri `
        -Body $body `
        -ContentType "application/json" `
        -Headers @{"accept" = "application/json"; "Authorization" = "Bearer $($Global:accessToken) " } `

}

# Helper function to create a multipart/form-data boundary
function Get-MultipartFormData {
    param (
        [string]$FileName,
        [byte[]]$FileData,
        [string]$Boundary
    )
    $fileDataString = [System.Convert]::ToBase64String($FileData)

    $stringBuilder = New-Object System.Text.StringBuilder
    [void]$stringBuilder.AppendLine("--$Boundary")
    [void]$stringBuilder.AppendLine("Content-Disposition: form-data; name=file; filename=$FileName")
    [void]$stringBuilder.AppendLine("Content-Type: application/octet-stream")
    [void]$stringBuilder.AppendLine()
    [void]$stringBuilder.AppendLine([System.Text.Encoding]::UTF8.GetString($FileData))
    #[void]$stringBuilder.AppendLine($fileDataString)
    [void]$stringBuilder.AppendLine("--$Boundary--")

    <#
    $lineBreak = "`r`n"
    $contentDisposition = "Content-Disposition: form-data; name=`"file`"; filename=`"$FileName`"" + $lineBreak
    $contentType = "Content-Type: application/octet-stream" + $lineBreak + $lineBreak
    $endBoundary = "--$Boundary--" + $lineBreak

    $formData = "--$Boundary" + $lineBreak
    $formData += $contentDisposition
    $formData += $contentType
    $formData += [System.Text.Encoding]::UTF8.GetString($FileData) + $lineBreak
    $formData += $endBoundary
#>
    return $stringBuilder.ToString()
}

function Invoke-AuthenticatedUploadFileRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $hostRelativeUri,
        [Parameter()]
        [byte[]]
        $content,
        [string]
        $filename
    )
    $uri = "$($global:WEBCONConfig.Hostname)$hostRelativeUri"
    #$contentBase64 = [System.Convert]::ToBase64String($content)
    $boundary = [System.Guid]::NewGuid().ToString()
    $body = Get-MultipartFormData -FileName $filename -FileData $content -Boundary $boundary
   
    Write-Host "Executing request against uri: $uri"    
  
    Return Invoke-RestMethod `
        -Method Post `
        -Uri  $uri `
        -Body $body `
        -ContentType "multipart/form-data; boundary=$boundary" `
        -Headers @{"accept" = "application/json"; "Authorization" = "Bearer $($Global:accessToken) " } 
        

}

function Invoke-AuthenticatedPatchRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $hostRelativeUri,
        [Parameter()]
        [string]
        $body
    )
    $uri = "$($global:WEBCONConfig.Hostname)$hostRelativeUri"
    Write-Host "Executing request against uri: $uri"    
    Return Invoke-RestMethod `
        -Method Patch `
        -Uri  $uri `
        -Body $body `
        -ContentType "application/json" `
        -Headers @{"accept" = "application/json"; "Authorization" = "Bearer $($Global:accessToken) " } `

}

<#

$dbId = 1
$importFilePath = ".\DummyApplication.bpe"
#>
function Import-Application {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]
        $dbId,
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path($_) })]
        $importFilePath
        ,
        [Parameter(Mandatory = $false)]
        $importConfigurationFilePath
    )
    begin {
        Set-AccessToken
        $defaultConfigurationFile = ".\defaultConfiguration.json"
        $maxWaitTimeout = 60
        $hasCustomConfiguration = $null -ne $importConfigurationFilePath
        if ($hasCustomConfiguration) {
            if ($false -eq (Test-Path $importConfigurationFilePath)) {
                throw "The provided configuration file '$(Resolve-Path $importConfigurationFilePath)' does not exist"
            }
        }
    }
    process {       
        $sessionId = Upload-ImportFile -dbId $dbId -importFilePath $importFilePath  
        if ($hasCustomConfiguration) {
            Write-Host "Import will be using a custom configuration file $($importConfigurationFilePath) created."
            $configuration = Get-Content $importConfigurationFilePath -Encoding utf8 -Raw
        }
        else {
            Write-Host "Import will be using default configuration file $($defaultConfigurationFile) created."
            $configuration = Get-Content $defaultConfigurationFile -Encoding utf8 -Raw
       
        }
        $jsonResult = Invoke-AuthenticatedPatchRequest -hostRelativeUri "/api/data/$($Global:WEBCONConfig.ApiVersion)/db/$($dbId)/importsessions/$($sessionId)" -body $configuration

        $awaitImportEnd = $true
        $status = [ImportStatus]::InProgress
        $secondsWaited = 0     
        while ($awaitImportEnd) {
            $jsonResult = Invoke-AuthenticatedGetRequest -hostRelativeUri "/api/data/$($Global:WEBCONConfig.ApiVersion)/db/$($dbId)/importsessions/$($sessionId)/status" 
            $status = [ImportStatus]$jsonResult.status
            $awaitImportEnd = $status -eq [ImportStatus]::InProgress
            if ($secondsWaited -gt $maxWaitTimeout) {
                Write-Host "Wait time execeeded maximum wait time of $maxWaitTimeout seconds"
                $awaitImportEnd = $false
            }
            else {                
                Start-Sleep 1 # sleep one second
            }
        }
        Write-Host "Import completed with status '$status'"
        
        if ($status -eq [ImportStatus]::Completed -or $status -eq [ImportStatus]::CompletedWithError ){
            $importLog = Invoke-AuthenticatedGetRequest -hostRelativeUri "/api/data/$($Global:WEBCONConfig.ApiVersion)/db/$($dbId)/importsessions/$($sessionId)/log" 
            # Version 2024.1.1.48 the Import log is not of type json. the value is not quoted
            # { IMPH_Log = <?xml version="1.0" encoding="utf-16"?><ImportLogData xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ImportExportData><Name>DummyApplication 2024.07.13 19:47:59</Name><Description /><PackageVersion><BranchNumber>2024_1_1</BranchNumber><DBVersion>9</DBVersion><BuildVersion>48</BuildVersion><Installation>Standalone</Installation><ExportedAsTemplate>false</ExportedAsTemplate><ExportedFromOneAppOnly>false</ExportedFromOneAppOnly><ImportCompatibilities><ImportCompatibilityListItem><BranchNumber>2024.1.1</BranchNumber><BuildVersion>1</BuildVersion></ImportCompatibilityListItem></ImportCompatibilities></PackageVersion><ExportLog>Import started.

        }
        else {
            Write-Host "There's only an import log if the import completed either with or without errors. Otherwise there aren't any logs."
        }
        
    }
    end {
        return $stepInformation
    }
}


<#

#>
function Upload-ImportFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]
        $dbId,
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path($_) })]
        $importFilePath
    )
    begin {
        $maxChunkSize = 1024 * 30 # 16 kb chunk size

        $file = Get-Item $importFilePath   
        $fileContent = [System.IO.File]::ReadAllBytes((Resolve-Path -literalpath $importFilePath))
        $totalBytes = $fileContent.Length
        $importChunkSize = $totalBytes   
        $numberOfChunks = [math]::Ceiling($totalBytes / $maxChunkSize)
        if (1 -lt $numberOfChunks ) {
            $importChunkSize = $maxChunkSize          
        }
    }
    process {       
        $body = New-Object WebconImportImportStartParams
        $body.totalSize = $totalBytes
        $body.chunkSize = $importChunkSize
        $importSessionsResult = Invoke-AuthenticatedPostRequest -hostRelativeUri "/api/data/$($Global:WEBCONConfig.ApiVersion)/db/$($dbId)/importsessions" -body (ConvertTo-Json $body)           
        $startResult = New-Object WebconImportImportStartResponse $importSessionsResult
        Write-Host "Import session with id $($startResult.sessionId) created for file '$importFilePath'. File size '$($body.totalSize)', chunk size '$($body.chunkSize)' number of chunks '$numberOfChunks'"        
       
        for ($i = 0; $i -lt $numberOfChunks; $i++) {
            <#
            $i = 2
            #> 
            $currentChunkIndex = $i + 1;
            $startIndex = $i * $body.chunkSize
            if ($i -eq $numberOfChunks -1) {
                $endIndex = $totalBytes-1
            }
            else {
                $endIndex = ($startIndex + $importChunkSize)
            }
            $endIndex = ($startIndex + $importChunkSize)
            Write-Host "Current chunk part $startIndex to $($endIndex)"
            [byte[]]$content = $fileContent[$startIndex..($endIndex)]
            $filename = 'Chunk_' + $currentChunkIndex + '_' + $file.Name
            $uploadResult = Invoke-AuthenticatedUploadFileRequest -hostRelativeUri  "/api/data/$($Global:WEBCONConfig.ApiVersion)/db/$($dbId)/importsessions/$($startResult.sessionId)/$($currentChunkIndex)"  -filename $filename -content $content
            #Write-Host "Uploaded chunk result: $uploadResult"
        }
        Write-Host "File uploaded to import session with id $($startResult.sessionId)."
        
       
    }
    end {
        return $startResult.sessionId
    }
}
