
$env:Path = $env:Path + "%ProgramData%\chocolatey;%ProgramData%\chocolatey\bin"
choco install git -y

choco install jenkins -y
