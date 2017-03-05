# Get all bin and obj folders and force delete them
Write-Output "Remove the bin and obj folders"
Get-ChildItem -Include bin,obj -Recurse | Remove-Item -Recurse -Force

Write-Output "Remove the node_modules folders"
Get-ChildItem -Include node_modules,dist -Recurse | Remove-Item -Recurse -Force

Write-Output "Remove the packages folder"
Get-ChildItem -Include packages -Recurse -exclude repositories.config | Remove-Item -Recurse -Force

Exit

