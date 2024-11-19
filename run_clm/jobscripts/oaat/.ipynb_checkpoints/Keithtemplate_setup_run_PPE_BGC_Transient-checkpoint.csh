#!/bin/csh -xv

#==============USER MODS=======================================
set tag = PPE.n11_ctsm5.1.dev030_djk2120
set dir_tag = /glade/work/oleson/
set case = ctsm51c8BGC_PPEn11ctsm51d030_2deg_GSWP3V1_Sparse400
#set case = ctsm51c8BGC_PPEn11ctsm51d030_2deg_GSWP3V1_Sparse400_part1
set chargenum = P93300041

set do_AD = 1
set do_step3 = 0
set do_step4 = 0
set do_prod = 0

set scenarios = ( Control )

#==============END USER MODS===================================

set cyear = 1850

# Loop over scenarios
foreach scenario ( $scenarios )

#==============================================================
# AD case setup and run
#==============================================================
 
if ($do_AD == 1) then

set suff = _{$scenario}_{$cyear}AD

cd {$dir_tag}{$tag}/cime/scripts
if (-d {$case}{$suff}) then
  rm -r -f {$case}{$suff}
endif
if (-d /glade/scratch/oleson/{$case}{$suff}) then
  rm -r -f /glade/scratch/oleson/{$case}{$suff}
endif
./create_newcase --case {$case}{$suff} --compset 1850_DATM%GSWP3v1_CLM51%BGC_SICE_SOCN_SROF_SGLC_SWAV_SIAC_SESP --res f19_g17 --project $chargenum --run-unsupported
cd {$case}{$suff}
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_datm.streams.txt.CLMGSWP3v1.Precip .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_datm.streams.txt.CLMGSWP3v1.Solar .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_datm.streams.txt.CLMGSWP3v1.TPQW .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_nl_datm .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/AD/user_nl_clm .

# env_run.xml
./xmlchange RUN_STARTDATE=0001-01-01
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=20
#./xmlchange STOP_N=1
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange ATM_DOMAIN_PATH=/glade/p/cgd/tss/people/oleson/modify_domain
./xmlchange LND_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange LND_DOMAIN_PATH=/glade/p/cgd/tss/people/oleson/modify_domain
./xmlchange DATM_CLMNCEP_YR_ALIGN=1
./xmlchange DATM_CLMNCEP_YR_START=1901
./xmlchange DATM_CLMNCEP_YR_END=1920
./xmlchange CLM_BLDNML_OPTS='-bgc bgc -no-megan'
./xmlchange DOUT_S=FALSE
./xmlchange CLM_ACCELERATED_SPINUP=on
# env_mach_pes.xml
./xmlchange NTASKS_CPL=-2
./xmlchange NTASKS_OCN=-2
./xmlchange NTASKS_WAV=-2
./xmlchange NTASKS_GLC=-2
./xmlchange NTASKS_ICE=-2
./xmlchange NTASKS_ROF=-2
./xmlchange NTASKS_LND=-2
# env_workflow.xml
./xmlchange JOB_WALLCLOCK_TIME=02:00:00 --subgroup case.run
./xmlchange JOB_QUEUE=economy --subgroup case.run

# Setup case
./case.setup

# Generate namelists
./preview_namelists

# Build case
qcmd -- ./case.build

# Submit case
./case.submit

endif
#==============================================================

#==============================================================
# Step 3 (sasu) case setup and run
#==============================================================

if ($do_step3 == 1) then

set suff = _{$scenario}_{$cyear}_step3

cd {$dir_tag}{$tag}/cime/scripts
if (-d {$case}{$suff}) then
  rm -r -f {$case}{$suff}
endif
if (-d /glade/scratch/oleson/{$case}{$suff}) then
  rm -r -f /glade/scratch/oleson/{$case}{$suff}
