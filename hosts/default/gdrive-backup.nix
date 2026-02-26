{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.rclone ];

  systemd.services.gdrive-backup = {
    description = "Backup jku-master-ds to Google Drive";
    serviceConfig = {
      Type = "oneshot";
      User = "tobi";
    };
    path = [ pkgs.rclone pkgs.rsync pkgs.coreutils ];
    script = ''
      set -e
      
      SOURCE="/home/tobi/repos/jku-master-ds"
      REPONAME="jku-master-ds"
      RCLONE_REMOTE="gdrive"
      GDRIVE_PATH="jku/backups/$REPONAME"
      LOCAL_BACKUP_DIR="/home/tobi/.cache/gdrive-backups"
      KEEP_COUNT=5
      
      mkdir -p "$LOCAL_BACKUP_DIR"
      
      TIMESTAMP=$(date +%Y%m%d_%H%M%S)
      SNAPSHOT_NAME="backup_$TIMESTAMP"
      
      echo "Creating snapshot: $SNAPSHOT_NAME"
      rsync -a --delete \
        --exclude '.venv' \
        --exclude '__pycache__' \
        --exclude '*.pyc' \
        --exclude 'node_modules' \
        --exclude '.DS_Store' \
        "$SOURCE/" "$LOCAL_BACKUP_DIR/$SNAPSHOT_NAME/"
      
      echo "Syncing to Google Drive..."
      rclone sync "$LOCAL_BACKUP_DIR" "$RCLONE_REMOTE:$GDRIVE_PATH" -v --fast-list
      
      echo "Cleaning old local backups (keeping last $KEEP_COUNT)..."
      cd "$LOCAL_BACKUP_DIR"
      ls -1t | tail -n +$((KEEP_COUNT + 1)) | xargs -r rm -rf
      
      echo "Backup complete!"
    '';
  };

  systemd.timers.gdrive-backup = {
    description = "Run Google Drive backup every 4 hours";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/4:00";
      Persistent = true;
    };
  };
}
