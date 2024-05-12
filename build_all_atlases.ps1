#You may need to allow execution of this script by running the following command first (and answer "Y")
# Set-ExecutionPolicy Unrestricted -Scope Process
#If run inside a PowerShell command line window the above command will have effect until you close the window

$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
Write-Host "InvocationName:" $MyInvocation.InvocationName
Write-Host "Path:" $scriptPath
Invoke-Expression "$scriptPath\build_atlas.ps1 defaultwidgets"
Invoke-Expression "$scriptPath\build_atlas.ps1 usericons"
Invoke-Expression "$scriptPath\build_atlas.ps1 empireicons"
Invoke-Expression "$scriptPath\build_atlas.ps1 ingamepanels"
Invoke-Expression "$scriptPath\build_atlas.ps1 CivAfri"
Invoke-Expression "$scriptPath\build_atlas.ps1 CivAsia"
Invoke-Expression "$scriptPath\build_atlas.ps1 CivMedi"
Invoke-Expression "$scriptPath\build_atlas.ps1 CivWest"
Invoke-Expression "$scriptPath\build_atlas.ps1 CivMeso"
Invoke-Expression "$scriptPath\build_atlas.ps1 CivOrie"
Invoke-Expression "$scriptPath\build_atlas.ps1 CivSlav"
Invoke-Expression "$scriptPath\build_atlas.ps1 CivNomad"
Invoke-Expression "$scriptPath\build_atlas.ps1 CivSeas"
Invoke-Expression "$scriptPath\build_atlas.ps1 ingameicons"
Invoke-Expression "$scriptPath\build_atlas.ps1 ingameunits"
Invoke-Expression "$scriptPath\build_atlas.ps1 ingamebuildings"
Invoke-Expression "$scriptPath\build_atlas.ps1 ingametechs"
Invoke-Expression "$scriptPath\build_atlas.ps1 ObjectiveAtlas"
Invoke-Expression "$scriptPath\build_atlas.ps1 chatatlas"
Invoke-Expression "$scriptPath\build_atlas.ps1 recordedgame"
Invoke-Expression "$scriptPath\build_atlas.ps1 menutabs"
Invoke-Expression "$scriptPath\build_atlas.ps1 ingamecursor"
Invoke-Expression "$scriptPath\build_atlas.ps1 Mixer"
Invoke-Expression "$scriptPath\build_atlas.ps1 mapicons"
Invoke-Expression "$scriptPath\build_atlas.ps1 campaignwidgets"
Invoke-Expression "$scriptPath\build_atlas.ps1 chatatlasbk"
Invoke-Expression "$scriptPath\build_atlas.ps1 historywidgets"
Invoke-Expression "$scriptPath\build_atlas.ps1 Techtree"
Invoke-Expression "$scriptPath\build_atlas.ps1 campaignSelectAtlas"
Invoke-Expression "$scriptPath\build_atlas.ps1 campaignicons"
Invoke-Expression "$scriptPath\build_atlas.ps1 ScenarioEditor"
Invoke-Expression "$scriptPath\build_atlas.ps1 challengemissionwidgets"
Invoke-Expression "$scriptPath\build_atlas.ps1 scenarioicons"
Invoke-Expression "$scriptPath\build_atlas.ps1 ingameunits 3"
Invoke-Expression "$scriptPath\build_atlas.ps1 mapicons 3"
