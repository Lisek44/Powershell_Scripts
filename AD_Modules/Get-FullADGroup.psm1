function Get-FullADGroup {
    <#
    .SYNOPSIS
        The Get-FullADGroup function retrieves detailed information about an Active Directory (AD) group and its members.

    .DESCRIPTION
        The Get-FullADGroup function uses the Get-ADGroup and Get-ADUser cmdlets to retrieve detailed information about a specified AD group and its members.
        It stores the group information in the global variable $Global:ADGroup and the members' information in the global variable $Global:ADGroupMembers.

    .PARAMETER name
        This mandatory parameter specifies the name of the AD group for which to retrieve information.

    .NOTES
        The function uses Write-Progress to display the progress of the search operation in the console.
        It calculates the progress percentage based on the number of members in the group.

    .EXAMPLE
        Get-FullADGroup -name "GroupName"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$name
    )
    BEGIN {
        $Global:ADGroup = $null
        $Global:ADGroupUsersMembers = @()
        $Global:ADGroupComputersMembers = @()
        $Global:usersCount = 0
        $Global:computersCount = 0
    }
    PROCESS {
        try {
            Write-Progress -Activity "Searching AD Group" -Status "Searching"
            $Global:ADGroup = Get-ADGroup -Identity $name -Properties *
            Write-Progress -Completed 'Unused'

            Write-Progress -Activity "Search of AD Group Members" -Status "Searching"
            $searchUsers = @()
            $searchUsers += Get-ADGroupMember -Identity $name
            Write-Progress -Completed 'Unused'
            $searchUsers | ForEach-Object -Begin {
                $i = [math]::Round(100/$searchUsers.Count, 1)
                $n = 0
            } -Process {
                Write-Progress -Activity "Search of AD Group Members" -Status "$n% Complete:" -PercentComplete $n
                try {
                    $Global:ADGroupUsersMembers += Get-ADUser $PSItem -Properties *
                    $Global:usersCount += 1
                }
                catch {
                    # TextForUserErrorMessage "Error: $PSItem Not found as User"
                }
                try {
                    $Global:ADGroupComputersMembers += Get-ADComputer $PSItem -Properties *
                    $Global:computersCount += 1
                }
                catch {
                    # TextForUserErrorMessage "Error: $PSItem Not found as Computer"
                }
                $n += $i
            }
            if ($null -ne $ADGroup -and ($null -ne $ADGroupUsersMembers -or ($null -ne $ADGroupComputersMembers))){
                $Global:checkData = $true
            }
        }
        catch{
            $Global:errorMessage = "Error: $name not found as Active Directory Group"
            $Global:checkData = $false
        }
    }
}