#-----------------------------------------------------------------------------------------------#
# Loading the SQL Provider
#-----------------------------------------------------------------------------------------------#
# Show loaded providers
Get-PSProvider

# Now load the sql provider and SMO
# . 'C:\PS\03 - SQL\02 - Load the Provider and SMO.ps1'
Import-Module "sqlps"

# Show it's now loaded
Get-PSProvider
  
  
Clear-Host

  
##
  
  
  
  
  
  
  
  
  
  
  
  
#-----------------------------------------------------------------------------------------------#
# A quick tour around the SQL Provider - Navigating its hierarchy
#-----------------------------------------------------------------------------------------------#
  
# Navigate to the provider
Set-Location SQLSERVER:\
Get-ChildItem

# Move to the SQL folder to see the Machine  
Set-Location SQLSERVER:\SQL
Get-ChildItem
  

# Move down to the Machine to see the installed instances
Set-Location SQLSERVER:\SQL\PORTHOS
Get-ChildItem

# Move down to the instance to see server level objects
Set-Location SQLSERVER:\SQL\PORTHOS\SQLEXPRESS
Get-ChildItem

# Providers are variable friendly
$machine = "PORTHOS"
$sqlServer = "SQLEXPRESS"
$instance = "SQLSERVER:\SQL\$machine\$sqlServer"

# Move down to databases to see them
Set-Location $instance\Databases
Get-ChildItem

# Move down to a specific databases to see its objects
Set-Location $instance\Databases\TestAdrian
Get-ChildItem

# Move to the table collection to see all the tables
Set-Location $instance\Databases\TestAdrian\Tables
Get-ChildItem

# and so on!
  
##    





#-----------------------------------------------------------------------------------------------#
# Get the SQL Server Instances for each machine we pass it
#-----------------------------------------------------------------------------------------------#

# Load an array of instance objects
$machine = $env:COMPUTERNAME
$instances = Get-ChildItem "SQLSERVER:\SQL\$machine"
Write-Output $instances 

# Load instances as an array of strings
$instances = @() # Initialize or reset instances array
Get-ChildItem "SQLSERVER:\SQL\$machine" |
Select-Object PSChildName | 
foreach{$instances += $_.PSChildName}

Write-Output $instances 


# Iterate over all the servers / instances 
# and do more complex tasks
  
# (Pretend like this is an array of server names)
$machines = $env:COMPUTERNAME

