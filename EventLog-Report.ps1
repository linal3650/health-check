# Get a breakdown of error sources in the System Event Log

Param(
    [string]$Log = "System",
    [string]$Computername = $env:COMPUTERNAME,
    [int32]$Newest = 500,
    [string]$ReportTitle = "Event Log Report",
    [Parameter(HelpMessage = "Enter the path for the HTML file.")]
    [string]$Path
)

$data = Get-EventLog -LogName $Log -EntryType Error -Newest $Newest -ComputerName $Computername |
    Group-Object -Property Source -NoElement

# Create an HTML report
$footer = "<h5><i>Report run on $(Get-Date)</i></h5>"
$precontent = "<h1>$Computername</h1><h2>Last $Newest error sources from $Log</h2>"

$data | Sort-Object -Property Count,Name -Descending |
    Select-Object Count,Name |
    ConvertTo-Html -Title $ReportTitle -PreContent $precontent -PostContent $footer |
    Out-File -FilePath $Path

#.\paramscript.ps1 -Path .\systemresources.html
