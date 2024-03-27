function Get-SearchableExchangeGroup {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$email
    )

    BEGIN {
        $Global:emailData = $null
        $Global:checkData = $null
        $Global:errorMessage = $null
        $Global:emailDataMembers = @()
        $oldPref = $global:ErrorActionPreference
        $global:ErrorActionPreference = "Stop"
    }

    PROCESS {
        try {
            Write-Progress -Activity "Searching Exchange/Teams Group" -Status "Searching"
            $Global:emailData = Get-Group $email -ErrorAction Stop | Select-Object -Property * -ErrorAction Stop
            Write-Progress -Completed 'Unused'
            $emailData.Members | ForEach-Object -Begin {
                $i = [math]::Round(100/$emailData.Members.count, 1)
                $n = 0
            } -Process {
                Write-Progress -Activity "Search of Exchange/Teams Group Members" -Status "$n% Complete:" -PercentComplete $n
                $Global:emailDataMembers += Get-Mailbox $PSItem | Select-Object -Property * -ErrorAction Stop
                $n += $i
            }

            $Global:checkData = $true
        }
        catch {
            $Global:errorMessage = "Error: $email not found on Exhange Servers as Exchange/Teams Group"
            $Global:checkData = $false
        }
    }
    END {
        $global:ErrorActionPreference = $oldPref
    }
}
