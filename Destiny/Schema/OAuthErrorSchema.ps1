$OAuthErrorSchema = @{
    required = @('error')
    properties = @{
        error = @{
            type = 'string'
            description = 'This is an OAuth2 error code.'
            enum = @('invalid_request', 'invalid_client', 'invalid_grant', 'invalid_scope', 'unauthorized_client', 'unsupported_grant_type')
        }
        error_description = @{
            type = 'string'
            description = 'A human readable version of the OAuth2 error code.'
        }
    }
}