# Importation du module Active Directory
Import-Module ActiveDirectory

# D�finition de l'OU o� les utilisateurs seront cr��s
$OU = "OU=OU_Users,DC=labo204,DC=local"

# Cr�ation d'une liste pour stocker les r�sultats
$results = @()

# Boucle pour cr�er les utilisateurs
for ($i = 1; $i -le 100; $i++) {
    # Formatage du nom d'utilisateur (student01, student02, ..., student100)
    $username = "student" + ($i.ToString("D2"))
    $password = ConvertTo-SecureString -String $username -AsPlainText -Force

    # V�rifier si l'utilisateur existe d�j�
    if (-not (Get-ADUser -Filter {SamAccountName -eq $username} -ErrorAction SilentlyContinue)) {
        # Cr�ation de l'utilisateur AD
        New-ADUser -SamAccountName $username `
                   -UserPrincipalName "$username@labo204.local" `
                   -Name $username `
                   -GivenName "Student" `
                   -Surname "$i" `
                   -Path $OU `
                   -AccountPassword $password `
                   -Enabled $true `
                   -ChangePasswordAtLogon $false `
                   -PasswordNeverExpires $true
        
        $status = "Cr��"
    } else {
        $status = "D�j� existant"
    }

    # Ajouter le r�sultat dans la liste
    $results += [PSCustomObject]@{
        "Utilisateur" = $username
        "Statut"      = $status
    }
}

# Affichage du tableau interactif avec Out-GridView
$results | Out-GridView -Title "R�sultat de la cr�ation des utilisateurs"
