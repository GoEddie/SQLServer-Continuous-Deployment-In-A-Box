$env:Path = $env:Path + "$($env:ProgramData)\chocolatey;$($env:ProgramData)\chocolatey\bin"
choco install git -y

choco install jenkins -y
