# Example script showing how to use environment variables for credentials
# This is a safer approach for production use

# Set environment variables (run these commands first):
# $env:NERIS_CLIENT_ID = "your_client_id_here"
# $env:NERIS_CLIENT_SECRET = "your_client_secret_here"

# Check if environment variables are set
if (-not $env:NERIS_CLIENT_ID) {
    Write-Error "NERIS_CLIENT_ID environment variable not set"
    Write-Output "Please run: `$env:NERIS_CLIENT_ID = 'your_client_id'"
    exit 1
}

if (-not $env:NERIS_CLIENT_SECRET) {
    Write-Error "NERIS_CLIENT_SECRET environment variable not set"
    Write-Output "Please run: `$env:NERIS_CLIENT_SECRET = 'your_client_secret'"
    exit 1
}

# Call the main script with environment variables
Write-Output "Using credentials from environment variables..."
.\test.ps1 -ClientId $env:NERIS_CLIENT_ID -ClientSecret $env:NERIS_CLIENT_SECRET -Endpoint "/health"