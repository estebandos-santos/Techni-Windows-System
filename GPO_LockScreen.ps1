Import-Module GroupPolicy
$GPO_Name = "Verrouillage Écran 5min"
$Domaine = "labo204.local"
$TargetOU = "OU=OU_Users,DC=labo204,DC=local"

$GPO = New-GPO -Name $GPO_Name -Domain $Domaine
New-GPLink -Name $GPO_Name -Target $TargetOU

Set-GPRegistryValue -Name $GPO_Name -Key "HKCU\Control Panel\Desktop" -ValueName "ScreenSaveTimeout" -Type String -Value "300"
Set-GPRegistryValue -Name $GPO_Name -Key "HKCU\Control Panel\Desktop" -ValueName "ScreenSaverIsSecure" -Type String -Value "1"

# Validation via Out-GridView
$GPOs = Get-GPO -All | Select-Object DisplayName, CreationTime, ModificationTime
$GPOs | Out-GridView -Title "Validation - GPOs Actives - $GPO_Name"
