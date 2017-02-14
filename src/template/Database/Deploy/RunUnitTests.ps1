param(
    [string]$projectPath
)

cd $projectPath

$files = ""

ls $projectPath\Test\Database.UnitTests\*.sql -recurse | %{ $files += "`"$($_.FullName)`" "  }
$files


$mstestPath = Join-Path  ${env:ProgramFiles(x86)} "\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"
if(!(Test-Path $mstestPath)){
    $mstestPath = Join-Path  ${env:ProgramFiles(x86)} "\Microsoft Visual Studio 15.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"
}

if(!(Test-Path $mstestPath)){
    Write-Host "Can't find vstest.console?? make sure you installed visual studio 2015 or 2017 but there is probably some package you can install if not"  -BackgroundColor $backColour -ForegroundColor $foreColour
    Exit(1)
}

& "$($projectPath)deploy/nuget.exe" install AgileSQLClub.tSQLtTestAdapter -o $projectPath\Test\Lib
$testAdapterPath = (ls tSQLt.TestAdapter.dll -recurse | %{ $_.Directory })
$args = "`"/TestAdapterPath:$testAdapterPath`" `"/Settings:$projectPath\Test\Database.UnitTests\Database.UnitTests.runsettings`" $($files)"

$fullCommand = '& "' + $msTestPath + '" --% ' + $args
Invoke-Expression $fullCommand
if(!($?) -or $lastExitCode -ne 0){
    exit(1)
}


