# NERIS API PowerShell Client - Complete Working Version
# Based on NERIS OAuth 2.0 documentation with proper WAF-friendly headers

param(
    [Parameter(Mandatory=$true)]
    [string]$ClientId,
    
    [Parameter(Mandatory=$true)]
    [string]$ClientSecret,
    
    [string]$BaseURL = 'https://api-test.neris.fsri.org/v1',
    
    [string]$Endpoint = '/health',
    
    [switch]$DebugMode
)

Write-Output "=== NERIS API PowerShell Client ==="
Write-Output "Token URL: $BaseURL/token"
Write-Output "API URL: $BaseURL$Endpoint"
Write-Output ""

# Step 1: Get OAuth 2.0 Token
Write-Output "Step 1: Getting OAuth 2.0 token..."

# Create Basic Auth header (NERIS requirement)
$AuthString = "${ClientId}:${ClientSecret}"
$AuthBytes = [System.Text.Encoding]::UTF8.GetBytes($AuthString)
$AuthBase64 = [System.Convert]::ToBase64String($AuthBytes)

if ($DebugMode) {
    Write-Output "DEBUG: Authorization header created"
    Write-Output "DEBUG: Basic Auth: $AuthBase64"
}

try {
    # Token request with proper headers (including User-Agent for WAF)
    $TokenRequest = [System.Net.HttpWebRequest]::Create("$BaseURL/token")
    $TokenRequest.Method = "POST"
    $TokenRequest.ContentType = "application/x-www-form-urlencoded"
    $TokenRequest.UserAgent = "PowerShell-NERIS-Client/1.0 (Windows NT; PowerShell)"
    $TokenRequest.Accept = "application/json"
    $TokenRequest.Headers.Add("Authorization", "Basic $AuthBase64")
    
    $Body = "grant_type=client_credentials"
    $BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($Body)
    $TokenRequest.ContentLength = $BodyBytes.Length
    
    if ($DebugMode) {
        Write-Output "DEBUG: Sending token request..."
        Write-Output "DEBUG: POST $BaseURL/token"
        Write-Output "DEBUG: Content-Type: application/x-www-form-urlencoded" 
        Write-Output "DEBUG: User-Agent: PowerShell-NERIS-Client/1.0 (Windows NT; PowerShell)"
        Write-Output "DEBUG: Body: $Body"
    }
    
    # Send request
    $Stream = $TokenRequest.GetRequestStream()
    $Stream.Write($BodyBytes, 0, $BodyBytes.Length)
    $Stream.Close()
    
    # Get token response
    $TokenResponse = $TokenRequest.GetResponse()
    $TokenReader = New-Object System.IO.StreamReader($TokenResponse.GetResponseStream())
    $TokenContent = $TokenReader.ReadToEnd()
    $TokenReader.Close()
    $TokenResponse.Close()
    
    if ($DebugMode) {
        Write-Output "DEBUG: Token response received"
        Write-Output "DEBUG: $TokenContent"
    }
    
    # Parse token response
    $TokenData = $TokenContent | ConvertFrom-Json
    
    if ($TokenData.access_token) {
        Write-Output "✅ OAuth 2.0 token obtained successfully!"
        Write-Output "   Token type: $($TokenData.token_type)"
        Write-Output "   Expires in: $($TokenData.expires_in) seconds"
        
        $AccessToken = $TokenData.access_token
        
        # Step 2: Make authenticated API call
        Write-Output ""
        Write-Output "Step 2: Making authenticated API call..."
        
        try {
            # API request with Bearer token
            $ApiRequest = [System.Net.HttpWebRequest]::Create("$BaseURL$Endpoint")
            $ApiRequest.Method = "GET"
            $ApiRequest.UserAgent = "PowerShell-NERIS-Client/1.0 (Windows NT; PowerShell)"
            $ApiRequest.Accept = "application/json"
            $ApiRequest.Headers.Add("Authorization", "Bearer $AccessToken")
            
            if ($DebugMode) {
                Write-Output "DEBUG: Sending API request..."
                Write-Output "DEBUG: GET $BaseURL$Endpoint"
                Write-Output "DEBUG: Authorization: Bearer [TOKEN]"
            }
            
            # Get API response
            $ApiResponse = $ApiRequest.GetResponse()
            $ApiReader = New-Object System.IO.StreamReader($ApiResponse.GetResponseStream())
            $ApiContent = $ApiReader.ReadToEnd()
            $ApiReader.Close()
            $ApiResponse.Close()
            
            Write-Output "✅ API call successful!"
            Write-Output ""
            Write-Output "=== API Response ==="
            Write-Output $ApiContent
            
            # Try to format as JSON
            try {
                $FormattedJson = $ApiContent | ConvertFrom-Json | ConvertTo-Json -Depth 10
                Write-Output ""
                Write-Output "=== Formatted JSON Response ==="
                Write-Output $FormattedJson
            } catch {
                Write-Output ""
                Write-Output "Note: Response is not JSON format"
            }
            
            Write-Output ""
            Write-Output "🎉 NERIS API integration completed successfully!"
            
        } catch {
            Write-Error "❌ API call failed: $($_.Exception.Message)"
            
            if ($_.Exception.Response) {
                $ApiStatusCode = $_.Exception.Response.StatusCode
                Write-Output "API HTTP Status: $ApiStatusCode"
                
                try {
                    $ApiErrorReader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                    $ApiErrorContent = $ApiErrorReader.ReadToEnd()
                    Write-Output "API Error Response: $ApiErrorContent"
                    $ApiErrorReader.Close()
                } catch {}
            }
        }
        
    } else {
        Write-Error "❌ No access_token found in response: $TokenContent"
    }
    
} catch {
    Write-Error "❌ Token request failed: $($_.Exception.Message)"
    
    if ($_.Exception.Response) {
        $StatusCode = $_.Exception.Response.StatusCode
        Write-Output "HTTP Status: $StatusCode"
        
        if ($StatusCode -eq "Forbidden") {
            Write-Output ""
            Write-Output "💡 This was likely a WAF block. Make sure User-Agent header is included."
        }
        
        try {
            $ErrorReader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $ErrorContent = $ErrorReader.ReadToEnd()
            Write-Output "Error Response: $ErrorContent"
            $ErrorReader.Close()
        } catch {}
    }
}