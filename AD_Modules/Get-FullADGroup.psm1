function Get-FullADGroup {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$group
    )
    BEGIN {
        # Creating necessary variables
        $Global:ADGroup = $null
        $Global:ADGroupUsersMembers = @()
        $Global:ADGroupComputersMembers = @()
        $Global:usersCount = 0
        $Global:computersCount = 0
    }
    PROCESS {
        try {
            # Searching for speficified $group
            Write-Progress -Activity "Searching AD Group" -Status "Searching"
            $Global:ADGroup = Get-ADGroup -Identity $group -Properties *
            Write-Progress -Completed 'Unused'

            # Searching for speficified $group's members
            Write-Progress -Activity "Search of AD Group Members" -Status "Searching"
            $searchUsers = @()
            $searchUsers += Get-ADGroupMember -Identity $group
            Write-Progress -Completed 'Unused'
            $searchUsers | ForEach-Object -Begin {
                $i = [math]::Round(100 / $searchUsers.Count, 1)
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
            if ($null -ne $ADGroup -and ($null -ne $ADGroupUsersMembers -or ($null -ne $ADGroupComputersMembers))) {
                $Global:checkData = $true
            }
        }
        catch {
            $Global:errorMessage = "Error: $group not found as Active Directory Group"
            $Global:checkData = $false
        }
    }
}