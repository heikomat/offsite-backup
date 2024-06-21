# offsite backup

This is my setup for encrypted offsite-backups to a nextcloud instance

**1. install rclone**  
you need at least version 1.65.0. See https://rclone.org/downloads/ for up-to-date instructions.

**2. configure rclone**  
you could use the `rclone config` command. That starts an interactive configuration menu which will create an `rclone.conf`.

Or you can pick the `rclone.conf` from this repository and adjust it yourself. The result will be the same.

Replace the following things in the [`rclone.conf`](./root/.config/rclone/rclone.conf):
- [**nextcloud-url**](https://rclone.org/webdav/#webdav-url)  
  Path to your nextcloud instance
- [**user**](https://rclone.org/webdav/#webdav-user)  
  Your nextcloud username
- **target-folder**  
  Path to the nextcloud-folder where the backup should live
- [**obscured-nextcloud-password**](https://rclone.org/webdav/#webdav-pass)  
  The password of the nextcloud user, but in obscured
- [**obscured-encryption-key**](https://rclone.org/crypt/#crypt-password) 
  The password used for encryption, but in obscured. Create a strong one, preferably
  without symbols that break the `rclone obscure` usage
- [**obscured-encryption-salt**](https://rclone.org/crypt/#crypt-password2) 
  salt for the encryption, but in obscured. In this case, this is effectively a second password, and you need both. Create a strong one, preferably without symbols that
  break the `rclone obscure` usage

**How to obscure passwords**  
See https://rclone.org/commands/rclone_obscure/
```
echo "the-password" | rclone obscure -
```

**configure backup script**  
The [`backup.sh`](./apps/server-scripts/backup.sh) has 3 functions. They are explained in the script.

If you want to use the `archive`-function you neet do adjust the base target-path
from `/fat-vault` to wherever you want to locally archive your data to

Just add all the `backup`, `backup_system` and `archive` commands you need. Examples are in the script aswell.

You should probably create the `/var/log/backup/`-folder, as the script might fail if it doesn't exist

**configure crontab**  
See the [crontab](./crontab)-file for an example usage. You can of course also use the command there to manually start the backup.

**logs**  
logs will end up in `/var/log/backup/`. There will be two files. One is the log-output from rclone, the other one is the stdout from the backup-script.
