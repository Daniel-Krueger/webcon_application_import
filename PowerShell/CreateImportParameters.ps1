using module  .\MergedClasses.psm1


$currentDirectory = Get-Item -Path .
if ($currentDirectory.Name -ne "PowerShell") {
    Set-Location .\"PowerShell"
}
Import-Module .\UtitilityFunctions.psm1 -Force -ErrorAction Stop

$config = new-object WebconImportConfigurationImportConfiguration
$config.ignoreNoExistingGUID = $true

#region application settings
$config.overwriteAllProcessesDeploymentMode = $false
# Assigning null will not set the value to null but to an empty string, which then causes issue down the line.
#$config.overwriteAllProcessesDeploymentModeMailRecipient = $null
# If we need to set a string to null, we need to use this:
$config.overwriteAllProcessesDeploymentModeMailRecipient = [NullString]::Value
$config.importAllNewApplications = $true
$config.importAllNewProcesses = $true
$config.importAllPresentationObjects = $true
$config.importOnlySelectedApplications = $null
<#
$selectedApplication = New-Object WebconImportConfigurationImportOnlySelectedApplication
$selectedApplication.appGuid = [System.Guid]::NewGuid()
$selectedApplication.importOnlySelectedPresentationsObjects.Add([System.Guid]::NewGuid().ToString())
$selectedApplicationProcess = New-Object WebconImportConfigurationImportOnlySelectedProcess
$selectedApplicationProcess.processGuid = [System.Guid]::NewGuid()
$selectedApplicationProcess.deploymentMode = $true
$selectedApplicationProcess.deploymentModeMailRecipient = 'someone@example.com'
$selectedApplication.importOnlySelectedProcesses.Add($selectedApplicationProcess)
$config.importOnlySelectedApplications.Add($selectedApplication)
#>
#endregion 

#region dictionaries / doc templates
$config.overwriteAllDictionaryItems = $true
$config.importAllDictionaryElements = $true
$config.importOnlySelectedDictionaryElements = $null
<#
$dictionaryToImport = New-Object WebconImportConfigurationImportOnlySelectedDictionaryElement
$dictionaryToImport.dictionaryGuid = [System.Guid]::NewGuid()
$dictionaryToImport.overwriteElements = $true
$config.importOnlySelectedDictionaryElements.Add($dictionaryToImport)
#>

$config.importAllDocTemplates = $true
$config.importAllModifiedApplications = $true
$config.importAllModifiedProcesses = $true

$config.overwriteAllDocTemplates = $true
$config.importOnlySelectedDocTemplates = $null
<#
$docTemplateToImport = New-Object WebconImportConfigurationImportOnlySelectedDocTemplate
$docTemplateToImport.docTemplateGuid = [System.Guid]::NewGuid()
$docTemplateToImport.overwriteElements = $false
$config.importOnlySelectedDocTemplates.Add($docTemplateToImport)
#>
#endregion 

#region data sources / globals
$config.overwriteAllConnections = $false
$config.overwriteSelectedConnections = $null
#$config.overwriteSelectedConnections.Add([System.Guid]::NewGuid())

$config.overwriteAllDataSources = $false
$config.overwriteSelectedDataSources = $null
#$config.overwriteSelectedDataSources.Add([System.Guid]::NewGuid())

$config.overwriteAllGlobalAutomations = $false
$config.overwriteSelectedGlobalAutomations = $null
#$config.overwriteSelectedGlobalAutomations.Add([System.Guid]::NewGuid())

$config.overwriteAllGlobalBusinessRules = $false
$config.overwriteSelectedGlobalBusinessRules.Add("0cbe377b-46de-472a-b1a0-9a906b6f52f9")
#$config.overwriteSelectedGlobalBusinessRules = $null

$config.overwriteAllGlobalConstants = $false
$config.overwriteSelectedGlobalConstants = $null
#$config.overwriteSelectedGlobalConstants.Add([System.Guid]::NewGuid())

$config.overwriteAllGlobalFields = $false
$config.overwriteSelectedGlobalFields = $null
#$config.overwriteSelectedGlobalFields.Add([System.Guid]::NewGuid())

$config.overwriteAllGlobalFormRules = $false
$config.overwriteSelectedGlobalFormRules = $null
#$config.overwriteSelectedGlobalFormRules.Add([System.Guid]::NewGuid())
#endregion


#region  system
$config.overwriteAllPluginPackages = $false
$config.overwriteSelectedPluginPackages.Add([System.Guid]::NewGuid())
$config.overwriteSelectedPluginPackages = $null

$config.importBpsGroups = $false
$config.importOnlySelectedBpsGroups.Add("nonexistinggroup@bps.local") 


$config.overwriteSecuritySettings = $false
$config.overwriteAllBusinessEntitiesPrivilegeSettings = $false
$config.overwriteSelectedBusinessEntitiesPrivilegeSettings = $null
#$config.overwriteSelectedBusinessEntitiesPrivilegeSettings.Add([System.Guid]::NewGuid())
#region  system




ConvertTo-Json $config -Depth 10  | Out-File ".\Artifcats\importParameters.json" -Encoding utf8
