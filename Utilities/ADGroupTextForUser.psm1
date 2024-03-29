function TextForUserCorrect {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$groupName
    )
    Write-Host "Found ""$groupName""" -ForegroundColor Green
    Write-Host "AD Group info is in Variable - " -ForegroundColor Green -NoNewline
    Write-Host "ADGroup" -ForegroundColor Blue
    if ($usersCount -gt 0) {
        Write-Host "AD Group Users Members are in Variable - " -ForegroundColor Green -NoNewline
        Write-Host "ADGroupUsersMembers" -ForegroundColor Blue -NoNewline
        Write-Host " | Count:" $usersCount -ForegroundColor Green
    }
    if ($computersCount -gt 0) {
        Write-Host "AD Group Computer Members are in Variable - " -ForegroundColor Green -NoNewline
        Write-Host "ADGroupComputersMembers" -ForegroundColor Blue -NoNewline
        Write-Host " | Count:" $computersCount -ForegroundColor Green
    }
    # Write-Host "Users:" -ForegroundColor Green -NoNewline
    # Write-Host $usersCount -ForegroundColor Blue
    # Write-Host "Computers:" -ForegroundColor Green -NoNewline
    # Write-Host $computersCount -ForegroundColor Blue
    if ($null -ne $ADGroupMembersHistory) {
        Write-Host "AD Group MembersHistory are in Variable - " -ForegroundColor Green -NoNewline
        Write-Host "ADGroupMembersHistory" -ForegroundColor Blue
    }
}
function TextForUserErrorMessage {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$errorMessage
    )
    Write-Host $errorMessage -ForegroundColor Red
}