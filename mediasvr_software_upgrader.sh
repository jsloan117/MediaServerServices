#!/bin/bash
# used to upgrade SickRage/CouchPotato/SABnzbd Centos 7+
# version: 1.5

cp_path='/data/couchpotato'
cp_base="$(dirname $cp_path)"
cp_user="transmission"
sr_path='/data/sickbeard'
sr_base="$(dirname $sr_path)"
sr_user="$cp_user"
sb_path='/data/sabnzbd'
sb_base="$(dirname $sb_path)"
sb_user="$cp_user"
backup_prefix='_old'

check_directory_exist () {
x=0

if [[ $prog = sickbeard ]]; then

  dir="$sr_path$backup_prefix"

elif [[ $prog = couchpotato ]]; then

  dir="$cp_path$backup_prefix"

elif [[ $prog = sabnzbd ]]; then

  dir="$sb_path$backup_prefix"

fi

while [[ -d $dir ]]; do

    x=$(( $x + 1 ))
    dir=$dir$x
    [[ -d $dir ]] && dir=$(echo $dir | sed 's|[0-9]||g')

done
export dir
}

check_for_updates () {
chk_couchpotato () {
local prog=couchpotato
local cp_upgrade=$(git --git-dir=$cp_path/.git status -u no | grep -q behind; echo $?)

if [[ $cp_upgrade = 0 ]]; then

  check_directory_exist && upgrade_couchpotato

fi
}

chk_sickrage () {
local prog=sickrage
local sr_upgrade=$(git --git-dir=$sr_path/.git status -u no | grep -q behind; echo $?)

if [[ $sr_upgrade = 0 ]]; then

  check_directory_exist && upgrade_sickrage

fi
}

chk_sabnzbd () {
local prog=sabnzbd
local sb_upgrade=$(git --git-dir=$sb_path/.git status -u no | grep -q behind; echo $?)

if [[ $sb_upgrade = 0 ]]; then

  check_directory_exist && upgrade_sabnzbd

fi
}

chk_couchpotato
chk_sickrage
chk_sabnzbd
}

upgrade_couchpotato () {
cd $cp_base
systemctl stop couchpotato
mv couchpotato $dir
git clone -q https://github.com/ruudburger/couchpotatoserver.git
mv couchpotatoserver couchpotato
cp -p $dir/settings.conf couchpotato
find $cp_path -type f -exec chmod 640 {} \;
find $cp_path -type d -exec chmod 750 {} \;
chmod 750 $cp_path/CouchPotato.py
chown -R $cp_user.$cp_user $cp_path
systemctl start couchpotato
}

upgrade_sickrage () {
cd $sr_base
systemctl stop sickbeard
mv sickbeard $dir
git clone -q https://github.com/SickRage/SickRage.git
mv SickRage sickbeard
cp -p $dir/failed.db sickbeard
cp -p $dir/sickbeard.db sickbeard
cp -p $dir/config.ini sickbeard
cp -Rp $dir/cache sickbeard
find $sr_path -type f -exec chmod 640 {} \;
find $sr_path -type d -exec chmod 750 {} \;
chmod 750 $sr_path/SickBeard.py
chown -R $sr_user.$sr_user $sr_path
systemctl start sickbeard
}

upgrade_sabnzbd () {
cd $sb_base
systemctl stop sabnzbd
mv sabnzbd $dir
git clone -qb master https://github.com/sabnzbd/sabnzbd.git
cp -p $dir/config.ini sabnzbd
cp -Rp $dir/admin sabnzbd
[[ -d "$dir/backupnzbs" ]] && cp -Rp $dir/backupnzbs sabnzbd
find $sb_path -type f -exec chmod 640 {} \;
find $sb_path -type d -exec chmod 750 {} \;
chmod 750 $sb_path/SABnzbd.py
chown -R $sb_user.$sb_user $sb_path
systemctl start sabnzbd
}

prog="$1"
case "$prog" in

    sickbeard)

        check_directory_exist && upgrade_sickrage ;;

    couchpotato)

        check_directory_exist && upgrade_couchpotato ;;

    sabnzbd)

        check_directory_exist && upgrade_sabnzbd ;;

    -a)

        check_for_updates ;;

    *)

        echo -e "You can call the script with a single argument of the program name or use the '-a' switch for automated/cron use. \n \nEx: $0 [sickbeard|couchpotato|sabnzbd|-a] \n" && exit 0 ;;

esac
