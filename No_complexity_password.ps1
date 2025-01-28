Import-Module ActiveDirectory

# Nom du domaine
$Domain = "labo204.local"

# D�sactivation de la complexit� des mots de passe
$DomainPolicy = Get-ADDefaultDomainPasswordPolicy -Identity $Domain

# Modification de la politique pour d�sactiver la complexit�
Set-ADDefaultDomainPasswordPolicy -Identity $Domain -ComplexityEnabled $false

# V�rification des param�tres de la politique apr�s modification
$UpdatedPolicy = Get-ADDefaultDomainPasswordPolicy -Identity $Domain
$UpdatedPolicy | Select-Object ComplexityEnabled, MinPasswordLength, MaxPasswordAge, MinPasswordAge | Out-GridView -Title "Validation de la politique de mot de passe du domaine"
