#!/bin/sh

if [ ! -f "/tmp/adbyby.updated" ];then
	wget_ok="0"
	while [ "$wget_ok" = "0" ]; do
		uclient-fetch --spider --quiet --timeout=3 http://www.baidu.com
		if [ "$?" == "0" ]; then
			wget_ok="1"
			touch /tmp/md5.json && uclient-fetch --no-check-certificate -T 10 -O /tmp/md5.json https://cdn.jsdelivr.net/gh/kongfl888/ad-rules/md5.json && dos2unix /tmp/md5.json
			adm5=$(md5sum /tmp/md5.json | awk -F' ' '{print $1}')
			touch /tmp/adbyby/admd5.json && bmd5=$(md5sum /tmp/adbyby/admd5.json | awk -F' ' '{print $1}')
			if [ "$adm5" == "$bmd5" ];then
				echo "Rules MD5 are the same!"
				echo $(date "+%Y-%m-%d %H:%M:%S") > /tmp/adbyby.updated
				exit 0
			elif [ -s /tmp/md5.json ];then
				touch /tmp/lazy.txt && uclient-fetch --no-check-certificate -T 10 -O /tmp/lazy.txt https://cdn.jsdelivr.net/gh/kongfl888/ad-rules/lazy.txt && dos2unix /tmp/lazy.txt
				touch /tmp/video.txt && uclient-fetch --no-check-certificate -T 10 -O /tmp/video.txt https://cdn.jsdelivr.net/gh/kongfl888/ad-rules/video.txt && dos2unix /tmp/video.txt
				touch /tmp/local-md5.json && md5sum /tmp/lazy.txt /tmp/video.txt > /tmp/local-md5.json
				lazy_local=$(grep 'lazy' /tmp/local-md5.json | awk -F' ' '{print $1}')
				video_local=$(grep 'video' /tmp/local-md5.json | awk -F' ' '{print $1}')
				lazy_online=$(sed 's/":"/\n/g' /tmp/md5.json | sed 's/","/\n/g' | sed -n '2p')
				video_online=$(sed 's/":"/\n/g' /tmp/md5.json | sed 's/","/\n/g' | sed -n '4p')
				if [ "$lazy_online"x == "$lazy_local"x -a "$video_online"x == "$video_local"x ]; then
					echo "adbyby rules MD5 OK!"
					mv /tmp/lazy.txt /tmp/adbyby/data/lazy.txt
					mv /tmp/video.txt /tmp/adbyby/data/video.txt
					mv /tmp/md5.json /tmp/adbyby/admd5.json
					echo $(date "+%Y-%m-%d %H:%M:%S") > /tmp/adbyby.updated
				fi
			fi
		else
			sleep 10
		fi
	done
	rm -f /tmp/adbyby/data/*.bak
	kill -9 $(busybox ps -w | grep "/tmp/adbyby/adbyby" | grep -v grep | grep -v update| grep -v adblock | awk '{print $1}') >/dev/null 2>&1
	/tmp/adbyby/adbyby >/dev/null 2>&1 &
fi
