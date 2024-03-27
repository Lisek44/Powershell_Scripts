function Get-SearchableMailbox {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$email
    )

    BEGIN {
        $Global:emailData = $null
        $Global:checkData = $null
        $Global:errorMessage = $null
        $Global:sharedMailboxADGroup = $null
        $Global:sharedMailboxADGroupMembers = @()
        $oldPref = $global:ErrorActionPreference
        $global:ErrorActionPreference = "Stop"
    }

    PROCESS {
        try {
            Write-Progress -Activity "Searching Mailbox/Shared Mailbox" -Status "Searching"
            $Global:emailData = Get-Mailbox $email | Select-Object -Property * -ErrorAction Stop
            $verify = (Get-MailboxPermission $emailData.PrimarySmtpAddress | Where-Object {$_.User -notmatch "NT AUTHORITY"}).User
            $Global:verifySharedMailbox = if ($null -ne $verify) {$true} else {$false}
            Write-Progress -Completed 'Unused'
            if($emailData.RecipientTypeDetails -eq "SharedMailbox" -or ($null -ne $verify)) {
                Write-Progress -Activity "Searching AD Group" -Status "Searching"
                $Global:sharedMailboxADGroup = Get-ADGroup ((Get-MailboxPermission $emailData.PrimarySmtpAddress | Where-Object {$_.User -notmatch "NT AUTHORITY"}).User) -Properties *
                Write-Progress -Completed 'Unused'
                $searchUsers = @()
                $searchUsers += Get-ADGroupMember $sharedMailboxADGroup
                $searchUsers | ForEach-Object -Begin {
                    $i = [math]::Round(100/$searchUsers.Count, 1)
                    $n = 0
                } -Process {
                    Write-Progress -Activity "Search of AD Group Members" -Status "$n% Complete:" -PercentComplete $n
                    $Global:sharedMailboxADGroupMembers += Get-ADUser $PSItem.SamAccountName -Properties *
                    $n += $i
                }
            }
            if ($null -ne $sharedMailboxADGroup){
                Get-ADGroupHistory $sharedMailboxADGroup.SamAccountName
            }
            $Global:checkData = $true
        }
        catch {
            $Global:errorMessage = "Error: $email not found on Exhange Servers as Mailbox/Shared Mailbox"
            $Global:checkData = $false
        }
    }
    END {
        $global:ErrorActionPreference = $oldPref
    }
}