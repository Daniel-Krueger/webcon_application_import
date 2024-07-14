using module  .\MergedClasses.psm1


$currentDirectory = Get-Item -Path .
if ($currentDirectory.Name -ne "PowerShell") {
    Set-Location .\"PowerShell"
}
Import-Module .\UtitilityFunctions.psm1 -Force -ErrorAction Stop

$dbId = 1
$importFilePath = ".\DummyApplication.bpe"
$importConfigurationFilePath = ".\DummyApplication_ImportParameters.json"

$result = Import-WEBCONPackage -dbId $dbId -importFilePath $importFilePath -importConfigurationFilePath $importConfigurationFilePath