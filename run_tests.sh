#!/bin/bash

source config.sh $1

echo "Run tests for every cipher, every digest and with compression enabled/dissabled"
echo "ciphers:"
cat $CIPHERS

echo "digests:"
cat $DIGESTS

echo "TEST: client --> server $SIZE MB random data $RANDOM_FILE"
echo "TEST: server --> client $SIZE MB random data $RANDOM_FILE"
echo "TEST: client --> server $SIZE MB zero data $ZERO_FILE"
echo "TEST: server --> client $SIZE MB zero data $ZERO_FILE"
