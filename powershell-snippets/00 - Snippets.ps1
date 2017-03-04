Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Load a script
$psFolder="c:\Work\ExamplesPowershell\"
Write-Host $psFolder
dir $psFolder | Format-List

. "$psFolder\02 - Load the Provider and SMO.ps1"

# Loads the SqlServerCmdletSnapin100 and SqlServerProviderSnapin100SMO
# SMO and SQLServerProvider
Import-Module "sqlps"

Get-PSProvider | Select-Object Name | Where-Object { $_ -match "Sql*" }

Get-ChildItem 'C:\Work'| Where-Object {$_.PSIsContainer} 

Get-ChildItem 'C:\Work'| Where-Object {$_.PSIsContainer} 

dir $psFolder | Where-Object {$_.PSIsContainer -eq $False} | Get-member

dir $psFolder | Get-member | Where-Object MemberType -eq Method

# See this: http://dbadailystuff.com/2012/06/09/powershell-get-childitem-examples
# Get files and directories in E:\temp directory
Get-ChildItem -path "E:\temp" 

# Connect to the LocalDB sql server instance
$localDbInstance="(localdb)\MSSQLLocalDB"
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server($localDbInstance) 
$Server.Databases

# List all the localdb instances
iex "SQLLocalDB i"