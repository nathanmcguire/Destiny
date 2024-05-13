--Staff
SELECT DISTINCT 
S.number AS schoolNumber,
PI.inputData AS PIN,
p.personID,
I.lastName,
I.firstName,
CASE WHEN I.middleName IS NULL THEN '' ELSE I.middleName END AS middleName,
CASE WHEN I.alias IS NULL THEN '' ELSE I.alias END AS alias,
'Staff' AS patronType,
'Patron' AS accessLevel,
CASE WHEN 
E.startDate <= GETDATE() AND (E.endDate IS NULL OR E.endDate >= GETDATE()) AND
EA.startDate <= GETDATE() AND (EA.endDate IS NULL OR EA.endDate >= GETDATE())
THEN 'Active' ELSE 'Inactive' END AS [status],
I.gender,
'' AS homeroom,
'' AS grade,
'' AS cardExpires,
'' AS acceptableUsePolicyFiled,
CASE WHEN EA.teacher = 1 THEN 'True' ELSE 'False' END AS isTeacher,
'' AS userDefined1,
'' AS userDefined2,
'' AS userDefined3,
'' AS userDefined4,
'' AS userDefined5,
'' AS graduationYear,
FORMAT(I.birthdate,'MM/dd/yyyy') AS birthDate,
UA.username AS userName,
'' AS [password],
Con.email AS email1,
'' AS email2,
'' AS email3,
'' AS email4,
'' AS email5,
'' AS address1line1,
'' AS address1line2,
'' AS address1city,
'' AS address1state,
'' AS address1zip,
'' AS address1phone1,
'' AS address1phone2,
'' AS address2line1,
'' AS address2line2,
'' AS address2city,
'' AS address2state,
'' AS address2zip,
'' AS address2phone1,
'' AS address2phone2,
'' AS assetGroup,
'' AS manageReadingPaths,
'' AS variable1,
'' AS variable2,
'' AS variable3,
'' AS variable4,
'' AS variable5

FROM Person P
JOIN [Identity] I ON I.identityID = P.currentIdentityID
JOIN POSIdentification PI ON PI.personID = P.personID AND PI.type = 'PC'
JOIN Contact Con ON Con.personID = P.personID
JOIN Employment E ON E.personID = P.personID
JOIN EmploymentAssignment EA ON EA.personID = P.personID
JOIN School S ON S.schoolID = EA.schoolID AND S.exclude = 0
LEFT JOIN UserAccount UA ON UA.personID = P.personID AND (UA.homepage IS NULL OR UA.homepage = 'nav-wrapper/TeacherApp/control-center/home')

ORDER BY lastName,firstName
