Enum OAuthErrorCode {
    invalid_request
    invalid_client
    invalid_grant
    invalid_scope
    unauthorized_client
    unsupported_grant_type
}
Class DestinyOAuthError {
    # This is an OAuth2 error code.
    [OAuthErrorCode]$Code
    # A human readable version of the OAuth2 error code.
    [String]$Description

}