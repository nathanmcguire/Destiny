-- DesitnyFine Table
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[cust].[DestinyFine]') AND type in (N'U'))
DROP TABLE [cust].[DestinyFine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cust].[DestinyFine](
	[fineId] [int] NULL,
	[siteId] [int] NULL,
	[patronId] [int] NULL,
	[collectionType] [varchar](50) NULL,
	[type] [varchar](50) NULL,
	[description] [varchar](max) NULL,
	[bibId] [int] NULL,
	[copyId] [int] NULL,
	[amountDue] [numeric](18, 4) NULL,
	[amount] [numeric](18, 4) NULL,
	[paid] [numeric](18, 4) NULL,
	[waived] [numeric](18, 4) NULL,
	[refundAmount] [numeric](18, 4) NULL,
	[refundPaid] [numeric](18, 4) NULL,
	[currencyUnit] [varchar](10) NULL,
	[paymentReversed] [numeric](18, 4) NULL,
	[waiverReversed] [numeric](18, 4) NULL,
	[dateCreated] [datetime] NULL,
	[onAPI] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- DesitnyPatron Table
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[cust].[DestinyPatron]') AND type in (N'U'))
DROP TABLE [cust].[DestinyPatron]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cust].[DestinyPatron](
	[patronId] [int] NULL,
	[districtId] [varchar](50) NULL,
	[lastName] [varchar](50) NULL,
	[firstName] [varchar](50) NULL,
	[middleName] [varchar](50) NULL,
	[nickName] [varchar](50) NULL,
	[gradeLevel] [varchar](50) NULL
) ON [PRIMARY]
GO

--DestinySite Table
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[cust].[DestinySite]') AND type in (N'U'))
DROP TABLE [cust].[DestinySite]
GO
CREATE TABLE [cust].[DestinySite](
	[siteId] [int] NULL,
	[fscCustomerNumber] [varchar](50) NULL,
	[stateId] [varchar](4) NULL,
	[name] [varchar](50) NULL,
	[shortName] [varchar](10) NULL,
	[librarySite] [bit] NULL,
	[textbookSite] [bit] NULL,
	[resourceSite] [bit] NULL,
	[rosterEnabled] [bit] NULL,
	[utcOffset] [varchar](10) NULL
) ON [PRIMARY]
GO

-- DestinySiteAssociation Table
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[cust].[DestinySiteAssociation]') AND type in (N'U'))
DROP TABLE [cust].[DestinySiteAssociation]
GO
CREATE TABLE [cust].[DestinySiteAssociation](
	[siteAssociationId] [int] NULL,
	[patronId] [int] NULL,
	[siteId] [int] NULL,
	[type] [varchar](50) NULL,
	[barcode] [varchar](50) NULL,
	[primarySite] [bit] NULL,
	[teacher] [bit] NULL,
	[status] [varchar](50) NULL
) ON [PRIMARY]
GO

--Destiny Campus Fee Adjustment Proposed View
DROP VIEW [cust].[DestinyCampusFeeAdjustmentProposed]
GO
CREATE VIEW [cust].[DestinyCampusFeeAdjustmentProposed] AS
SELECT A.assignmentID, B.balance * -1 AS amount, GETDATE() AS adjustmentDate, 'SYS' AS type, 1 AS createdById, GETDATE() AS createdDate
FROM cust.DestinyFine F
JOIN FeeAssignment A ON 'DESTINY-' + CAST(F.fineID AS VARCHAR(20)) = A.legacyKey
JOIN v_FeeBalance B ON B.assignmentID = A.assignmentID
WHERE B.balance < 0
AND F.onAPI = 0
GO

