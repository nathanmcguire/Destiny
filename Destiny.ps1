. ./MyConfiguration.ps1
$baseURL = "https://$Domain/api/v1/rest/context/$Context"
function Get-DestinyAccessToken {
    param(
        [string]$clientId,
        [string]$clientSecret
    )
    $url = "$baseURL/auth/accessToken"
    $body = @{
        grant_type = 'client_credentials'
        client_id = $clientId
        client_secret = $clientSecret
    }
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body
    return $response
}
function Get-Patron {
    param (
        [string]$accessToken,
        [string]$id,
        [string]$siteId = ""
    )
    if ($siteId -eq "") {
        $url = "$baseURL/patrons/$id"
    } else {
        $url = "$baseURL/sites/$siteId/patrons/$id"
    }
    Invoke-RestMethod -Uri $url -Method Get -Headers @{ "Authorization" = "Bearer $accessToken" }
}
function Get-Sites {
    param (
        [string]$accessToken,
        [string]$id,
        [string[]]$productTypes
    )
    # If $id is provided, retrieve a specific site
    if ($id) {
        $url = "$baseUrl/sites/$id"
    }
    # If $productTypes is provided, retrieve sites based on product types
    elseif ($productTypes) {
        $url = "$baseUrl/sites?productTypes=$($productTypes -join '&productTypes=')"
    }
    # If neither $id nor $productTypes is provided, retrieve all sites
    else {
        $url = "$baseUrl/sites"
    }
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $accessToken"} -Method Get
    return $response
}
function Get-Fines {
    param (
        [string]$accessToken,
        [string]$districtId,
        [string]$patronBarcode,
        [string]$siteId,
        [string]$collectionType
    )
    $url = "$baseURL/fines"
    $queryParams = @{}
    if ($districtId) { $queryParams['districtId'] = $districtId }
    if ($patronBarcode) { $queryParams['patronBarcode'] = $patronBarcode }
    if ($siteId) { $queryParams['siteId'] = $siteId }
    if ($collectionType) { $queryParams['collectionType'] = $collectionType }
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -Query $queryParams
    return $response
}
function Pay-Fines {
    param (
        [string]$accessToken,
        [array]$finePayments
    )
    $url = "$baseURL/fines/payments"
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body ($finePayments | ConvertTo-Json)
    return $response
}
# Example usage:
# $accessToken = "your_access_token_here"
# Get-Fines -accessToken $accessToken -districtId "2020-789"
# Pay-Fines -accessToken $accessToken -finePayments @(@{fineId=224; externalPaymentId='001-23438F'; payment=2.37})