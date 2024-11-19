#!/bin/bash
# change pe layout of PPEn14trans basecases for Derecho

# ===============================================
# setup

tag_dir="/glade/work/linnia/PPEn14trans"
chargenum='P93300041'

source ~/.bashrc

# ==============================================
# Build and run basecases
conda activate runclm

cd ${tag_dir}/cime/scripts/
casedir="/glade/work/linnia/PPEn14trans/cime/scripts/transient/basecases/"
case="PPEn14_transient"

do_AD=1
do_SASU=1
do_postSASU=1
do_transient=1

#===== AD ========================

if [ "$do_AD" -eq 1 ]; then

    suffix="_AD"
    cd ${casedir}${case}${suffix}

    pwd
    
    ./xmlchange NTASKS_ATM=128
    ./xmlchange NTASKS_CPL=256
    ./xmlchange NTASKS_OCN=256
    ./xmlchange NTASKS_WAV=256
    ./xmlchange NTASKS_GLC=256
    ./xmlchange NTASKS_ICE=256
    ./xmlchange NTASKS_ROF=256
    ./xmlchange NTASKS_LND=256
    
    ./case.setup

fi

#===== SASU ========================

if [ "$do_SASU" -eq 1 ]; then

    suffix="_SASU"
    cd ${casedir}${case}${suffix}

    pwd
    
    ./xmlchange NTASKS_ATM=128
    ./xmlchange NTASKS_CPL=256
    ./xmlchange NTASKS_OCN=256
    ./xmlchange NTASKS_WAV=256
    ./xmlchange NTASKS_GLC=256
    ./xmlchange NTASKS_ICE=256
    ./xmlchange NTASKS_ROF=256
    ./xmlchange NTASKS_LND=256
    
    ./case.setup

fi

#===== postSASU ========================

if [ "$do_postSASU" -eq 1 ]; then

    suffix="_postSASU"
    cd ${casedir}${case}${suffix}

    pwd
    
    ./xmlchange NTASKS_ATM=128
    ./xmlchange NTASKS_CPL=256
    ./xmlchange NTASKS_OCN=256
    ./xmlchange NTASKS_WAV=256
    ./xmlchange NTASKS_GLC=256
    ./xmlchange NTASKS_ICE=256
    ./xmlchange NTASKS_ROF=256
    ./xmlchange NTASKS_LND=256
    
    ./case.setup

fi

#===== transient ========================

if [ "$do_transient" -eq 1 ]; then

    cd ${casedir}${case}

    pwd
    
    ./xmlchange NTASKS_ATM=128
    ./xmlchange NTASKS_CPL=256
    ./xmlchange NTASKS_OCN=256
    ./xmlchange NTASKS_WAV=256
    ./xmlchange NTASKS_GLC=256
    ./xmlchange NTASKS_ICE=256
    ./xmlchange NTASKS_ROF=256
    ./xmlchange NTASKS_LND=256
    
    ./case.setup

fi