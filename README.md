# NERIS API OAuth 2.0 PowerShell Client

This PowerShell script demonstrates how to authenticate with the NERIS API using OAuth 2.0 client credentials flow and make authenticated API calls.

## Features

- OAuth 2.0 client credentials authentication
- SSL certificate validation bypass (for test environments)
- Authenticated API calls with Bearer token
- JSON response formatting
- Comprehensive error handling

## Usage

### Basic Usage

```powershell
.\test.ps1 -ClientId "your_client_id" -ClientSecret "your_client_secret"
```

### Specify Different Endpoint

```powershell
.\test.ps1 -ClientId "your_client_id" -ClientSecret "your_client_secret" -Endpoint "/entity"
```

### Use Production Environment

```powershell
.\test.ps1 -ClientId "your_client_id" -ClientSecret "your_client_secret" -BaseURL "https://api.neris.fsri.org/v1"
```

## Parameters

- **ClientId** (Required): Your OAuth 2.0 client ID
- **ClientSecret** (Required): Your OAuth 2.0 client secret  
- **BaseURL** (Optional): API base URL (default: https://api-test.neris.fsri.org/v1)
- **Endpoint** (Optional): API endpoint to call (default: /health)

## Authentication Flow

1. **Token Request**: Makes a POST request to `/v1/token` with:
   - `grant_type=client_credentials`
   - Your client ID and secret
   - Content-Type: `application/x-www-form-urlencoded`

2. **API Call**: Uses the returned access token in the Authorization header:
   - `Authorization: Bearer <access_token>`

## Example Output

```
=== NERIS API OAuth 2.0 Authentication Test ===
Base URL: https://api-test.neris.fsri.org/v1
Target Endpoint: /health
Requesting OAuth 2.0 token from: https://api-test.neris.fsri.org/v1/token
Successfully obtained access token

=== Making Authenticated API Call ===
Making authenticated GET request to: https://api-test.neris.fsri.org/v1/health

Response from https://api-test.neris.fsri.org/v1/health :
{"status": "ok", "timestamp": "2025-11-04T..."}

Formatted JSON Response:
{
  "status": "ok",
  "timestamp": "2025-11-04T..."
}
```

## Security Notes

- Never commit client credentials to version control
- Use environment variables or secure credential storage in production
- The script bypasses SSL validation for test environments - remove this for production use

## Common Endpoints

After authentication, you can test other endpoints:

- `/health` - Health check
- `/user` - User management
- `/entity` - Department data
- `/incdient` - Incident data

## Troubleshooting

- Ensure your client credentials are valid
- Check that the API base URL is correct
- Verify network connectivity to the API endpoints
- Review error messages for specific authentication issues