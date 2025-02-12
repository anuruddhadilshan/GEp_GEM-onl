#!/bin/bash

set -u

# Script to run cosmic tracking analysis for FTgems+FPPgems and display, print, and log the results.

# Usage: $ analyze-allgem-cosmics.sh <runnunm> <daqtype>

# List of arguments
runnum=$1           # run number
daqtype=$2          # DAQ type. Input '1' for main DAQ and '2' for stand-alone GEM DAQ.

if [ $daqtype -eq 1 ] ; then
  
  fname_prefix='gep5'

elif [ $daqtype -eq 2 ] ; then

  fname_prefix='gem'

else

  echo -e '\n Input Error: The second input, <daqtype>, should be either 1 (for main DAQ data) or 2 (for stand-alone GEM DAQ). \n'; exit

fi

nevents=-1      # total no. of events to replay. Input -1 to replay all the events to completion within a EVIO file split.
firstevent=0        # the first event to analyze
firstsegment=0      # first evio file segment to analyze
maxsegments=1       # maximum no. of segments (or jobs) to analyze
pedestalmode=0      # set to 1 for pedestal analysis

script='run-allgem-replay.sh'

# Check if $DATA_DIR is set properly.
if [ -z "$DATA_DIR" ]; then
    echo "ERROR: DATA_DIR is not set."
    exit 1
fi

# Find the # of EVIO file segments
iseg=0
seg=-1

case $daqtype in

    1) 
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

        ;;

    2) 
        while : # Infinite loop
        do 
        found=false # Flag to indicate if the file exists in any directory.
        
        for dir in ${DATA_DIR//:/ }; do # Replace ':' with space to loop through directories
            if [ -f "${dir}/${fname_prefix}_${runnum}.dat.0.${iseg}" ]; then
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

        ;;

esac


echo "No of file segments for run $runnum: $seg"

# How many jobs to run? That will decide number of segments per job.
read -p "How many parallel jobs would you like to run? " njobs

seg_per_job=$((seg/njobs))

echo "Segments per job: $seg_per_job"
echo "Job remainder: $((seg % njobs))"

for ((ijob=0; ijob<njobs; ijob++))
do
  first_seg=$((seg_per_job * ijob))
  xterm -e "ssh a-onl@aonl1 'bash -i -c \"gogem && source setenv.sh && $script $runnum $nevents $firstevent $fname_prefix $first_seg $seg_per_job $pedestalmode\"'" &
done

if ((seg % njobs != 0)); then # Run one additional job to replay the remainder of the segments if seg is not divisible by njobs.
  first_seg=$((seg_per_job * njobs))
  xterm -e "ssh a-onl@aonl1 'bash -i -c \"gogem && source setenv.sh && $script $runnum $nevents $firstevent $fname_prefix $first_seg $((seg % njobs)) $pedestalmode\"'" &
fi

# # Wait for all the background processes to finish
wait

## Put the replayed ROOT files together ##
concat_rootfilename="${fname_prefix}_fullreplay_allGEMs_${runnum}_all.root"

echo ""
echo "Putting all the replayed ROOT files together to make plots. This may take a few minuites..."
echo ""
hadd -k -f -j 16 $OUT_DIR/${concat_rootfilename} $OUT_DIR/${fname_prefix}_fullreplay_allGEMs_${runnum}_seg*.root


## Making Panguin plots ##
module purge
module load panguin
export PANGUIN_CONFIG_PATH=$SBS_REPLAY/onlineGUIconfig:$SBS_REPLAY/onlineGUIconfig/scripts

# Where are the replayed ROOT files located?
ROOT_DIR=$OUT_DIR

# What is the ROOT file to make plots from?
ROOTFILE=$ROOT_DIR/${concat_rootfilename}

panguin -f sbs_gem_gepFT.cfg -r $runnum -R $ROOTFILE
panguin -f sbs_gem_basic_gepFT.cfg -r $runnum -R $ROOTFILE

panguin -f sbs_gem_gepFPP.cfg -r $runnum -R $ROOTFILE
panguin -f sbs_gem_basic_gepFPP.cfg -r $runnum -R $ROOTFILE

panguin -f sbs_gem_gepFT.cfg -r $runnum -R $ROOTFILE -P
panguin -f sbs_gem_basic_gepFT.cfg -r $runnum -R $ROOTFILE -P

panguin -f sbs_gem_gepFPP.cfg -r $runnum -R $ROOTFILE -P
panguin -f sbs_gem_basic_gepFPP.cfg -r $runnum -R $ROOTFILE -P

PLOTS_DIR=/chafs2/work1/sbs/plots/

mv summaryPlots_${runnum}_sbs_gem_gepFT.pdf $PLOTS_DIR
mv summaryPlots_${runnum}_sbs_gem_basic_gepFT.pdf $PLOTS_DIR
mv summaryPlots_${runnum}_sbs_gem_gepFPP.pdf $PLOTS_DIR
mv summaryPlots_${runnum}_sbs_gem_basic_gepFPP.pdf $PLOTS_DIR

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