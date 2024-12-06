#!/bin/bash

# Script to run pedestal analysis for FTgems and display, print, and log the results.

# Usage: $ analyze-FTgem-pedestal <runnunm>

# List of arguments
runnum=$1           # run number
nevents=1000        # total no. of events to replay. We typically replay 5K events for pedestals.
firstevent=0        # the first event to analyze
fname_prefix='e1217004'     # set according to the CODA file name prefix
firstsegment=0      # first evio file segment to analyze
maxsegments=1       # maximum no. of segments (or jobs) to analyze
pedestalmode=1      # set to 1 for pedestal analysis

script='run-FTgem-replay.sh'

$script $runnum $nevents $firstevent $fname_prefix $firstsegment $maxsegments $pedestalmode

                    ## Making Panguin plots ##

export PANGUIN_CONFIG_PATH=$SBS_REPLAY/onlineGUIconfig:$SBS_REPLAY/onlineGUIconfig/scripts

# Where are the replayed ROOT files located?
ROOT_DIR=/chafs2/work1/sbs/Rootfiles

# What is the ROOT file to make plots from?
ROOTFILE=$ROOT_DIR/${fname_prefix}_replayed_gepFTGEMs_${runnum}_seg0_${firstsegment}_firstevent${firstevent}_nevent${nevents}.root

panguin -f sbs_gem_ped_and_commonmode_gepFT.cfg -r $runnum -R $ROOTFILE 

panguin -f sbs_gem_ped_and_commonmode_gepFT.cfg -r $runnum -R $ROOTFILE -P

PLOTS_DIR=/chafs2/work1/sbs/plots/

mv summaryPlots_${runnum}_sbs_gem_ped_and_commonmode_gepFT.pdf $PLOTS_DIR

function yes_or_no(){
  while true; do
    read -p "$* [y/n]: " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) echo "No entered" ; return 1 ;;
    esac
  done
}

# Don't use until fixed: /site/ace/certified/apps/bin/logentry \

# yes_or_no "Upload these plots to logbook HALOG? " && \
#     /adaqfs/apps/bin/logentry \
#     --logbook "HALOG" \
#     --tag Autolog \
#     --title "FTGEM pedestal plots for run ${runnum}" \
#     --attach ${PLOTS_DIR}/summaryPlots_${runnum}_sbs_gem_ped_and_commonmode_gepFT.pdf

echo ""

# Prompt the user to decide whether to compy ped and CM files into the VTP and $SBS_REPLAY/DB/gemped directories.
if yes_or_no "Copy ped and CM files to vtp directories and SBS-replay/DB/gemped?"; then
    # for ((ivtp=2; ivtp<=4; ivtp++))
    # do

    #     echo "Ignore these X11 errors. It is working fine"
    #     ssh adaq@adaq2 ssh sbs-onl@sbsvtp${ivtp} "scp a-onl@aonl2:~/sbs/GEM_replay/daq_cmr_bb_gem_run"$runnum".dat cfg/pedestals"
    #     ssh adaq@adaq2 ssh sbs-onl@sbsvtp${ivtp} "scp a-onl@aonl2:~/sbs/GEM_replay/db_cmr_bb_gem_run"$runnum".dat cfg/pedestals"
    #     ssh adaq@adaq2 ssh sbs-onl@sbsvtp${ivtp} "scp a-onl@aonl2:~/sbs/GEM_replay/daq_ped_bb_gem_run"$runnum".dat cfg/pedestals"
    #     ssh adaq@adaq2 ssh sbs-onl@sbsvtp${ivtp} "scp a-onl@aonl2:~/sbs/GEM_replay/daq_cmr_sbs_gem_run"$runnum".dat cfg/pedestals"
    #     ssh adaq@adaq2 ssh sbs-onl@sbsvtp${ivtp} "scp a-onl@aonl2:~/sbs/GEM_replay/db_cmr_sbs_gem_run"$runnum".dat cfg/pedestals"
    #     ssh adaq@adaq2 ssh sbs-onl@sbsvtp${ivtp} "scp a-onl@aonl2:~/sbs/GEM_replay/daq_ped_sbs_gem_run"$runnum".dat cfg/pedestals"

    # done

    mv db_cmr_sbs_gemFT_run${runnum}.dat $SBS_REPLAY/DB/gemped
    mv daq_cmr_sbs_gemFT_run${runnum}.dat $SBS_REPLAY/DB/gemped
    mv daq_ped_sbs_gemFT_run${runnum}.dat $SBS_REPLAY/DB/gemped
    mv GEM_alignment_info_sbs_gemFT_run${runnum}.txt $SBS_REPLAY/DB/gemped

    echo ""
    echo "Now you must log into sbsvtp# and change vtp/cfg/sbsvtp#.config to match the pedestal run number"
    echo "Then change db_sbs.gemFT.dat to also match the pedestal run number"
else
    # Create the output directory for GEM ped files if necessary.
    gemped_localoutdir=gemped
    if [[ ! -d $gemped_localoutdir ]]; then
        { #try
        mkdir $gemped_localoutdir
        } || { #catch
        echo -e "\n!!!!!!!! ERROR !!!!!!!!!"
        echo -e $gemped_localoutdir "doesn't exist and cannot be created! \n"
        exit;
        }
    fi
    
    mv db_cmr_sbs_gemFT_run${runnum}.dat $gemped_localoutdir
    mv daq_cmr_sbs_gemFT_run${runnum}.dat $gemped_localoutdir
    mv daq_ped_sbs_gemFT_run${runnum}.dat $gemped_localoutdir
    mv GEM_alignment_info_sbs_gemFT_run${runnum}.txt $gemped_localoutdir

    echo "Pedestal and CM files were moved to the folder: ${gemped_localoutdir}"
fi