using module  .\MergedClasses.psm1

$ErrorActionPreference = 'Break'

<#
.SYNOPSIS
    Set's the global configuration information. Secret information are read from a file outside of the repository.
#>
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

#region RestRequests
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

    $body = [System.Net.Http.MultipartFormDataContent]::new()
    $memoryStream = new-object System.IO.MemoryStream(, $content) 
    $fileContent = [System.Net.Http.StreamContent]::new($memoryStream)
    $fileContent.Headers.ContentDisposition = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $fileContent.Headers.ContentDisposition.Name = '"file"'
    $fileContent.Headers.ContentDisposition.FileName = $filename
    $fileContent.Headers.ContentType = 'application/octet-stream'
    $body.Add($fileContent)

  
    Write-Host "Executing request against uri: $uri"    
    Return Invoke-RestMethod `
        -Method Post `
        -Uri  $uri `
        -Body $body `
        -ContentType "multipart/form-data; boundary=`"$boundary`"" `
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
#endregion RestRequests

<#
.SYNOPSIS
    Imports the application 
.PARAMETER dbId
    The id of the database into which the package should be imported
.PARAMETER importFilePath
    The path the the package.
.PARAMETER importConfigurationFilePath
    The configuration file path. The default value is  ".\defaultConfiguration.json"
.PARAMETER maxWaitTimeout
    The nnumber of seconds WEBCON BPS will be polled until it is aborted. Default value is 60.
.Example 

    $dbId = 1
    $importFilePath = ".\DummyApplication.bpe"
    $importConfigurationFilePath = ".\DummyApplication_ImportParameters.json"
    Import-WEBCONPackage -dbId $dbId -importFilePath $importFilePath -importConfigurationFilePath $importConfigurationFilePath
#>
function Import-WEBCONPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]
        $dbId,
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path($_) })]
        [string]$importFilePath
        ,
        [Parameter(Mandatory = $false)]
        [string]$importConfigurationFilePath = ".\defaultConfiguration.json"
        ,
        [Parameter(Mandatory = $false)]
        [int]$maxWaitTimeout = 60
    )
    begin {
        Set-AccessToken        
        
        if ($false -eq (Test-Path $importConfigurationFilePath)) {
            throw "The provided configuration file '$(Resolve-Path $importConfigurationFilePath)' does not exist"
        }
    }
    process {       
        $sessionId = Start-WEBCONPackageImport -dbId $dbId -importFilePath $importFilePath  
        Write-Host "Import will be started using configuration file $($importConfigurationFilePath)."    
        $configuration = Get-Content $importConfigurationFilePath -Encoding utf8 -Raw
    
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
        return $importLog
    }
}



<#
.SYNOPSIS
    Starts the import by creating a new session and uploading the file.
    The file is uploaded in 300 kb chunks.
.PARAMETER dbId
    The id of the database into which the package should be imported
.PARAMETER importFilePath
    The path the the package.
#>
function Start-WEBCONPackageImport {
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
        
        $maxChunkSize = 1024 * 300 # 300 kb chunk size

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
       
        # Read the content as bytes in chunks. 
        $tempChunks = Get-Content $importFilePath -AsByteStream -ReadCount $body.chunkSize
        # If the file is smaller than the chunk size, we get a byte array and not an object array with byte arrays as values. 
        if ($body.chunkSize -ge $body.totalSize) {
            
            # Creating an array which uses the value of $tempChunks as a value. The comma is important otherwise all values of the $tempChunks array would be used as array values. 
            # With otherwords, without the comma we could simply write $chunks = $tempChunks
            $chunks = @(, $tempChunks)
        }
        else {
            $chunks = $tempChunks
        }


        for ($i = 0; $i -lt $chunks.Count; $i++) {                   
            $currentChunkIndex = $i + 1;
            $filename = 'Chunk_' + $currentChunkIndex + '_' + $file.Name
            $uploadResult = Invoke-AuthenticatedUploadFileRequest -hostRelativeUri  "/api/data/$($Global:WEBCONConfig.ApiVersion)/db/$($dbId)/importsessions/$($startResult.sessionId)/$($currentChunkIndex)"  -filename $filename -content $chunks[$i]
            Write-Host "Uploaded chunk result: $uploadResult" -ForegroundColor Cyan
        }

        Write-Host "File uploaded to import session with id $($startResult.sessionId)."
    }
    end {
        return $startResult.sessionId
    }
}