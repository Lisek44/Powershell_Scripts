function Get-ADGroupHistory {
    <#
    .SYNOPSIS
        This function retrieves the history of members in an Active Directory (AD) group.

    .DESCRIPTION
        The Get-ADGroupHistory function uses the repadmin command to fetch metadata about a specified AD group. It then parses this metadata to construct a history of the group’s members, including when each member was added or removed.

    .PARAMETER group
        This mandatory parameter specifies the name of the AD group for which to retrieve member history.
    .NOTES

        The function uses regular expressions to parse the output of the repadmin command.
        The function updates a global variable $ADGroupMembersHistory with the history of the group’s members.
        The function also verifies if the user still exists in the AD. If not, it updates the state to ABSENT_DELETED.
    .EXAMPLE

        Get-ADGroupHistory -group "GroupName"

        DomainController : DefaultController
        ModifiedCounter  : 1
        LastModified     : 1/4/2024 4:15:08 PM
        Username         : johndoe
        State            : PRESENT
        Group            : GroupName

        This command retrieves the member history for the AD group named “GroupName”.
        The history is stored in the global variable $ADGroupMembersHistory.
        You can view this history by simply typing $ADGroupMembersHistory in your PowerShell session.
        Please replace “GroupName” with the actual name of your AD group.
        Remember that the function needs to be run with sufficient permissions to access AD group information.

        Please note that this function is designed to work in an environment where the repadmin command is available,
        which typically means it should be run on a machine that is part of the AD domain.
        Also, the user running the script should have the necessary permissions to execute the repadmin command and to read AD group information.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$group
    )
    BEGIN {
        $Global:ADGroupMembersHistory = @()
        [regex]$pattern = '^(?<State>\w+)\s+member(?:\s(?<DateTime>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+(?:.*\\)?(?<DC>\w+|(?:(?:\w{8}-(?:\w{4}-){3}\w{12})))\s+(?:\d+)\s+(?:\d+)\s+(?<Modified>\d+))?'
        [regex]$usernamePattern = '\((.*?)\)'
        $DomainController = ($env:LOGONSERVER -replace "\\\\")
        $distinguishedName = (Get-ADGroup -Identity $group).DistinguishedName
    }
    PROCESS {
        Write-Progress -Activity "Searching AD Group Members History" -Status "Searching"
        $RepadminMetaData = (repadmin /showobjmeta $DomainController $distinguishedName | Select-String "^\w+\s+member" -Context 2)
        ForEach ($rep in $RepadminMetaData) {
           If ($rep.line -match $pattern) {
               $object = New-Object PSObject -Property  @{
                    Username = [regex]::Matches($rep.context.postcontext,"CN=(?<Username>.*?),.*") | ForEach {$_.Groups['Username'].Value}
                    LastModified = If ($matches.DateTime) {[datetime]$matches.DateTime} Else {$Null}
                    DomainController = $matches.dc
                    Group = $group
                    State = $matches.state
                    ModifiedCounter = $matches.modified
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
                if($verifyUser -eq $null){
                    $PSItem.State = "ABSENT_DELETED"
                }
            }
        }
        Write-Progress -Completed 'Unused'
    }
}