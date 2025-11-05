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
.\neris-client.ps1 -ClientId "your_client_id" -ClientSecret "your_client_secret"
```

### With Debug Output

```powershell
.\neris-client.ps1 -ClientId "your_client_id" -ClientSecret "your_client_secret" -DebugMode
```

### Different API Endpoint

```powershell
.\neris-client.ps1 -ClientId "your_client_id" -ClientSecret "your_client_secret" -Endpoint "/entity"
```

### Use Production Environment

```powershell
.\neris-client.ps1 -ClientId "your_client_id" -ClientSecret "your_client_secret" -BaseURL "https://api.neris.fsri.org/v1"
```

### Using Environment Variables (Recommended for Security)

```powershell
.\example-with-env-vars.ps1
```

### Quick Testing/Debugging

```powershell
.\test-minimal.ps1 -ClientId "your_client_id" -ClientSecret "your_client_secret" -Debug
```

## Parameters

- **ClientId** (Required): Your OAuth 2.0 client ID
- **ClientSecret** (Required): Your OAuth 2.0 client secret  
- **BaseURL** (Optional): API base URL (default: https://api-test.neris.fsri.org/v1)
- **Endpoint** (Optional): API endpoint to call (default: /health)
- **DebugMode** (Optional): Enable detailed debugging output

## Authentication Flow (Official NERIS Method)

Based on official NERIS documentation:

### Step 1: Get Access Token
*"The request to the /token endpoint must contain an Authorization header with a Basic auth consisting of client id and client secret delimited by : and base64 encoded."*

```http
POST /v1/token HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Authorization: Basic base64(client_id:client_secret)

grant_type=client_credentials
```

### Step 2: Use Bearer Token for API Calls  
*"Use the access token returned from the call to /token as the bearer token in the Authorization header of subsequent requests"*

```http
GET /v1/health HTTP/1.1
Authorization: Bearer <access_token>
Accept: application/json
```

### PowerShell Implementation:
1. **Token Request**: `Authorization: Basic base64(client_id:client_secret)`
2. **API Calls**: `Authorization: Bearer <access_token>`

## Example Output

```
=== NERIS API OAuth 2.0 Authentication Test ===
Base URL: https://api-test.neris.fsri.org/v1
Target Endpoint: /entity
Requesting OAuth 2.0 token from: https://api-test.neris.fsri.org/v1/token
Successfully obtained access token

=== Making Authenticated API Call ===
Making authenticated GET request to: https://api-test.neris.fsri.org/v1/entity

Response from https://api-test.neris.fsri.org/v1/entity :
{"page_size": 0, "page_count": 0,...}

Formatted JSON Response:
{
  "page_size": 0,
  "page_count": 0,
  "page_number": 0,
  "total_count": 0,
  "entities": [
}
```

## Security Notes

- Never commit client credentials to version control
- Use environment variables or secure credential storage in production
- The script bypasses SSL validation for test environments - remove this for production use

## Common Endpoints

After authentication, you can test other endpoints:

- `/health` - Health check (Unauth)
- `/user` - User management
- `/entity` - Department data
- `/incident` - Incident data

## Troubleshooting

### General Issues
- Ensure your client credentials are valid
- Check that the API base URL is correct
- Verify network connectivity to the API endpoints
- Review error messages for specific authentication issues

### 500 Internal Server Error on Token Endpoint
If you're getting a 500 error when requesting tokens, try these steps:

1. **Enable Debug Mode**:
   ```powershell
   .\test.ps1 -ClientId "your_id" -ClientSecret "your_secret" -Debug
   ```

2. **Try Basic Authentication Method**:
   ```powershell
   .\test.ps1 -ClientId "your_id" -ClientSecret "your_secret" -UseBasicAuth -Debug
   ```

3. **Run Endpoint Diagnostics**:
   ```powershell
   .\debug-token-endpoint.ps1 -ClientId "your_id" -ClientSecret "your_secret"
   ```

4. **Check for Common Issues**:
   - Verify the token URL is exactly: `https://api-test.neris.fsri.org/v1/token`
   - Ensure client credentials don't contain special characters that need URL encoding
   - Check if the API server is experiencing issues
   - Contact the API administrator if the 500 error persists

## Project Files

- **`neris-client.ps1`** - Main NERIS API client (complete OAuth 2.0 implementation)
- **`test-minimal.ps1`** - Minimal test script for quick debugging
- **`example-with-env-vars.ps1`** - Example using environment variables for secure credential handling
- **`config.template.ps1`** - Template for configuration file (copy to `config.ps1` and fill in values)
- **`README.md`** - This documentation
- **`.gitignore`** - Prevents accidental credential commits

## Implementation Notes

The client implements the exact NERIS OAuth 2.0 specification with WAF-friendly headers to ensure reliable authentication.

# About NERIS

NERIS is the National Emergency Response Information System, learn more at https://neris.fsri.org