endif
./create_newcase --case {$case}{$suff} --compset 1850_DATM%GSWP3v1_CLM51%BGC_SICE_SOCN_SROF_SGLC_SWAV_SIAC_SESP --res f19_g17 --project $chargenum --run-unsupported
cd {$case}{$suff}
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_datm.streams.txt.CLMGSWP3v1.Precip .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_datm.streams.txt.CLMGSWP3v1.Solar .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_datm.streams.txt.CLMGSWP3v1.TPQW .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_nl_datm .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/_step3/user_nl_clm .
set finidat=`ls -1 /glade/scratch/oleson/{$case}_{$scenario}_{$cyear}AD/run/{$case}_{$scenario}_{$cyear}AD.clm?.r.*.nc | tail -1`
echo $finidat
echo " finidat = '$finidat'" >> user_nl_clm
# env_run.xml
./xmlchange RUN_STARTDATE=0001-01-01
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=80
#./xmlchange STOP_N=1
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange ATM_DOMAIN_PATH=/glade/p/cgd/tss/people/oleson/modify_domain
./xmlchange LND_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange LND_DOMAIN_PATH=/glade/p/cgd/tss/people/oleson/modify_domain
./xmlchange DATM_CLMNCEP_YR_ALIGN=1
./xmlchange DATM_CLMNCEP_YR_START=1901
./xmlchange DATM_CLMNCEP_YR_END=1920
./xmlchange CLM_BLDNML_OPTS='-bgc bgc -no-megan'
./xmlchange DOUT_S=FALSE
./xmlchange CLM_ACCELERATED_SPINUP=sasu
# env_mach_pes.xml
./xmlchange NTASKS_CPL=-2
./xmlchange NTASKS_OCN=-2
./xmlchange NTASKS_WAV=-2
./xmlchange NTASKS_GLC=-2
./xmlchange NTASKS_ICE=-2
./xmlchange NTASKS_ROF=-2
./xmlchange NTASKS_LND=-2
#env_workflow.xml
./xmlchange JOB_WALLCLOCK_TIME=06:00:00 --subgroup case.run
./xmlchange JOB_QUEUE=economy --subgroup case.run

./case.setup

./preview_namelists

qcmd -- ./case.build

# Submit case
./case.submit

endif

#=================================================================

#==============================================================
# Step 4 (post-sasu-spinup) case setup and run
#==============================================================

if ($do_step4 == 1) then

set suff = _{$scenario}_{$cyear}_step4

cd {$dir_tag}{$tag}/cime/scripts
if (-d {$case}{$suff}) then
  rm -r -f {$case}{$suff}
endif
if (-d /glade/scratch/oleson/{$case}{$suff}) then
  rm -r -f /glade/scratch/oleson/{$case}{$suff}
endif
./create_newcase --case {$case}{$suff} --compset 1850_DATM%GSWP3v1_CLM51%BGC_SICE_SOCN_SROF_SGLC_SWAV_SIAC_SESP --res f19_g17 --project $chargenum --run-unsupported
cd {$case}{$suff}
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_datm.streams.txt.CLMGSWP3v1.Precip .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_datm.streams.txt.CLMGSWP3v1.Solar .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_datm.streams.txt.CLMGSWP3v1.TPQW .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_nl_datm .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/_step4/user_nl_clm .
set finidat=`ls -1 /glade/scratch/oleson/{$case}_{$scenario}_{$cyear}_step3/run/{$case}_{$scenario}_{$cyear}_step3.clm?.r.*.nc | tail -1`
echo $finidat
echo " finidat = '$finidat'" >> user_nl_clm
# env_run.xml
./xmlchange RUN_STARTDATE=0001-01-01
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=40
#./xmlchange STOP_N=1
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange ATM_DOMAIN_PATH=/glade/p/cgd/tss/people/oleson/modify_domain
./xmlchange LND_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange LND_DOMAIN_PATH=/glade/p/cgd/tss/people/oleson/modify_domain
./xmlchange DATM_CLMNCEP_YR_ALIGN=1
./xmlchange DATM_CLMNCEP_YR_START=1901
./xmlchange DATM_CLMNCEP_YR_END=1920
./xmlchange CLM_BLDNML_OPTS='-bgc bgc -no-megan'
./xmlchange DOUT_S=FALSE
./xmlchange CLM_ACCELERATED_SPINUP=off
# env_mach_pes.xml
./xmlchange NTASKS_CPL=-2
./xmlchange NTASKS_OCN=-2
./xmlchange NTASKS_WAV=-2
./xmlchange NTASKS_GLC=-2
./xmlchange NTASKS_ICE=-2
./xmlchange NTASKS_ROF=-2
./xmlchange NTASKS_LND=-2
#env_workflow.xml
./xmlchange JOB_WALLCLOCK_TIME=03:00:00 --subgroup case.run
./xmlchange JOB_QUEUE=economy --subgroup case.run

