$backColour = "White"
$foreColour = "Black"

function Test-Administrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

if(!(Test-Administrator)){

	Write-Host "Sorry you must run this as an admin, do it on a test vm :)"
	exit

}

$root = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$script = (Join-Path $root -ChildPath "choco-install.ps1")

powershell.exe -File $script

$script = (Join-Path $root -ChildPath "tools.ps1")

powershell.exe -File $script

& ${env:ProgramFiles(x86)}\Jenkins\jenkins.exe stop | Out-Null
& ${env:ProgramFiles(x86)}\Jenkins\jenkins.exe start
Start-Sleep 20

Start-Process "http://localhost:8080"
Start-Sleep 20
Write-Host "*************************************************************************************************************************"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*                                                                                                                       *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*                                                                                                                       *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "You will now see a web browser and you will asked for a password, enter in the password:                                *"  -BackgroundColor $backColour -ForegroundColor $foreColour

if(!(Test-Path ${env:ProgramFiles(x86)}\Jenkins\secrets\initialAdminPassword)){
    Write-Host "`t`t ERROR the password file was not found, have you already setup jenkins on here?? - see if you can browse to jenkins, it might already be working?? "  -BackgroundColor $backColour -ForegroundColor $foreColour    
}
type ${env:ProgramFiles(x86)}\Jenkins\secrets\initialAdminPassword

Write-Host "*                                                                                                                       *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*                                                                                                                       *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*  When you have unlocked the instance, choose `"Install suggested plugins`"                                            *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*                                                                                                                       *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*  Wait a while for all the green ticks to come in                                                                      *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*                                                                                                                       *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*  Then create an admin user (admin/admin is a great user password combo)                                               *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*                                                                                                                       *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*  Finally save and exit and then start using jenkins                                                                   *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*                                                                                                                       *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*                                                                                                                       *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*  When Jenkins has installed and you can see his happy face, press c to continue...(this is going to be epic btw)      *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*                                                                            (unless you do ctrl+c which would be awful *"  -BackgroundColor $backColour -ForegroundColor $foreColour
Write-Host "*************************************************************************************************************************"  -BackgroundColor $backColour -ForegroundColor $foreColour


$c = "a"
while($c -ne "c"){
    $c = Read-Host
}

powershell.exe -File ./ssdt-project.ps1
