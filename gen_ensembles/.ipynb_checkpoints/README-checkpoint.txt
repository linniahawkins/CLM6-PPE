# So you want to run a PPE? This is a good place to start.
# Daniel Kennedy developed this workflow: see Kennedy et al., 2024; JAMES 
# But you can blame Linnia for anything that doesn't work, she hacked it up. 
## LH3194@columbia.edu

----------------------------------------------------------------------------------------
######## Set up CLM ############

Step 0: First you'll need to checkout the codebase.
You can use this script to clone the branch of CLM you want to work with 

    # change the paths then run
    $ bash CLM6-PPE/run_clm/jobscripts/step0.startup.sh

Step 1: Next you will need to set up basecases. 
There are four stages to the spinup protocol:
AD: accelerated Decomposition (20 years)
SASU: this uses MatrixCN (80 years)
postSASU: 40 more 'regular' years
Transient: 1850-2022 

You will need a basecase for each stage. 
You only have to do this once. All other PPE simulations will clone these basecases. 

    # change the paths then (on derecho) run:
    $ bash step1.setup_basecases.sh 

Note: run step1.setup_basecases.sh one for each stage (changing flag) and wait for each stage to finish before moving to next stage. Do not run the transient case, just build.
----------------------------------------------------------------------------------------
######### Create parameter files ##############

The CLM5 parameter masterlist with plausible ranges is here:
https://docs.google.com/spreadsheets/d/1kY9Cl0c3KuZb4LayHvrEcJCy0hz5XJ_EweKSUickOwM/edit?usp=drive_link

ctsm6 one-at-a-time ensemble: https://docs.google.com/spreadsheets/d/1R0AybNR0YAmMDjRqp9oyUffDhKeAWv1QF4yWTHqiXXM/edit?usp=drive_link

Option 1: don't overcomplicate things, just create a file like a file like ctsm6oaat_extras.txt and use the generate_paramfiles_simple.ipynb script.  

Option 2: get fancy! create your own file like the ctsm6oaat_paramranges_10252024.csv file and use the generate_paramfiles_oaat.ipynb


Latin hypercube ensemble: https://docs.google.com/spreadsheets/d/1_LkI00s2-V1hg0KbFLrhH3vTDjasNHK3aZkzv_vFd74/edit?usp=sharing 


Option 1: uniform PFT parameter perturbations. Some parameters have different default settings for each PFT and/or different ranges. If you want to make a uniform perturbation to all PFT parameters (i.e., scale all PFTs to the 90th percentile of the range) then use:

    generate_paramfiles_uniformPFT.ipynb

Option 2: independent PFT parameter perturbations. 



----------------------------------------------------------------------------------------
######### Run CLM PPE ensemble members ##############

Spinup:
AD: 20 years with accelerated decomposition
SASU: 80 years with Matrix CN
postSASU: 40 years regular

Simulation:
The simulation is performed in four segments: 
1850-1901: recycle 1901-1920 climate
1901-2001: transient climate
1985-2014: add daily history variables
2014-2023: recycle 2014 preso3 and presaero : user_nl_datm_streams_CRUJRA.2015-2023

Tethering: 
too complicated for a README - email us.  

Step 1: setup jobscripts, 
- make a copy of oaat or lhc folder 
- modify your config file 
- change the scratch dir in all the mods files
- make a text file with the key of the simulations you want to run (like oaat.txt)

Step 2: run ensemble (with tethering)
bash run_ens.sh ./oaat/configs/oaat.config &> oaat.out &


