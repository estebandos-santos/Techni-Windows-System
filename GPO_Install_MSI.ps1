$AppPath = "set-location\\srv0401.labo204.local\SYSVOL\labo204.local\apps"
$Softwares = @("7zip.msi", "firefox.msi")
$GPO_Name = "Déploiement Applications"

$GPO = New-GPO -Name $GPO_Name -Domain "labo204.local"
New-GPLink -Name $GPO_Name -Target "OU=OU_Computers,DC=labo204,DC=local"

foreach ($Software in $Softwares) {
    $MSIPath = Join-Path -Path $AppPath -ChildPath $Software
    Set-GPSoftwareInstallation -GPO $GPO -Action Install -Package $MSIPath
}

# Validation via Out-GridView
$GPOs = Get-GPO -All | Select-Object DisplayName, CreationTime, ModificationTime
$GPOs | Out-GridView -Title "Validation - GPOs Actives - $GPO_Name"