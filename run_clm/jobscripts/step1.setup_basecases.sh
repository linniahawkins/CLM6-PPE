#!/bin/bash
# create base cases for ctsm5.2.027 

# ===============================================
# setup

tag_dir="/glade/work/linnia/ctsm5.2.027"
chargenum='P08010000'

source ~/.bashrc

user_mods_dir='/glade/u/home/linnia/CLM6-PPE/run_clm/jobscripts/user_mods'
mesh_file=${user_mods_dir}/lnd_mesh.nc

# ==============================================
# Build and run basecases
conda activate runclm

cd ${tag_dir}/cime/scripts/
casedir="/glade/work/linnia/ctsm5.2.027/cime/scripts/transient/basecases/"
case="ctsm5.2.027_transient"

do_AD=1
do_SASU=0
do_postSASU=0
do_transient=0

# ==============================================
# Setup and run AD spinup
# ==============================================

if [ "$do_AD" -eq 1 ]; then

# create new case
mkdir $casedir
suffix="_AD"

if [ -d "${casedir}${case}${suffix}" ]; then
  rm -r -f "${casedir}${case}${suffix}"
fi
if [ -d "${SCRATCH}${case}${suffix}" ]; then
  rm -r -f "${SCRATCH}${case}${suffix}"
fi

./create_newcase --case ${casedir}${case}${suffix} --compset 1850_DATM%CRUv7_CLM60%BGC_SICE_SOCN_SROF_SGLC_SWAV_SESP --res f19_g17 --project ${chargenum} --run-unsupported

cd ${casedir}${case}${suffix}

cp ${user_mods_dir}/user_nl_datm_streams .
cp ${user_mods_dir}/user_nl_clm_AD ./user_nl_clm


finidat='/glade/derecho/scratch/slevis/ctsm52026_f09_pSASU/run/ctsm52026_f09_pSASU.clm2.r.0421-01-01-00000.nc'
echo $finidat
echo "finidat = '$finidat'" >> user_nl_clm

# env_run.xml
./xmlchange RUN_STARTDATE=0001-01-01
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=20
./xmlchange MASK_MESH=${mesh_file}
./xmlchange ATM_DOMAIN_MESH=${mesh_file}
./xmlchange LND_DOMAIN_MESH=${mesh_file}
./xmlchange DATM_YR_ALIGN=1
./xmlchange DATM_YR_START=1901
./xmlchange DATM_YR_END=1920
./xmlchange CLM_BLDNML_OPTS='-bgc bgc -no-megan'
./xmlchange DOUT_S=FALSE
./xmlchange CLM_ACCELERATED_SPINUP=on
# env_mach_pes.xml
./xmlchange NTASKS_OCN=112
./xmlchange NTASKS_WAV=112
./xmlchange NTASKS_GLC=112
./xmlchange NTASKS_ICE=112
./xmlchange NTASKS_ROF=112
./xmlchange ROOTPE_LND=16
./xmlchange ROOTPE_OCN=16
./xmlchange ROOTPE_WAV=16
./xmlchange ROOTPE_GLC=16
./xmlchange ROOTPE_ICE=16
./xmlchange ROOTPE_ROF=16
./xmlchange ROOTPE_ATM=0
./xmlchange ROOTPE_CPL=16
./xmlchange NTASKS_LND=112
./xmlchange NTASKS_ATM=16
./xmlchange NTASKS_CPL=112
# env_workflow.xml
./xmlchange JOB_WALLCLOCK_TIME=04:00:00
./xmlchange JOB_PRIORITY=economy

# change paramfile
#paramfile='/glade/u/home/linnia/clm5ppe/jobscripts/PPEn14/LHC0000.nc'
#echo $paramfile
#echo "paramfile = '$paramfile'" >> user_nl_clm

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

./create_newcase --case ${casedir}${case}${suffix} --compset 1850_DATM%CRUv7_CLM60%BGC_SICE_SOCN_SROF_SGLC_SWAV_SESP --res f19_g17 --project ${chargenum} --run-unsupported

cd ${casedir}${case}${suffix}

