
$root = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$script = (Join-Path $root -ChildPath "choco-install.ps1")

powershell.exe -File $script

$script = (Join-Path $root -ChildPath "tools.ps1")

powershell.exe -File $script

& ${env:ProgramFiles(x86)}\Jenkins\jenkins.exe stop | Out-Null
& ${env:ProgramFiles(x86)}\Jenkins\jenkins.exe start


Start-Process "http://localhost:8080"
Start-Sleep 10
Write-Host "*************************************************************************************************************************"
Write-Host "*                                                                                                                       *"
Write-Host "*                                                                                                                       *"
Write-Host "You will now see a web browser and you will asked for a password, enter in the password:                                *"

type ${env:ProgramFiles(x86)}\Jenkins\secrets\initialAdminPassword

Write-Host "*                                                                                                                       *"
Write-Host "*                                                                                                                       *"
Write-Host "*  When you have unlocked the instance, choose `"Install suggested plugins`"                                            *"
Write-Host "*                                                                                                                       *"
Write-Host "*  Wait a while for all the green ticks to come in                                                                       *"
Write-Host "*                                                                                                                       *"
Write-Host "*  Then create an admin user (admin/admin is a great user password combo)                                               *"
Write-Host "*                                                                                                                       *"
Write-Host "*  Finally save and exit and then start using jenkins                                                                   *"
Write-Host "*                                                                                                                       *"
Write-Host "*                                                                                                                       *"
Write-Host "*  When Jenkins has installed and you can see his happy face, press c to continue...(this is going to be epic btw)      *"
Write-Host "*                                                                            (unless you do ctrl+c which would be awful *"
Write-Host "*************************************************************************************************************************"


$c = "a"
while($c -ne "c"){
    $c = Read-Host
}
