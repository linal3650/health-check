# takes a text file input "computers.txt" of computers to scan and runs the DriveReport.ps1 to generate a report 

$filename = "$(Get-Date -Format "yyyyddMM")-VolumeReport.txt"

$report = Join-Path -path . -ChildPath $filename

if (Test-Path -Path C:\Users\<user>\computers.txt) {
    $computers = Get-Content -Path C:\Users\<user>\computers.txt
    $data = C:\Users\<user>\DriveReport.ps1 -Computername $computers

    if ($data) {
        "Volume Report: $(Get-Date)" | Out-File -FilePath $filename
        "Run by: $($env:USERNAME)" | Out-File -FilePath $filename -Append
        "**********************************" | Out-File -FilePath $filename -Append

        $data |
            Sort-Object -Property Computername, Drive |
            Format-Table -GroupBy Computername -Property Drive, FileSystem, SizeGB, FreeGB, PctFree |
            Out-File -FilePath $report -Append

            $found = $data.computername | Select-Object -Unique
            $missed = $computers | Where-Object {$found -notcontains $_}
            $missed | Out-File -filepath .\Offline.txt

            "Missed computers:" | Out-File -FilePath $filename -Append
            $missed | ForEach-Object {$_.toUpper()} | Out-File -FilePath $filename -Append

            Write-Host "Report finished. See $report." -ForegroundColor Green
    }
    else {
        Write-Warning "Failed to capture any volume information. Is DiskReport.ps1 in the same folder as this script?"
    }
}
else {
    Write-Warning "Can't find computers.txt"
}
