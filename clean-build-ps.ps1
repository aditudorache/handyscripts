# Get all bin and obj folders and force delete them
Get-ChildItem -Include bin,obj -Recurse | Remove-Item -Recurse -Force

Exit

