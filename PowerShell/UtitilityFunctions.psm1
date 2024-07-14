using module  .\MergedClasses.psm1


<# WebCon.WorkFlow.Model.Service.Import.ImportStatusEnum
public enum ImportStatusEnum
#>

$ErrorActionPreference = 'Break'
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
	#$enc = [System.Text.Encoding]::GetEncoding('UTF-8')
   # $enc = [System.Text.Encoding]::GetEncoding('ASCII')
    #$enc = [System.Text.Encoding]::GetEncoding('iso-8859-1')
	
	$fileEnc = $enc.GetString($FileData)


    $stringBuilder = New-Object System.Text.StringBuilder
    [void]$stringBuilder.AppendLine("--$Boundary")
    [void]$stringBuilder.AppendLine("Content-Disposition: form-data; name=file; filename=$FileName")
    [void]$stringBuilder.AppendLine("Content-Type: application/octet-stream")
    [void]$stringBuilder.AppendLine()
    #[void]$stringBuilder.AppendLine([System.Text.Encoding]::UTF8.GetString($FileData))
    [void]$stringBuilder.AppendLine($fileEnc)
    [void]$stringBuilder.AppendLine("--$Boundary--")

    $content = [System.Net.Http.MultipartFormDataContent]::new()
    $fileContent = [System.Net.Http.StreamContent]::new($fileStream)
    $fileContent.Headers.ContentDisposition = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    # Your example had quotes in your literal form-data example so I kept them here
    $fileContent.Headers.ContentDisposition.Name = '"Filedata"'
    $fileContent.Headers.ContentDisposition.FileName = '"{0}"' -f $file.Name
    
    $fileContent.Headers.ContentType = 'application/octet-stream'
    $content.Add($fileContent)
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

function Get-MultipartFormData {
    param (
        [string]$FileName,
        [byte[]]$FileData,
        [string]$Boundary
    )
    
    $lineBreak = "`r`n"
    $contentDisposition = "Content-Disposition: form-data; name=`"file`"; filename=`"$FileName`"" + $lineBreak
    $contentType = "Content-Type: application/octet-stream" + $lineBreak + $lineBreak
    $endBoundary = "--$Boundary--" + $lineBreak

    # Convert file data to base64 string
    $fileDataString = [System.Convert]::ToBase64String($FileData)

    # Build the form data
    $formData = "--$Boundary" + $lineBreak
    $formData += $contentDisposition
    $formData += $contentType
    $formData += $fileDataString + $lineBreak
    $formData += $endBoundary

    return $formData
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

    #using MemoryStream memStream = new MemoryStream(chunk);
	#using HttpContent fileStreamContent = new StreamContent(memStream);
	#MultipartFormDataContent content = new MultipartFormDataContent { { fileStreamContent, "File", "ImportPackage" } };


    $body = [System.Net.Http.MultipartFormDataContent]::new()
    $memoryStream = new-object System.IO.MemoryStream(,$content) 
    $fileContent = [System.Net.Http.StreamContent]::new($memoryStream)
    $fileContent.Headers.ContentDisposition = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    # Your example had quotes in your literal form-data example so I kept them here
    $fileContent.Headers.ContentDisposition.Name = '"file"'
    $fileContent.Headers.ContentDisposition.FileName = $filename
    $fileContent.Headers.ContentType = 'application/octet-stream'
    $body.Add($fileContent)

<#

    #$contentBase64 = [System.Convert]::ToBase64String($content)
    $boundary = [System.Guid]::NewGuid().ToString()
    $body = Get-MultipartFormData -FileName $filename -FileData $content -Boundary $boundary
   # Convert the multipart content to bytes
$multipartBytes = [System.Text.Encoding]::UTF8.GetBytes($body)
#>
    Write-Host "Executing request against uri: $uri"    
  
    Return Invoke-RestMethod `
        -Method Post `
        -Uri  $uri `
        -Body $abc `
        -Proxy "http://localhost:8000" `
        -ContentType "multipart/form-data; boundary=`"$boundary`"" `
        -Headers @{"accept" = "application/json"; "Authorization" = "Bearer $($Global:accessToken) " } 

        
        #-ContentType "multipart/form-data; boundary=`"$boundary`"" `
        
        #-ContentType "multipart/form-data; boundary=$boundary" `

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
        $importLog = Invoke-AuthenticatedGetRequest -hostRelativeUri "/api/data/$($Global:WEBCONConfig.ApiVersion)/db/$($dbId)/importsessions/$($sessionId)/logs"
               
        
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
        $maxChunkSize = 1024 * 300 # 16 kb chunk size

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
       <# 
        $uploadResult = Invoke-RestMethod `
        -Method Post `
        -Uri  "$($global:WEBCONConfig.Hostname)/api/data/$($Global:WEBCONConfig.ApiVersion)/db/$($dbId)/importsessions/$($startResult.sessionId)/1" `
        -Form @{"file" = Get-Item $importFilePath}`
        -Proxy "http://localhost:8000" `
        -Headers @{"accept" = "application/json"; "Authorization" = "Bearer $($Global:accessToken) " } 
#>       

       
       $tempChunks = Get-Content $importFilePath -AsByteStream -ReadCount $body.chunkSize
        if ($body.chunkSize -le $body.totalSize) {
            
            $chunks = @(,$tempChunks)
        }
        else {
            $chunks = $tempChunks
        }

        for ($i = 0; $i -lt $chunks.Count; $i++) {                   
            $currentChunkIndex = $i + 1;
            [byte[]]$content = $fileContent[$startIndex..($endIndex)]
            $filename = 'Chunk_' + $currentChunkIndex + '_' + $file.Name
            $uploadResult = Invoke-AuthenticatedUploadFileRequest -hostRelativeUri  "/api/data/$($Global:WEBCONConfig.ApiVersion)/db/$($dbId)/importsessions/$($startResult.sessionId)/$($currentChunkIndex)"  -filename $filename -content $chunks[$i]
            Write-Host "Uploaded chunk result: $uploadResult" -BackgroundColor Cyan
        }

        Write-Host "File uploaded to import session with id $($startResult.sessionId)."
        
       
    }
    end {
        return $startResult.sessionId
    }
}
