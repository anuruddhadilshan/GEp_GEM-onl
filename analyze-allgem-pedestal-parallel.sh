#!/bin/bash

set -u

# Script to run pedestal analysis for FTgems and FPPgems and display, print, and log the results.

# Usage: $ analyze-gem-pedestal <runnunm> <daqtype>

# List of input arguments
runnum=$1           # run number
daqtype=$2          # DAQ type. Input '1' for main DAQ and '2' for stand-alone GEM DAQ.

if [ $daqtype -eq 1 ] ; then
  
  fname_prefix='gep5'

elif [ $daqtype -eq 2 ] ; then

  fname_prefix='gem'

else

  echo -e '\n Input Error: The second input, <daqtype>, should be either 1 (for main DAQ data) or 2 (for stand-alone GEM DAQ). \n'; exit

fi


nevents=5000        # total no. of events to replay. We typically replay 5K events for pedestals.
firstevent=0        # the first event to analyze
firstsegment=0      # first evio file segment to analyze
maxsegments=1       # maximum no. of segments (or jobs) to analyze
pedestalmode=1      # set to 1 for pedestal analysis

source setenv.sh

scriptFT='run-FTgem-replay.sh'
scriptFPP='run-FPPgem-replay.sh'

xterm -e "ssh a-onl@aonl1 'bash -i -c \"gogem && source setenv.sh && $scriptFT $runnum $nevents $firstevent $fname_prefix $firstsegment $maxsegments $pedestalmode\"'" &
xterm -e "ssh a-onl@aonl1 'bash -i -c \"gogem && source setenv.sh && $scriptFPP $runnum $nevents $firstevent $fname_prefix $firstsegment $maxsegments $pedestalmode\"'" &

# # Wait for all the background processes to finish
wait

                    ## Making Panguin plots ##
module purge
module load panguin
export PANGUIN_CONFIG_PATH=$SBS_REPLAY/onlineGUIconfig:$SBS_REPLAY/onlineGUIconfig/scripts

# Where are the replayed ROOT files located?
ROOT_DIR=/chafs2/work1/sbs/Rootfiles

# What is the ROOT file to make plots from?
ROOTFILEFT=$ROOT_DIR/${fname_prefix}_replayed_gepFTGEMs_${runnum}_seg0_${firstsegment}_firstevent${firstevent}_nevent${nevents}.root
ROOTFILEFPP=$ROOT_DIR/${fname_prefix}_replayed_gepFPPGEMs_${runnum}_seg0_${firstsegment}_firstevent${firstevent}_nevent${nevents}.root

panguin -f sbs_gem_ped_and_commonmode_gepFT.cfg -r $runnum -R $ROOTFILEFT 
panguin -f sbs_gem_ped_and_commonmode_gepFT.cfg -r $runnum -R $ROOTFILEFT -P

panguin -f sbs_gem_ped_and_commonmode_gepFPP.cfg -r $runnum -R $ROOTFILEFPP 
panguin -f sbs_gem_ped_and_commonmode_gepFPP.cfg -r $runnum -R $ROOTFILEFPP -P


PLOTS_DIR=/chafs2/work1/sbs/plots/

mv summaryPlots_${runnum}_sbs_gem_ped_and_commonmode_gepFT.pdf $PLOTS_DIR

mv summaryPlots_${runnum}_sbs_gem_ped_and_commonmode_gepFPP.pdf $PLOTS_DIR

function yes_or_no(){
  while true; do
    read -p "$* [y/n]: " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) echo "No entered" ; return 1 ;;
    esac
  done
}

echo ""

# Prompt the user to decide whether to compy ped and CM files into the VTP and $SBS_REPLAY/DB/gemped directories.
if yes_or_no "Copy ped and CM files to vtp directories and SBS-replay/DB/gemped?"; then

    mv db_cmr_sbs_gemFT_run${runnum}.dat $SBS_REPLAY/DB/gemped
    mv daq_cmr_sbs_gemFT_run${runnum}.dat $SBS_REPLAY/DB/gemped
    mv daq_ped_sbs_gemFT_run${runnum}.dat $SBS_REPLAY/DB/gemped
    
    mv db_cmr_sbs_gemFPP_run${runnum}.dat $SBS_REPLAY/DB/gemped
    mv daq_cmr_sbs_gemFPP_run${runnum}.dat $SBS_REPLAY/DB/gemped
    mv daq_ped_sbs_gemFPP_run${runnum}.dat $SBS_REPLAY/DB/gemped
    
    echo ""
    echo "Now you must log into sbsvtp# and change vtp/cfg/sbsvtp#.config to match the pedestal run number"
    echo "Then change db_sbs.gemFT.dat amd db_sbs.gemFPP.dat to also match the pedestal run number"
    echo ""
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
    
    mv db_cmr_sbs_gemFPP_run${runnum}.dat $gemped_localoutdir
    mv daq_cmr_sbs_gemFPP_run${runnum}.dat $gemped_localoutdir
    mv daq_ped_sbs_gemFPP_run${runnum}.dat $gemped_localoutdir
    
    echo "Pedestal and CM files were moved to the folder: ${gemped_localoutdir}"
fi

# Let's move the GEM align info files to a separate directory remove the clutter in the top level directory.
gemalign_localdir=gemalign

if [ -f GEM_alignment_info_sbs_gemFT_run${runnum}.txt ]; then
  mv GEM_alignment_info_sbs_gemFT_run${runnum}.txt $gemalign_localdir
  echo "GEM alignment info file for FT can be found at the folder: "${gemalign_localdir}
  echo ""
fi

if [ -f GEM_alignment_info_sbs_gemFPP_run${runnum}.txt ]; then
  mv GEM_alignment_info_sbs_gemFPP_run${runnum}.txt $gemalign_localdir
  echo "GEM alignment info file for FPP can be found at the folder: "${gemalign_localdir}
  echo ""
fi