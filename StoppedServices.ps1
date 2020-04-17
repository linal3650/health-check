$computername = Read-Host 'Enter name of host'

Start-Transcript -path .\Transcript.txt -append

$stoppedService = Get-Service -ComputerName $computername | 
                        Where-Object -Property Status -eq Stopped
                        
Write-Output $stoppedService

Stop-Transcript

