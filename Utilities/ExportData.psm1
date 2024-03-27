function ExportDatatoCSV {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [array]$exportVar
    )
    $exportVar | ForEach-Object -Process {
        if (Test-Path -Path .\Export\$PSItem.csv){
            Remove-Item -Path .\Export\$PSItem.csv
        }
        $exportVariable = Get-Variable $PSItem
        if ($null -ne $exportVariable.Value){
            if ($null -eq $exportVariable.Value.Count){
                Export-Csv -InputObject $exportVariable.Value -Path .\Export\$PSItem.csv -NoTypeInformation
            } else {
                $name = $exportVariable.Name
                $exportVariable.Value | ForEach-Object -Process {
                    Export-Csv -InputObject $PSItem -Path .\Export\$name.csv -NoTypeInformation -Append -Force
                }
            }
        }
    }
}