param([string]$projectPath, [string]$projectName)

$backColour = "White"
$foreColour = "Black"


$root = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

function Get-JenkinsUser{  

    Write-Host "We need to create the default job so...What was the name of the user you created in Jenkins (admin/admin would have been a great choice)?"  -BackgroundColor $backColour -ForegroundColor $foreColour

    $user = Read-Host

    Write-Host "In the web browser you may need to login then , please can you click the `"Show API Token...`" button and paste the api key here:" -BackgroundColor $backColour -ForegroundColor $foreColour

    Start-Sleep -Seconds 3

    Start-Process "http://localhost:8080/user/$($user)/configure"

    $token = Read-Host  

    [hashtable]$details = @{} 
    $details.User = $user
    $details.Token = $token

    return $details

}

$yn = "n"

while("Y" -ne $yn.ToUpperInvariant()) {

    $userDetails = Get-JenkinsUser

    Write-Host "Great, so the user is called `"$($userDetails.User)`" and the token is `"$($userDetails.Token)`" is that right? (y/n)" -BackgroundColor $backColour -ForegroundColor $foreColour

    $yn = Read-Host

}


function Get-Crumb{

    [xml]$x = (& $root\tools\curl.exe -S  "http://$($userDetails.User):$($userDetails.Token)@localhost:8080/crumbIssuer/api/xml") 2> NULL
    $x.defaultCrumbIssuer.crumb
}


$currentCrumb = Get-Crumb


$sourceXml = [System.IO.File]::ReadAllText((Join-Path $($root) "jenkinsJob.xml"))
$sourceXml = $sourceXml.Replace("%%PROJECT%%", $projectPath)
[System.IO.File]::WriteAllText((Join-Path $($root) "jenkinsJob.xml.tmp"), $sourceXml)

Write-Host "Creating Job..." -BackgroundColor $backColour -ForegroundColor $foreColour
& "$($root)\tools\curl.exe" -H "Jenkins-Crumb:$($currentCrumb)" -H "Content-Type:application/xml" -d "@jenkinsJob.xml.tmp" "http://localhost:8080/createItem?name=$($projectName)" -u "$($userDetails.User):$($userDetails.Token)" 2> NULL | Out-Null
& "$($root)\tools\curl.exe" -H "Jenkins-Crumb:$($currentCrumb)" -H "Content-Type:application/xml" -d "@jenkinsJob.xml.tmp" "http://localhost:8080/job/$($projectName)/build?delay=0" -u "$($userDetails.User):$($userDetails.Token)" 2> NULL | Out-Null


Write-Host "Sleeping 5 seconds..." -BackgroundColor $backColour -ForegroundColor $foreColour
Start-Sleep -Seconds 5

Start-Process "http://localhost:8080/job/$($projectName)"


