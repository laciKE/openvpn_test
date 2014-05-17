#!/bin/bash

source config.sh $1

echo "Run tests for every cipher, every digest and with compression enabled/disabled"
echo "ciphers:"
cat $CIPHERS

echo "digests:"
cat $DIGESTS

function get_time()
{
    date '+%s.%N'
}

function get_peer_ip()
{
    case $MODE in
        server)
            echo $CLIENT_VPN_IP
            ;;
        client)
            echo $SERVER_VPN_IP
            ;;
    esac
}

function start_vpn()
{
    DIGEST=$1
    CIPHER=$2
    COMP=$3
    case $MODE in
        client)
            cat > $CONFIG <<EOF
dev tun
remote $SERVER_IP
ifconfig $CLIENT_VPN_IP $SERVER_VPN_IP
secret $STATIC_KEY
auth $DIGEST
cipher $CIPHER
comp-lzo $COMP
EOF
            ;;
        server)
            cat > $CONFIG <<EOF
dev tun
ifconfig $SERVER_VPN_IP $CLIENT_VPN_IP
secret $STATIC_KEY
auth $DIGEST
cipher $CIPHER
comp-lzo $COMP
EOF
            ;;
    esac

    [ -s $PIDFILE ] && kill -HUP $(cat $PIDFILE) || \
        openvpn --config $CONFIG --daemon --pidfile $PIDFILE \
                --log-append $LOGFILE
}

function kill_vpn()
{
    kill -TERM $(cat $PIDFILE)
}

function receive_file()
{
    nc -l -p $NC_PORT > /dev/null
}

function send_file()
{
    sleep 2 # to make sure the listener is ready
    BEFORE=$(get_time)
    nc -q 0 $(get_peer_ip) < $1
    AFTER=$(get_time)
    echo "$AFTER - $BEFORE" | bc -l
}


for COMP in yes no; do
    for DIGEST in $(cat $DIGESTS); do
        for CIPHER in $(cat $CIPHERS); do
            echo "Digest: $DIGEST, cipher: $CIPHER, compression $COMP"
            start_vpn $DIGEST $CIPHER $COMP
            case $MODE in
                client)
                    echo "Sending ${RANDOM_FILE}..."
                    send_file $RANDOM_FILE > \
                            $RESULT_DIR/$DIGEST-$CIPHER-$COMP-random-client
                    echo "Receiving ${RANDOM_FILE}..."
                    receive_file
                    echo "Sending ${ZERO_FILE}..."
                    send_file $ZERO_FILE > \
                            $RESULT_DIR/$DIGEST-$CIPHER-$COMP-zero-client
                    echo "Receiving ${ZERO_FILE}..."
                    receive_file
                    ;;
                server)
                    echo "Receiving ${RANDOM_FILE}..."
                    receive_file
                    echo "Sending ${RANDOM_FILE}..."
                    send_file $RANDOM_FILE > \
                            $RESULT_DIR/$DIGEST-$CIPHER-$COMP-random-server
                    echo "Receiving ${ZERO_FILE}..."
                    receive_file
                    echo "Sending ${ZERO_FILE}..."
                    send_file $ZERO_FILE > \
                            $RESULT_DIR/$DIGEST-$CIPHER-$COMP-zero-server
                    ;;
            esac
        done
    done
done

kill_vpn
