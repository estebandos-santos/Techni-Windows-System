# Importation des modules n�cessaires
Import-Module ActiveDirectory
Import-Module GroupPolicy

# D�finition des variables
$GPO_Name = "Cr�ation �tudiants"
$Domaine = "labo204.local"
$TargetOU = "OU=OU_Users,DC=labo204,DC=local"

# Cr�ation de la GPO si elle n'existe pas
$GPO = Get-GPO -Name $GPO_Name -ErrorAction SilentlyContinue
if (-not $GPO) {
    $GPO = New-GPO -Name $GPO_Name -Domain $Domaine
    Write-Host "GPO '$GPO_Name' cr��e avec succ�s."
} else {
    Write-Host "GPO '$GPO_Name' existe d�j�."
}

# Lier la GPO � l'OU_Users
New-GPLink -Name $GPO_Name -Target $TargetOU

# D�sactivation temporaire de la complexit� des mots de passe
secedit /export /cfg C:\secpol.cfg
(Get-Content C:\secpol.cfg) -replace "PasswordComplexity = 1", "PasswordComplexity = 0" | Set-Content C:\secpol.cfg
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
Remove-Item C:\secpol.cfg -Force

# Cr�ation des utilisateurs student01 � student100
For ($i = 1; $i -le 100; $i++) {
    $User = "student" + "{0:D2}" -f $i
    $Password = $User
    $OU = "OU=OU_Users,DC=labo204,DC=local"

    # V�rifier si l'utilisateur existe d�j�
    if (-not (Get-ADUser -Filter {SamAccountName -eq $User} -ErrorAction SilentlyContinue)) {
        New-ADUser -SamAccountName $User -UserPrincipalName "$User@labo204.local" `
                   -Name $User -GivenName "Student" -Surname $i `
                   -Path $OU -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
                   -Enabled $true
        Write-Host "Utilisateur $User cr�� avec succ�s."
    }
    
    # Forcer le changement de mot de passe � la connexion
    Set-ADUser -Identity $User -ChangePasswordAtLogon $true
    Set-ADUser -Identity $User -Replace @{pwdLastSet=0}
}

Write-Host "Les comptes �tudiants sont cr��s et d�sactiv�s jusqu'� ce qu'ils changent leur mot de passe."

# Attente de 10 minutes pour permettre aux utilisateurs de changer leur mot de passe
Start-Sleep -Seconds 600  

# R�activation de la complexit� des mots de passe apr�s que les utilisateurs ont chang� leur mot de passe
secedit /export /cfg C:\secpol.cfg
(Get-Content C:\secpol.cfg) -replace "PasswordComplexity = 0", "PasswordComplexity = 1" | Set-Content C:\secpol.cfg
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
Remove-Item C:\secpol.cfg -Force

# R�activation des comptes �tudiants apr�s qu'ils aient chang� leur mot de passe
For ($i = 1; $i -le 100; $i++) {
    $User = "student" + "{0:D2}" -f $i
    $PasswordSetDate = (Get-ADUser -Identity $User -Properties "PasswordLastSet").PasswordLastSet
    if ($PasswordSetDate -gt (Get-Date).AddMinutes(-10)) {
        Enable-ADAccount -Identity $User
    }
}

Write-Host "Les comptes �tudiants sont r�activ�s apr�s validation."

# V�rification des utilisateurs cr��s
$UsersStatus = Get-ADUser -Filter {Name -like "student*"} -Property Enabled, PasswordLastSet | 
               Select-Object Name, Enabled, PasswordLastSet
$UsersStatus | Out-GridView -Title "�tat des Comptes �tudiants"
