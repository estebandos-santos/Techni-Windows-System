# Variables
$ScriptPath = "\\labo204.local\sysvol\labo204.local\scripts\logon_ping.bat"
$Domaine = "labo204.local"
$TargetOU = "OU=OU_Computers,DC=labo204,DC=local"
$GPO_Name = "Script Logon Ping"

# Créer le script .bat qui effectue un ping et redirige la sortie vers un fichier sur le bureau
$Content = @"
@echo off
set UserDesktop=%USERPROFILE%\Desktop
ping 127.0.0.1 > "%UserDesktop%\ping_result.txt"
pause
"@

# Sauvegarder le script dans le dossier sysvol
New-Item -Path $ScriptPath -ItemType File -Force -Value $Content

# Créer la GPO
$GPO = New-GPO -Name $GPO_Name -Domain $Domaine

# Lier la GPO à l'OU spécifiée
New-GPLink -Name $GPO_Name -Target $TargetOU

# Ajouter le script de connexion à la GPO
# Spécifie le chemin du script dans SYSVOL pour qu'il soit exécuté lors de la connexion de l'utilisateur
Set-GPLogonScript -GPO $GPO -ScriptName "logon_ping.bat" -ScriptPath "\\labo204.local\sysvol\labo204.local\scripts"

# Validation via Out-GridView
$GPOs = Get-GPO -All | Select-Object DisplayName, CreationTime, ModificationTime
$GPOs | Out-GridView -Title "Validation - GPOs Actives - $GPO_Name"