--Destiny Campus Fee Assignment Proposed View
DROP VIEW [cust].[DestinyCampusFeeAssignmentProposed]
GO
CREATE VIEW [cust].[DestinyCampusFeeAssignmentProposed] AS
WITH
-- Calendar CTE
C AS (
    SELECT 
        S.name AS schoolName, 
        S.number AS schoolNumber, 
        C.calendarID, 
        C.name AS calendarName, 
        Y.startDate, 
        DATEADD(day, 1, Y.endDate) AS endDate
    FROM 
        Calendar C
    JOIN 
        SchoolYear Y ON C.endYear = Y.endYear
    JOIN 
        School S ON S.schoolID = C.schoolID
    WHERE 
        C.summerSchool = 0 
        AND C.name NOT LIKE '%Prekindergarten%'
),
-- Fee CTE
CF AS (
    SELECT 
        F.feeID,
        S.number AS schoolNumber
    FROM 
        Fee F
    JOIN 
        School S ON F.schoolID = S.schoolId
    WHERE 
        F.name = 'Library' 
        AND F.type = 'LIB'
),
-- PIN CTE
PI AS (
    SELECT personID,inputData
    FROM POSIdentification
    WHERE [type] = 'PC'
)
SELECT
    C.calendarID,
    P.districtId AS personID,
    CF.feeId,
    F.type + ' - ' + F.[description] AS comments,
    F.amount,
    F.dateCreated AS createdDate,
    1 AS createdById,
    'DESTINY-' + CAST(F.fineID AS VARCHAR(20)) AS legacyKey
FROM 
    cust.[DestinyFine] F
JOIN 
    cust.[DestinySite] S ON S.siteId = F.siteId
JOIN 
    cust.[DestinyPatron] P ON F.patronId = P.patronId
JOIN 
    C ON F.dateCreated >= C.startDate AND F.dateCreated <= C.endDate AND S.stateId = C.schoolNumber
JOIN 
    CF ON CF.schoolNumber = S.stateId
--JOIN 
--    cust.[DestinySiteAssociation] SA ON SA.siteId = F.siteId AND SA.patronId = F.patronId
JOIN 
    PI ON CAST(PI.personID AS varchar(10)) = P.districtId --AND REPLACE(SA.barcode, 'P ', '') = PI.inputData
GO

-- Destiny Fine No Campus POS Identity Match
DROP VIEW [cust].[DestinyFineNoCampusPOSIdentityMatch]
GO
CREATE VIEW [cust].[DestinyFineNoCampusPOSIdentityMatch] AS
WITH
-- PIN CTE
PI AS (
    SELECT identificationID,personID,inputData
    FROM POSIdentification
    WHERE [type] = 'PC'
)
SELECT 
    F.fineID
FROM 
    cust.[DestinyFine] F
JOIN 
    cust.[DestinyPatron] P ON F.patronId = P.patronId
JOIN 
    cust.[DestinySiteAssociation] SA ON SA.siteId = F.siteId AND SA.patronId = F.patronId
LEFT JOIN PI ON CAST(PI.personID AS varchar(10)) = P.districtId AND REPLACE(SA.barcode, 'P ', '') = PI.inputData
WHERE PI.identificationID IS NULL
GO

-- Destiny Fine No Site Association
DROP VIEW [cust].[DestinyFineNoSiteAssociation]
GO
CREATE VIEW [cust].[DestinyFineNoSiteAssociation] AS
SELECT fineId
FROM cust.DestinyFine F
LEFT JOIN cust.DestinySiteAssociation SA ON F.patronId = SA.patronId AND F.siteId = SA.siteId
WHERE SA.siteAssociationId IS NULL
GO

-- Merge Destiny Campus Fee Assignment Proposed
DROP PROCEDURE [cust].[MergeDestinyCampusFeeAssignmentProposed]
GO
CREATE PROCEDURE [cust].[MergeDestinyCampusFeeAssignmentProposed] AS
BEGIN
    MERGE INTO FeeAssignment AS T
    USING osage_school.cust.DestinyCampusFeeAssignmentProposed AS S
    ON T.legacyKey = S.legacyKey
    WHEN MATCHED THEN
        UPDATE SET
            T.calendarId = S.calendarId,
            T.personId = S.personId,
            T.feeId = S.feeId,
            T.comments = S.comments,
            T.amount = S.amount,
            T.createdDate = S.createdDate,
            T.createdByID = S.createdByID
        WHEN NOT MATCHED BY TARGET THEN
        INSERT (calendarID, personID,feeID, comments, amount, createdDate,createdByID,legacyKey)
        VALUES (S.calendarId, S.personId, S.feeId, S.comments, S.amount, S.createdDate, createdByID,legacyKey);
END
GO