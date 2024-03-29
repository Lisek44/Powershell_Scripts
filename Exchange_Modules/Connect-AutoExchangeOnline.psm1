function Connect-AutoExchangeOnline {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$User_Domain = $env:USERDOMAIN,
        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$User_name = $env:USERNAME
    )

    # Creation of variables
    $Global:credential = Get-Credential $User_Domain\$User_name
    $Global:Script_user = Get-ADUser $User_name
    $Global:credential_mail = New-Object pscredential ($Script_user.UserPrincipalName, $credential.Password)

    # Establishing connection to Exchange Online with typed credentials or via MFA login
    $Connection = Get-ConnectionInformation
    if ($null -eq $Connection) {
        do {
            try {
                Connect-ExchangeOnline -Credential $credential_mail
                $Connection = Get-ConnectionInformation
                if ($null -ne $Connection) {
                    [bool]$Connection_Check = $true
                }
            }
            catch {
                [bool]$Connection_Check = $false
            }
            try {
                Connect-ExchangeOnline
                $Connection = Get-ConnectionInformation
                if ($null -ne $Connection) {
                    [bool]$Connection_Check = $true
                }
            }
            catch {
                [bool]$Connection_Check = $false
            }
        } while (
            $Connection_Check -eq $false
        )
    }
}
