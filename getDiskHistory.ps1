# Get disk usage information and export it to a CSV file for trend reporting

Param (
    [string[]]$Computername = $env:COMPUTERNAME    # takes multiple arguments from command line
)

# path to CSV file is hard coded
$CSV = "C:\Users\<user>\DiskHistory.csv"

# initialize an empty array
$data = @()

# define a hashtable of parameters to splat to Get-CimInstance
$cimParams = @{
    Classname = "Win32_LogicalDisk"
    Filter = "drivetype = 3"
    ErrorAction = "Stop"
}

Write-Host "Getting disk information from $Computername" -ForegroundColor Cyan
foreach($computer in $Computername) {
    Write-Host "Getting disk information from $computer." -ForegroundColor Cyan
    $cimParams.Computername = $computer
    
    Try {
        $disks = Get-CimInstance @cimParams

        $data += $disks |
            Select-Object @{Name = "Computername"; Expression = {$_.SystemName}},
        DeviceId, Size, FreeSpace,
        @{Name = "PctFree"; Expression = { ($_.FreeSpace / $_.Size) * 100}},
        @{Name = "Date"; Expression = {Get-Date}}
    } # try
    
    Catch {
        Write-Warning "Failed to get disk data from $($computer.toUpper()). $($_.Exception.message)"
    } # catch
    
} # foreach

# only export if there is something in $data
if ($data) {
    $data | Export-Csv -Path $CSV -Append -NoTypeInformation
    Write-Host "Disk report complete. See $CSV." -ForegroundColor Green
}
else {
    Write-Host "No disk data found." -ForegroundColor Yellow
}

#sample usage
# .\GetDiskHistory.ps1 -Computername ABC,DEF,GHI,JKL