cp ${user_mods_dir}/user_nl_datm_streams .
cp ${user_mods_dir}/user_nl_clm_SASU ./user_nl_clm

finidat=`ls -1 ${SCRATCH}/${case}_AD/run/${case}_AD.clm?.r.*.nc | tail -1`
echo $finidat
echo " finidat = '$finidat'" >> user_nl_clm

# env_run.xml
./xmlchange RUN_STARTDATE=0001-01-01
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=80
./xmlchange MASK_MESH=${mesh_file}
./xmlchange ATM_DOMAIN_MESH=${mesh_file}
./xmlchange LND_DOMAIN_MESH=${mesh_file}
./xmlchange DATM_YR_ALIGN=1
./xmlchange DATM_YR_START=1901
./xmlchange DATM_YR_END=1920
./xmlchange CLM_BLDNML_OPTS='-bgc bgc -no-megan'
./xmlchange DOUT_S=FALSE
./xmlchange CLM_ACCELERATED_SPINUP=sasu
# env_mach_pes.xml
./xmlchange NTASKS_OCN=112
./xmlchange NTASKS_WAV=112
./xmlchange NTASKS_GLC=112
./xmlchange NTASKS_ICE=112
./xmlchange NTASKS_ROF=112
./xmlchange ROOTPE_LND=16
./xmlchange ROOTPE_OCN=16
./xmlchange ROOTPE_WAV=16
./xmlchange ROOTPE_GLC=16
./xmlchange ROOTPE_ICE=16
./xmlchange ROOTPE_ROF=16
./xmlchange ROOTPE_ATM=0
./xmlchange ROOTPE_CPL=16
./xmlchange NTASKS_LND=112
./xmlchange NTASKS_ATM=16
./xmlchange NTASKS_CPL=112
#env_workflow.xml
./xmlchange JOB_WALLCLOCK_TIME=12:00:00
./xmlchange JOB_PRIORITY=economy

# change paramfile
#paramfile='/glade/u/home/linnia/clm5ppe/jobscripts/PPEn14/LHC0000.nc'
#echo $paramfile
#echo "paramfile = '$paramfile'" >> user_nl_clm

./case.setup

./preview_namelists

qcmd -A ${chargenum} -- ./case.build

# Submit case
./case.submit

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

./create_newcase --case ${casedir}${case}${suffix} --compset 1850_DATM%CRUv7_CLM60%BGC_SICE_SOCN_SROF_SGLC_SWAV_SESP --res f19_g17 --project ${chargenum} --run-unsupported

cd ${casedir}${case}${suffix}

cp ${user_mods_dir}/user_nl_datm_streams .
cp ${user_mods_dir}/user_nl_clm_postSASU ./user_nl_clm

finidat=`ls -1 ${SCRATCH}/${case}_SASU/run/${case}_SASU.clm?.r.*.nc | tail -1`
echo $finidat
echo " finidat = '$finidat'" >> user_nl_clm

# env_run.xml
./xmlchange RUN_STARTDATE=0001-01-01
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=40
./xmlchange MASK_MESH=${mesh_file}
./xmlchange ATM_DOMAIN_MESH=${mesh_file}
./xmlchange LND_DOMAIN_MESH=${mesh_file}
./xmlchange DATM_YR_ALIGN=1
./xmlchange DATM_YR_START=1901
./xmlchange DATM_YR_END=1920
./xmlchange CLM_BLDNML_OPTS='-bgc bgc -no-megan'
./xmlchange DOUT_S=FALSE
./xmlchange CLM_ACCELERATED_SPINUP=off
# env_mach_pes.xml
./xmlchange NTASKS_OCN=112
./xmlchange NTASKS_WAV=112
./xmlchange NTASKS_GLC=112
./xmlchange NTASKS_ICE=112
./xmlchange NTASKS_ROF=112
./xmlchange ROOTPE_LND=16
./xmlchange ROOTPE_OCN=16
./xmlchange ROOTPE_WAV=16
./xmlchange ROOTPE_GLC=16
./xmlchange ROOTPE_ICE=16
./xmlchange ROOTPE_ROF=16
./xmlchange ROOTPE_ATM=0
./xmlchange ROOTPE_CPL=16
./xmlchange NTASKS_LND=112
./xmlchange NTASKS_ATM=16
./xmlchange NTASKS_CPL=112
#env_workflow.xml
./xmlchange JOB_WALLCLOCK_TIME=06:00:00
./xmlchange JOB_PRIORITY=economy

