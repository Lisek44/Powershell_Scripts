function TextForUserCorrect {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$email,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$text,
        [Parameter(Position = 2, Mandatory = $false)]
        [string]$type
    )
    Write-Host "Found ""$email"" as $text" -ForegroundColor Green
    Write-Host "Data is in Variable - " -ForegroundColor Green -NoNewline
    Write-Host "emailData" -ForegroundColor Blue
    switch($type){
        {$type -eq "Mailbox"}{}
        {$type -eq "Shared Mailbox"}{
            Write-Host "AD Group info is in Variable - " -ForegroundColor Green -NoNewline
            Write-Host "sharedMailboxADGroup" -ForegroundColor Blue
            Write-Host "AD Group Members are in Variable - " -ForegroundColor Green -NoNewline
            Write-Host "sharedMailboxADGroupMembers" -ForegroundColor Blue
            Write-Host "AD Group MembersHistory are in Variable - " -ForegroundColor Green -NoNewline
            Write-Host "ADGroupMembersHistory" -ForegroundColor Blue
        }
        default{
            Write-Host "Members are in Variable - " -ForegroundColor Green -NoNewline
            Write-Host "emailDataMembers" -ForegroundColor Blue
        }
    }
}
function TextForUserErrorNotFoundAny {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$email
    )
    Write-Host ""
    Write-Host "Error: $email not found anywhere on Exchange server" -ForegroundColor Red
}
function TextForUserErrorMessage {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$errorMessage
    )
    Write-Host $errorMessage -ForegroundColor Red
}