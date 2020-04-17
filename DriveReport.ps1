param (
    [string[]]$Computername = $env:COMPUTERNAME
)

foreach ($computer in $Computername) {
    # verify computer is online
    if (Test-Connection -ComputerName $Computer -Count 2 -Quiet) {
        # use Try/Catch because a computer may be online but encounter other issues connecting like invalid credentials
        Try {
            Write-Host "Getting volume data from $($computer.toUpper())" -ForegroundColor Cyan
            #get all volumes that have a DriveLetter assigned
            Get-Volume -ErrorAction Stop | Where-Object {$_.DriveLetter} |
                Select-Object @{Name = "ComputerName"; Expression = {$computer.ToUpper()}},
            @{Name = "Drive"; Expression = {$_.DriveLetter}},
            FileSystem,
            @{Name = "SizeGB"; Expression = {$_.size / 1gb -as [int32]}},
            @{Name = "FreeGB"; Expression = {[math]::Round($_.SizeRemaining / 1gb, 2)}},
            @{Name = "PctFree"; Expression = {[math]::Round(($_.SizeRemaining / $_.size) * 100, 2)}}
        }
        Catch {
            Write-Warning "Can't get volume data from $($Computer.toUpper()).%($_.Exception.Message)."
        }
    } #if test is ok
    else {
        Write-Warning "Can't ping $($computer.ToUpper())."
    }
} #foreach computer
