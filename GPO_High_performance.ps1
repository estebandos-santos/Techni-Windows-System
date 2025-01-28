Import-Module GroupPolicy
$GPO_Name = "Mode Haute Performance - Client02"
$Domaine = "labo204.local"
$TargetComputer = "CLI0402"  # Nom de l'ordinateur sp�cifique
$GroupName = "GPO_Clients_HighPerformance"  # Nom du groupe de s�curit�
$GPO = New-GPO -Name $GPO_Name -Domain $Domaine

# 1. Cr�er un groupe de s�curit� s'il n'existe pas d�j�
$Group = Get-ADGroup -Filter {Name -eq $GroupName}
if (-not $Group) {
    $Group = New-ADGroup -Name $GroupName -GroupScope Global -Path "CN=Users,DC=labo204,DC=local" -GroupCategory Security
}

# 2. Ajouter l'ordinateur dans ce groupe de s�curit�
Add-ADGroupMember -Identity $GroupName -Members $TargetComputer

# 3. Lier la GPO � l'OU_Computers
$TargetOU = "OU=OU_Computers,DC=labo204,DC=local"
New-GPLink -Name $GPO_Name -Target $TargetOU

# 4. Appliquer la GPO uniquement au groupe de s�curit�
Set-GPPermissions -Name $GPO_Name -TargetName $GroupName -TargetType Group -PermissionLevel GpoApply

# 5. Configuration du mode Haute Performance
Set-GPRegistryValue -Name $GPO_Name -Key "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes" -ValueName "ActivePowerScheme" -Type String -Value "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

# 6. Validation via Out-GridView
$GPOs = Get-GPO -All | Select-Object DisplayName, CreationTime, ModificationTime
$GPOs | Out-GridView -Title "Validation - GPOs Actives - $GPO_Name"
