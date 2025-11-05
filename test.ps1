# Description: This script obtains an OAuth 2.0 token using client credentials
#              and makes authenticated API requests to NERIS endpoints
param(
    [Parameter(Mandatory=$true)]
    [string]$ClientId,
    
    [Parameter(Mandatory=$true)]
    [string]$ClientSecret,
    
    [string]$BaseURL = 'https://api-test.neris.fsri.org/v1',
    
    [string]$Endpoint = '/health'
)

# API URLs
$TokenURL = "$BaseURL/token"
$ApiURL = "$BaseURL$Endpoint"

# Ignore SSL certificate errors (including self-signed certificates)
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
    $certCallback = @"
        using System;
        using System.Net;
        using System.Net.Security;
        using System.Security.Cryptography.X509Certificates;
        public class ServerCertificateValidationCallback
        {
            public static void Ignore()
            {
                if(ServicePointManager.ServerCertificateValidationCallback ==null)
                {
                    ServicePointManager.ServerCertificateValidationCallback += 
                        delegate
                        (
                            Object obj, 
                            X509Certificate certificate, 
                            X509Chain chain, 
                            SslPolicyErrors errors
                        )
                        {
                            return true;
                        };
                }
            }
        }
"@
    Add-Type $certCallback
}
[ServerCertificateValidationCallback]::Ignore()

# Function to get OAuth 2.0 token
function Get-OAuth2Token {
    param(
        [string]$TokenUrl,
        [string]$ClientId,
        [string]$ClientSecret
    )
    
    Write-Output "Requesting OAuth 2.0 token from: $TokenUrl"
    
    # Prepare the request body for client_credentials grant
    $Body = @{
        grant_type = "client_credentials"
        client_id = $ClientId
        client_secret = $ClientSecret
    }
    
    # Convert body to URL-encoded format
    $BodyString = ($Body.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
    $BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($BodyString)
    
    # Create HTTP request for token
    $TokenRequest = [System.Net.HttpWebRequest]::Create($TokenUrl)
    $TokenRequest.Method = "POST"
    $TokenRequest.ContentType = "application/x-www-form-urlencoded"
    $TokenRequest.ContentLength = $BodyBytes.Length
    $TokenRequest.UserAgent = "MyPowerShellClient/1.0"
    
    try {
        # Write the body to the request stream
        $RequestStream = $TokenRequest.GetRequestStream()
        $RequestStream.Write($BodyBytes, 0, $BodyBytes.Length)
        $RequestStream.Close()
        
        # Get the token response
        $TokenResponse = $TokenRequest.GetResponse()
        $StreamReader = New-Object System.IO.StreamReader($TokenResponse.GetResponseStream())
        $TokenResponseContent = $StreamReader.ReadToEnd()
        
        # Clean up
        $StreamReader.Close()
        $TokenResponse.Close()
        
        # Parse JSON response to get access token
        $TokenData = $TokenResponseContent | ConvertFrom-Json
        
        Write-Output "Successfully obtained access token"
        return $TokenData.access_token
        
    } catch {
        Write-Error "Failed to obtain token: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $ErrorStream = $_.Exception.Response.GetResponseStream()
            $ErrorReader = New-Object System.IO.StreamReader($ErrorStream)
            $ErrorContent = $ErrorReader.ReadToEnd()
            Write-Error "Error response: $ErrorContent"
            $ErrorReader.Close()
        }
        return $null
    }
}

# Function to make authenticated API call
function Invoke-AuthenticatedApiCall {
    param(
        [string]$Url,
        [string]$AccessToken,
        [string]$Method = "GET"
    )
    
    Write-Output "Making authenticated $Method request to: $Url"
    
    # Create HTTP request with Authorization header
    $Request = [System.Net.HttpWebRequest]::Create($Url)
    $Request.UserAgent = "MyPowerShellClient/1.0"
    $Request.Method = $Method
    $Request.Headers.Add("Authorization", "Bearer $AccessToken")
    
    try {
        # Get the response
        $Response = $Request.GetResponse()
        
        # Read the response content
        $StreamReader = New-Object System.IO.StreamReader($Response.GetResponseStream())
        $ResponseContent = $StreamReader.ReadToEnd()
        
        # Clean up resources
        $StreamReader.Close()
        $Response.Close()
        
        return $ResponseContent
        
    } catch {
        Write-Error "Failed to make authenticated request: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $ErrorStream = $_.Exception.Response.GetResponseStream()
            $ErrorReader = New-Object System.IO.StreamReader($ErrorStream)
            $ErrorContent = $ErrorReader.ReadToEnd()
            Write-Error "Error response: $ErrorContent"
            $ErrorReader.Close()
        }
        return $null
    }
}

# Main execution
Write-Output "=== NERIS API OAuth 2.0 Authentication Test ==="
Write-Output "Base URL: $BaseURL"
Write-Output "Target Endpoint: $Endpoint"

# Step 1: Obtain OAuth 2.0 token
$AccessToken = Get-OAuth2Token -TokenUrl $TokenURL -ClientId $ClientId -ClientSecret $ClientSecret

if ($AccessToken) {
    Write-Output "`n=== Making Authenticated API Call ==="
    
    # Step 2: Make authenticated API call
    $ApiResponse = Invoke-AuthenticatedApiCall -Url $ApiURL -AccessToken $AccessToken
    
    if ($ApiResponse) {
        Write-Output "`nResponse from $ApiURL :"
        Write-Output $ApiResponse
        
        # Try to format as JSON if possible
        try {
            $JsonResponse = $ApiResponse | ConvertFrom-Json | ConvertTo-Json -Depth 10
            Write-Output "`nFormatted JSON Response:"
            Write-Output $JsonResponse
        } catch {
            # If not JSON, just display as-is
            Write-Output "Response is not JSON format"
        }
    }
} else {
    Write-Error "Could not obtain access token. Cannot proceed with API calls."
}