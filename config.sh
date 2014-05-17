#!/bin/bash

#configuration variables

SERVER_IP=klement.ksp
CLIENT_IP=cement.ksp
SERVER_VPN_IP=10.74.47.1
CLIENT_VPN_IP=10.74.47.2
NC_PORT=4247

TEST_DIR=/tmp/openvpn_test #directory for testing specific files, e.g. openvpn config, static key, results,...
RAMDISK=$TEST_DIR/ramdisk 
SIZE=320 #320 for real test
RAMDISK_SIZE=`expr 2 \* $SIZE + 16`m # 16MB reserve
RANDOM_FILE=$RAMDISK/random_file
ZERO_FILE=$RAMDISK/zero_file
STATIC_KEY=$TEST_DIR/static.key
CIPHERS=$TEST_DIR/ciphers
DIGESTS=$TEST_DIR/digests
CONFIG=$TEST_DIR/openvpn.conf
PIDFILE=$TEST_DIR/openvpn.pid
LOGFILE=$TEST_DIR/openvpn.log
RESULT_DIR=$TEST_DIR/results

MODE="$1"

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
