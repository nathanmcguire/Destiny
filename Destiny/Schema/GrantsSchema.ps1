$GrantsSchema = @{
    required = @('principalId', 'grants')
    properties = @{
        principalId = @{
            type = 'string'
            description = 'This is the primary identifier that the user will be known as in Destiny. This identifier must be globally unique, non-changing and never reused.'
        }
        grants = @{
            type = 'array'
            items = 'string'
            description = 'Array of identifiers by which the principal is known in Destiny. Destiny can format the strings of this array in any way to meet the needs at hand. AASP will only ensure that these grants are placed onto the access token along with the other provided information. An empty array here will still result in an access token being created.'
        }
        extraClaims = @{
            type = 'string'
            description = 'Collection of key/value strings which will be included in the construction of the access token.'
        }
    }
    example = @{
        principalId = 'FSS.destiny-E5A2.fdaaf99f-f37e-4ff4-b45f-464c25df3eba'
        grants = @('ViewAnyFines', 'FinesWaiveLibrary')
        extraClaims = @{
            '/destiny/siteGuid' = '32ef328d-0016-4625-82fa-d497e8e942f0'
            '/destiny/appFamilyId' = 'FOLLETT_CLOUD'
        }
    }
}