Push-Location
$machineInstances = @() # Initialize or reset instances array
foreach ($machine in $machines) {
  if ($machine -ne "") {
    # In reality you could issue complex commands
    # inside the foreach loop
    Set-Location "SQLSERVER:\SQL\$machine"
    Get-ChildItem |
    Select-Object PSChildName |
    foreach {$machineInstances += "$machine\" + $_.PSChildName }
  }
}
Pop-Location
  
Write-Output $machineInstances
 


##















#-----------------------------------------------------------------------------------------------#
# A first look at SMO
#-----------------------------------------------------------------------------------------------#
  
# The SMO (SQL Management Object) is a .Net library for working with SQL Server. 
# The object model shows all the available objects, and how they are related. All objects
# in SMO extend from the root node of "Server". Once you create a server object, you can then
# drill down and work with the rest of the objects on the server. 
  
# To see the object model for SMO, a diagram of everything in the library, visit:
# http://msdn.microsoft.com/en-us/library/ms162209.aspx
#   or
# http://bit.ly/smodiagram

# To see the details about the namespace visit:
# http://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo
#   or
# http://bit.ly/smonamespace













##

#-----------------------------------------------------------------------------------------------#
# Get version for each instance
#-----------------------------------------------------------------------------------------------#

function Get-SQLVersion ($fullversion) {		
  switch ($fullversion) {
    "8.194.0" {
      $ver = " SQL Server 2000 RTM"; break
    }
    "8.384.0" {
      $ver = " SQL Server 2000 SP1"; break
    }
    "8.534.0" {
      $ver = " SQL Server 2000 SP2"; break
    }
    "8.760.0" {
      $ver = " SQL Server 2000 SP3"; break
    }
    "8.00.2039" {
      $ver = " SQL Server 2000 SP4"; break
    }
    "9.00.1399" {
      $ver = " SQL Server 2005 RTM"; break
    }
    "9.00.2047" {
      $ver = " SQL Server 2005 SP1"; break
    }
    "9.00.3042" {
      $ver = " SQL Server 2005 SP2"; break
    }
    "9.00.4035" {
      $ver = " SQL Server 2005 SP3"; break
    }
    "10.0.1300" {
      $ver = " SQL Server 2008 CTP6"; break
    }
    "10.0.1600" {
      $ver = " SQL Server 2008 RTM"; break
    }
    "10.0.2531" {
      $ver = " SQL Server 2008 SP1"; break
    }
    "10.50.161" {
      $ver = " SQL Server 2008 R2"; break
    } 
    "11.0.2100" {
      $ver = " SQL Server 2012 RTM"; break
    } 
    "13.0.4001" {
      $ver = " SQL Server 2016 "; break
    } 
    default {
      $ver = " version cannot be determined. Returned value was $versub"; break
    }
  }
  return $ver
}

# To get the instance names you have to step outside
# SMO, since the root object of SMO, Server, really
# represents the Server + Instance
#
# Here we will use a class supplied in ADO.Net to get 
# available data sources, then convert them to a string array
  
$instances = @() # Initialize or reset instances array
([System.Data.Sql.SqlDataSourceEnumerator]::Instance).GetDataSources() |
Select-Object ServerName, InstanceName  | 
foreach{
  if ($_.InstanceName -eq "DEFAULT") {
    $mi = $_.ServerName 
  }
  else {
    $mi = $_.ServerName + "\" + $_.InstanceName 
  }

  $instances += $mi
}

# Now create a server object for each instance
# and get it's VersionString property
# Finally, run that property thru the function
# and add to the hashtable
$versions = @{}  # Initialize or reset the versions hashtable
foreach ($instance in $instances) {
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server($instance)
  $ServerVer = $Server.Information.Properties |
  Where-Object {$_.name -eq "VersionString"}
  $versub = $ServerVer.Value.SubString(0,9)
  Write-Output "SQL Server version: $versub"
  $versions[$instance] = Get-SQLVersion($versub)  
} # instances

Clear-Host
$versions
  

##




#-----------------------------------------------------------------------------------------------#
# Some things can be done in either SMO or the SQL Provider
# Here we get a list of databases on the server\instance
#-----------------------------------------------------------------------------------------------#
# Put your instance name in the quotes, or omit it for the default instance
$mi = $env:COMPUTERNAME + "\SQLEXPRESS"  
#$mi = $env:COMPUTERNAME + "\SQL2012"    
$mi = "(localdb)\MSSQLLocalDB"  

# Get a list of databases on the server\instance. 
# Note by default, system db's like tempdb are omitted
Get-ChildItem SQLSERVER:\sql\$mi\databases 

# To show system dbs as well, use the -force
Get-ChildItem sqlserver:\sql\$mi\databases -Force 

# Use SMO to get list of db's. Note system db's are included by default
$smoNamespace = "Microsoft.SqlServer.Management.Smo." 
$server = New-Object ($smoNamespace + "Server") "$mi" 
$server.databases   



#-----------------------------------------------------------------------------------------------#
# A second example of doing things in either SMO or the SQL Provider
# Here we find out all sorts of cool things about the databases
#-----------------------------------------------------------------------------------------------#

# The SQL Provider way
# Using the provider
#$mi = $env:COMPUTERNAME + "\SQL2012"  
Get-ChildItem SQLSERVER:\sql\$mi\databases |
Format-Table -AutoSize -Property Name, Size, DataSpaceUsage, IndexSpaceUsage,SpaceAvailable

# Added formatting, also added the -Force switch to display system databases
#$mi = $env:COMPUTERNAME + "\SQL2012"  
Get-ChildItem SQLSERVER:\sql\$mi\databases -Force |
Format-Table -AutoSize -Property Name `
        , @{Label="Size";Alignment="Right";Exp={"{0,0:n0}" -f($_.Size)}} `
        , @{Label="Data Space Used";Alignment="Right";Exp={"{0,0:n0}" -f($_.DataSpaceUsage)}} `
        , @{Label="Index Space Used";Alignment="Right";Exp={"{0,0:n0}" -f($_.IndexSpaceUsage)}} `
        , @{Label="Space Available KB";Alignment="Right";Exp={"{0,0:n0}" -f($_.SpaceAvailable/1KB)}}

# Some other data that's available to us
Get-ChildItem sqlserver:\sql\$mi\databases |
Format-Table Name,
@{Label="Size"
  Alignment="Right"
  Expression={($_.Size).ToString("F")}
},
@{Label="Available"
  Alignment="Right"
  Expression={($_.SpaceAvailable/1KB).ToString("F")}
},
@{Label="LogSize"
  Alignment="Right"
  Expression = {($_.LogFiles[0].Size/1KB).ToString("F4")}
},
@{Label="LogUsed"
  Alignment="Right"
  Expression={($_.LogFiles[0].UsedSpace/1KB).ToString("F")}
} 

# Discovering all the properties and methods
Get-Item SQLSERVER:\sql\$mi\databases\tempdb | Get-Member

# Getting the value of a specific property
(Get-Item SQLSERVER:\sql\$mi\databases\tempdb).CreateDate

$db = Get-Item SQLSERVER:\sql\$mi\databases\tempdb
$db.CreateDate
    
# Getting a property which is itself a collection of objects
(Get-Item SQLSERVER:\sql\$mi\databases\tempdb).Schemas 

# Pass that collection down the pipeline to do fun things
$db.Schemas | Where-Object {$_.Name -NotLike "db_*"}



# Using SMO
$machine = $env:COMPUTERNAME + "\SQLEXPRESS"  

#!$machine = "(localdb)\MSSQLLocalDB"  

# $machine = $env:COMPUTERNAME + "\SQL2012"  
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$Server.databases |
Format-Table -AutoSize -Property Name, Size, DataSpaceUsage, IndexSpaceUsage,SpaceAvailable

# Add some formatting
$Smo = "Microsoft.SqlServer.Management.Smo."
$server = New-Object ($Smo + 'server') "$mi" 

# Headers
"    {0,27}  {1,10} {2,10}  {3,10} {4,10}" `
      -f "Table Name", "Size", "Space", "Log Size", "Used"

"    {0,27}  {1,10} {2,10}  {3,10} {4,10}" `
      -f ("-" * 27), ("-" * 10), ("-" * 10), ("-" * 10), ("-" * 10)

# Data
foreach ($db in $Server.Databases) {
  "    {0,27}  {1,10:n} {2,10:n}  {3,10:n} {4,10:n}" `
        -f $db.Name, 
  $db.Size, 
  $($db.SpaceAvailable/1KB), 
$($db.LogFiles[0].Size/1KB), 
$($db.LogFiles[0].UsedSpace/1KB)
} 

$testDbName="tempdb"

# How to get a list of methods and properties for an object
$Server.Databases.Item("$testDbName") | Get-Member
    
# Get a specific property
$Server.Databases.Item("$testDbName").Name
$Server.Databases.Item("$testDbName").CreateDate

$db = New-Object Microsoft.SqlServer.Management.SMO.Database
$db = $Server.Databases.Item("$testDbName")
    
$db.Name
$db.CreateDate
foreach($schema in $db.Schemas) {
  $schema.Name 
}
    

##






#-----------------------------------------------------------------------------------------------#
# Get table space usage
#-----------------------------------------------------------------------------------------------#
$mi = $env:COMPUTERNAME + "\SQLEXPRESS"  
# $mi = $env:COMPUTERNAME + "\SQL2012"  
Get-ChildItem SQLServer:\sql\$mi\databases\AdventureWorksLT2012\Tables |
Format-Table -AutoSize -Property Schema, Name, DataSpaceUsed, IndexSpaceUsed, RowCount

# $db = "AdventureWorksLT2012"
$db = "master"
Get-ChildItem SQLServer:\sql\$mi\databases\$db\Tables -Force |
Format-Table -AutoSize -Property Schema, Name `
      , @{Label="Data Space Used";Alignment="Right";Exp={"{0,0:n0}" -f($_.DataSpaceUsed)}} `
      , @{Label="Index Space Used";Alignment="Right";Exp={"{0,0:n0}" -f($_.IndexSpaceUsed)}} `
      , @{Label="Row Count";Alignment="Right";Exp={"{0,0:n0}" -f($_.RowCount)}} 



#-----------------------------------------------------------------------------------------------#
# Combining Methods
#-----------------------------------------------------------------------------------------------#
$mi = $env:COMPUTERNAME + "\SQLEXPRESS"  
# $mi = $env:COMPUTERNAME + "\SQL2012"  
$databases = Get-ChildItem SQLSERVER:\sql\$mi\databases 
  
foreach ($database in $databases) {
  $dbname = $database.Name  
  Write-Host $dbname " *******************************************************************"
  Get-ChildItem SQLServer:\sql\$mi\databases\$dbname\Tables -Force |
  Format-Table -AutoSize -Property Schema, Name `
        , @{Label="Data Space Used";Alignment="Right";Exp={"{0,0:n0}" -f($_.DataSpaceUsed)}} `
        , @{Label="Index Space Used";Alignment="Right";Exp={"{0,0:n0}" -f($_.IndexSpaceUsed)}} `
        , @{Label="Row Count";Alignment="Right";Exp={"{0,0:n0}" -f($_.RowCount)}} 		
}


##






#-----------------------------------------------------------------------------------------------#
# Get number of rows in each table
#-----------------------------------------------------------------------------------------------#

$machine = $env:COMPUTERNAME + "\SQL2012"  
$dbName = "AdventureWorksLT2012"

# Get rows with minimal coding
(Get-Item SQLSERVER:\sql\$machine\databases\$dbName\tables).Collection |
Select-Object Schema, Name, Rowcount |
Sort-Object Schema, Name |
Format-Table -Autosize

# Grab the collection so we can work with it
$tablesCollection = (Get-Item SQLSERVER:\sql\$machine\databases\$dbName\tables).Collection

# To display
$tablesCollection |
Select-Object Schema, Name, Rowcount |
Sort-Object Schema, Name |
Format-Table -Autosize

# Loop thru the tablesCollection directly, adding data
# to the hash table
$rowCounts = @{}
foreach($table in $tablesCollection) {
  $dbt = $table.Schema + "." + $table.Name
  $rowCounts[$dbt] = $table.RowCount
}
$rowCounts.GetEnumerator() | Sort-Object Name | Format-Table -AutoSize

# Create a new collection of objects based on 
#   the table objects in the tables collection
# These new objects will only have three properties:
#   Schema, Name, and RowCount
# (You might want to do this to create a 
#    lighterweight object to move around)
$miniTablesCollection = $tablesCollection |
Select-Object Schema, Name, Rowcount |
Sort-Object Schema, Name 
  
# Add the lightweight collection to hash table  
$rowCounts = @{}
foreach($miniTable in $miniTablesCollection) {
  $dbt = $miniTable.Schema + "." + $miniTable.Name
  $rowCounts[$dbt] = $miniTable.RowCount
}      
$rowCounts.GetEnumerator() | Sort-Object Name | Format-Table -AutoSize


# Add rowcounts to a hashtable using SMO
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$database = $Server.Databases[$dbName]

$rowCounts = @{}
foreach($table in $database.Tables) {
  # $dbt = $database.Name + "\" + $table.Schema + "." + $table.Name
  $dbt = "$($database.Name)\$($table.Schema).$($table.Name)"
  $rowCounts[$dbt] = $table.RowCount
}

$rowCounts.GetEnumerator() | Sort-Object Name | Format-Table -AutoSize


##


#-----------------------------------------------------------------------------------------------#
# Backup a database
#-----------------------------------------------------------------------------------------------#
Get-ChildItem C:\Backups

$machine = $env:COMPUTERNAME + "\SQL2012"  
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")

$bkup = New-Object Microsoft.SQLServer.Management.Smo.Backup 
$bkup.Database = "AdventureWorksLT2012"

$date = Get-Date   
$date = $date -replace "/", "-"     
$date = $date -replace ":", "-"  
$date = $date -replace " ", "_" 

$file = "C:\Backups\AdventureWorksLT2012" + "_" + $date + ".bak"  
  
$bkup.Devices.AddDevice($file, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)  
$bkup.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database  

$bkup.SqlBackup($server)

Get-ChildItem C:\Backups

Remove-Item C:\Backups\*.bak


##







#-----------------------------------------------------------------------------------------------#
# SMO only Stuff
#-----------------------------------------------------------------------------------------------#
#$mi = $env:COMPUTERNAME + "\SQL2012"  
$mi = "(localdb)\MSSQLLocalDB"  
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server($mi)  

"`n"
"Server Information"
$Server.Information.Properties | Select-Object Name, Value |Format-Table -auto 

"`n"
"Server Settings"
$Server.Settings.Properties | Select-Object Name, Value | Format-Table -auto     

"`n"
"User Options"
$Server.UserOptions.Properties | Select-Object Name, Value | Format-Table -auto  

"`n"
"Server Configuration"
$Server.Configuration.Properties | Select-Object DisplayName, ConfigValue, RunValue, Description | Format-Table -auto 

# Get the current value of one of the properties
"NoCount Value is " + $Server.UserOptions.Properties["NoCount"].Value

# Update the value
$Server.UserOptions.Properties["NoCount"].Value = $true
$server.Alter()
"NoCount Value is " + $Server.UserOptions.Properties["NoCount"].Value

$Server.UserOptions.Properties["NoCount"].Value = $false
$server.Alter()
"NoCount Value is " + $Server.UserOptions.Properties["NoCount"].Value


##

















#-----------------------------------------------------------------------------------------------#
# Mapping the SQL Provider to SMO
#-----------------------------------------------------------------------------------------------#

# SQLSERVER:\SQL                       Microsoft.SqlServer.Management.Smo
#                                      Microsoft.SqlServer.Management.Smo.Agent
#                                      Microsoft.SqlServer.Management.Smo.Broker
#                                      Microsoft.SqlServer.Management.Smo.Mail
  
# SQLSERVER:\SQLPolicy                 Microsoft.SqlServer.Management.Dmf
#                                      Microsoft.SqlServer.Management.Facets
  
# SQLSERVER:\Registration              Microsoft.SqlServer.Management.RegisteredServers
#                                      Microsoft.SqlServer.Management.Smo.RegSvrEnum
  
# SQLSERVER:\Utility                   Microsoft.SqlServer.Management.Utility
  
# SQLSERVER:\DAC                       Microsoft.SqlServer.Management.DAC
  
# SQLSERVER:\DataCollection            Microsoft.SqlServer.Management.Collector
  
# Source: http://msdn.microsoft.com/en-us/library/cc281947(v=sql.105).aspx
#     or: http://bit.ly/smoprovider





##

###






