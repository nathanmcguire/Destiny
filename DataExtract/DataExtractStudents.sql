WITH 
D AS (
    --Demographics
    SELECT 
    P.personID, 
    COALESCE(I.lastName,'') AS lastName, 
    COALESCE(I.firstName,'') AS firstName,
    COALESCE(I.middleName,'') AS middleName,
    COALESCE(I.alias,'') AS alias,
    I.gender, 
    FORMAT(I.birthdate,'MM/dd/yyyy') AS birthDate,
    C.email,
    U.username
    FROM Person P
    JOIN [Identity] I ON P.currentIdentityID = I.identityID
    JOIN Contact C ON P.personID = C.personID
    JOIN UserAccount U ON U.personID = P.personID AND U.homepage = 'nav-wrapper/student/portal/student'
),
--Calendar
C AS ( 
    SELECT C.calendarID,S.number AS schoolNumber,C.endYear
    FROM Calendar C 
    JOIN School S 
        ON C.schoolID = S.schoolID
        AND C.summerSchool = 0 
        AND C.exclude = 0 
    JOIN SchoolYear SY 
        ON C.endYear = SY.endYear 
        AND SY.active = 1
),
--Enrollment
E AS (
    SELECT 
    E.personID, 
    C.schoolNumber,
    CASE 
        WHEN E.endDate IS NULL THEN 'Active' 
        WHEN E.endDate >= GETDATE() THEN 'Active' 
        ELSE 'Inactive' 
        END AS [status],
    E.grade,
    GY.graduationYear
    FROM Enrollment E
    JOIN C
        ON E.calendarID = C.calendarID 
        AND E.externalLMSExclude = 0
    JOIN cust.GraduationYear GY ON C.endYear = GY.endYear AND E.grade = GY.gradeLevel
),
--Homeroom
H AS (
    SELECT DISTINCT
        studentPersonID AS personID,
        COALESCE(SH.teacherDisplay,'') AS homeroom
    FROM v_StudentHomeroom SH
    JOIN Trial T 
        ON SH.trialID = T.trialID 
        AND T.active = 1
    JOIN C ON SH.calendarID = C.calendarID
    JOIN Section S 
        ON SH.sectionID = S.sectionID
        AND S.externalLMSExclude = 0
    JOIN SectionPlacement SP 
        ON S.sectionID = SP.sectionID 
        AND SP.trialID = T.trialID
    JOIN Term Te 
        ON SP.termID = Te.termID 
        AND Te.startDate <= GETDATE() 
        AND Te.endDate >= GETDATE()
),
--PIN
P AS (
    SELECT personID, inputData AS pin
    FROM POSIdentification
    WHERE [type] = 'PC'
),
--Address
A AS (
    SELECT HM.personID, HM.[secondary], H.householdID,
    CASE
        WHEN A.postOfficeBox = 1 THEN
            'PO BOX ' + COALESCE(A.number,'')
        WHEN A.apt IS NOT NULL THEN
        'Apt #' + A.apt
        ELSE
            COALESCE(A.number + ' ','') + COALESCE(A.prefix + ' ','') + COALESCE(A.street + ' ','') + COALESCE(A.tag + ' ','') + COALESCE(A.dir,'') 
    END AS [addressLine1],
    CASE
        WHEN A.apt IS NOT NULL THEN
            COALESCE(A.number + ' ','') + COALESCE(A.prefix + ' ','') + COALESCE(A.street + ' ','') + COALESCE(A.tag + ' ','') + COALESCE(A.dir,'') 
        ELSE 
            ''
    END AS [addressLine2],
    A.city, A.state, A.zip
    FROM Household H
    JOIN HouseholdMember HM ON H.householdID = HM.householdID 
        AND HM.startDate <= GETDATE() 
        AND ( HM.endDate IS NULL OR HM.endDate >= GETDATE() )
        AND HM.mailing = 1
    JOIN HouseholdLocation HL ON HL.householdID = H.householdID
        AND HL.startDate <= GETDATE() 
        AND ( HL.endDate IS NULL OR HL.endDate >= GETDATE() )
        AND HL.mailing = 1
    JOIN [Address] A ON A.addressID = HL.addressID
),
--Address 1 Partition
A1 AS (
    SELECT *
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY personID ORDER BY [householdID] DESC) AS rowNumber
        FROM (
            SELECT * 
            FROM A 
            WHERE [secondary] = 0
        ) A
    ) A
    WHERE rowNumber = 1
),
--Address 2 Partition
A2 AS (
    SELECT *
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY personID ORDER BY [householdID] DESC) AS rowNumber
        FROM (
            SELECT * 
            FROM A 
            WHERE [secondary] = 1
        ) A
    ) A
    WHERE rowNumber = 1
)

SELECT DISTINCT
E.schoolNumber,
P.pin,
E.personID,
D.lastName,
D.firstName,
D.middleName,
D.alias,
'Student' AS patronType,
'Patron' AS accessLevel,
E.status,
D.gender,
COALESCE(H.homeroom,'') AS homeroom,
E.grade,
'' AS cardExpires,
'' AS acceptableUsePolicyFiled,
'False' AS isTeacher,
'' AS userDefined1,
'' AS userDefined2,
'' AS userDefined3,
'' AS userDefined4,
'' AS userDefined5,
E.graduationYear,
D.birthDate,
D.username,
'' AS [password],
D.email AS email1,
'' AS email2,
'' AS email3,
'' AS email4,
'' AS email5,
COALESCE(A1.addressLine1,'') AS address1line1,
COALESCE(A1.addressLine2,'') AS address1line2,
COALESCE(A1.city,'') AS address1city,
COALESCE(A1.[state],'') AS address1state,
COALESCE(A1.zip,'') AS address1zip,
'' AS address1phone1,
'' AS address1phone2,
COALESCE(A2.addressLine1,'') AS address2line1,
COALESCE(A2.addressLine2,'') AS address2line2,
COALESCE(A2.city,'') AS address2city,
COALESCE(A2.[state],'') AS address2state,
COALESCE(A2.zip,'') AS address2zip,
'' AS address2phone1,
'' AS address2phone2,
'' AS assetGroup,
'' AS manageReadingPaths,
'' AS variable1,
'' AS variable2,
'' AS variable3,
'' AS variable4,
'' AS variable5
FROM D
JOIN E ON D.personID = E.personID
JOIN P ON D.personID = P.personID
LEFT JOIN H ON D.personID = H.personID
LEFT JOIN A1 ON A1.personID = P.personID
LEFT JOIN A2 ON A2.personID = P.personID
