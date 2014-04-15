#!/bin/bash

source config.sh

#remove ramdisk 
if [ -d $RAMDISK ]; then
	if [ "`ls -A $RAMDISK`" ]; then
		rm -i $RAMDISK/*
	fi
	umount $RAMDISK 
	rmdir $RAMDISK
fi
