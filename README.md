The purpose of the **GEpGEM-onl** repository is to provide tools to do GEM specific online replay for the GEp experiment using the Hall-A `aonlx` machines, in a user-friendly and streamlined manner. In addition to doing replay, it also does things such as making Panguin plots, making HALOG entries from Panguin plots, and moving pedestal, CM, and alignment information files to relevant directories after the replay (the functionality for merging the ped and CM files from the two trackers and sending them to the VTPs is to be included). 
If you want to do analysis on the data that has already been moved to `\cache` or `\mss`, using either ifarm or batch farm is preferred. The [jlab-HPC](https://github.com/provakar1994/jlab-HPC.git) machinery will be updated soon for that purpose. 

By typing `gogem` in `a-onl@aonlx` terminals, you will be brought to the **GEpGEM-onl** directory: `/adaqfs/home/a-onl/sbs/GEM_replay/GEpGEM-onl`. It will also give you a welcome message and source the `setenv.sh` script to set the necessary enviroment variables.

## 1. Design
These shell scripts are intended to be run directly on the terminal and no user changes/modifications should be needed within these scripts for normal functioning. The shell scripts that the user will directly run to do analysis all begins with the word "analyze". For example, if you want to replay cosmic data from run no 123 that includes both the FT and FPP, and you want to do tracking analysis for both of them, you simply type `$./analyze-allgem-cosmics 123 <DAQ_type>`. With <DAQ_type> being 1 for data from the main DAQ and 2 for data from the stand-alone DAQ. The shell scripts that begins with the word "run" are being called by the "analyze" shell scripts and the user should not have to run the "run" shell scripts as by design of this repository. The replay scripts relevant to GEM analysis in `$SBS_REPLAY/replay` are called within the "run" shell scripts.

## 2. Scripts included
The following scripts and sub repositories are included.
1. `setenv.sh`: The necessary environment variables are all set inside this script. Unless you want change something such as the `SBS_OFFLINE` build and `SBS_REPLAY`, everything is aleady set here approprately. As you can see, right now, we are pointing to a local `SBS_OFFLINE` and `SBS_REPLAY`. 
2. `run-FTgem-replay.sh`: This script will run the `$SBS_REPLAY/replay/replay_gep_FTGEM.C` replay script.
3. `run-FPPgem-replay.sh`: This script will run the `$SBS_REPLAY/replay/replay_gep_FPPGEM.C` replay script. 
4. `run-allgem-replay.sh`: This script will run the `$SBS_REPLAY/replay/replay_gep_allGEM.C` replay script.
5. `analyze-FTgem-pedestal.sh`: This script will analyze 5K events of pedestal data from a give pedestal run, for the FT.
6. `analyze-FPPgem-pedestal.sh`: This script will analyze 5K events of pedestal data from a give pedestal run, for the FPP.
7. `analyze-allgem-pedestal.sh`: This script will analyze 5K events of pedestal data from a given pedestal run, for both FT and FPP. It will call `run-allgem-replay.sh` and therefore will be using the `$SBS_REPLAY/replay/replay_gep_allGEM.C` script which does the FT and FPP analysis as single analysis job whic leads to a slower processing time.
8. `analyze-allgem-pedestal-parallel.sh`: This script will analyze 5K events of pedestal data from a given pedestal run, for both FT and FPP. It will call `run-FTgem-replay.sh` and `run-FPPgem-replay.sh`, in two parallel jobs. This leads to a faster processing time and recommended over `analyze-allgem-pedestal.sh`.
9. `analyze-FTgem-cosmics.sh`: Perform FT only cosmic tracking analysis.
10. `analyze-FPPgem-cosmics.sh`: Perform FPP only cosmic tracking analysis.
11. `analyze-allgem-cosmics.sh`: Perform FT and FPP cosmic tracking analysis. Tracking is still being performed separately for the FT and FPP (just like it will be during the experiment).

## 3. Analyzing pedestal data
Follow the following steps to analyze 5K events of pedestal data, generate the plots, copy pedestal and CM files into `$SBS_REPLAY/DB/gemped` and also to the VTP config (this part is commented out right now).
1. Run `$ analyze-allgem-pedestal-parallel.sh <CODA_runnum> <DAQ_type>`. This will analyze 5K events from the specified CODA run. For `<DAQ_type>` input 1 for maing DAQ runs and 2 for stand-alone DAQ runs.
2. Panguin  plots will be generated and saved to `/chafs2/work1/sbs/plots/`
3. User is prompted to decide whether or not to move the pedestal and CM files to the `$SBS_OFFLINE/DB/gemped` and the VTP config files.

## 4. Analysing a cosmic run
1. Run `$ analyze-allgem-cosmics.sh <CODA runnum> <DAQ_type>`. For `<DAQ_type>` input 1 for maing DAQ runs and 2 for stand-alone DAQ runs.
2. First it will check whether the CODA run exists within the specified data directories (`$OUT_DIR`) in the `setenv.sh` script. 
3. If yes, it will ask how many parallel jobs you would like to run. More parallel jobs you run, the faster your analysis will be. 
4. Once the analysis is complete, the replayed ROOT files from the individual jobs will be added together to make a single ROOT file to make the plots.
5. Panguin  plots are generated and saved to `/chafs2/work1/sbs/plots/`

## 5. Questions or comments?
Please reach out to Anuruddha Rathanayake.