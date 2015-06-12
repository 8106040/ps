"Azure TFS Demo Env Management Script"
"Please Choose:"
"Option [1] - Start ALL Azure VM"
"Option [2] - Stop ALL Azure VM"
$value = Read-Host

#Add-AzureAccount

$azurevm=Get-AzureVM

Switch($azurevm)
{
{$value -eq 1} {  Start-AzureVM -ServiceName $_.ServiceName -Name $_.Name }
{$value -eq 2} {  Stop-AzureVM -ServiceName $_.ServiceName -Name $_.Name -StayProvisioned }
Default {"Error input"}
}
<#
If( $value -eq 1 )
{

	"--------------------Starting xhtfs.cloudapp.net VM--------------------"
	 Start-AzureVM -ServiceName xhtfs -Name xhtfs
	 "--------------------Starting linuxagent.cloudapp.net VM--------------------"
	 Start-AzureVM -ServiceName xhlinuxagent -Name linuxagent
	"--------------------Status--------------------"
}
Elseif( $value -eq 2)
{
	"--------------------Stoping xhtfs.cloudapp.net VM--------------------"
 	 Stop-AzureVM -ServiceName xhtfs -Name xhtfs -Force
	"--------------------Stoping linuxagent.cloudapp.net VM--------------------"
	 Stop-AzureVM -ServiceName xhlinuxagent -Name linuxagent -Force
	"--------------------Status--------------------"
}
Else
{
    "Error Input"
}#>
"--------------------Operation Completed--------------------"