Import-Module ActiveDirectory

# Nom du domaine
$Domain = "labo204.local"

# Désactivation de la complexité des mots de passe
$DomainPolicy = Get-ADDefaultDomainPasswordPolicy -Identity $Domain

# Modification de la politique pour désactiver la complexité
Set-ADDefaultDomainPasswordPolicy -Identity $Domain -ComplexityEnabled $false

# Vérification des paramètres de la politique après modification
$UpdatedPolicy = Get-ADDefaultDomainPasswordPolicy -Identity $Domain
$UpdatedPolicy | Select-Object ComplexityEnabled, MinPasswordLength, MaxPasswordAge, MinPasswordAge | Out-GridView -Title "Validation de la politique de mot de passe du domaine"
