[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$group
)

BEGIN {
    # Importing Modules
    try {
        Import-Module -Name .\AD_Modules\Get-FullADGroup.psm1
        Import-Module -Name .\AD_Modules\Get-ADGroupHistory.psm1
        Import-Module -Name .\Utilities\ADGroupTextForUser.psm1
        Import-Module -Name .\Utilities\ExportData.psm1
    }
    catch {
        Write-Error -Message "Error - Module Not Found"
    }
    # Creating necessary variables
    $oldPref = $global:ErrorActionPreference
    $Global:ErrorActionPreference = "Stop"
    $Global:errorMessage = $null
    $Global:checkData = $null

    # Importing AD Module
    Get-ADDomain | Out-Null

    Clear-Host
}
PROCESS {
    # Process of searching for $group via different modules and sending information to user via console
    Get-FullADGroup $group
    if ($checkData -eq $true) {
        Get-ADGroupHistory $group
        if ($checkData -eq $true) {
            TextForUserCorrect $group
        }
        else {
            TextForUserErrorMessage "Error: $group history of members could be resolved"
        }
    }
    else {
        TextForUserErrorMessage "Error: $group not found as AD Group"
    }
    # Exporting information to *.csv files
    ExportDatatoCSV ADGroup, ADGroupMembersHistory
    if ($ADGroupUsersMembers.Count -gt 0) {
        ExportDatatoCSV ADGroupUsersMembers
    }
    if ($ADGroupComputersMembers.Count -gt 0) {
        ExportDatatoCSV ADGroupComputersMembers
    }
    ExportTextForUser
}
END {
    # Removing Modules
    $global:ErrorActionPreference = $oldPref
    Remove-Module Get-FullADGroup
    Remove-Module Get-ADGroupHistory
    Remove-Module ADGroupTextForUser
    Remove-Module ExportData
}