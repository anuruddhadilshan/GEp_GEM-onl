#!bin/bash

echo -e "\n"
echo "*** Welcome to the GEp GEM Expert Analysis ***"
echo -e "\n"
echo "You are at: $(pwd)"
echo "Setting path variables for local scripts..."

#module purge
module use /adaqfs/apps/modulefiles
module load analyzer
module load panguin
module list

# Set what SBS-offline installation to use in here.
export SBS=$HOME/sbs/GEM_replay/GEpGEM-onl/SBS-offline/install

source $SBS/bin/sbsenv.sh

# Set what SBS-replay to use in here.
export SBS_REPLAY=$HOME/sbs/GEM_replay/GEpGEM-onl/SBS-replay

export DATA_DIR=/adaqeb1/data1:/cache/halla/sbs/GEnRP/raw
export DB_DIR=$SBS_REPLAY/DB
export OUT_DIR=$HOME/sbs/Rootfiles
export LOG_DIR=/aonl1/work1/logs
export ANALYZER_CONFIGPATH=$SBS_REPLAY/replay


