. ./MyConfiguration.ps1

$baseURL = "https://$Domain/api/v1/rest/context/$Context"

# Function to get grants
function Get-DestinyGrants {
    param(
        [string]$appId,
        [string[]]$appFamilyIds,
        [string[]]$principalIds,
        [string]$subcontextId
    )

    # Construct the URL
    $url = "$baseURL/auth/grants"

    # Construct query parameters
    $queryParams = @{
        appId = $appId
        appFamilyIds = $appFamilyIds -join ','
        principalIds = $principalIds -join ','
        subcontextId = $subcontextId
    }

    # Make the API request
    $response = Invoke-RestMethod -Uri $url -Method Get -Query $queryParams

    # Return the response
    return $response
}

# Function to get access token
function Get-DestinyAccessToken {
    param(
        [string]$clientId,
        [string]$clientSecret
    )

    # Construct the URL
    $url = "$baseURL/auth/accessToken"

    # Construct the request body
    $body = @{
        grant_type = 'client_credentials'
        client_id = $clientId
        client_secret = $clientSecret
    }

    # Make the API request
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body

    # Return the response
    return $response
}

# Function to get public key
function Get-DestinyPublicKey {
    param(
        [string]$name
    )

    # Construct the URL
    $url = "$baseURL/auth/publickey/$name"

    # Make the API request
    $response = Invoke-RestMethod -Uri $url -Method Get

    # Return the response
    return $response
}

# Export functions
Export-ModuleMember -Function Get-DestinyGrants, Get-DestinyAccessToken, Get-DestinyPublicKey
