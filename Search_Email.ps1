[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$email
)

BEGIN {
    # Importing Modules
    try {
        Import-Module -Name .\Exchange_Modules\Connect-AutoExchangeOnline.psm1
        Import-Module -Name .\Exchange_Modules\Get-SearchableMailbox.psm1
        Import-Module -Name .\Exchange_Modules\Get-SearchableDistributionGroup.psm1
        Import-Module -Name .\Exchange_Modules\Get-SearchableDynamicDistributionGroup.psm1
        Import-Module -Name .\Exchange_Modules\Get-SearchableExchangeGroup.psm1
        Import-Module -Name .\AD_Modules\Get-ADGroupHistory.psm1
        Import-Module -Name .\Utilities\ExchangeTextForUser.psm1
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
    $Global:emailData = $null
    $Global:emailDataMembers = $null
    $Global:emailDataMembers = $null
    $Global:ADGroupMembersHistory = @()

    # Importing Exchange Online Module
    if ($null -eq (Get-Module -Name ExchangeOnlineManagement)) {
        Install-Module -Name ExchangeOnlineManagement -RequiredVersion 3.4.0
    }

    # Check for connection to Exchange Online
    if ($null -eq $credential_mail) {
        Connect-AutoExchangeOnline
    }
    Clear-Host
}

PROCESS {
    # Process of searching for $email via different modules and sending information to user via console
    Get-SearchableMailbox $email
    if ($checkData -eq $false) {
        TextForUserErrorMessage $errorMessage
        Get-SearchableDistributionGroup $email
        if ($checkData -eq $false) {
            TextForUserErrorMessage $errorMessage
            Get-SearchableDynamicDistributionGroup $email
            if ($checkData -eq $false) {
                TextForUserErrorMessage $errorMessage
                Get-SearchableExchangeGroup $email
                if ($checkData -eq $false) {
                    TextForUserErrorMessage $errorMessage
                    TextForUserErrorNotFoundAny $email
                }
                else {
                    TextForUserCorrect $email "Exchange/Teams Group" "Exchange/Teams Group"
                }
            }
            else {
                TextForUserCorrect $email "Dynamic Distribution Group" "Dynamic Distribution Group"
            }
        }
        else {
            TextForUserCorrect $email "Distribution Group" "Distribution Group"
        }
    }
    else {
        if ($emailData.RecipientTypeDetails -eq "SharedMailbox" -or ($verifySharedMailbox -eq $true)) {
            TextForUserCorrect $email "Mailbox/Shared Mailbox" "Shared Mailbox"
        }
        else {
            TextForUserCorrect $email "Mailbox/Shared Mailbox" "Mailbox"
        }
    }
    # Exporting information to *.csv files
    ExportDatatoCSV emailData, emailDataMembers, sharedMailboxADGroup, sharedMailboxADGroupMembers, ADGroupMembersHistory
    ExportTextForUser
}

END {
    # Removing Modules
    $global:ErrorActionPreference = $oldPref
    Remove-Module Get-SearchableMailbox
    Remove-Module Get-SearchableDistributionGroup
    Remove-Module Get-SearchableDynamicDistributionGroup
    Remove-Module Get-SearchableExchangeGroup
    Remove-Module Get-ADGroupHistory
    Remove-Module ExchangeTextForUser
    Remove-Module ExportData
}