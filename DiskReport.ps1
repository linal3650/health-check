# generates a daily disk report using DiskHistory.csv as standard input

Param (
    [string]$path = "C:\Users\Alex\Documents\Notes\PowerShell\DiskHistory.csv",
    [string]$reportPath = "C:\Users\Alex\Documents\Notes\PowerShell"
)

if (Test-Path -path $path) {
    # everything imported into a CSV is a string so rebuild as an object
    # with properties of the correct type
    $data = Import-CSV -Path $path | foreach-object {
        [pscustomobject]@{
            Computername = $_.Computername
            DeviceID     = $_.DeviceID
            SizeGB       = ($_.size / 1GB) -as [int32]
            FreeGB       = [math]::Round(($_.freespace / 1GB),2)
            PctFree      = [math]::Round($_.PctFree -as [double],2)
            Date         = $_.Date -as [datetime]
        }
    }
    $grouped = $data | Group-Object -Property Computername
}
else {
    Write-Warning "Can't find $path."
    #break out of the script
    Return
}

$timestamp = Get-Date -format yyyyMMdd
$outputFile = "$timestamp-diskreport.txt"
$outputPath = Join-Path -path $reportPath -ChildPath $outputFile

$outParams = @{
    FilePath = $outputPath
    Encoding = "UTF8"
    Append   = $True
    Width    = 120
}

$header = @"
Disk History Report - $((Get-Date).ToShortDateString())
*************************************
Data Source = $path

*************
Latest Check
*************
"@
$header | Out-File @outParams

$latest = foreach($computer in $grouped) {
    $devices = $computer.Group  | Group-Object -Property DeviceID
    $devices | foreach-object {
        $_.Group | Sort-Object Date -Descending |  Select-Object -first 1
    }    
}

$latest | Sort-Object -property Computername | 
    Format-Table -AutoSize | Out-file @outParams

# report on servers with low disk space
$header = @"
*********************
Low Diskpace <= 30 %
*********************
"@
$header | Out-File @outParams

$latest | Where-Object {$_.PctFree -le 30} | 
    Sort-Object -Property Computername |
    Format-Table -AutoSize | 
    Out-File @outParams

$all = $data | Group-object -property {"$($_.Computername) $($_.DeviceID)"}

$header = @"
**************************************
Change Percent between last 2 reports
**************************************
"@
$header | Out-File @outParams

$all | foreach-object {
    $checks = $_.group | 
    Sort-Object -Property date -Descending |
        Select-Object -first 2
        
    "$($checks[0].Computername) Drive $($checks[0].DeviceID) had a change of $(($checks[0].PctFree - $checks[1].PctFree) -as [int32])%"
} | Out-File @outParams


$header = @"


*******************************
Percent Free Average Over Time
*******************************
"@
$header | Out-File @outParams


foreach ($computer in $all) {
    $stat = $computer.group | Measure-Object -property pctFree -Average
    "$($computer.name) = $($stat.Average -as [int32])%" | Out-File @outParams
} 

#write the report file to the pipeline
Get-Item -Path $outputPath
