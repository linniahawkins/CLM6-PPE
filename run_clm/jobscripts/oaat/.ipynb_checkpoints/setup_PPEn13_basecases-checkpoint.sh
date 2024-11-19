#!/bin/bash
# create base cases for PPEn13_ctsm5.1.dev042 

# ===============================================
# setup

tag_dir="/glade/work/linnia/PPEn13trans"
chargenum='P93300041'

source ~/.bashrc

# ==============================================
# Build and run basecases
conda activate runclm

cd ${tag_dir}/cime/scripts/
casedir="/glade/work/linnia/PPEn13trans/cime/scripts/transient/basecases/"
#mkdir $casedir
case="PPEn13_transient"

do_AD=1
do_SASU=0
do_postSASU=0
do_transient=0

# ==============================================
# Setup and run AD spinup
# ==============================================

if [ "$do_AD" -eq 1 ]; then

# create new case
suffix="_AD"

if [ -d "${casedir}${case}${suffix}" ]; then
  rm -r -f "${casedir}${case}${suffix}"
fi
if [ -d "${SCRATCH}${case}${suffix}" ]; then
  rm -r -f "${SCRATCH}${case}${suffix}"
fi

./create_newcase --case ${casedir}${case}${suffix} --compset 1850_DATM%GSWP3v1_CLM51%BGC_SICE_SOCN_SROF_SGLC_SWAV_SIAC_SESP --res f19_g17 --project P93300041 --run-unsupported

cd ${casedir}${case}${suffix}
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_datm.streams.txt.CLMGSWP3v1.Precip .
sed -i 's:/glade/p/cgd/:/glade/campaign/cgd/:g' user_datm.streams.txt.CLMGSWP3v1.Precip
sed -i 's:/glade/scratch/oleson/:/glade/campaign/cgd/tss/projects/PPE/:g' user_datm.streams.txt.CLMGSWP3v1.Precip
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_datm.streams.txt.CLMGSWP3v1.Solar .
sed -i 's:/glade/p/cgd/:/glade/campaign/cgd/:g' user_datm.streams.txt.CLMGSWP3v1.Solar
sed -i 's:/glade/scratch/oleson/:/glade/campaign/cgd/tss/projects/PPE/:g' user_datm.streams.txt.CLMGSWP3v1.Solar
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_datm.streams.txt.CLMGSWP3v1.TPQW .
sed -i 's:/glade/p/cgd/:/glade/campaign/cgd/:g' user_datm.streams.txt.CLMGSWP3v1.TPQW
sed -i 's:/glade/scratch/oleson/:/glade/campaign/cgd/tss/projects/PPE/:g' user_datm.streams.txt.CLMGSWP3v1.TPQW
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_nl_datm .
cp /glade/work/oleson/PPE/casefiles/Transient/Control/AD/user_nl_clm .
#sed -i 's:/glade/p/cgd/tss/people/oleson/CLM5_restarts/:/glade/campaign/cgd/tss/people/oleson/CLM5_restarts/:g' user_nl_clm
finidat='/glade/u/home/djk2120/restarts/PPEn11_transient_postSASU_LHC0000.clm2.r.0041-01-01-00000.nc'
echo $finidat
echo " finidat = '$finidat'" >> user_nl_clm

# env_run.xml
./xmlchange RUN_STARTDATE=0001-01-01
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=20
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange ATM_DOMAIN_PATH=/glade/campaign/cgd/tss/people/oleson/modify_domain
./xmlchange LND_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange LND_DOMAIN_PATH=/glade/campaign/cgd/tss/people/oleson/modify_domain
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
./xmlchange JOB_PRIORITY=economy --subgroup case.run

./case.setup

# Generate namelists
./preview_namelists

# Build case
qcmd -A ${chargenum} -- ./case.build

# Submit case
./case.submit

fi

# ==============================================
# Setup and run SASU
# ==============================================

if [ "$do_SASU" -eq 1 ]; then

# create new case
suffix="_SASU"

if [ -d "${casedir}${case}${suffix}" ]; then
  rm -r -f "${casedir}${case}${suffix}"
