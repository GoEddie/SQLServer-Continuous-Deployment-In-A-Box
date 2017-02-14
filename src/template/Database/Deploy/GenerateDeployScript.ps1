param([string]$dacpac, [string]$publishProfile, [string]$projectPath)

New-Item -Type Directory Artifacts -Force | Out-Null
