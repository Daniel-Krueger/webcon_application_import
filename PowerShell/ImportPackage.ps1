#using module  .\MergedClasses.psm1


$currentDirectory = Get-Item -Path .
if ($currentDirectory.Name -ne "PowerShell") {
    Set-Location .\"PowerShell"
}
Import-Module .\UtitilityFunctions.psm1 -Force -ErrorAction Stop

$dbId = 1
$importFilePath = ".\Artifcats\DummyApplication.bpe"
$importConfigurationFilePath = ".\Artifcats\importParameters.json"

$result = Import-WEBCONPackage -dbId $dbId -importFilePath $importFilePath -importConfigurationFilePath $importConfigurationFilePath
#$result = Import-WEBCONPackage -dbId $dbId -importFilePath $importFilePath