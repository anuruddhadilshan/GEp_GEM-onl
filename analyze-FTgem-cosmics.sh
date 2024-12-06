#!/bin/bash

set -u

# Script to run pedestal analysis for FTgems and display, print, and log the results.

# Usage: $ analyze-FTgem-cosmics.sh <runnunm>

# List of arguments
runnum=$1           # run number
nevents=-1      # total no. of events to replay. Input -1 to replay all the events to completion within a EVIO file split.
firstevent=0        # the first event to analyze
fname_prefix='e1217004'     # set according to the CODA file name prefix
firstsegment=0      # first evio file segment to analyze
maxsegments=1       # maximum no. of segments (or jobs) to analyze
pedestalmode=0      # set to 1 for pedestal analysis

script='run-FTgem-replay.sh'

# Check if $DATA_DIR is set properly.
if [ -z "$DATA_DIR" ]; then
    echo "ERROR: DATA_DIR is not set."
    exit 1
fi

# Find the # of EVIO file segments
iseg=0
seg=-1
while : # Infinite loop
do 
  found=false # Flag to indicate if the file exists in any directory.
  
  for dir in ${DATA_DIR//:/ }; do # Replace ':' with space to loop through directories
      if [ -f "${dir}/${fname_prefix}_${runnum}.evio.0.${iseg}" ]; then
          found=true # File segment found in the current dir. 
          break # Exit the for loop.
      fi
  done

  if [ "$found" = false ]; then
      break # Exit the while loop if the file is not found
  fi
  
  seg=$iseg
  ((iseg++))

done

# Exit if there are no EVIO files
if (($seg == -1)); then
    echo "${dir}/${fname_prefix}_${runnum}.evio.0.${iseg}"
    echo "No CODA EVIO files found for run "$runnum
    exit
fi

((seg++))

echo "No of file segments for run $runnum: $seg"

# How many jobs to run? That will decide number of segments per job.
read -p "How many parallel jobs would you like to run? " njobs

seg_per_job=$((seg/njobs))

echo "Segments per job: $seg_per_job"
echo "Job remainder: $((seg % njobs))"


for ((ijob=0; ijob<njobs; ijob++))
do
  first_seg=$((seg_per_job * ijob))
  xterm -e "ssh a-onl@aonl1 'bash -i -c \"gogem && $script $runnum $nevents $firstevent $fname_prefix $first_seg $seg_per_job $pedestalmode\"'" &
done

if ((seg % njobs != 0)); then # Run one additional job to replay the remainder of the segments if seg is not divisible by njobs.
  first_seg=$((seg_per_job * njobs))
  xterm -e "ssh a-onl@aonl1 'bash -i -c \"gogem && $script $runnum $nevents $firstevent $fname_prefix $first_seg $((seg % njobs)) $pedestalmode\"'" &
fi

# Wait for all the background processes to finish
wait

## Put the replayed ROOT files together ##
concat_rootfilename="${fname_prefix}_fullreplay_gepFTGEMs_${runnum}_all.root"

echo ""
echo "Putting all the replayed ROOT files together to make plots. This may take a few minuites..."
echo ""
hadd -k -f -j 16 $OUT_DIR/${concat_rootfilename} $OUT_DIR/${fname_prefix}_fullreplay_gepFTGEMs_${runnum}_seg*.root


## Making Panguin plots ##
export PANGUIN_CONFIG_PATH=$SBS_REPLAY/onlineGUIconfig:$SBS_REPLAY/onlineGUIconfig/scripts

# Where are the replayed ROOT files located?
ROOT_DIR=$OUT_DIR

# What is the ROOT file to make plots from?
ROOTFILE=$ROOT_DIR/${fname_prefix}_fullreplay_gepFTGEMs_${runnum}_all.root

panguin -f sbs_gem_gepFT.cfg -r $runnum -R $ROOTFILE
panguin -f sbs_gem_gepFT.cfg -r $runnum -R $ROOTFILE -P 

panguin -f sbs_gem_basic_gepFT.cfg -r $runnum -R $ROOTFILE
panguin -f sbs_gem_basic_gepFT.cfg -r $runnum -R $ROOTFILE -P

PLOTS_DIR=/chafs2/work1/sbs/plots/

mv summaryPlots_${runnum}_sbs_gem_gepFT.pdf $PLOTS_DIR
mv summaryPlots_${runnum}_sbs_gem_basic_gepFT.pdf $PLOTS_DIR

echo ""
echo "You can find the PDFs at: ${PLOTS_DIR}"
echo ""

# function yes_or_no(){
#   while true; do
#     read -p "$* [y/n]: " yn
#     case $yn in
#       [Yy]*) return 0 ;;
#       [Nn]*) echo "No entered" ; return 1 ;;
#     esac
#   done
# }

# Don't use until fixed: /site/ace/certified/apps/bin/logentry \

# yes_or_no "Upload these plots to logbook HALOG? " && \
#     /adaqfs/apps/bin/logentry \
#     --logbook "HALOG" \
#     --tag Autolog \
#     --title "FTGEM pedestal plots for run ${runnum}" \
#     --attach ${PLOTS_DIR}/summaryPlots_${runnum}_sbs_gem_ped_and_commonmode_gepFT.pdf

