# Recorder board control script.
# This script controls playing file function.
#
# Author: Yusuke Mitsuki <mickey.happygolucky@gmail.com>
# License: MIT
#
#!/bin/sh

IN_PORT=12
OUT_PORT=24
CURR=0
PREV=0
LED=1
SRATE=96000
PLAYDIR=/home/root/recorder
PLAYFILE=
FILENAME=$PLAYDIR/filename
IS_PLAYING=0

update_playfile() {
    if [ -e $FILENAME ] ; then
	PLAYFILE=$(cat $FILENAME)
	echo "## $PLAYFILE"
    else
	PLAYFILE=""
	echo "###"
    fi
}

activate_gpio() {
    if [ ! -e /sys/class/gpio/gpio$1 ] ; then
	echo "$1" > /sys/class/gpio/export
    fi
    echo "$2" > /sys/class/gpio/gpio$1/direction
    echo "$3" > /sys/class/gpio/gpio$1/direction
}

is_playing() {
    if [ $# -ne 0 ] ; then
	echo $1 > /tmp/playing
    else
	return $(cat /tmp/playing)
    fi
    return 0
}

set_led() {
    echo $1 > /sys/class/gpio/gpio${OUT_PORT}/value
}

play() {
    if [ -z "$1" ] ; then
	echo "playfile is not selected"
	return
    fi
    set_led 1
    is_playing 1
    aplay $PLAYDIR/$1
    set_led 0
    is_playing 0
}

stop_play() {
    killall aplay
    set_led 0
    is_playing 0
}

activate_gpio $IN_PORT "in" "high"
activate_gpio $OUT_PORT "out" "low"

is_playing 0
while :
do
    CURR=`cat /sys/class/gpio/gpio${IN_PORT}/value`
    if [ $CURR -ne $PREV ] ; then
	if [ $CURR -eq 0 ] ; then
	    is_playing
	    IS_PLAYING=$?
	    if [ $IS_PLAYING -eq 0 ] ; then
		update_playfile
		play $PLAYFILE &
	    else
		stop_play
	    fi
	fi
    fi
    PREV=$CURR
    usleep 50000
done

echo "done"
