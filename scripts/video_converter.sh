#!/bin/bash
# Takes input video files and converts them to mp4 format

video_file="$1"
ffmpeg_log=/var/log/ffmpegreport.log

read line <<<$video_file

original_video="$line"
movie_name=$(echo $original_video | awk -F'.' '{ print $1 }')
extension=$(echo $original_video | awk -F'.' '{ print $2 }')
new_video="$movie_name.mp4"

ffmpeg -i $original_video -c:v libx264 -crf 23 -c:a libfaac -q:a 100 $new_video > $ffmpeg_log 2>&1

exit 0
