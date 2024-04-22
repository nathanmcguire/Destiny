Function New-DestinyAccessToken {
    <#
        .SYNOPSIS
            Obtain an access token to be used for making calls into the Destiny API
        .DESCRIPTION
            Use this API to obtain an access token from Destiny if your API Account was setup with 
            the client credential option. The Destiny administrator will have generated a client id 
            and secret which must be shared with the party accessing the Destiny API. The key and 
            secret should not be shared with anybody else, and care should be used to guard it from 
            discovery by other parties. 

            If the Destiny API account was setup using either a "Follett App ID" or "Follett App 
            Family", then this service should not be used to obtain an access token. The Follett 
            hosted API should be used to access the Destiny API otherwise. 

            This API will return a JSON Web Token (JWT) access token if the given credentials are 
            accepted. This JWT access token must be included as an authorization header (Ex: 
            "Authorization: Bearer <access_token>") or as a query parameter (Ex: 
            "&accessToken=<access_token>") in any subsequent API calls. Upon expiration of the 
            token any subsequent API call will result in a 401 (Unauthorized) server response. In 
            such a case a new access token will need to be generated to continue.
    #>
    [CmdletBinding()]
    Param(
        # Domain for Destiny server.
        [Parameter(mandatory=$true)]
        [String]$Domain,
        # Context or Database Name
        [Parameter(mandatory=$true)]
        [String]$Context,
        # This should be the Client ID from the Destiny API account.
        [Parameter(mandatory=$true)]
        [String]$ClientId,
        # This should be the Client Secret from the Destiny API account.
        [Parameter(mandatory=$true)]
        [String]$ClientSecret
    )
    $Uri = "https://$Domain/api/v1/rest/context/$Context/auth/accessToken"
    $ContentType = 'application/x-www-form-urlencoded'
    $GrantType = 'client_credentials'
    $Body = @{
        grant_type = $GrantType
        client_id = $ClientId
        client_secret = $ClientSecret
    }
    $Response = Invoke-RestMethod -Method Post -Uri $Uri -Body $Body -ContentType $ContentType -StatusCodeVariable $Status
    Switch ($Status) {
        200 {
            # A bearer type access token will be returned along with time until the token expires.
            $DestinyAccessToken = [DestinyAccessToken]::new()
            $DestinyAccessToken.AccessToken = $Response.access_token
            $DestinyAccessToken.TokenType = $Response.token_type
            $DestinyAccessToken.ExpiresIn($Response.expires_in)
            Return $AccessToken
        }
        400 {
            # If one of the required form parameters isn't specified.
            Write-Error "400 Bad Request"
            $DestinyError = [DestinyError]::new()
            $DestinyError.Code = $Response.code
            $DestinyError.Message = $Response.message
            $DestinyError.Target = $Response.target
            $DestinyError.LogId = $Response.logId
            Return $DestinyError
        }
        401 {
            # If the key/secret credentials are invalid, or grant_type is not set to "client_credentials".
            Write-Error "401 Unauthorized"
            $DestinyOAuthError = [DestinyOAuthError]::new()
            $DestinyOAuthError.Code = $Response.error
            $DestinyOAuthError.Description = $Response.description
        }
        500 {
            # This is an unexpected fault/error in the server
            Write-Error "500 Internal Server Error"
            $DestinyError = [DestinyError]::new()
            $DestinyError.Code = $Response.code
            $DestinyError.Message = $Response.message
            $DestinyError.Target = $Response.target
            $DestinyError.LogId = $Response.logId
        }
        default {
            # Status Code Not Implemented
            Write-Error "$Status Unknown"
        }
    }
}