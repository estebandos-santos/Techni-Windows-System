# Importation des modules nécessaires
Import-Module ActiveDirectory
Import-Module GroupPolicy

# Définition des variables
$GPO_Name = "Création Étudiants"
$Domaine = "labo204.local"
$TargetOU = "OU=OU_Users,DC=labo204,DC=local"

# Création de la GPO si elle n'existe pas
$GPO = Get-GPO -Name $GPO_Name -ErrorAction SilentlyContinue
if (-not $GPO) {
    $GPO = New-GPO -Name $GPO_Name -Domain $Domaine
    Write-Host "GPO '$GPO_Name' créée avec succès."
} else {
    Write-Host "GPO '$GPO_Name' existe déjà."
}

# Lier la GPO à l'OU_Users
New-GPLink -Name $GPO_Name -Target $TargetOU

# Désactivation temporaire de la complexité des mots de passe
secedit /export /cfg C:\secpol.cfg
(Get-Content C:\secpol.cfg) -replace "PasswordComplexity = 1", "PasswordComplexity = 0" | Set-Content C:\secpol.cfg
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
Remove-Item C:\secpol.cfg -Force

# Création des utilisateurs student01 à student100
For ($i = 1; $i -le 100; $i++) {
    $User = "student" + "{0:D2}" -f $i
    $Password = $User
    $OU = "OU=OU_Users,DC=labo204,DC=local"

    # Vérifier si l'utilisateur existe déjà
    if (-not (Get-ADUser -Filter {SamAccountName -eq $User} -ErrorAction SilentlyContinue)) {
        New-ADUser -SamAccountName $User -UserPrincipalName "$User@labo204.local" `
                   -Name $User -GivenName "Student" -Surname $i `
                   -Path $OU -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
                   -Enabled $true
        Write-Host "Utilisateur $User créé avec succès."
    }
    
    # Forcer le changement de mot de passe à la connexion
    Set-ADUser -Identity $User -ChangePasswordAtLogon $true
    Set-ADUser -Identity $User -Replace @{pwdLastSet=0}
}

Write-Host "Les comptes étudiants sont créés et désactivés jusqu'à ce qu'ils changent leur mot de passe."

# Attente de 10 minutes pour permettre aux utilisateurs de changer leur mot de passe
Start-Sleep -Seconds 600  

# Réactivation de la complexité des mots de passe après que les utilisateurs ont changé leur mot de passe
secedit /export /cfg C:\secpol.cfg
(Get-Content C:\secpol.cfg) -replace "PasswordComplexity = 0", "PasswordComplexity = 1" | Set-Content C:\secpol.cfg
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
Remove-Item C:\secpol.cfg -Force

# Réactivation des comptes étudiants après qu'ils aient changé leur mot de passe
For ($i = 1; $i -le 100; $i++) {
    $User = "student" + "{0:D2}" -f $i
    $PasswordSetDate = (Get-ADUser -Identity $User -Properties "PasswordLastSet").PasswordLastSet
    if ($PasswordSetDate -gt (Get-Date).AddMinutes(-10)) {
        Enable-ADAccount -Identity $User
    }
}

Write-Host "Les comptes étudiants sont réactivés après validation."

# Vérification des utilisateurs créés
$UsersStatus = Get-ADUser -Filter {Name -like "student*"} -Property Enabled, PasswordLastSet | 
               Select-Object Name, Enabled, PasswordLastSet
$UsersStatus | Out-GridView -Title "État des Comptes Étudiants"
