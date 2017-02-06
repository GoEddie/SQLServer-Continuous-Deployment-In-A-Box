

$backColour = "White"
$foreColour = "Black"

$msbuildPath = Join-Path ${env:ProgramFiles(x86)}  "Msbuild\14.0\bin\msbuild"

if(!(Test-Path $msbuildPath)){

    $msbuildPath = Join-Path ${env:ProgramFiles(x86)}  "Msbuild\15.0\bin\msbuild"
}

if(!(Test-Path $msbuildPath)){

    Write-Host "Can't find msbuild?? make sur eyou installed visual studio 2015 or 2017"  -BackgroundColor $backColour -ForegroundColor $foreColour
    Exit(1)
}

cd $root = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
cd ..
& $msbuildPath .\Database.sln