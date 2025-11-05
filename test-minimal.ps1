param([string]$ClientId, [string]$ClientSecret, [switch]$Debug)

Write-Output "Testing basic authentication to NERIS API"

# Create Basic Auth header
$AuthString = "${ClientId}:${ClientSecret}"
$AuthBytes = [System.Text.Encoding]::UTF8.GetBytes($AuthString)
$AuthBase64 = [System.Convert]::ToBase64String($AuthBytes)

Write-Output "Auth String: $AuthBase64"

if ($Debug) {
    Write-Output ""
    Write-Output "DEBUG - Request Details:"
    Write-Output "  URL: https://api-test.neris.fsri.org/v1/token"
    Write-Output "  Method: POST"
    Write-Output "  Content-Type: application/x-www-form-urlencoded"
    Write-Output "  User-Agent: PowerShell-NERIS-Client/1.0 (Windows NT; PowerShell)"
    Write-Output "  Accept: application/json"
    Write-Output "  Authorization: Basic [REDACTED]"
    Write-Output "  Body: grant_type=client_credentials"
    Write-Output ""
}

try {
    $Request = [System.Net.HttpWebRequest]::Create("https://api-test.neris.fsri.org/v1/token")
    $Request.Method = "POST"
    $Request.ContentType = "application/x-www-form-urlencoded"
    $Request.UserAgent = "PowerShell-NERIS-Client/1.0 (Windows NT; PowerShell)"
    $Request.Accept = "application/json"
    $Request.Headers.Add("Authorization", "Basic $AuthBase64")
    
    $Body = "grant_type=client_credentials"
    $BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($Body)
    $Request.ContentLength = $BodyBytes.Length
    
    $Stream = $Request.GetRequestStream()
    $Stream.Write($BodyBytes, 0, $BodyBytes.Length)
    $Stream.Close()
    
    $Response = $Request.GetResponse()
    $Reader = New-Object System.IO.StreamReader($Response.GetResponseStream())
    $Content = $Reader.ReadToEnd()
    
    Write-Output "SUCCESS: Got response"
    Write-Output $Content
    
    $Reader.Close()
    $Response.Close()
} catch {
    $StatusCode = $_.Exception.Response.StatusCode
    $StatusDescription = $_.Exception.Response.StatusDescription
    
    Write-Output "ERROR: $($_.Exception.Message)"
    Write-Output "HTTP Status: $StatusCode - $StatusDescription"
    
    if ($StatusCode -eq "Forbidden") {
        Write-Output ""
        Write-Output "✅ GOOD NEWS: Authentication format is correct!"
        Write-Output "❌ Issue: Credentials are being rejected (403 Forbidden)"
        Write-Output ""
        Write-Output "This means:"
        Write-Output "• Basic Authentication is working properly"
        Write-Output "• The API endpoint is responding"
        Write-Output "• The client credentials may be invalid, expired, or lack permissions"
        Write-Output ""
        Write-Output "Next steps:"
        Write-Output "1. Verify the Client ID and Client Secret are correct"
        Write-Output "2. Check if the credentials have expired"
        Write-Output "3. Confirm the credentials have proper API access permissions"
        Write-Output "4. Contact NERIS support to verify credential status"
    }
    
    if ($_.Exception.Response) {
        try {
            $ErrorReader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $ErrorContent = $ErrorReader.ReadToEnd()
            Write-Output ""
            Write-Output "Server Error Response: $ErrorContent"
            $ErrorReader.Close()
        } catch {}
    }
}