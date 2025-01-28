Import-Module GroupPolicy
$GPO_Name = "Désactivation Firewall"
$Domaine = "labo204.local"
$TargetOU = "OU=OU_Computers,DC=labo204,DC=local"

# Création et lien de la GPO
$GPO = New-GPO -Name $GPO_Name -Domain $Domaine
New-GPLink -Name $GPO_Name -Target $TargetOU

# Configuration du firewall
Set-GPRegistryValue -Name $GPO_Name -Key "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -ValueName "EnableFirewall" -Type DWord -Value 0

# Validation via Out-GridView
$GPOs = Get-GPO -All | Select-Object DisplayName, CreationTime, ModificationTime
$GPOs | Out-GridView -Title "Validation - GPOs Actives - $GPO_Name"
