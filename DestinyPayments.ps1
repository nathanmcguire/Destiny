. ./MyConfiguration.ps1
. ./DestinyAPI.ps1
Clear
$DestinyAccessToken = Get-DestinyAccessToken -ClientId $ClientId -ClientSecret $ClientSecret -Domain $Domain -Context $Context


#$Query = "SELECT fineId,externalPaymentId,payment,waiver,refund,paymentReversal,waiverReversal FROM PaymentProposed"
#$Payments = Invoke-SqlCmd -ServerInstance $SQLServer -Database $SQLDatabase -Query $query
#$Payments | FT


$Response = '[
    {
      "fineId": 224,
      "externalPaymentId": "001-23438F",
      "fineType": "Damaged",
      "patron": {
        "primarySiteGuid": "d96ad6cb-d7e9-4416-bf75-9ec42db4af50",
        "primarySiteName": "Elmwood Elementary",
        "primarySiteShortName": "ELM",
        "guid": "0b75062d-6067-4759-aa1b-c8fe5c349694",
        "internalId": 123,
        "districtId": "2020-789",
        "barcode": "P 12383",
        "lastName": "Stantz",
        "firstName": "Raymond"
      },
      "site": {
        "guid": "d96ad6cb-d7e9-4416-bf75-9ec42db4af50",
        "internalId": 267,
        "name": "Elmwood Elementary",
        "shortName": "ELM"
      },
      "payment": {
        "status": "success",
        "message": "Payment applied $2.37",
        "amount": 2.37
      },
      "paymentSummary": {
        "amountDue": 0,
        "amount": 2.37,
        "paid": 2.37,
        "waived": 0,
        "refundAmount": 0,
        "refundPaid": 0,
        "currencyUnit": "usd",
        "paymentReversed": 0,
        "waiverReversed": 0
      }
    },
    {
      "fineId": 125,
      "fineType": "Overdue",
      "externalPaymentId": "001-27378G",
      "payment": {
        "status": "unchanged",
        "message": "FineId 125 not found",
        "amount": 1.27
      },
      "waiver": {
        "status": "unchanged",
        "message": "FineId 125 not found",
        "amount": 2
      }
    },
    {
      "fineId": 424,
      "externalPaymentId": "001-29488I",
      "fineType": "Overdue",
      "patron": {
        "guid": "26708b77-1943-44ce-801f-88cab47cfaf4",
        "internalId": 123,
        "districtId": "2020-795",
        "barcode": "P 384763",
        "lastName": "Spengler",
        "firstName": "Egon"
      },
      "site": {
        "guid": "1cc660cc-7b99-451e-9dbc-0d291dd8174c",
        "internalId": 267,
        "name": "Cherryvale High School",
        "shortName": "CHE"
      },
      "refund": {
        "status": "success",
        "message": "Payment applied $2.00",
        "amount": 2
      },
      "paymentSummary": {
        "amountDue": 0,
        "amount": 2,
        "paid": 2,
        "waived": 0,
        "refundAmount": 2,
        "refundPaid": 2,
        "currencyUnit": "usd",
        "paymentReversed": 0,
        "waiverReversed": 0
      }
    },
    {
      "fineId": 1537,
      "externalPaymentId": "001-58714K",
      "fineType": "Lost",
      "patron": {
        "guid": "26708b77-1943-44ce-801f-88cab47cfaf4",
        "internalId": 123,
        "districtId": "2020-795",
        "barcode": "P 384763",
        "lastName": "Spengler",
        "firstName": "Egon"
      },
      "site": {
        "guid": "1cc660cc-7b99-451e-9dbc-0d291dd8174c",
        "internalId": 267,
        "name": "Cherryvale High School",
        "shortName": "CHE"
      },
      "paymentReversal": {
        "status": "success",
        "message": "Payment reversed $9.99",
        "amount": 9.99
      },
      "paymentSummary": {
        "amountDue": 9.99,
        "amount": 9.99,
        "paid": 0,
        "waived": 0,
        "refundAmount": 0,
        "refundPaid": 0,
        "currencyUnit": "usd",
        "paymentReversed": 9.99,
        "waiverReversed": 0
      }
    },
    {
      "fineId": 6978,
      "externalPaymentId": "001-98436M",
      "fineType": "Overdue",
      "patron": {
        "guid": "26708b77-1943-44ce-801f-88cab47cfaf4",
        "internalId": 123,
        "districtId": "2020-795",
        "barcode": "P 384763",
        "lastName": "Spengler",
        "firstName": "Egon"
      },
      "site": {
        "guid": "1cc660cc-7b99-451e-9dbc-0d291dd8174c",
        "internalId": 267,
        "name": "Cherryvale High School",
        "shortName": "CHE"
      },
      "waiverReversal": {
        "status": "success",
        "message": "Waiver reversed $5.00",
        "amount": 5
      },
      "paymentSummary": {
        "amountDue": 10,
        "amount": 20,
        "paid": 10,
        "waived": 0,
        "refundAmount": 0,
        "refundPaid": 0,
        "currencyUnit": "usd",
        "paymentReversed": 0,
        "waiverReversed": 5
      }
    }
  ]'

$Receipts = $Response | ConvertFrom-JSON
$Receipts | foreach {
    $fineId = $_.fineId
    $externalPaymentId = $_.externalPaymentId

    $payment = $_.payment
    $waiver = $_.waiver
    $refund = $_.refund
    $paymentReversal = $_.paymentReversal
    $waiverReversal = $_.waiverReversal
    
    $paymentSummary = $_.paymentSummary
}

<#
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
#>