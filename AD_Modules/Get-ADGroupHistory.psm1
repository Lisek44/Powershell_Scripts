function Get-ADGroupHistory {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$group
    )
    BEGIN {
        # Creating necessary variables
        $Global:ADGroupMembersHistory = @()
        [regex]$pattern = '^(?<State>\w+)\s+member(?:\s(?<DateTime>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+(?:.*\\)?(?<DC>\w+|(?:(?:\w{8}-(?:\w{4}-){3}\w{12})))\s+(?:\d+)\s+(?:\d+)\s+(?<Modified>\d+))?'
        [regex]$usernamePattern = '\((.*?)\)'
        $DomainController = ($env:LOGONSERVER -replace "\\\\")
        $distinguishedName = (Get-ADGroup -Identity $group).DistinguishedName
    }
    PROCESS {
        # Searching for speficified $group Members history
        Write-Progress -Activity "Searching AD Group Members History" -Status "Searching"
        $RepadminMetaData = (repadmin /showobjmeta $DomainController $distinguishedName | Select-String "^\w+\s+member" -Context 2)
        ForEach ($rep in $RepadminMetaData) {
            If ($rep.line -match $pattern) {
                $object = New-Object PSObject -Property  @{
                    Username         = [regex]::Matches($rep.context.postcontext, "CN=(?<Username>.*?),.*") | ForEach { $_.Groups['Username'].Value }
                    LastModified     = If ($matches.DateTime) { [datetime]$matches.DateTime } Else { $Null }
                    DomainController = $matches.dc
                    Group            = $group
                    State            = $matches.state
                    ModifiedCounter  = $matches.modified
                }
                $Global:ADGroupMembersHistory += $object
            }
        }
        $Matches = $null
        $ADGroupMembersHistory | ForEach-Object -Process {
            if ($PSItem.Username -match $usernamePattern) {
                try {
                    $verifyUser = $null
                    $verifyUser = Get-ADUser $Matches[1] -ErrorAction Ignore
                }
                catch {
                }
                if ($verifyUser -eq $null) {
                    $PSItem.State = "ABSENT_DELETED"
                }
            }
        }
        Write-Progress -Completed 'Unused'
    }
}