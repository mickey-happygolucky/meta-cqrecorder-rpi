# Recorder board control script.
# This script controls selecting file function.
#
# Author: Yusuke Mitsuki <mickey.happygolucky@gmail.com>
# License: MIT
#
#!/bin/sh

LED0_PORT=14
LED1_PORT=15
LED2_PORT=23
F_PORT=8
B_PORT=7


F_CURR=0
F_PREV=0
B_CURR=0
B_PREV=0
CURSOR=0

RECORDDIR=/home/root/recorder
RECORDFILE=record_001.wav
FILENAME=$RECORDDIR/filename
MIN=0
MAX=0

activate_gpio() {
    if [ ! -e /sys/class/gpio/gpio$1 ] ; then
	echo "$1" > /sys/class/gpio/export
    fi
    echo "$2" > /sys/class/gpio/gpio$1/direction
    echo "$3" > /sys/class/gpio/gpio$1/direction
}

set_led() {
    echo $2 > /sys/class/gpio/gpio$1/value
}

set_counter() {
    if [ $(($1 & 0x1)) -ne 0 ] ; then
	set_led $LED0_PORT 1
    else
	set_led $LED0_PORT 0
    fi
    if [ $(($1 & 0x2)) -ne 0 ] ; then
	set_led $LED1_PORT 1
    else
	set_led $LED1_PORT 0
    fi
    if [ $(($1 & 0x4)) -ne 0 ] ; then
	set_led $LED2_PORT 1
    else
	set_led $LED2_PORT 0
    fi
}

create_dir()
{
    if [ ! -e $RECORDDIR ] ; then
	mkdir -p $RECORDDIR
	echo "$RECORDDIR created"
    fi
}

create_filename() {
    if [ ! -e $RECORDDIR/record_001.wav ] ; then
	RECORDFILE=record_001.wav
    elif [ -e $RECORDDIR/record_007.wav ] ; then
	RECORDFILE=$(ls $RECORDDIR -tr | grep -e 'record_00[1-7].wav' | head -n1)
    else
	RECORDFILE=$(printf 'record_%03d.wav' $((`ls $RECORDDIR | grep -e 'record_00[1-7].wav' | tail -n1 | cut -d'_' -f2 | cut -d'.' -f1`+1)))
    fi
}

update_minmax()
{
    echo "minmax start"
    if [ ! -e $RECORDDIR/record_001.wav ] ; then
	MIN=0
	MAX=0
    else
	MIN=$(ls $RECORDDIR | grep -e 'record_00[1-7].wav' | head -n1 | cut -d'_' -f2 | cut -d'.' -f1)
	MAX=$(ls $RECORDDIR | grep -e 'record_00[1-7].wav' | tail -n1 | cut -d'_' -f2 | cut -d'.' -f1)
    fi
    echo "minmax end"
}


forward() {
    update_minmax

    if [ $(($CURRENT+1)) -ge $MAX ] ; then
	CURRENT=$MAX
	echo "## $CURRENT:$MAX"
    else
	CURRENT=$(($CURRENT+1))
	echo "** $CURRENT:$MAX"
    fi
    set_counter $CURRENT
    if [ $CURRENT -ne 0 ] ; then
	echo $(printf 'record_%03d.wav' $CURRENT) > $FILENAME
    fi
}

back() {
    update_minmax

    if [ $(($CURRENT-1)) -le $MIN ] ; then
	CURRENT=$MIN
	echo "## $CURRENT:$MIN"
    else
	CURRENT=$(($CURRENT-1))
	echo "** $CURRENT:$MIN"
    fi
    set_counter $CURRENT
    echo $(printf 'record_%03d.wav' $CURRENT) > $FILENAME
    cat $FILENAME
}



activate_gpio $F_PORT "in" "high"
activate_gpio $B_PORT "in" "high"

activate_gpio $LED0_PORT "out" "low"
activate_gpio $LED1_PORT "out" "low"
activate_gpio $LED2_PORT "out" "low"

set_led $LED0_PORT 1
set_led $LED1_PORT 1
set_led $LED2_PORT 1

set_counter 0
while :
do
    F_CURR=`cat /sys/class/gpio/gpio${F_PORT}/value`
    if [ $F_CURR -ne $F_PREV ] ; then
	if [ $F_CURR -eq 0 ] ; then
	    echo "F pushed"
	    forward
	fi
    fi
    F_PREV=$F_CURR

    B_CURR=`cat /sys/class/gpio/gpio${B_PORT}/value`
    if [ $B_CURR -ne $B_PREV ] ; then
	if [ $B_CURR -eq 0 ] ; then
	    echo "B pushed"
	    back
	fi
    fi
    B_PREV=$B_CURR

    usleep 50000
done

echo "done"
