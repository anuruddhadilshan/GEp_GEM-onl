The purpose of the **GEpGEM-onl** repository is to provide tools to do GEM specific online replay for the GEp experiment using the Hall-A `aonlx` machines. If you want to do analysis on the data that has already been moved to `\cache` or `\mss`, using either ifarm or batch farm is preferred. The [jlab-HPC](https://github.com/provakar1994/jlab-HPC.git) machinery will be updated soon for that purpose.

## Status as of 12/6/2024:
For the moment, it only contains shell scripts to run pedestal and cosmic analysis for the front tracker of the GEp hadron arm. In the very near future, we will extend the machinery to be able to analyze the data from the polarimeter tracker, support data from the 3-stream readout, and etc. (What else should we have?)

## 1. Design
The following scripts and sub repositories are included.
1. `setenv.sh`: The necessary environment variables are all set inside this script. Unless you want change something such as the `SBS_OFFLINE` build and `SBS_REPLAY`, everything is aleady set here approprately. As you can see, right now, we are pointing to a local `SBS_OFFLINE` and `SBS_REPLAY`. The reason for this is to allow us to do our own changes without changing the common repositories, especially `SBS_REPLAY` as we are still adding/changing our databases and etc. 
2. `run-FTgem-replay.sh`: This script will run the `SBS_REPLAY` replay script. It is not meant to be run by itself by the user and no user configurable parts exists within it.
3. `analyze-FTgem-pedestal.sh`: This script is run to analyze 5K events of pedestal data from a give pedestal run, for the FT.
4. `analyze-FTgem-cosmics.sh`: This script is run to analyze an entire run cosmic run, for the FT.
5.The local builds of `SBS_OFFLINE` and `SBS_REPLAY` are included for the reasons mentioned in the above step 1.

## 2. Analyzing pedestal data
Follow the following steps to analyze 5K events of pedestal data, generate the plots, copy pedestal and CM files into `$SBS_REPLAY/DB/gemped` and also to the VTP config (this part is commented out right now).
1. Run `$ analyze-FTgem-pedestal.sh <CODA runnum>`. This will analyze 5K events from the specified CODA run.
2. Panguin  plots are generated and saved to `/chafs2/work1/sbs/plots/`
3. User is prompted to decide whether or not to move the pedestal and CM files to the `$SBS_OFFLINE/DB/gemped` and the VTP config files.

## 3. Analysing a cosmic run
1. Run `$ analyze-FTgem-cosmics.sh <CODA runnum>`. 
2. First it will check whether the CODA run exists within the specified data directories (`$OUT_DIR`) in the `setenv.sh` script. 
3. If yes, it will ask how many parallel jobs you would like to run. More parallel jobs you run, the faster your analysis will be. 
4. Once the analysis is complete, the replayed ROOT files from the individual jobs will be added together to make a single ROOT file to make the plots.
5. Panguin  plots are generated and saved to `/chafs2/work1/sbs/plots/`