fi
if [ -d "${SCRATCH}${case}${suffix}" ]; then
  rm -r -f "${SCRATCH}${case}${suffix}"
fi

./create_newcase --case ${casedir}${case}${suffix} --compset 1850_DATM%GSWP3v1_CLM51%BGC_SICE_SOCN_SROF_SGLC_SWAV_SIAC_SESP --res f19_g17 --project P93300041 --run-unsupported

cd ${casedir}${case}${suffix}
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_datm.streams.txt.CLMGSWP3v1.Precip .
sed -i 's:/glade/p/cgd/:/glade/campaign/cgd/:g' user_datm.streams.txt.CLMGSWP3v1.Precip
sed -i 's:/glade/scratch/oleson/:/glade/campaign/cgd/tss/projects/PPE/:g' user_datm.streams.txt.CLMGSWP3v1.Precip
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_datm.streams.txt.CLMGSWP3v1.Solar .
sed -i 's:/glade/p/cgd/:/glade/campaign/cgd/:g' user_datm.streams.txt.CLMGSWP3v1.Solar
sed -i 's:/glade/scratch/oleson/:/glade/campaign/cgd/tss/projects/PPE/:g' user_datm.streams.txt.CLMGSWP3v1.Solar
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_datm.streams.txt.CLMGSWP3v1.TPQW .
sed -i 's:/glade/p/cgd/:/glade/campaign/cgd/:g' user_datm.streams.txt.CLMGSWP3v1.TPQW
sed -i 's:/glade/scratch/oleson/:/glade/campaign/cgd/tss/projects/PPE/:g' user_datm.streams.txt.CLMGSWP3v1.TPQW
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_nl_datm .
cp /glade/work/oleson/PPE/casefiles/Transient/Control/_step3/user_nl_clm .
finidat=`ls -1 ${SCRATCH}/${case}_AD/run/${case}_AD.clm?.r.*.nc | tail -1`
echo $finidat
echo " finidat = '$finidat'" >> user_nl_clm

# env_run.xml
./xmlchange RUN_STARTDATE=0001-01-01
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=80
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange ATM_DOMAIN_PATH=/glade/campaign/cgd/tss/people/oleson/modify_domain
./xmlchange LND_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange LND_DOMAIN_PATH=/glade/campaign/cgd/tss/people/oleson/modify_domain
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
./xmlchange JOB_PRIORITY=economy --subgroup case.run

./case.setup

./preview_namelists

qcmd -A ${chargenum} -- ./case.build

# Submit case
#./case.submit

fi

# ==============================================
# Setup and run postSASU
# ==============================================

if [ "$do_postSASU" -eq 1 ]; then

# create new case
suffix="_postSASU"

if [ -d "${casedir}${case}${suffix}" ]; then
  rm -r -f "${casedir}${case}${suffix}"
fi
if [ -d "${SCRATCH}${case}${suffix}" ]; then
  rm -r -f "${SCRATCH}${case}${suffix}"
fi

./create_newcase --case ${casedir}${case}${suffix} --compset 1850_DATM%GSWP3v1_CLM51%BGC_SICE_SOCN_SROF_SGLC_SWAV_SIAC_SESP --res f19_g17 --project P93300041 --run-unsupported

