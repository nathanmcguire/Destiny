$ErrorSchema = @{
    required = @('code', 'message')
    properties = @{
        error = @{
            type = 'object'
            properties = @{
                code = @{
                    type = 'string'
                    description = 'Identifies the type of errors that could happen when calling this API.'
                    enum = @(
                        'CODE_MISSING_TOKEN',
                        'CODE_INVALID_TOKEN',
                        'CODE_UNKNOWN_APPID',
                        'CODE_CONTEXT_NOT_FOUND',
                        'CODE_CONTEXT_REQUIRED_IN_CONSORTIUM',
                        'CODE_UNAUTHORIZED_ACCESS',
                        'CODE_INSUFFICIENT_RIGHTS_TO_API',
                        'CODE_APPID_OR_APPFAMILYID_REQUIRED',
                        'TOKEN_APPID_MISMATCH_WITH_AASP_SERVER_APPID',
                        'CODE_PRINCIPALID_NOT_FOUND',
                        'CODE_PRINCIPAL_NO_SITE_ACCESS',
                        'CODE_PRINCIPAL_SITE_ACCESS_NOT_VALIDATED',
                        'CODE_INVALID_PATH',
                        'CODE_SITE_VALUE_NOT_FOUND',
                        'CODE_INTERNAL_SERVER_ERROR'
                    )
                }
                message = @{
                    type = 'string'
                    description = 'A human readable message about the error.'
                }
                target = @{
                    type = 'string'
                    description = 'Field, parameter or path associated with the error'
                }
                logId = @{
                    type = 'string'
                    description = 'A unique value generated and written to the Destiny log file in association with the error.'
                }
            }
        }
    }
}