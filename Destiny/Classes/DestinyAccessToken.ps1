Class DestinyAccessToken {
    [String]$AccessToken
    [String]$TokenType
    [Datetime]$Expires
    [Int]ExpiresIn() { 
        Return (New-TimeSpan -Start Get-Date -End $This.Expires).TotalSeconds
    }
    [Void]ExpiresIn([Int]$Seconds) {
        [Decimal]$EarlyExpireFactor = .95
        $This.Expires = Get-Date.AddSeconds([Math]::Round($Seconds * $EarlyExpireFactor))
    }
}