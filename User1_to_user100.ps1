# Importation du module Active Directory
Import-Module ActiveDirectory

# Définition de l'OU où les utilisateurs seront créés
$OU = "OU=OU_Users,DC=labo204,DC=local"

# Création d'une liste pour stocker les résultats
$results = @()

# Boucle pour créer les utilisateurs
for ($i = 1; $i -le 100; $i++) {
    # Formatage du nom d'utilisateur (student01, student02, ..., student100)
    $username = "student" + ($i.ToString("D2"))
    $password = ConvertTo-SecureString -String $username -AsPlainText -Force

    # Vérifier si l'utilisateur existe déjà
    if (-not (Get-ADUser -Filter {SamAccountName -eq $username} -ErrorAction SilentlyContinue)) {
        # Création de l'utilisateur AD
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
        
        $status = "Créé"
    } else {
        $status = "Déjà existant"
    }

    # Ajouter le résultat dans la liste
    $results += [PSCustomObject]@{
        "Utilisateur" = $username
        "Statut"      = $status
    }
}

# Affichage du tableau interactif avec Out-GridView
$results | Out-GridView -Title "Résultat de la création des utilisateurs"
