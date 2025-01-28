# D�sactiver le pare-feu pour tous les profils (Domaine, Priv�, Public)
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False

# V�rification de l'�tat du pare-feu
$firewallStatus = Get-NetFirewallProfile | Select-Object Name, Enabled

# Affichage du r�sultat dans une fen�tre Out-GridView
$firewallStatus | Out-GridView -Title "�tat du Firewall"
