#!/bin/bash
# Fixes permissions/ownership and removes junk type files from the mediasvr setup

PATH=/sbin:/bin:/usr/sbin:/usr/bin
mediadir='/data/plexmediaserver'
torrentsdir='/data/torrents'

# Fixes ownership issues
chown -R plex:media $mediadir
chown -R transmission:media $torrentsdir

# Removes junk type files from media folders
find $mediadir/{movies,tvshows} -type f \( -iname "*.html" -o -iname "*.smi" -o -iname "*.srt.random-*" -o -iname "*.dbm" -o -iname "*.website" -o -iname "*.url" -o -iname "*.txt" -o -iname "*.nfo*" -o -iname "*.ignore" -o -iname "*.db" -o -iname "*.nzb" -o -iname "*.part" -o -iname "*.added" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.par2" -o -iname "*.part" -o -iname "*.srr" -o -iname "*.sfv" -o -iname "*.rar" -o -iname "*.r[0-9][0-9]" -o -iname "*.ico" \) -exec rm -f {} \;

# Removes junk type files from the download folder.
find $torrentsdir/downloaded -type f \( -iname "*.html" -o -iname "*.smi" -o -iname "*.srt.random-*" -o -iname "*.dbm" -o -iname "*.website" -o -iname "*.url" -o -iname "*.txt" -o -iname "*.nfo*" -o -iname "*.ignore" -o -iname "*.db" -o -iname "*.nzb" -o -iname "*.part" -o -iname "*.added" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.par2" -o -iname "*.part" -o -iname "*.srr" -o -iname "*.sfv" -o -iname "*.rar" -o -iname "*.r[0-9][0-9]" -o -iname "*.ico" \) -exec rm -f {} \;

# Removes more junk type files/folders from downloaded folder
find $torrentsdir/downloaded \( -iname "*sample*" -o -iname "ETRG.*" \) -exec rm -rf {} \;

# Removes empty files/folders from downloaded folder
find $torrentsdir/downloaded/* -empty -exec rm -rf {} \; > /dev/null 2>&1

# Fixes permissions on the masses
find $mediadir/{movies,tvshows} -type f ! -perm 0640 -exec chmod 640 {} \;
find $mediadir/{movies,tvshows} -type d ! -perm 0770 -exec chmod 770 {} \;

# Fixes permissions on main directories
#chmod 770 $mediadir $torrentsdir
#chmod 770 $mediadir/{movies,music,tvshows}
#chmod 770 $torrentsdir/{downloading,downloaded}

exit 0