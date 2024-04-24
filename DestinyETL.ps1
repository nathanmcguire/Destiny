. ./MyConfiguration.ps1
. ./Destiny.ps1
Clear
$DestinyAccessToken = Get-DestinyAccessToken -ClientId $ClientId -ClientSecret $ClientSecret -Domain $Domain -Context $Context

$DestinySite = Get-DestinySite -AccessToken $DestinyAccessToken.access_token -Domain $Domain -Context $Context
$DestinySite | foreach {
    $SiteGuid = $_.guid
    $Site = Get-DestinySite -AccessToken $DestinyAccessToken.access_token -Domain $Domain -Context $Context -SiteId "$SiteGuid"
    $SiteId = $Site.internalId
    $FSCCustomerNumber = $Site.fscCustomerNumber
    $StateId = $Site.stateIdentifier
    $Name = $Site.name
    $ShortName = $Site.shortName
    $LibrarySite = $Site.librarySite
    $TextbookSite = $Site.textbookSite
    $ResourceSite = $Site.resourceSite
    $RosterEnabled = $Site.rosterEnabled
    $UTCOffset = $Site.utcOffset
    $query = "SELECT siteId FROM Site WHERE siteId = $SiteId"
    $existingRecordsCount = (Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query).Count
    if ($existingRecordsCount -eq 0) {
        # Insert the record if it doesn't exist
        $query = "
            SET IDENTITY_INSERT Site ON;
            INSERT INTO Site (
                [siteId],[fscCustomerNumber],[stateId],[name],[shortName],
                [librarySite],[textbookSite],[resourceSite],[rosterEnabled],[utcOffset])
            VALUES (
                '$SiteId','$FSCCustomerNumber','$StateId','$Name','$ShortName',
                '$LibrarySite','$TextbookSite','$ResourceSite','$RosterEnabled','$UTCOffset');
            SET IDENTITY_INSERT Site OFF;
        "
        Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query -Verbose
    } else {
        # Update the record if it exists
        $query = "
            UPDATE Site
            SET 
            [fscCustomerNumber] = '$FSCCustomerNumber',
            [stateId] = '$StateId',
            [name] = '$Name',
            [shortName] = '$ShortName',
            [librarySite] = '$LibrarySite',
            [textbookSite] = '$TextbookSite',
            [resourceSite] = '$ResourceSite',
            [rosterEnabled] = '$RosterEnabled',
            [utcOffset] = '$UTCOffset'
            WHERE siteId = $SiteId
        "
        Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query -Verbose
    }
}
$DestinyFine = Get-DestinyFine -AccessToken $DestinyAccessToken.access_token -Domain $Domain -Context $Context
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

    $query = "SELECT fineId FROM Fine WHERE fineId = $FineId"
    $existingRecordsCount = (Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query).Count
    if ($existingRecordsCount -eq 0) {
        # Insert the record if it doesn't exist
        $query = "
            SET IDENTITY_INSERT Fine ON;
            INSERT INTO Fine (
                [fineId],[siteId],[patronId],[collectionType],[type],
                [dateCreated],[description],[bibId],[copyId],[amountDue],
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
            dateCreated = '$DateCreated',
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





$Query = "SELECT DISTINCT patronId FROM Fine"
$Patrons = Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $Query
$Patrons | Foreach {
    $DestinyPatron = Get-DestinyPatron -AccessToken $DestinyAccessToken.access_token -Domain $Domain -Context $Context -PatronId $_.patronId
    $DestinyPatron | foreach {
        $PatronId = $_.internalId
        $DistrictId = $_.districtId
        $LastName = $_.lastName -replace "'", ""
        $FirstName = $_.firstName -replace "'", ""
        $Nickname = $_.nickname -replace "'", ""
        $GradeLevel = $_.gradeLevel
        $SiteAssociation = $_.siteAssociations
        $query = "SELECT patronId FROM Patron WHERE patronId = $PatronId"
        $existingRecordsCount = (Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query).Count
        if ($existingRecordsCount -eq 0) {
            $query = "
                SET IDENTITY_INSERT Patron ON;
                INSERT INTO Patron (
                    [patronId],[districtid],[lastName],[firstName],[middleName],
                    [nickName],[gradeLevel])
                VALUES (
                    '$PatronId','$DistrictId','$LastName','$FirstName','$MiddleName',
                    '$Nickname','$gradeLevel');
                SET IDENTITY_INSERT Patron OFF;
            "
            Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query -Verbose
        } else {
            $query = "
                UPDATE Patron
                SET 
                districtId = '$DistrictId',
                lastName = '$LastName',
                firstName = '$FirstName',
                middleName = '$MiddleName',
                nickName = '$NickName',
                gradeLevel = '$GradeLevel'
                WHERE patronId = $PatronId
            "
            Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query -Verbose
        }
        $SiteAssociation | foreach {
            $SiteId = $_.siteId
            $Barcode = $_.barcode
            $PrimarySite = $_.primarySite
            $Type = $_.type
            $Teacher = $_.teacher
            $Status = $_.status
            $query = "SELECT siteAssociationId  FROM SiteAssociation WHERE patronId = $PatronId AND siteId = $SiteId"
            $existingRecordsCount = (Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query).Count
            if ($existingRecordsCount -eq 0) {
                $query = "
                    INSERT INTO SiteAssociation (
                        [patronId],[siteId],[barcode],[primarySite],[type],
                        [teacher],[status])
                    VALUES (
                        '$PatronId','$SiteId','$Barcode','$PrimarySite','$Type',
                        '$Teacher','$Status');
                "
                Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query -Verbose
            } else {
                $query = "
                    UPDATE SiteAssociation
                    SET 
                    barcode = '$Barcode',
                    primarySite = '$PrimarySite',
                    type = '$Type',
                    teacher = '$Teacher',
                    Status = '$Status'
                    WHERE patronId = $PatronId AND siteId = $SiteId
                "
                Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query -Verbose
            }
            
        }
    }
}