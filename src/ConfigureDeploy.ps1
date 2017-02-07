param([string]$projectPath, [string]$projectName)

## This creates the dependencies needed to deploy and test the database locally

$backColour = "White"
$foreColour = "Black"

$root = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

cd $projectPath\Deploy

if(!(Test-Path ./nuget.exe)){
    wget https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile ./nuget.exe
}
./nuget install Microsoft.Data.Tools.Msbuild -o  $projectPath\Deploy\bin

$sqlPackagePath = ""

ls $projectPath\Deploy\bin\Microsoft.Data.Tools.Msbuild* | %{
    $sqlpackagePath = (Join-Path $projectPath "Deploy\bin\$($_.Name)\lib\net40")
}

Write-Host "We need a database we can deploy the unit tests to, please put in a connection string we can use - this is for a test database and we will be dropping it and re-creating it for each and every build. We will call the database `"DatabaseName.UnitTests`" - if you can use a localdb instance then I would go with that otherwise a dev instance somewhere. Because we will be dropping and re-creating the database for every build we will need sa. For the `"CD in a box demo`" we will be deploying from jenkins so please setup a username/password rather than windows auth. In a real environment this can be configured to use windows auth just here it is a little hard" -BackgroundColor $backColour -ForegroundColor $foreColour

$yn = "n"

while("Y" -ne $yn.ToUpperInvariant()) {

    Write-Host "What is the instance name? For this demo . will do if you have a local dev instance" -BackgroundColor $backColour -ForegroundColor $foreColour

    $instance = Read-Host

    Write-Host "username?"  -BackgroundColor $backColour -ForegroundColor $foreColour

    $user = Read-Host

    Write-Host "password?"  -BackgroundColor $backColour -ForegroundColor $foreColour

    $pass = Read-Host
    $testDbConnection = "Server=$($instance);UID=$($user);PWD=$($pass)"

    Write-Host "Great, so we should use `"$($testDbConnection)`" as the connection string to the unit test database (which will be dropped and re-created for every build) is that right? (y/n)" -BackgroundColor $backColour -ForegroundColor $foreColour

    $yn = Read-Host
}


$xml = "<?xml version=`"1.0`" encoding=`"utf-8`"?><Project ToolsVersion=`"14.0`" xmlns=`"http://schemas.microsoft.com/developer/msbuild/2003`"><PropertyGroup><IncludeCompositeObjects>True</IncludeCompositeObjects><CreateNewDatabase>True</CreateNewDatabase><TargetDatabaseName>Database.UnitTests</TargetDatabaseName><DeployScriptFileName>Database.UnitTests.sql</DeployScriptFileName><TargetConnectionString>%CONNECTIONSTRING%</TargetConnectionString><ProfileVersionNumber>1</ProfileVersionNumber></PropertyGroup></Project>"

$xml = $xml.Replace("%CONNECTIONSTRING%", $testDbConnection)
$publishProfile = (Join-Path $($projectPath) "Test\Database.UnitTests\Database.UnitTests.Publish.xml")
[System.IO.File]::WriteAllText($publishProfile, $xml)

$dacpac = (Join-Path $projectPath  "Test\Database.UnitTests\bin\debug\Database.UnitTests.dacpac")

$testProjectDeployCommand = "$($sqlPackagePath)\sqlpackage.exe /Action:Publish /Profile:`$(`$publishProfile) /TargetDatabaseName:Database.UnitTests /SourceFile:`$dacpac"
$deployScriptPath = Join-Path $projectPath "Deploy\DeployDacpac.ps1"

[System.IO.File]::WriteAllText($deployScriptPath, ([System.IO.File]::ReadAllText($deployScriptPath) + "`n" + $testProjectDeployCommand))

$sourceRunSettingsFile = (Join-Path $projectPath "Test\Database.UnitTests\Database.UnitTests.runsettings")
$runSettings = [System.IO.File]::ReadAllText($sourceRunSettingsFile)

$runSettings = $runSettings.Replace("%CONNECTIONSTRING%", $testDbConnection)
[System.IO.File]::WriteAllText($sourceRunSettingsFile, $runSettings)





