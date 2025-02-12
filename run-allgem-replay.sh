#!/bin/bash

### Written by Anuruddha Rathnayake; adr@jlab.org, anuruddha@uconn.edu ###

# This script will take the required arguments and run the replay script 'replay_gep_allGEM.C'.

# List of arguments
runnum=$1
maxevents=$2
firstevent=$3
prefix=$4
firstsegment=$5
maxsegments=$6
pedestalmode=$7

# handling any existing .rootrc files
if [[ -f .rootrc ]]; then
    mv .rootrc .rootrc_temp
fi

cp $SBS/run_replay_here/.rootrc .

analyzer -b -q 'replay_gep_allGEM.C+('$runnum', '$maxevents', '$firstevent', '\"$prefix\"', '$firstsegment', '$maxsegments', '$pedestalmode')'

# clean up the directory
rm .rootrc
if [[ -f .rootrc_temp ]]; then
    mv .rootrc_temp .rootrc
fi