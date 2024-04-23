. ./MyConfiguration.ps1
. ./Destiny.ps1
Clear

$DestinyAccessToken = Get-DestinyAccessToken -ClientId $ClientId -ClientSecret $ClientSecret -Domain $Domain -Context $Context
$DestinyFine = Get-DestinyFine -AccessToken $DestinyAccessToken.access_token -Domain $Domain -Context $Context
# Iterate through each record in $DestinyFine
$DestinyFine | Foreach {
    $FineId = $_.fineId
    $SiteId = $_.siteId
    $PatronId = $_.patronId
    $CollectionType = $_.collectionType
    $Type = $_.type
    $DateCreated = $_.dateCreated
    $Description = $_.description -replace "'", ""
    $BibId = $_.bibId
    $CopyId = $_.copyId
    $AmountDue = $_.amountDue
    $Amount = $_.amount
    $Paid = $_.paid
    $Waived = $_.waived
    $RefundAmount = $_.refundAmount
    $RefundPaid = $_.refundPaid
    $CurrencyUnit = $_.currencyUnit
    $PaymentReversed = $_.paymentReversed
    $WaiverReversed = $_.waiverReversed

    # Check if the record already exists in the database
    $query = "SELECT fineId FROM Fine WHERE fineId = $FineId"
    $existingRecordsCount = (Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query).Count
    if ($existingRecordsCount -eq 0) {
        # Insert the record if it doesn't exist
        $query = "
            SET IDENTITY_INSERT Fine ON;
            INSERT INTO Fine (
                [fineId],[siteId],[patronId],[collectionType],[type],
                [destinyDateCreated],[description],[bibId],[copyId],[amountDue],
                [amount],[paid],[waived],[refundAmount],[refundPaid],
                [currencyUnit],[paymentReversed],[waiverReversed])
            VALUES (
                '$FineId','$SiteId','$PatronId','$CollectionType','$Type',
                '$DateCreated','$Description','$BibId','$CopyId','$AmountDue',
                '$Amount','$Paid','$Waived','$RefundAmount','$RefundPaid',
                '$CurrencyUnit','$PaymentReversed','$WaiverReversed');
            SET IDENTITY_INSERT Fine OFF;
        "
        Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query -Verbose
    } else {
        # Update the record if it exists
        $query = "
            UPDATE Fine
            SET 
            siteId = '$SiteId',
            patronId = '$PatronId',
            collectionType = '$CollectionType',
            type = '$Type',
            DestinyDateCreated = '$DateCreated',
            description = '$Description',
            bibId = '$BibId',
            copyId = '$CopyId',
            amountDue = '$AmountDue',
            amount = '$Amount',
            paid = '$Paid',
            waived = '$Waived',
            refundAmount = '$RefundAmount',
            refundPaid = '$RefundPaid',
            currencyUnit = '$CurrencyUnit',
            paymentReversed = '$PaymentReversed',
            waiverReversed = '$WaiverReversed'
            WHERE fineId = $FineId
        "
        Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query -Verbose
    }
}
