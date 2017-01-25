$backColour = "White"
$foreColour = "Black"


$root = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$sourceDir = Join-Path $root "template\Database"
$templateDir = Join-Path $env:HOMEPATH "Documents\CD In A Box"
$projectRoot = Join-Path $templateDir "Database" 

$i = 0

if (Test-Path $projectRoot){        
    $project = $projectRoot
    while( Test-Path $projectRoot ){
        
        $projectRoot = "$project$i"
        $i++
    }    
}

Write-Host "Creating SSDT project in: " $projectRoot  -BackgroundColor $backColour -ForegroundColor $foreColour
Copy-Item -Path $sourceDir -Destination $projectRoot -Recurse

$projectRoot = (Get-Item $projectRoot).FullName

Write-Host "Creating Git Repo"  -BackgroundColor $backColour -ForegroundColor $foreColour
cd $projectRoot

pwd
git init

function Get-ModelVersion{
    param([int]$version)
    $number = -1
    switch($version){
        
        2008{$number=100}
        2012{$number=110}
        2014{$number=120}
        2016{$number=130}
    }   
    
    return $number 
}


function Copy-Libs{
    param(
        [int]$version        
    )

    $src = Join-Path $root "template\Libs\tSQLt"
    $src = Join-Path $src $version
    $src = Join-Path $src "tSQLt.dacpac"
    
    $dst = Join-Path $projectRoot "test\Lib"

    Write-Host "Copying from: " $src " to: " $dst 
    Copy-Item $src  $dst
}


function ReWrite-File{
    param(
        [string]$fileName,
        [string]$source,
        [string]$updated
    )
    
    $text = [System.IO.File]::ReadAllText($fileName)
    $text = $text.Replace($source, $updated)

    [System.IO.File]::WriteAllText($fileName, $text)
}

function Fix-SchemaDsp{
    param([int]$version)

    $sourceText = "130"
    $newText = "$($version)"
    
    $file = Join-Path $projectRoot "Database\Database.sqlproj"
    ReWrite-File $file $sourceText $newText
    
    $file = Join-Path $projectRoot "Test\Database.UnitTests\Database.UnitTests.sqlproj"
    ReWrite-File $file $sourceText $newText
}


function Configure-SSDT{
    param(
        
        [Parameter(Mandatory=$true, HelpMessage="What version of SQL Server will you be targeting? Please enter one of '2005, 2008, 2012, 2014, 2016'")] 
        [int]$sqlVersion
    )
    
    $modelVersion = Get-ModelVersion $sqlVersion
    if( $modelVersion -eq -1 ){        
        return $false
    }

    Copy-Libs $modelVersion
    Fix-SchemaDsp $modelVersion
    return $true

}

$configured = $false

while(!$configured){
    
    Write-Host "**`r`n     What version of SQL Server will you be targetting? Please enter one of '2008, 2012, 2014, 2016'     ***`r`n"  -BackgroundColor $backColour -ForegroundColor $foreColour
    $configured = Configure-SSDT

}

$projectName = (Split-Path $projectRoot -Leaf)
$projectRoot
powershell.exe -File "$root/ConfigureJenkins.ps1" -projectPath $projectRoot -projectName $projectName

powershell.exe -File "$root/ConfigureDeploy.ps1"  -projectPath $projectRoot -projectName $projectName

git add .
git commit -m "Adding template"


Write-Host "You will now see a visual studio solution (Database.sln) and a jenkins build - have a little explore, when you fix the failing unit test your build will get another step, the deploy step which is currently to generate a deployment script - you can modify it to do the actual deploy for you." -BackgroundColor $backColour -ForegroundColor $foreColour

Start-Sleep -seconds 5

Start-Process $projectRoot\Database.sln
Start-Process "http://localhost:8080/job/$($projectName)"

