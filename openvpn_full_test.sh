#!/bin/bash

source config.sh $1
source init.sh $1
sleep 2
source run_tests.sh $1
#source finalize.sh $1
