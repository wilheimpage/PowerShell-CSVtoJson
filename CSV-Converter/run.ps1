using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Look for a JSON object property called fileContent.

$fileContent = $Request.Body.fileContent

# If the required object property is missing, return a string response

$body = "This HTTP triggered function executed successfully. Pass a base64 encoded file in the body with the following schema: {`"fileContent`":`"Base64 encoded CSV goes here`"}"
$contentType = "text/plain"

#If it is present, do stuff
if ($fileContent) {

  # Decode the Base64 string into text  
  $decodedCSV=  [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($fileContent))

  # Convert it to a PSObject using ConvertFrom-CSV
  $convertedObject = ConvertFrom-Csv -InputObject $decodedCSV

  # Now convert the PSObject into JSON format
  $JsonOutput = ConvertTo-Json -InputObject $convertedObject

  # Now return the output of that function
  $body = $JsonOutput
  $contentType = "application/json"
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
    Headers = @{ContentType = $contentType}

})
