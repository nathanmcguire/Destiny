Function Get-DestinyAccessToken {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Domain,
        [Parameter(Mandatory=$true)]
        [string]$ClientId,
        [Parameter(Mandatory=$true)]
        [string]$ClientSecret,
        [string]$Context
    )
    $Url = "https://$Domain/api/v1/rest"
    if ($Context) {
        $Url += "/context/$Context"
    }
    $Url += "/auth/accessToken"
    $Body = @{
        grant_type = 'client_credentials'
        client_id = $ClientId
        client_secret = $ClientSecret
    }
    $Response = Invoke-RestMethod -Uri $Url -Method Post -Body $Body
    $Response.PSObject.Properties.Add([PSNoteProperty]::new('expires',(Get-Date).AddSeconds([int]$Response.expires_in - 10)))
    $Response.PSObject.Properties.Remove('expires_in')
    return $Response
}
function Get-DestinyPatron {
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
function Get-DestinySite {
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
function Get-DestinyFine {
    param (
        [Parameter(Mandatory=$true)]
        [string]$AccessToken,
        [Parameter(Mandatory=$true)]
        [string]$Domain,
        [string]$Context,
        [string]$PatronDistrictId,
        [string]$PatronBarcode,
        [string]$SiteId,
        [string]$CollectionType
    )
    $Url = "https://$Domain/api/v1/rest"
    if ($Context) {
        $Url += "/context/$Context"
    }
    $Url += "/fines"
    $QueryParam = ""
    if ($PatronDistrictId) { 
        $QueryParam += "&districtId=$PatronDistrictId"
    }
    if ($PatronBarcode) { 
        $QueryParam += "&patronBarcode=$PatronBarcode"
    }
    if ($SiteId) { 
        $QueryParam += "&siteId=$SiteId"
    }
    if ($CollectionType) { 
        $QueryParam += "&collectionType=$CollectionType"
    }
    if ($QueryParam.Length -gt 0) {
        $QueryParam = "?" + $QueryParam.Substring(1)
        $Url += $QueryParam
    }
    $Header = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Response = Invoke-RestMethod -Uri $Url -Method Get -Headers $Header
    $Fine = @()
    $Response | Foreach {
        $SiteId = $_.site.internalId
        $PatronId = $_.patron.internalId
        $_.fines | Foreach {
            $FineId = $_.internalId
            $CollectionType = $_.collectionType
            $Type = $_.type
            $DateCreated = $_.dateCreated
            $Description = $_.description
            $Bib = $_.bib.internalId 
            $Copy = $_.copy.internalId
            $Fine += [PSCustomObject]@{
                siteId = $SiteId
                patronId = $PatronId
                fineId = $FineId
                collectionType = $CollectionType
                type = $Type
                dateCreated = $DateCreated
                description = $Description
                bibId = $Bib
                copyId = $Copy
                amountDue = $_.paymentSummary.amountDue
                amount = $_.paymentSummary.amount
                paid = $_.paymentSummary.paid
                waived = $_.paymentSummary.waived
                refundAmount = $_.paymentSummary.refundAmount
                refundPaid = $_.paymentSummary.refundPaid
                currencyUnit = $_.paymentSummary.currencyUnit
                paymentReversed = $_.paymentSummary.paymentReversed
                waiverReversed = $_.paymentSummary.waiverReversed
            }
        }
    }
    return $Fine
}
Function New-DestinyPayment {
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