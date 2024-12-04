#!/bin/bash

### Written by Anuruddha Rathnayake; adr@jlab.org, anuruddha@uconn.edu ###

# This script will take the required arguments and run the replay script 'replay_gep_FTGEM.C'.

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

analyzer -b -q 'replay_gep_FTGEM.C+('$runnum', '$maxevents', '$firstevent', '\"$prefix\"', '$firstsegment', '$maxsegments', '$pedestalmode')'

# if [[ $pedestalmode == 1 ]]; then
#     db_cmfile='db_cmr_sbs_gemFT_run'$runnum'.dat'
#     daq_pedfile='daq_ped_sbs_gemFT_run'$runnum'.dat'
#     daq_cmfile='daq_cmr_sbs_gemFT_run'$runnum'.dat'
#     gem_aligninfofile='GEM_alignment_info_sbs_gemFT_run'$runnum'.txt'
#     # move output files
#     mv $db_cmfile $DB_DIR/gemped
#     mv $daq_pedfile $DB_DIR/gemped
#     mv $daq_cmfile $DB_DIR/gemped
#     mv $gem_aligninfofile $DB_DIR/gemped
# fi

# clean up the directory
rm .rootrc
if [[ -f .rootrc_temp ]]; then
    mv .rootrc_temp .rootrc
fi