#!/bin/bash

#configuration variables

SERVER_IP=192.168.0.2
CLIENT_IP=192.168.0.1
NC_PORT=4247

RAMDISK=/mnt/openvpn_test_ramdisk 
SIZE=32 #320 for real test
RAMDISK_SIZE=`expr 2 \* $SIZE + 16`m # 16MB reserve
RANDOM_FILE=$RAMDISK/random_file
ZERO_FILE=$RAMDISK/zero_file
TEST_DIR=/tmp/openvpn_test #directory for testing specific files, e.g. openvpn config, static key, results,...
STATIC_KEY=$TEST_DIR/static.key
CIPHERS=$TEST_DIR/ciphers
DIGESTS=$TEST_DIR/digests

case "$1" in
	client)
		;;
	server)
		;;
	*)
		echo "usage: openvpn_full_test.sh {server|client}"
		exit 1
		;;
esac
