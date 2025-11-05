# Configuration template for NERIS API
# Copy this file to config.ps1 and fill in your actual values
# DO NOT commit config.ps1 to version control!

# OAuth 2.0 Credentials
$ClientId = "your_client_id_here"
$ClientSecret = "your_client_secret_here"

# API Configuration  
$BaseURL = "https://api-test.neris.fsri.org/v1"  # Test environment
# $BaseURL = "https://api.neris.fsri.org/v1"      # Production environment

# Default endpoint to test
$DefaultEndpoint = "/health"

# Export variables for use in other scripts
$env:NERIS_CLIENT_ID = $ClientId
$env:NERIS_CLIENT_SECRET = $ClientSecret
$env:NERIS_BASE_URL = $BaseURL

Write-Output "Configuration loaded:"
Write-Output "  Base URL: $BaseURL"
Write-Output "  Client ID: $($ClientId.Substring(0, [Math]::Min(8, $ClientId.Length)))..." 
Write-Output "  Default Endpoint: $DefaultEndpoint"