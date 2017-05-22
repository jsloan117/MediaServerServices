#!/bin/bash
# Used to download subtitles

video_dir="$1"

[[ -n $video_dir && -d $video_dir ]] && subliminal download -l en -v $video_dir || echo -e "Enter directory to run subtitler-downloader against. \n" && exit 1
