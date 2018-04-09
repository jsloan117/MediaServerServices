#!/bin/bash
# used to upgrade Sonarr/Radarr/Jackett CentOS 7+

rd_path='/data/radarr'
rd_base="$(dirname $rd_path)"
rd_user='transmission'
sr_path='/data/sonarr'
sr_base="$(dirname $sr_path)"
sr_user="$rd_user"
jk_path='/data/jackett'
jk_base="$(dirname $jk_path)"
jk_user="$rd_user"
backup_prefix='_old'

usage () {
cat <<EOF
You can call the script with a single argument of the program name or use the '-a' switch for automated/cron use.

Ex: $0 [sonarr|radarr|jackett|-a]

EOF
}

check_directory_exists () {
x=0

if [[ $prog = sonarr ]]; then

  dir="$sr_path$backup_prefix"

elif [[ $prog = radarr ]]; then

  dir="$rd_path$backup_prefix"

elif [[ $prog = jackett ]]; then

  dir="$jk_path$backup_prefix"

fi

while [[ -d $dir ]]; do

    x=$(( x + 1 ))
    dir=$dir$x
    [[ -d $dir ]] && dir=$(echo $dir | sed 's/[0-9]*//g')

done
export dir
}

upgrade_all () {
dl_radarr () {
local prog=radarr
check_directory_exists && upgrade_radarr
}

dl_sonarr () {
local prog=sonarr
check_directory_exists && upgrade_sonarr
}

dl_jackett () {
local prog=jackett
check_directory_exists && upgrade_jackett
}

dl_radarr
dl_sonarr
dl_jackett
}

upgrade_radarr () {
cd "$rd_base" || exit
systemctl stop radarr
mv radarr $dir
curl -sLO $( curl -s https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 )
tar -xaf Radarr.develop.*.linux.tar.gz
mkdir -p radarr/bin
mv Radarr/* radarr/bin
rmdir Radarr
rm -f Radarr.develop.*.linux.tar.gz
cp -Rp $dir/userdata radarr
chown -R $rd_user.$rd_user $rd_path
systemctl start radarr
}

upgrade_sonarr () {
cd "$sr_base" || exit
systemctl stop sonarr
mv sonarr $dir
wget -q http://update.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz
tar -xaf NzbDrone.master.tar.gz
mkdir -p sonarr/bin
mv NzbDrone/* sonarr/bin
rmdir NzbDrone
rm -f NzbDrone.master.tar.gz
cp -Rp $dir/userdata sonarr
chown -R $sr_user.$sr_user $sr_path
systemctl start sonarr
}

upgrade_jackett () {
cd "$jk_base" || exit
systemctl stop jackett
mv jackett $dir
local ver=$(wget -q https://github.com/Jackett/Jackett/releases/latest -O - | grep -E \/tag\/ | awk -F "[><]" '{print $3}')
local jackettver=$(echo $ver | awk '{print $3}')
wget -q https://github.com/Jackett/Jackett/releases/download/$jackettver/Jackett.Binaries.Mono.tar.gz
tar -xaf Jackett.Binaries.Mono.tar.gz
mkdir -p jackett/bin
mv Jackett/* jackett/bin
rmdir Jackett
rm -f Jackett.Binaries.Mono.tar.gz
cp -Rp $dir/userdata jackett
chown -R $jk_user.$jk_user $jk_path
systemctl start jackett
}

prog="$1"
case "$prog" in

    sonarr)

        check_directory_exists && upgrade_sonarr ;;

    radarr)

        check_directory_exists && upgrade_radarr ;;

    jackett)

        check_directory_exists && upgrade_jackett ;;

    -a)

        upgrade_all ;;

    *)

        usage && exit 1 ;;

esac