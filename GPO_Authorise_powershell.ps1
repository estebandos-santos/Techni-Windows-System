Import-Module GroupPolicy
$GPO_Name = "Autoriser Scripts PowerShell"
$Domaine = "labo204.local"
$TargetOU = "OU=OU_Computers,DC=labo204,DC=local"

$GPO = New-GPO -Name $GPO_Name -Domain $Domaine
New-GPLink -Name $GPO_Name -Target $TargetOU

Set-GPRegistryValue -Name $GPO_Name -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" -ValueName "ExecutionPolicy" -Type String -Value "Unrestricted"

# Validation via Out-GridView
$GPOs = Get-GPO -All | Select-Object DisplayName, CreationTime, ModificationTime
$GPOs | Out-GridView -Title "Validation - GPOs Actives - $GPO_Name"
