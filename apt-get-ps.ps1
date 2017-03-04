Param(
  [Parameter(Mandatory=$True)][string]$command,
  [Parameter(Mandatory=$false)][string]$package_name
)

#Write-Output "First parameter $command"
#Write-Output "Second parameter $package_name"



function AptGetInstall {
  param ($package_name) 
	
  if ($package_name -eq "choco"){
    Write-Output "Installing chocolatey"
    #Invoke-Expression alias iex
    Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
  }
  else {
    Write-Output "Installing $package_name"
    choco install $package_name -y
  }
}

function AptGetListPackages{
  $packageList = @(
    '7zip'
    'googlechrome'
    'googledrive'
    'notepadplusplus'
    'paint.net'
    'sysinternals'
    'keepass'
    'slack'
    'git'
    'nant'
    'nunit'
    'nuget.commandline'
    'tortoisesvn'
    'jenkins'
    'cctray'
    'cruisecontrol.net'
  )

  foreach ($package in $packageList) {
    Write-Output "* $package" 
  }
}

# Start main script
cls
if ($command  -eq "install") {
  Write-Output "Installing..."
  AptGetInstall $package_name
}
elseif ($command  -eq "remove"){
  Write-Output "Removing... (not implemented yet)"
} 
elseif ($command  -eq "list-packages"){
  $nl = [Environment]::NewLine
  Write-Output "This is a short list of available packages.`r`nFor more go to https://chocolatey.org/packages"
  AptGetListPackages
}
else {
  Write-Output "Unknown command. Supported commands are (install, remove, list-packages)"
}





Exit

