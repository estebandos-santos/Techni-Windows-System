# Désactiver le pare-feu pour tous les profils (Domaine, Privé, Public)
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False

# Vérification de l'état du pare-feu
$firewallStatus = Get-NetFirewallProfile | Select-Object Name, Enabled

# Affichage du résultat dans une fenêtre Out-GridView
$firewallStatus | Out-GridView -Title "État du Firewall"
