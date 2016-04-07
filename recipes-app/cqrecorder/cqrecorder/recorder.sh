#
# Recorder board control script.
# This script controls recording function.
#
# Author: Yusuke Mitsuki <mickey.happygolucky@gmail.com>
# License: MIT
#
#!/bin/sh

IN_PORT=16
OUT_PORT=25
CURR=0
PREV=0
LED=1
SRATE=96000
BUFTIME=50000
RECORDDIR=/home/root/recorder
RECORDFILE=record_001.wav
IS_RECORDING=0


activate_gpio() {
    if [ ! -e /sys/class/gpio/gpio$1 ] ; then
	echo "$1" > /sys/class/gpio/export
    fi
    echo "$2" > /sys/class/gpio/gpio$1/direction
    echo "$3" > /sys/class/gpio/gpio$1/direction
}

is_recording() {
    if [ $# -ne 0 ] ; then
	echo $1 > /tmp/recording
    else
	return $(cat /tmp/recording)
    fi
    return 0
}

set_led() {
    echo $1 > /sys/class/gpio/gpio${OUT_PORT}/value
}

create_dir()
{
    if [ ! -e $RECORDDIR ] ; then
	mkdir -p $RECORDDIR
	echo "$RECORDDIR created"
    fi
}

create_filename()
{
    if [ ! -e $RECORDDIR/record_001.wav ] ; then
	RECORDFILE=record_001.wav
    elif [ -e $RECORDDIR/record_007.wav ] ; then
	RECORDFILE=$(ls $RECORDDIR -tr | grep -e 'record_00[1-7].wav' | head -n1)
    else
	RECORDFILE=$(printf 'record_%03d.wav' $((`ls $RECORDDIR | grep -e 'record_00[1-7].wav' | tail -n1 | cut -d'_' -f2 | cut -d'.' -f1`+1)))
    fi
}

record() {
    set_led 1
    is_recording 1
    arecord -f S24_LE -c 2 -B $BUFTIME -r $SRATE $RECORDDIR/$1
    set_led 0
    is_recording 0
}

stop_record() {
    killall arecord
    sync
    set_led 0
    is_recording 0
}

create_dir

activate_gpio $IN_PORT "in" "high"
activate_gpio $OUT_PORT "out" "low"

is_recording 0
while :
do
    CURR=`cat /sys/class/gpio/gpio${IN_PORT}/value`
    if [ $CURR -ne $PREV ] ; then
	if [ $CURR -eq 0 ] ; then
	    is_recording
	    IS_RECORDING=$?
	    if [ $IS_RECORDING -eq 0 ] ; then
		create_filename
		record $RECORDFILE &
	    else
		stop_record
	    fi
	fi
    fi
    PREV=$CURR
    usleep 50000
done

echo "done"
