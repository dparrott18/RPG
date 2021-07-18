$files = Get-ChildItem -Recurse "$PSScriptRoot\ScriptFiles" -Include *.ps1 

# dot source the individual scripts that make-up this module
foreach ($file in $files) { . $files.FullName }

Write-Host -ForegroundColor Green "Module $(Split-Path $PSScriptRoot -Leaf) was successfully loaded."