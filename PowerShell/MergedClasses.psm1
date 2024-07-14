class WebconImportConfigurationImportConfiguration {
    [bool]$importAllNewApplications
    [bool]$importAllModifiedApplications
    [bool]$importAllPresentationObjects
    [bool]$importAllNewProcesses
    [bool]$importAllModifiedProcesses
    [System.Collections.Generic.List[WebconImportConfigurationImportOnlySelectedApplication]]$importOnlySelectedApplications = [System.Collections.Generic.List[WebconImportConfigurationImportOnlySelectedApplication]]::new()
    [bool]$importBpsGroups
    [System.Collections.Generic.List[string]]$importOnlySelectedBpsGroups = [System.Collections.Generic.List[string]]::new()
    [bool]$overwriteAllBusinessEntitiesPrivilegeSettings
    [System.Collections.Generic.List[string]]$overwriteSelectedBusinessEntitiesPrivilegeSettings = [System.Collections.Generic.List[string]]::new()
    [bool]$overwriteSecuritySettings
    [bool]$overwriteAllGlobalBusinessRules
    [System.Collections.Generic.List[string]]$overwriteSelectedGlobalBusinessRules = [System.Collections.Generic.List[string]]::new()
    [bool]$overwriteAllGlobalFormRules
    [System.Collections.Generic.List[string]]$overwriteSelectedGlobalFormRules = [System.Collections.Generic.List[string]]::new()
    [bool]$overwriteAllGlobalFields
    [System.Collections.Generic.List[string]]$overwriteSelectedGlobalFields = [System.Collections.Generic.List[string]]::new()
    [bool]$overwriteAllGlobalConstants
    [System.Collections.Generic.List[string]]$overwriteSelectedGlobalConstants = [System.Collections.Generic.List[string]]::new()
    [bool]$overwriteAllGlobalAutomations
    [System.Collections.Generic.List[string]]$overwriteSelectedGlobalAutomations = [System.Collections.Generic.List[string]]::new()
    [bool]$overwriteAllDataSources
    [System.Collections.Generic.List[string]]$overwriteSelectedDataSources = [System.Collections.Generic.List[string]]::new()
    [bool]$overwriteAllConnections
    [System.Collections.Generic.List[string]]$overwriteSelectedConnections = [System.Collections.Generic.List[string]]::new()
    [bool]$overwriteAllPluginPackages
    [System.Collections.Generic.List[string]]$overwriteSelectedPluginPackages = [System.Collections.Generic.List[string]]::new()
    [bool]$overwriteAllProcessesDeploymentMode
    [string]$overwriteAllProcessesDeploymentModeMailRecipient
    [bool]$importAllDictionaryElements
    [bool]$overwriteAllDictionaryItems
    [System.Collections.Generic.List[WebconImportConfigurationImportOnlySelectedDictionaryElement]]$importOnlySelectedDictionaryElements = [System.Collections.Generic.List[WebconImportConfigurationImportOnlySelectedDictionaryElement]]::new()
    [bool]$importAllDocTemplates
    [bool]$overwriteAllDocTemplates
    [System.Collections.Generic.List[WebconImportConfigurationImportOnlySelectedDocTemplate]]$importOnlySelectedDocTemplates = [System.Collections.Generic.List[WebconImportConfigurationImportOnlySelectedDocTemplate]]::new()
    [bool]$ignoreNoExistingGUID
    WebconImportConfigurationImportConfiguration () {
    }
    WebconImportConfigurationImportConfiguration ([PSCustomObject] $json) {
        $this.Init($json) 
    }
    WebconImportConfigurationImportConfiguration ([PSCustomObject] $json, [scriptblock] $action) {
        $this.Init($json)            
        if ($null -ne $action ) { 
            Invoke-Command -ScriptBlock $action -ArgumentList $json, $this
        }
    }
    hidden Init($json) {
        if ($null -ne $json."importAllNewApplications") { $this.importAllNewApplications = $json.importAllNewApplications }
        if ($null -ne $json."importAllModifiedApplications") { $this.importAllModifiedApplications = $json.importAllModifiedApplications }
        if ($null -ne $json."importAllPresentationObjects") { $this.importAllPresentationObjects = $json.importAllPresentationObjects }
        if ($null -ne $json."importAllNewProcesses") { $this.importAllNewProcesses = $json.importAllNewProcesses }
        if ($null -ne $json."importAllModifiedProcesses") { $this.importAllModifiedProcesses = $json.importAllModifiedProcesses }
        $json.importOnlySelectedApplications | ForEach-Object { $this.importOnlySelectedApplications.add([WebconImportConfigurationImportOnlySelectedApplication]::new($_)) }
        if ($null -ne $json."importBpsGroups") { $this.importBpsGroups = $json.importBpsGroups }
        $json.importOnlySelectedBpsGroups | ForEach-Object { $this.importOnlySelectedBpsGroups.add($_) }
        if ($null -ne $json."overwriteAllBusinessEntitiesPrivilegeSettings") { $this.overwriteAllBusinessEntitiesPrivilegeSettings = $json.overwriteAllBusinessEntitiesPrivilegeSettings }
        $json.overwriteSelectedBusinessEntitiesPrivilegeSettings | ForEach-Object { $this.overwriteSelectedBusinessEntitiesPrivilegeSettings.add($_) }
        if ($null -ne $json."overwriteSecuritySettings") { $this.overwriteSecuritySettings = $json.overwriteSecuritySettings }
        if ($null -ne $json."overwriteAllGlobalBusinessRules") { $this.overwriteAllGlobalBusinessRules = $json.overwriteAllGlobalBusinessRules }
        $json.overwriteSelectedGlobalBusinessRules | ForEach-Object { $this.overwriteSelectedGlobalBusinessRules.add($_) }
        if ($null -ne $json."overwriteAllGlobalFormRules") { $this.overwriteAllGlobalFormRules = $json.overwriteAllGlobalFormRules }
        $json.overwriteSelectedGlobalFormRules | ForEach-Object { $this.overwriteSelectedGlobalFormRules.add($_) }
        if ($null -ne $json."overwriteAllGlobalFields") { $this.overwriteAllGlobalFields = $json.overwriteAllGlobalFields }
        $json.overwriteSelectedGlobalFields | ForEach-Object { $this.overwriteSelectedGlobalFields.add($_) }
        if ($null -ne $json."overwriteAllGlobalConstants") { $this.overwriteAllGlobalConstants = $json.overwriteAllGlobalConstants }
        $json.overwriteSelectedGlobalConstants | ForEach-Object { $this.overwriteSelectedGlobalConstants.add($_) }
        if ($null -ne $json."overwriteAllGlobalAutomations") { $this.overwriteAllGlobalAutomations = $json.overwriteAllGlobalAutomations }
        $json.overwriteSelectedGlobalAutomations | ForEach-Object { $this.overwriteSelectedGlobalAutomations.add($_) }
        if ($null -ne $json."overwriteAllDataSources") { $this.overwriteAllDataSources = $json.overwriteAllDataSources }
        $json.overwriteSelectedDataSources | ForEach-Object { $this.overwriteSelectedDataSources.add($_) }
        if ($null -ne $json."overwriteAllConnections") { $this.overwriteAllConnections = $json.overwriteAllConnections }
        $json.overwriteSelectedConnections | ForEach-Object { $this.overwriteSelectedConnections.add($_) }
        if ($null -ne $json."overwriteAllPluginPackages") { $this.overwriteAllPluginPackages = $json.overwriteAllPluginPackages }
        $json.overwriteSelectedPluginPackages | ForEach-Object { $this.overwriteSelectedPluginPackages.add($_) }
        if ($null -ne $json."overwriteAllProcessesDeploymentMode") { $this.overwriteAllProcessesDeploymentMode = $json.overwriteAllProcessesDeploymentMode }
        if ($null -ne $json."overwriteAllProcessesDeploymentModeMailRecipient") { $this.overwriteAllProcessesDeploymentModeMailRecipient = $json.overwriteAllProcessesDeploymentModeMailRecipient }
        if ($null -ne $json."importAllDictionaryElements") { $this.importAllDictionaryElements = $json.importAllDictionaryElements }
        if ($null -ne $json."overwriteAllDictionaryItems") { $this.overwriteAllDictionaryItems = $json.overwriteAllDictionaryItems }
        $json.importOnlySelectedDictionaryElements | ForEach-Object { $this.importOnlySelectedDictionaryElements.add([WebconImportConfigurationImportOnlySelectedDictionaryElement]::new($_)) }
        if ($null -ne $json."importAllDocTemplates") { $this.importAllDocTemplates = $json.importAllDocTemplates }
        if ($null -ne $json."overwriteAllDocTemplates") { $this.overwriteAllDocTemplates = $json.overwriteAllDocTemplates }
        $json.importOnlySelectedDocTemplates | ForEach-Object { $this.importOnlySelectedDocTemplates.add([WebconImportConfigurationImportOnlySelectedDocTemplate]::new($_)) }
        if ($null -ne $json."ignoreNoExistingGUID") { $this.ignoreNoExistingGUID = $json.ignoreNoExistingGUID }
    }
}
class WebconImportConfigurationImportOnlySelectedApplication {
    [string]$appGuid
    [System.Collections.Generic.List[string]]$importOnlySelectedPresentationsObjects = [System.Collections.Generic.List[string]]::new()
    [System.Collections.Generic.List[WebconImportConfigurationImportOnlySelectedProcess]]$importOnlySelectedProcesses = [System.Collections.Generic.List[WebconImportConfigurationImportOnlySelectedProcess]]::new()
    WebconImportConfigurationImportOnlySelectedApplication () {
    }
    WebconImportConfigurationImportOnlySelectedApplication ([PSCustomObject] $json) {
        $this.Init($json) 
    }
    WebconImportConfigurationImportOnlySelectedApplication ([PSCustomObject] $json, [scriptblock] $action) {
        $this.Init($json)            
        if ($null -ne $action ) { 
            Invoke-Command -ScriptBlock $action -ArgumentList $json, $this
        }
    }
    hidden Init($json) {
        if ($null -ne $json."appGuid") { $this.appGuid = $json.appGuid }
        $json.importOnlySelectedPresentationsObjects | ForEach-Object { $this.importOnlySelectedPresentationsObjects.add($_) }
        $json.importOnlySelectedProcesses | ForEach-Object { $this.importOnlySelectedProcesses.add([WebconImportConfigurationImportOnlySelectedProcess]::new($_)) }
    }
}
class WebconImportConfigurationImportOnlySelectedDictionaryElement {
    [string]$dictionaryGuid
    [bool]$overwriteElements
    WebconImportConfigurationImportOnlySelectedDictionaryElement () {
    }
    WebconImportConfigurationImportOnlySelectedDictionaryElement ([PSCustomObject] $json) {
        $this.Init($json) 
    }
    WebconImportConfigurationImportOnlySelectedDictionaryElement ([PSCustomObject] $json, [scriptblock] $action) {
        $this.Init($json)            
        if ($null -ne $action ) { 
            Invoke-Command -ScriptBlock $action -ArgumentList $json, $this
        }
    }
    hidden Init($json) {
        if ($null -ne $json."dictionaryGuid") { $this.dictionaryGuid = $json.dictionaryGuid }
        if ($null -ne $json."overwriteElements") { $this.overwriteElements = $json.overwriteElements }
    }
}
class WebconImportConfigurationImportOnlySelectedDocTemplate {
    [string]$docTemplateGuid
    [bool]$overwriteElements
    WebconImportConfigurationImportOnlySelectedDocTemplate () {
    }
    WebconImportConfigurationImportOnlySelectedDocTemplate ([PSCustomObject] $json) {
        $this.Init($json) 
    }
    WebconImportConfigurationImportOnlySelectedDocTemplate ([PSCustomObject] $json, [scriptblock] $action) {
        $this.Init($json)            
        if ($null -ne $action ) { 
            Invoke-Command -ScriptBlock $action -ArgumentList $json, $this
        }
    }
    hidden Init($json) {
        if ($null -ne $json."docTemplateGuid") { $this.docTemplateGuid = $json.docTemplateGuid }
        if ($null -ne $json."overwriteElements") { $this.overwriteElements = $json.overwriteElements }
    }
}
class WebconImportConfigurationImportOnlySelectedProcess {
    [string]$processGuid
    [bool]$deploymentMode
    [string]$deploymentModeMailRecipient
    WebconImportConfigurationImportOnlySelectedProcess () {
    }
    WebconImportConfigurationImportOnlySelectedProcess ([PSCustomObject] $json) {
        $this.Init($json) 
    }
    WebconImportConfigurationImportOnlySelectedProcess ([PSCustomObject] $json, [scriptblock] $action) {
        $this.Init($json)            
        if ($null -ne $action ) { 
            Invoke-Command -ScriptBlock $action -ArgumentList $json, $this
        }
    }
    hidden Init($json) {
        if ($null -ne $json."processGuid") { $this.processGuid = $json.processGuid }
        if ($null -ne $json."deploymentMode") { $this.deploymentMode = $json.deploymentMode }
        if ($null -ne $json."deploymentModeMailRecipient") { $this.deploymentModeMailRecipient = $json.deploymentModeMailRecipient }
    }
}
class WebconImportImportStartParams {
    [int]$chunkSize
    [int]$totalSize
    WebconImportImportStartParams () {
    }
    WebconImportImportStartParams ([PSCustomObject] $json) {
        $this.Init($json) 
    }
    WebconImportImportStartParams ([PSCustomObject] $json, [scriptblock] $action) {
        $this.Init($json)            
        if ($null -ne $action ) { 
            Invoke-Command -ScriptBlock $action -ArgumentList $json, $this
        }
    }
    hidden Init($json) {
        if ($null -ne $json."chunkSize") { $this.chunkSize = $json.chunkSize }
        if ($null -ne $json."totalSize") { $this.totalSize = $json.totalSize }
    }
}
class WebconImportImportStartResponse {
    [string]$sessionId
    WebconImportImportStartResponse () {
    }
    WebconImportImportStartResponse ([PSCustomObject] $json) {
        $this.Init($json) 
    }
    WebconImportImportStartResponse ([PSCustomObject] $json, [scriptblock] $action) {
        $this.Init($json)            
        if ($null -ne $action ) { 
            Invoke-Command -ScriptBlock $action -ArgumentList $json, $this
        }
    }
    hidden Init($json) {
        if ($null -ne $json."sessionId") { $this.sessionId = $json.sessionId }
    }
}
class WebconImportImportStatus {
    [int]$status
    [string]$logs
    WebconImportImportStatus () {
    }
    WebconImportImportStatus ([PSCustomObject] $json) {
        $this.Init($json) 
    }
    WebconImportImportStatus ([PSCustomObject] $json, [scriptblock] $action) {
        $this.Init($json)            
        if ($null -ne $action ) { 
            Invoke-Command -ScriptBlock $action -ArgumentList $json, $this
        }
    }
    hidden Init($json) {
        if ($null -ne $json."status") { $this.status = $json.status }
        if ($null -ne $json."logs") { $this.logs = $json.logs }
    }
}
class WebconImportImportUploadResponse {
    [int]$nextChunkIndex
    WebconImportImportUploadResponse () {
    }
    WebconImportImportUploadResponse ([PSCustomObject] $json) {
        $this.Init($json) 
    }
    WebconImportImportUploadResponse ([PSCustomObject] $json, [scriptblock] $action) {
        $this.Init($json)            
        if ($null -ne $action ) { 
            Invoke-Command -ScriptBlock $action -ArgumentList $json, $this
        }
    }
    hidden Init($json) {
        if ($null -ne $json."nextChunkIndex") { $this.nextChunkIndex = $json.nextChunkIndex }
    }
}



enum ImportStatus 
{
    Error
    Completed
    CompletedWithError
    NotExist
    Created
    InProgress
}
class WEBCONConfig {
    [string]$ClientId
    [string]$ClientSecret
    [string]$Hostname
    [string]$ApiVersion   
    
    [void]UpdateFromConfig([WEBCONConfig] $config) {
        $this.ClientId = $config.ClientId
        $this.ClientSecret = $config.ClientSecret
        $this.Hostname = $config.Hostname
        $this.ApiVersion = $config.ApiVersion
    }
}