cd ${casedir}${case}${suffix}
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_datm.streams.txt.CLMGSWP3v1.Precip .
sed -i 's:/glade/p/cgd/:/glade/campaign/cgd/:g' user_datm.streams.txt.CLMGSWP3v1.Precip
sed -i 's:/glade/scratch/oleson/:/glade/campaign/cgd/tss/projects/PPE/:g' user_datm.streams.txt.CLMGSWP3v1.Precip
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_datm.streams.txt.CLMGSWP3v1.Solar .
sed -i 's:/glade/p/cgd/:/glade/campaign/cgd/:g' user_datm.streams.txt.CLMGSWP3v1.Solar
sed -i 's:/glade/scratch/oleson/:/glade/campaign/cgd/tss/projects/PPE/:g' user_datm.streams.txt.CLMGSWP3v1.Solar
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_datm.streams.txt.CLMGSWP3v1.TPQW .
sed -i 's:/glade/p/cgd/:/glade/campaign/cgd/:g' user_datm.streams.txt.CLMGSWP3v1.TPQW
sed -i 's:/glade/scratch/oleson/:/glade/campaign/cgd/tss/projects/PPE/:g' user_datm.streams.txt.CLMGSWP3v1.TPQW
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_nl_datm .
cp /glade/work/oleson/PPE/casefiles/Transient/Control/_step4/user_nl_clm .
finidat=`ls -1 ${SCRATCH}/${case}_SASU/run/${case}_SASU.clm?.r.*.nc | tail -1`
echo $finidat
echo " finidat = '$finidat'" >> user_nl_clm

# env_run.xml
./xmlchange RUN_STARTDATE=0001-01-01
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=40
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange ATM_DOMAIN_PATH=/glade/campaign/cgd/tss/people/oleson/modify_domain
./xmlchange LND_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange LND_DOMAIN_PATH=/glade/campaign/cgd/tss/people/oleson/modify_domain
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
./xmlchange JOB_PRIORITY=economy --subgroup case.run

./case.setup

./preview_namelists

qcmd -A ${chargenum} -- ./case.build

# Submit case
#./case.submit

fi


# ==============================================
# Setup and run Transient
# ==============================================

if [ "$do_transient" -eq 1 ]; then

# create new case
if [ -d "${casedir}${case}$" ]; then
  rm -r -f "${casedir}${case}"
fi
#if [ -d "${SCRATCH}${case}" ]; then
#  rm -r -f "${SCRATCH}${case}"
#fi

./create_newcase --case ${casedir}${case} --compset HIST_DATM%GSWP3v1_CLM51%BGC_SICE_SOCN_SROF_SGLC_SWAV_SIAC_SESP --res f19_g17 --project $chargenum --run-unsupported

cd ${casedir}${case}
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_nl_datm1901-1920 .
cp /glade/work/oleson/PPE/casefiles/Transient/Control/user_nl_datm1901-2014 .
cp /glade/u/home/oleson/run_hist_1850_files/BGC/original_user_nl_clm_nocrop_ctsm ./original_user_nl_clm
cp /glade/u/home/oleson/run_hist_1850_files/BGC/user_nl_clm_histdaily_ctsm ./user_nl_clm_histdaily
cp /glade/u/home/oleson/run_hist_1850_files/BGC/user_nl_clm_histsubdaily_ctsm ./user_nl_clm_histsubdaily
# probably need to make some changes to this file: 
cp /glade/u/home/oleson/run_hist_1850_files/BGC/run_clm_historical.v7.csh .
cp /glade/work/oleson/PPE/casefiles/Transient/Control/prod/user_nl_clm .

cp user_nl_datm1901-1920 user_nl_datm
finidat=`ls -1 ${SCRATCH}/${case}_postSASU/run/${case}_postSASU.clm?.r.*.nc | tail -1`
echo $finidat
echo " finidat = '$finidat'" >> original_user_nl_clm

# env_run.xml
./xmlchange DIN_LOC_ROOT_CLMFORC='/glade/campaign/cgd/tss/projects/PPE'
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange ATM_DOMAIN_PATH=/glade/campaign/cgd/tss/people/oleson/modify_domain
./xmlchange LND_DOMAIN_FILE=domain.lnd.fv1.9x2.5_gx1v7.181205v4.sparse400.nc
./xmlchange LND_DOMAIN_PATH=/glade/campaign/cgd/tss/people/oleson/modify_domain
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
./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run
./xmlchange JOB_PRIORITY=economy --subgroup case.run

./case.setup

./preview_namelists

qcmd -A ${chargenum} -- ./case.build

# Do not submit this case as is.
# At this point, run_ens.sh script should be run with a config file.
# clm5ppe/jobscripts/run_ens.sh
# ./run_ens.sh *.config >& tmp.out &

fi

