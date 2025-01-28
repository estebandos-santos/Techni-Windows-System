Import-Module GroupPolicy
$GPO_Name = "Masquer Dernier Login"
$Domaine = "labo204.local"
$TargetOU = "OU=OU_Computers,DC=labo204,DC=local"

$GPO = New-GPO -Name $GPO_Name -Domain $Domaine
New-GPLink -Name $GPO_Name -Target $TargetOU

Set-GPRegistryValue -Name $GPO_Name -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "DontDisplayLastUserName" -Type DWord -Value 1

# Validation via Out-GridView
$GPOs = Get-GPO -All | Select-Object DisplayName, CreationTime, ModificationTime
$GPOs | Out-GridView -Title "Validation - GPOs Actives - $GPO_Name"
