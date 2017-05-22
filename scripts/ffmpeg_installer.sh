#!/bin/bash
# install ffmpeg on CentOS 7 # the yum install list maybe incomplete/inaccurate slighlty 

rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
rpm -Uvh http://li.nux.ro/download/nux/dextop/el6/x86_64/nux-dextop-release-0-2.el6.nux.noarch.rpm
yum install ffmpeg ffmpeg-devel libusbx libusbx-devel libusb libusb-devel libva libva-devel lame lame-devel \
x265 x265-devel x264 x264-devel facc facc-devel -y
