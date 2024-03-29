function Get-SearchableDistributionGroup {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$email
    )

    BEGIN {
        # Creating necessary variables
        $Global:emailData = $null
        $Global:emailDataMembers = $null
        $Global:emailDataOwners = @()
        $Global:checkData = $null
        $Global:errorMessage = $null
        $oldPref = $global:ErrorActionPreference
        $global:ErrorActionPreference = "Stop"
    }

    PROCESS {
        try {
            # Searching for speficified $email, members and owners information
            Write-Progress -Activity "Searching Distribution Group" -Status "Searching"
            $Global:emailData = Get-DistributionGroup $email | Select-Object -Property * -ErrorAction Stop
            $Global:emailDataMembers = Get-DistributionGroupMember $email | Select-Object -Property * | Sort-Object Name
            $searchOnwers = $emailData.ManagedBy | Sort-Object Name
            $searchOnwers | ForEach-Object -Process {
                $Global:emailDataOwners += Get-Mailbox $PSItem | Select-Object -Property *
            }
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
