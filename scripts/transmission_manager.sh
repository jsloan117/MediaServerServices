#!/bin/bash
# used to manage torrents in transmission-daemon

# Path to transmission-remote
TR="/usr/bin/transmission-remote HOST:PORT"

remove_finished_torrents () { # Remove finished torrents
local TOR_LIST=$($TR -l | tail -n+2 | grep Finished | awk '{ print $1 }')
[[ -z $TOR_LIST ]] && echo -e "\nThere are currently no torrents listed in Transmission\n" && exit 5

for ID in $TOR_LIST; do

  local NAME="$($TR -t $ID -i | grep Name:)"
  echo "$ID: ${NAME#*Name: }"

  $TR -t $ID -r

done
}

delete_torrent () { # Delete torrent AND its data!!!
[[ -z "$1" ]] && echo -e "\nYou must supply at least one torrent id to completely delete it and its data from transmission/drive.\n" && exit 5

for torrentid in "$@"; do

  $TR -t "$torrentid" --remove-and-delete

done
}

cleanup_dead_torrents () {
local TOR_LIST=$($TR -l | grep "Idle" | egrep -w "0\%|n\/a" | awk '{ print $1 }')
[[ -z $TOR_LIST ]] && echo -e "\nThere are currently no dead/inactive torrents in Transmission\n" && exit 5

for ID in $TOR_LIST; do

  local NAME="$($TR -t $ID -i | grep Name:)"
  echo "$ID: ${NAME#*Name: }"

  $TR -t $ID --remove-and-delete

done
}

active_torrents () { # Shows active and idling torrents in transmision
local HEADER=$($TR -l | head -n1)
local ACTIVE_NUM=$($TR -l | tail -n+2 | grep -vE "100%|Stopped|Idle" | grep -v "^Sum\:" | wc -l)
local ACTIVE=$($TR -l | tail -n+2 | grep -vE "100%|Stopped|Idle" | grep -v "^Sum\:" | sort -nrk2)
local SUM=$($TR -l | tail -n+2 | grep -vE "100%|Stopped|Idle" | grep -w "^Sum\:")
local IDLE_NUM=$($TR -l | tail -n+2 | grep "Idle" | grep -v "^Sum\:" | wc -l)
local IDLE=$($TR -l | tail -n+2 | grep "Idle" | grep -v "^Sum\:" | sort -nrk2)

printf "There is %d active torrent currently within Transmission\n\n" "$ACTIVE_NUM"
printf "%s\n\n" "$HEADER"
printf "%s\n\n" "$ACTIVE"
printf "%s\n\n" "$SUM"
printf "There is %d idling torrents currently within Transmission\n\n" "$IDLE_NUM"
printf "%s\n\n" "$HEADER"
printf "%s\n\n" "$IDLE"
}

finished_torrents () { # Shows the finished torrents in transmission
local HEADER=$($TR -l | head -n1)
local FINISHED_NUM=$($TR -l | tail -n+2 | grep "Finished" | grep -v "^Sum\:" | wc -l)
local FINISHED=$($TR -l | tail -n+2 | grep "Finished" | grep -v "^Sum\:")

printf "There is %d finished torrents currently within Transmission\n\n" "$FINISHED_NUM"
printf "%s\n\n" "$HEADER"
printf "%s\n\n" "$FINISHED"
}

add_new_torrent () { # Add new torrents from the command line
for torrent in "$@"; do

  $TR --trash-torrent -a "$torrent"; echo -e "\n"

done
}

list_torrents () {
local TOR_LIST=$($TR -l | tail -n+2 | grep -v "^Sum\:" | awk '{ print $1 }')
[[ -z $TOR_LIST ]] && echo -e "\nThere are currently no torrents listed in Transmission\n" && exit 5

for ID in $TOR_LIST; do

  local NAME="$($TR -t $ID -i | grep Name:)"
  echo -e "$ID: ${NAME#*Name: }"

done
}

verify_torrents () { # Verify torrents
read -ep "Please enter torrent ID number: " TOR_ID
[[ -z "$TOR_ID" ]] && echo -e "\nYou must supply a torrent ID\n" && exit 5
echo -e "\n"; $TR -t $TOR_ID -v
}

torrent_information () { # Check torrent information
read -ep "Please enter torrent ID number: " TOR_ID
[[ -z "$TOR_ID" ]] && echo -e "\nYou must supply a torrent ID\n" && exit 5
echo -e "\n"; $TR -t $TOR_ID -i
}

list_torrent_files () { # torrents file list
read -ep "Please enter torrent ID number: " TOR_ID
[[ -z "$TOR_ID" ]] && echo -e "\nYou must supply a torrent ID\n" && exit 5
echo -e "\n"; $TR -t $TOR_ID -f
}

ask_for_more_peers () {
read -ep "Please enter torrent ID number: " TOR_ID
[[ -z "$TOR_ID" ]] && echo -e "\nYou must supply a torrent ID\n" && exit 5
echo -e "\n"; $TR -t $TOR_ID --reannounce
}

session_info () {
$TR -si
}

session_stats () {
$TR -st
}

help_menu () {
prog="$(echo $(basename $0))"

cat <<EOF
This script is used to manage torrents within the transmission daemon. You can add/remove/verify torrents, check out session related info, list torrents, list files, ask for more peers.
Becareful using the -c|--cleanuptorrents as this is automated, and will grep for Idleing torrents with a progress/status of 0% and n/a.
  $prog <[-h|--help] [-rf|--remove-finished] [-d|--delete] [-c|--cleanuptorrents] [-a|--active] [-f|--finished] [-n|--new] [-l|--list] [-v|--verify] [-i|--info] [-lf|--files] [-mp|--morepeers] [-si] [-ss|--stats]>
EOF
}

selection=$1
case $selection in

  -rf|--remove-finished)

    remove_finished_torrents ;;

  -d|--delete)

    shift
    delete_torrent "$@" ;;

  -c|--cleanuptorrents)

    cleanup_dead_torrents ;;

  -a|--active)

    active_torrents ;;

  -f|--finished)

    finished_torrents ;;

  -n|--new)

    shift
    add_new_torrent "$@" ;;

  -l|--list)

    list_torrents ;;

  -v|--verify)

    verify_torrents ;;

  -i|--info)

    torrent_information ;;

  -lf|--files)

    list_torrent_files ;;

  -mp|--morepeers)

    ask_for_more_peers ;;

  -si)

    session_info ;;

  -ss|--stats)

    session_stats ;;

  -h|--help|*)

    help_menu ;;

esac
