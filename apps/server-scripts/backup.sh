#!/bin/bash

START_TIME=$(date +%s)
LOG_PATH="/var/log/backup/backup.log"

# If a backup log already exists, delete it
if [ -f "$LOG_PATH" ]; then
    rm "$LOG_PATH"
fi

# Use this to remotely sync media, images, documents etc.
#
# the path on the remote will be determined by the second parameter, because
# you want to have a folder of backup stuff, not necessarily recreate the
# whole directory structure.
# 
# Usage: backup <source_directory> <backup_directory> <optional_flags>
#
# Parameters:
#   - source_directory: The directory to be backed up.
#   - backup_directory: The destination directory where the backup will be stored.
#   - optional_flags: Optional flags to customize the backup process.
#
# Example usage:
#   backup /vault/media /documents
#     this will backup everything in `/vault/media/documents` to `backup:/documents`
#
#   backup /vault/media /images --include="{Heiko/**}
#     this will backup everything in `/vault/media/images` to `backup:/images`
#     if it is somewhere in a directory called `Heiko`
function backup {
  rclone sync \
    --progress \
    --fast-list \
    --transfers 12 \
    --checkers 8 \
    --verbose=1 \
    --log-file="$LOG_PATH" \
    ${3} ${4} ${5} "${1}${2}" "backup:${2}"
}

# Use this to remotely sync system directories like /root, /etc etc.
# 
# This differs from the 'backup' function in one aspect: You don't have to
# provide a target directory, it is always `backup:/system<directory>`, because
# when dealing with system files you probably DO want to recreate the whole
# directory structure.
#
# Usage: backup_system <source_directory> <optional_flags>
#
# Parameters:
#   - source_directory: The directory to be backed up.
#   - optional_flags: Optional flags to customize the backup process.
#
# Example usage:
#   backup_system /etc --include="{mdadm/**,rsyslog.conf,logrotate.d/**,systemd/**,docker/**}"
#     this will backup mdadm-config, rsyslog.conf, all logrotate.d files, all systemd files and the docker config
#
#   backup /vault/media /images --include="{Heiko/**}
#     this will backup everything in `/vault/media/images` to `backup:/images`
#     if it is somewhere in a directory called `Heiko`
function backup_system {
  rclone sync \
    --progress \
    --fast-list \
    --transfers 12 \
    --checkers 8 \
    --verbose=1 \
    --log-file="$LOG_PATH" \
    ${2} ${3} ${4} "${1}" "backup:/system${1}"
}


# Use this to sync something locally to another directoy.
#
# This is useful for backing up things from a quick ssd to an hdd-raid. For example:
# immich uses a directory on an ssd to backup and serve the images from my phone.
# I use this to periodically backup the images to the hdd-raid, in case the ssd fails.
# 
# Usage: acrhive <source_directory> <target_directoy>
# 
# Parameters:
#   - source_directory: The directory to be archived.
#   - target_directoy: Where to sync the source directory to.
#
# Example usage:
#   archive /quick-vault/main-storage/images /media
#     this will sync everything in `/quick-vault/main-storage/images` to `/fat-vault/media/images`
function archive {
  rsync --archive --verbose -e ssh --partial --progress --delete \
    "${1}" "/fat-vault${2}/"
}


# Exaple usage:
# ############### backup and archive media files and backups
# ### offsite-backup and archive media from the ssd
# backup /quick-vault/main-storage /documents
# backup /quick-vault/main-storage /audiobooks
# backup /quick-vault/main-storage /images
# 
# archive /quick-vault/main-storage/documents /media
# archive /quick-vault/main-storage/audiobooks /media
# archive /quick-vault/main-storage/images /media
# 
# ### sync smartphone images and other backups from ssd to a larger backups-folder in the hdd-raid
# archive /quick-vault/main-storage/backups/Heiko/smartphone /media/backups/Heiko
# archive /quick-vault/main-storage/backups/ente /media/backups/ente
# 
# ############### backup all relevant backups offsite
# ### Heiko's PC and smartphone
# backup /fat-vault/media /backups/Heiko --include="{PC/**,smartphone/**}"
# ### Backups from other people
# backup /fat-vault/media /backups --include="{<person1>/**,<person1>/**,old-hdd-2007.tar.zst,ente/**}"
# 
# ############### archive system settings offsite
# SYSTEM_EXCLUDES="{log/**,logs/**,media/**,Cache/**,Caches/**,cache/**,half_year/**,media_store/**,metadata/**,encoded-video/**,thumbs/**,model-cache/**,smart-home/database/**,node_modules/**,.git/**,monerod/data/**,backup_log.txt,backup.screenlog,prometheus/data/**,.npm/**}"
# backup_system /docker --exclude="${SYSTEM_EXCLUDES}"
# backup_system /apps --exclude="${SYSTEM_EXCLUDES}"
# backup_system /root --include="{.docker/**,.ssh/**}"
# backup_system /etc --include="{mdadm/**,rsyslog.conf,logrotate.d/**,systemd/**,docker/**}"

END_TIME=$(date +%s)
echo "backup duration: $((END_TIME - START_TIME)) seconds"
