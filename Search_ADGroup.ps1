[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string]$name
)

BEGIN {
    try{
        Import-Module -Name .\AD_Modules\Get-FullADGroup.psm1
        Import-Module -Name .\AD_Modules\Get-ADGroupHistory.psm1
        Import-Module -Name .\Utilities\ADGroupTextForUser.psm1
    }
    catch {
        Write-Error -Message "Error - Module Not Found"
    }

    $oldPref = $global:ErrorActionPreference
    $Global:ErrorActionPreference = "Stop"
    $Global:errorMessage = $null
    $Global:checkData = $null

    Get-ADDomain | Out-Null

    Clear-Host
}
PROCESS {
    Get-FullADGroup $name
    if ($checkData -eq $true){
        Get-ADGroupHistory $name
        if ($checkData -eq $true){
            TextForUserCorrect $name
        } else {
            TextForUserErrorMessage "Error: $name history of members could be resolved"
        }
    } else {
        TextForUserErrorMessage "Error: $name not found as AD Group"
    }
}
END {
    $global:ErrorActionPreference = $oldPref
    Remove-Module Get-FullADGroup
    Remove-Module Get-ADGroupHistory
    Remove-Module ADGroupTextForUser
}