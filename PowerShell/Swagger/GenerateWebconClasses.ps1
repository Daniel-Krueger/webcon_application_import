
#Making sure that we the folder in which the scripts are located.
$currentDirectory = Get-Item -Path .
if ($currentDirectory.Name -ne "PowerShell") {
    Set-Location .\"PowerShell"
}

Import-Module ".\Swagger\UtilityFunctions.psm1" -Force

# Load Swagger JSON
$swaggerPath = "./Swagger/swagger.json"
$swagger = Get-Content $swaggerPath -Encoding UTF8 | ConvertFrom-Json

# Variable prepartion so it's easier to debug 
$Definitions = $swagger.components.schemas
$output = New-Object System.Text.StringBuilder
$resolvedDefinitions = [System.Collections.Generic.Dictionary[string, boolean]]::new()
$classInherits = [System.Collections.Generic.Dictionary[string, string]]::new()

# Actual code for generating the classes

# Get the names of all elements that start with "6.0.Import."
$importSchemas = $swagger.components.schemas.PSObject.Properties.Name | Where-Object { $_ -like '6.0.Import.*' }

#New-WebconPowerShellClass -StartingDefinition $importSchemas[0] -Definitions $swagger.components.schemas -output $output -ResolvedDefinitions $resolvedDefinitions -ClassInherits $classInherits  

foreach ($importSchema in $importSchemas) {
    New-WebconPowerShellClass -StartingDefinition $importSchema -Definitions $swagger.components.schemas -output $output -ResolvedDefinitions $resolvedDefinitions -ClassInherits $classInherits  
}

$output.ToString() | Out-File -Encoding utf8 -Force -FilePath "./Classes/API.psm1"