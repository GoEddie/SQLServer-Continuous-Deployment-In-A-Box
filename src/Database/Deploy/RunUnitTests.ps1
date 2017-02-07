param(
    [string]$projectPath
)

$files = ""

ls $projectPath\Test\Database.UnitTests\*.sql -recurse | %{ $iles += "`"$_.FullName`" "  }

$mstestPath = Join-Path  ${env:ProgramFiles(x86)} "\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"
if(!(Test-Path $mstestPath)){
    $mstestPath = Join-Path  ${env:ProgramFiles(x86)} "\Microsoft Visual Studio 15.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"
}

if(!(Test-Path $mstestPath)){
    Write-Host "Can't find vstest.console?? make sure you installed visual studio 2015 or 2017 but there is probably some package you can install if not"  -BackgroundColor $backColour -ForegroundColor $foreColour
    Exit(1)
}

./nuget install AgileSQLClub.tSQLtTestAdapter -o $projectPath\Test\Lib
$testAdapterPath = (ls $projectPath\Test\Lib\AgileSQLClub.tSQLtTestAdapter\tSQLt.TestAdapter.dll | %{ $_.Directory })

& $mstestPath /TestAdapterPath:$testAdapterPath /Settings:"$projectPath\Test\Database.UnitTests\Database.UnitTests.runsettings" $files