./case.setup

./preview_namelists

qcmd -- ./case.build

# Submit case
./case.submit

endif

#=================================================================

#==============================================================
# Production case setup and run
#==============================================================

if ($do_prod == 1) then

set suff = _{$scenario}_hist

cd {$dir_tag}{$tag}/cime/scripts
echo {$case}{$suff}
if (-d {$case}{$suff}) then
  rm -r -f {$case}{$suff}
endif
if (-d /glade/scratch/oleson/{$case}{$suff}) then
  rm -r -f /glade/scratch/oleson/{$case}{$suff}
endif
./create_newcase --case {$case}{$suff} --compset HIST_DATM%GSWP3v1_CLM51%BGC_SICE_SOCN_SROF_SGLC_SWAV_SIAC_SESP --res f19_g17 --project $chargenum --run-unsupported
cd {$case}{$suff}
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_nl_datm1901-1920 .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/user_nl_datm1901-2014 .
cp /glade/u/home/oleson/run_hist_1850_files/BGC/original_user_nl_clm_nocrop_ctsm ./original_user_nl_clm
cp /glade/u/home/oleson/run_hist_1850_files/BGC/user_nl_clm_histdaily_ctsm ./user_nl_clm_histdaily
cp /glade/u/home/oleson/run_hist_1850_files/BGC/user_nl_clm_histsubdaily_ctsm ./user_nl_clm_histsubdaily
cp /glade/u/home/oleson/run_hist_1850_files/BGC/run_clm_historical.v7.csh .
cp /glade/work/oleson/PPE/casefiles/Transient/{$scenario}/prod/user_nl_clm .
# NOTE this is hardcoded for now because of the existence of two transients (part 1 for Daniel and the full transient, so I can't use
# the case environment variable)
set finidat=`ls -1 /glade/scratch/oleson/ctsm51c8BGC_PPEn11ctsm51d030_2deg_GSWP3V1_Sparse400_Control_1850_step4/run/ctsm51c8BGC_PPEn11ctsm51d030_2deg_GSWP3V1_Sparse400_Control_1850_step4.clm?.r.*.nc | tail -1`
echo $finidat
echo " finidat = '$finidat'" >> original_user_nl_clm
# env_run.xml
./xmlchange DIN_LOC_ROOT_CLMFORC=/glade/scratch/oleson
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange ATM_DOMAIN_PATH=/glade/p/cgd/tss/people/oleson/modify_domain
./xmlchange LND_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange LND_DOMAIN_PATH=/glade/p/cgd/tss/people/oleson/modify_domain
./xmlchange CLM_BLDNML_OPTS='-bgc bgc -no-megan'
./xmlchange DOUT_S=TRUE
./xmlchange CLM_ACCELERATED_SPINUP=off
# env_mach_pes.xml
./xmlchange NTASKS_CPL=-2
./xmlchange NTASKS_OCN=-2
./xmlchange NTASKS_WAV=-2
./xmlchange NTASKS_GLC=-2
./xmlchange NTASKS_ICE=-2
./xmlchange NTASKS_ROF=-2
./xmlchange NTASKS_LND=-2
#env_workflow.xml
./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run
./xmlchange JOB_QUEUE=economy --subgroup case.run

./case.setup

./preview_namelists

# At this point, the run_clm_historical.v7.csh script should be run after first modifying the "CASENAME"
# in that script. The case build and case submit is implemented in that script.
# ./run_clm_historical.v7.csh >&! run_clm_historical.v7.out &

endif

end

#=================================================================