# change paramfile
#paramfile='/glade/u/home/linnia/clm5ppe/jobscripts/PPEn14/LHC0000.nc'
#echo $paramfile
#echo "paramfile = '$paramfile'" >> user_nl_clm

./case.setup

./preview_namelists

qcmd -A ${chargenum} -- ./case.build

# Submit case
./case.submit

fi


# ==============================================
# Setup Transient (don't run)
# ==============================================

if [ "$do_transient" -eq 1 ]; then

# create new case
if [ -d "${casedir}${case}$" ]; then
  rm -r -f "${casedir}${case}"
fi
if [ -d "${SCRATCH}${case}" ]; then
  rm -r -f "${SCRATCH}${case}"
fi

cd ${tag_dir}/cime/scripts/

./create_newcase --case ${casedir}${case} --compset HIST_DATM%CRUv7_CLM60%BGC_SICE_SOCN_SROF_SGLC_SWAV_SESP --res f19_g17 --project $chargenum --run-unsupported

cd ${casedir}${case}

cp ${user_mods_dir}/user_nl_datm_streams .
cp ${user_mods_dir}/user_nl_datm_streams.2015-2023 .
cp ${user_mods_dir}/user_nl_clm_transient_1985 ./user_nl_clm

finidat=`ls -1 ${SCRATCH}/${case}_postSASU/run/${case}_postSASU.clm?.r.*.nc | tail -1`
echo $finidat
echo " finidat = '$finidat'" >> user_nl_clm

# env_run.xml
#./xmlchange DIN_LOC_ROOT_CLMFORC='/glade/campaign/cgd/tss/projects/PPE'
./xmlchange MASK_MESH=${mesh_file}
./xmlchange ATM_DOMAIN_MESH=${mesh_file}
./xmlchange LND_DOMAIN_MESH=${mesh_file}
./xmlchange DATM_YR_ALIGN=1850
./xmlchange DATM_YR_START=1901
./xmlchange DATM_YR_END=1920
./xmlchange CLM_BLDNML_OPTS='-bgc bgc -no-megan'
#./xmlchange DATM_MODE=CLMGSWP3v1
./xmlchange DOUT_S=FALSE
./xmlchange CLM_ACCELERATED_SPINUP=off
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=51

# env_mach_pes.xml
./xmlchange NTASKS_OCN=112
./xmlchange NTASKS_WAV=112
./xmlchange NTASKS_GLC=112
./xmlchange NTASKS_ICE=112
./xmlchange NTASKS_ROF=112
./xmlchange ROOTPE_LND=16
./xmlchange ROOTPE_OCN=16
./xmlchange ROOTPE_WAV=16
./xmlchange ROOTPE_GLC=16
./xmlchange ROOTPE_ICE=16
./xmlchange ROOTPE_ROF=16
./xmlchange ROOTPE_ATM=0
./xmlchange ROOTPE_CPL=16
./xmlchange NTASKS_LND=112
./xmlchange NTASKS_ATM=16
./xmlchange NTASKS_CPL=112
#env_workflow.xml
./xmlchange JOB_WALLCLOCK_TIME=22:00:00
./xmlchange JOB_PRIORITY=economy

# change paramfile
paramfile='/glade/work/linnia/CLM-PPE-LAI_tests/ctsm5.2.027/paramfiles/ctsm60_params.c240814.nc'
echo $paramfile
echo "paramfile = '$paramfile'" >> user_nl_clm

./case.setup

./preview_namelists

#qcmd -A ${chargenum} -- ./case.build

# Do not submit this case as is.
# At this point, run_ens.sh script should be run with a config file.
# clm5ppe/jobscripts/run_ens.sh
# ./run_ens.sh *.config >& tmp.out &

fi

