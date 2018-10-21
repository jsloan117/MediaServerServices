#!/bin/bash
# used to upgrade SickRage/CouchPotato/SABnzbd/NZBHydra Centos 7+

cp_path='/data/couchpotato'
cp_base="$(dirname $cp_path)"
cp_user='transmission'
sr_path='/data/sickbeard'
sr_base="$(dirname $sr_path)"
sr_user="$cp_user"
nh_path='/data/nzbhydra'
nh_base="$(dirname $nh_path)"
nh_user="$cp_user"
sb_path='/data/sabnzbd'
sb_base="$(dirname $sb_path)"
sb_user="$cp_user"
backup_prefix='_old'

usage () {
cat <<EOF
You can call the script with a single argument of the program name or use the '-a' switch for automated/cron use.

Ex: $0 [sickbeard|couchpotato|sabnzbd|nzbhydra|-a]

EOF
}

check_directory_exist () {
x=0

if [[ $prog = sickbeard ]]; then

  dir="$sr_path$backup_prefix"

elif [[ $prog = couchpotato ]]; then

  dir="$cp_path$backup_prefix"

elif [[ $prog = sabnzbd ]]; then

  dir="$sb_path$backup_prefix"

elif [[ $prog = nzbhydra ]]; then

  dir="$nh_path$backup_prefix"

fi

while [[ -d $dir ]]; do

    x=$(( x + 1 ))
    dir=$dir$x
    [[ -d $dir ]] && dir=$(echo $dir | sed 's/[0-9]*//g')

done
export dir
}

check_for_updates () {
chk_couchpotato () {
local prog=couchpotato
local -r cp_upgrade=$(git --git-dir=$cp_path/.git status -u no | grep -q behind; echo $?)

if [[ $cp_upgrade = 0 ]]; then

  check_directory_exist && upgrade_couchpotato

fi
}

chk_sickrage () {
local prog=sickbeard
local -r sr_upgrade=$(git --git-dir=$sr_path/.git status -u no | grep -q behind; echo $?)

if [[ $sr_upgrade = 0 ]]; then

  check_directory_exist && upgrade_sickrage

fi
}

chk_nzbhydra () {
local prog=nzbhydra
local -r nh_upgrade=$(git --git-dir=$nh_path/.git status -u no | grep -q behind; echo $?)

if [[ $nh_upgrade = 0 ]]; then

  check_directory_exist && upgrade_nzbhydra

fi
}

chk_sabnzbd () {
local prog=sabnzbd

if [[ $prog = 'sabnzbd' ]]; then

  check_directory_exist && upgrade_sabnzbd

fi
}

chk_couchpotato
chk_sickrage
chk_nzbhydra
chk_sabnzbd
}

upgrade_couchpotato () {
cd "$cp_base" || exit
systemctl stop couchpotato
mv $cp_path $dir
git clone -q https://github.com/ruudburger/couchpotatoserver.git
mv couchpotatoserver $cp_path
cp -p $dir/settings.conf $cp_path
find $cp_path -type f -exec chmod 640 {} \;
find $cp_path -type d -exec chmod 750 {} \;
chmod 750 $cp_path/CouchPotato.py
chown -R $cp_user.$cp_user $cp_path
systemctl start couchpotato
}

upgrade_sickrage () {
cd "$sr_base" || exit
systemctl stop sickbeard
mv $sr_path $dir
git clone -q https://github.com/SickChill/SickChill.git
mv SickChill $sr_path
cp -p $dir/{failed.db,sickbeard.db,config.ini} $sr_path
cp -Rp $dir/cache $sr_path
find $sr_path -type f -exec chmod 640 {} \;
find $sr_path -type d -exec chmod 750 {} \;
chmod 750 $sr_path/SickBeard.py
chown -R $sr_user.$sr_user $sr_path
systemctl start sickbeard
}

upgrade_nzbhydra () {
cd "$nh_base" || exit
systemctl stop nzbhydra
mv $nh_path $dir
git clone -q https://github.com/theotherp/nzbhydra.git
cp -p $dir/{config.cfg,nzbhydra.db} $nh_path
find $nh_path -type f -exec chmod 640 {} \;
find $nh_path -type d -exec chmod 750 {} \;
chmod 750 $nh_path/nzbhydra.py
chown -R $nh_user.$nh_user $nh_path
systemctl start nzbhydra
}

upgrade_sabnzbd () {
cd "$sb_base" || exit
systemctl stop sabnzbd
mv $sb_path $dir
local saburl=$(wget -q https://github.com/sabnzbd/sabnzbd/releases/latest -O - | grep -E \/tag\/ | awk -F "[><]" '{print $3}')
local sabver=$(echo $saburl | awk -F' ' '{ print $4 }')
wget -q https://github.com/sabnzbd/sabnzbd/releases/download/$sabver/SABnzbd-$sabver-src.tar.gz
tar -xaf SABnzbd-$sabver-src.tar.gz
mv SABnzbd-$sabver $sb_path
rm -f SABnzbd-$sabver-src.tar.gz
cp -p $dir/config.ini $sb_path
cp -Rp $dir/admin $sb_path
[[ -d "$dir/backupnzbs" ]] && mv $dir/backupnzbs $sb_path
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

    nzbhydra)

        check_directory_exist && upgrade_nzbhydra ;;

    sabnzbd)

        check_directory_exist && upgrade_sabnzbd ;;

    -a)

        check_for_updates ;;

    *)

        usage && exit 1 ;;

esac
