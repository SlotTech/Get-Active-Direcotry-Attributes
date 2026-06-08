#Run PowerShell as admin
# This script can be customized to read various on premise attributes

#Connection Library (Update with server change)
."E:\Scripts\Office365\lib\connection-lib.ps1"

# Get Authentication Variables
($ctprint,$appid,$tenantID) = MgGraph-ConnectionInfo

# Connect to Microsoft Graph PowerShell SDK
Write-host "Connecting to Microsoft Graph PowerShell SDK"	
Connect-MgGraph -TenantId $tenantID -ClientId $appid -CertificateThumbprint $ctprint -NoWelcome

# Use the $PSScriptRoot automatic variable to get the directory of the script.
$scriptPath = $PSScriptRoot

# Prompt the user for the name of the input CSV file.
# The user only needs to enter the filename, e.g., "users.csv".
$inputFilename = Read-Host -Prompt "Enter the name of the input CSV file (e.g., users.csv)"

# Construct the full path for the input CSV file.
$inputFilePath = Join-Path -Path $scriptPath -ChildPath $inputFilename

# Check if the input file exists.
if (-not (Test-Path -Path $inputFilePath -PathType Leaf)) {
    Write-Error "Input CSV file not found at: $inputFilePath"
    return
}

# Import the CSV file. This assumes the CSV has a header, such as 'upn'.
$csvData = Import-Csv -Path $inputFilePath

# Extract the UPNs from the imported data.
$upns = $csvData.upn

# Define the extension attributes you want to retrieve.
$attributesToGet = 'extensionAttribute2', 'extensionAttribute4', 'extensionAttribute14'

# Create an empty array to store the results.
$results = @()

# Initialize counters (if needed).
$counter = 0
$uct = $upns.Count

# Loop through the list of User Principal Names (UPNs).
foreach ($upn in $upns) {
    # Increment the counter.
    $counter++

    # Display progress.
    Write-Host "Processing $counter of $uct : $upn" -ForegroundColor Cyan

    try {
        # Retrieve the user object, specifying all desired attributes in the -Property parameter.
        $user = Get-MgUser -UserId $upn -Property "userPrincipalName,displayName,onPremisesExtensionAttributes" -ErrorAction Stop

        # Access the OnPremisesExtensionAttributes object.
        $onPremAttributes = $user.OnPremisesExtensionAttributes

        # Create a custom object with the UPN and the desired attributes.
        $properties = [PSCustomObject]@{
            'upn'                  = $upn
			'DisplayName'		   = $user.displayName
            'ExtensionAttribute2'  = $onPremAttributes.extensionAttribute2
            'ExtensionAttribute4'  = $onPremAttributes.extensionAttribute4
            'ExtensionAttribute14' = $onPremAttributes.extensionAttribute14
		}

        # Add the properties object to the results array.
        $results += $properties
    }
    catch {
        Write-Warning "Failed to retrieve attributes for UPN: $upn. Error: $_"
    }
}

# Construct the full path for the output CSV file in the same directory.
$outputFilePath = Join-Path -Path $scriptPath -ChildPath "Extension_Attributes_Output.csv"

# Export the results to the output CSV file.
Write-Host "Exporting results to: $outputFilePath" -ForegroundColor Green
$results | Export-Csv -Path $outputFilePath -NoTypeInformation

Write-Host "Script complete." -ForegroundColor Green
