#!/bin/bash

source config.sh $1

#create ramdisk 
if [ ! -d $RAMDISK ]; then
	echo "Creating ramdisk at $RAMDISK with size $RAMDISK_SIZE"
	mkdir $RAMDISK
	mount -t tmpfs -o size=$RAMDISK_SIZE tmpfs $RAMDISK 
fi

#generate random file at server and send it to client
case "$1" in
	server)
		if [ ! -f $RANDOM_FILE ]; then
			echo "Generating $RANDOM_FILE with size $SIZE MB"
			dd if=/dev/urandom bs=`expr 1024 \* 1024` count=$SIZE | pv > $RANDOM_FILE
		fi
		echo -n "Sending $RANDOM_FILE to client..."
		cat $RANDOM_FILE | pv | nc -q 0 $CLIENT_IP $NC_PORT
		sleep 10 
		echo "OK"
		;;
	client)
		echo -n "Receiving $RANDOM_FILE..."
		nc -l -p $NC_PORT | pv > $RANDOM_FILE
		echo "OK"
		;;
esac

#create random file
if [ ! -f $ZERO_FILE ]; then
	echo "Generating $ZERO_FILE with size $SIZE MB"
	dd if=/dev/zero bs=`expr 1024 \* 1024` count=$SIZE | pv > $ZERO_FILE
fi

#create testing directory
if [ ! -d $TEST_DIR ]; then
	echo "Creating openvpn testing directory $TEST_DIR"
	mkdir $TEST_DIR
fi

#backup content of testing directory
#TODO

#create static key
case "$1" in
	server)
		echo -n "Generating and sending static key to client..."
		sleep 2
		openvpn --genkey --secret $STATIC_KEY
		cat $STATIC_KEY | nc -q 0 $CLIENT_IP $NC_PORT
		echo "OK"
		;;
	client)
		echo -n "Receiving static key..."
		nc -l -p $NC_PORT > $STATIC_KEY
		echo "OK"
		;;
esac



#create unique list of ciphers and digests supported by both client and server
echo "Detecting supported ciphers and digests"
openvpn --show-ciphers | head --lines=-1 | tail --lines=+8 > $TEST_DIR/ciphers.1
openvpn --show-digests | head --lines=-1 | tail --lines=+7 > $TEST_DIR/digests.1

echo -n "Sending and receiving available ciphers and digests..."
case "$1" in
	server)
		sleep 2
		cat $TEST_DIR/ciphers.1 | nc -q 0 $CLIENT_IP $NC_PORT
		sleep 1
		cat $TEST_DIR/digests.1 | nc -q 0 $CLIENT_IP $NC_PORT
		nc -l -p $NC_PORT > $TEST_DIR/ciphers.2
		nc -l -p $NC_PORT > $TEST_DIR/digests.2
		;;
	client)
		nc -l -p $NC_PORT > $TEST_DIR/ciphers.2
		nc -l -p $NC_PORT > $TEST_DIR/digests.2
		sleep 2
		cat $TEST_DIR/ciphers.1 | nc -q 0 $SERVER_IP $NC_PORT
		sleep 1
		cat $TEST_DIR/digests.1 | nc -q 0 $SERVER_IP $NC_PORT
		;;
esac
echo "OK"

echo "Create uniq list of ciphers and digests"
sort $TEST_DIR/ciphers.* | uniq -d > $CIPHERS
sort $TEST_DIR/digests.* | uniq -d > $DIGESTS
rm $TEST_DIR/ciphers.* $TEST_DIR/digests.*
