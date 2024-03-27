function Get-SearchableDistributionGroup {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$email
    )

    BEGIN {
        $Global:emailData = $null
        $Global:emailDataMembers = $null
        $Global:checkData = $null
        $Global:errorMessage = $null
        $oldPref = $global:ErrorActionPreference
        $global:ErrorActionPreference = "Stop"
    }

    PROCESS {
        try {
            Write-Progress -Activity "Searching Distribution Group" -Status "Searching"
            $Global:emailData = Get-DistributionGroup $email | Select-Object -Property * -ErrorAction Stop
            $Global:emailDataMembers = Get-DistributionGroupMember $email | Select-Object -Property * | Sort-Object Name
            Write-Progress -Completed 'Unused'
            $Global:checkData = $true
        }
        catch {
            $Global:errorMessage = "Error: $email not found on Exhange Servers as Distribution Group"
            $Global:checkData = $false
        }
    }
    END {
        $global:ErrorActionPreference = $oldPref
    }
}
