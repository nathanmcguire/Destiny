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
    $AccessToken = Invoke-RestMethod -Uri $Url -Method Post -Body $Body
    $AccessToken.PSObject.Properties.Add([PSNoteProperty]::new('expires',(Get-Date).AddSeconds([int]$Response.expires_in - 10)))
    $AccessToken.PSObject.Properties.Remove('expires_in')
    return $AccessToken
}
Function Get-DestinyPatron {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Domain,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken,
        [Parameter(Mandatory = $true)]
        [string]$PatronId,
        [string]$Context,
        [string]$SiteId = ""
    )
    $Url = "https://$Domain/api/v1/rest"
    if ($Context) {
        $Url += "/context/$Context"
    }
    if ($SiteId -eq "") {
        $Url += "/patrons/$PatronId"
    } else {
        $Url += "/sites/$SiteId/patrons/$PatronId"
    }
    $Patron = Invoke-RestMethod -Uri $Url -Method Get -Headers @{ "Authorization" = "Bearer $AccessToken" }
    return $Patron
}
Function Get-DestinySite {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Domain,
        [Parameter(Mandatory=$true)]
        [string]$AccessToken,
        [string]$Context,
        [string]$SiteId
    )
    $Url = "https://$Domain/api/v1/rest"
    if ($Context) {
        $Url += "/context/$Context"
    }
    if ($SiteId) {
        $Url += "/sites/$SiteId"
        Return Invoke-RestMethod -Uri $Url -Headers @{Authorization = "Bearer $AccessToken"} -Method Get
    } else {
        $Url += "/sites"
        Return (Invoke-RestMethod -Uri $Url -Headers @{Authorization = "Bearer $AccessToken"} -Method Get).Value
    }
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
                amountDue = [decimal]$_.paymentSummary.amountDue
                amount = [decimal]$_.paymentSummary.amount
                paid = [decimal]$_.paymentSummary.paid
                waived = [decimal]$_.paymentSummary.waived
                refundAmount = [decimal]$_.paymentSummary.refundAmount
                refundPaid = [decimal]$_.paymentSummary.refundPaid
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
    $Url = "$baseURL/fines/payments"
    $Headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    Return Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body ($finePayments | ConvertTo-Json)
}