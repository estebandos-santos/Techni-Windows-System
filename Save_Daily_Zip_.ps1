# Dossier source à sauvegarder
$SourceDir = "C:\"

# Dossier de destination pour la sauvegarde avec date
$DestinationDir = "E:\Save"
$Date = Get-Date -Format "yyyy-MM-dd"
$BackupFolder = "$DestinationDir\Backup_$Date"

# Créer le dossier de destination avec la date
If (-not (Test-Path -Path $BackupFolder)) {
    New-Item -Path $BackupFolder -ItemType Directory
}

# Fichier de log
$LogFile = "$BackupFolder\BackupLogs\backup_log_$Date.txt"
If (-not (Test-Path -Path "$BackupFolder\BackupLogs")) {
    New-Item -Path "$BackupFolder\BackupLogs" -ItemType Directory
}

# Exécution de robocopy pour copier tous les fichiers et gérer les permissions
Write-Host "Lancement de la sauvegarde avec robocopy..."

$robocopyCommand = "robocopy $SourceDir $BackupFolder /MIR /Z /SEC /R:3 /W:5"
Invoke-Expression $robocopyCommand

# Vérifier le statut de la sauvegarde et l'enregistrer dans le log
$robocopyExitCode = $LastExitCode

# Ajouter les logs
Add-Content -Path $LogFile -Value "Backup effectué de $SourceDir vers $BackupFolder"
Add-Content -Path $LogFile -Value "Sauvegarde terminée à $(Get-Date)"
Add-Content -Path $LogFile -Value "Code de sortie : $robocopyExitCode"
Add-Content -Path $LogFile -Value "----------------------------------------"

# Affichage des informations via Out-GridView pour validation
$BackupInfo = [PSCustomObject]@{
    Source = $SourceDir
    Destination = $BackupFolder
    Date = $Date
    Status = "Succès"
}

$BackupInfo | Out-GridView -Title "Validation de la Sauvegarde"
Exit
