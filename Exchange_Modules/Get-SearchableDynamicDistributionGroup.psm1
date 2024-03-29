function Get-SearchableDynamicDistributionGroup {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$email
    )

    BEGIN {
        # Creating necessary variables
        $Global:emailData = $null
        $Global:emailDataMembers = $null
        $Global:checkData = $null
        $Global:errorMessage = $null
        $oldPref = $global:ErrorActionPreference
        $global:ErrorActionPreference = "Stop"
    }

    PROCESS {
        try {
            # Searching for speficified $email and members information
            Write-Progress -Activity "Searching Dynamic Distribution Group" -Status "Searching"
            $Global:emailData = Get-DynamicDistributionGroup $email -ErrorAction Stop | Select-Object -Property * -ErrorAction Stop
            $Global:emailDataMembers = Get-DynamicDistributionGroupMember $email -ResultSize Unlimited -ErrorAction Stop | Select-Object -Property * -ErrorAction Stop | Sort-Object Name
            Write-Progress -Completed 'Unused'
            $Global:checkData = $true
        }
        catch {
            $Global:errorMessage = "Error: $email not found on Exhange Servers as Dynamic Distribution Group"
            $Global:checkData = $false
        }
    }
    END {
        $global:ErrorActionPreference = $oldPref
    }
}
