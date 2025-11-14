#!/bin/bash
# copy files from scratch to campaign

# ===============================================

do_hist=0
do_ssp=1
do_spin=1

spin_dir="/glade/campaign/cgd/tss/projects/PPE/ctsm53065_lhc/spin/" # postSASU history files
hist_dir="/glade/campaign/cgd/tss/projects/PPE/ctsm53065_lhc/hist/" # history files
rest_dir="/glade/campaign/cgd/tss/projects/PPE/ctsm53065_lhc/rest/" # restart files
ssp_dir="/glade/campaign/cgd/tss/projects/PPE/ctsm53065_lhc/ssp370/" # ssp history files

# ===============================================

if [ "$do_hist" -eq 1 ]; then

cd $SCRATCH

ens_list=`ls -d ctsm5.3.065_transient_lhc01*`

for member in $ens_list
do
    echo $member
    cd ${member}/run/
    cp ctsm5.3.065_transient_lhc*.clm2.h* $hist_dir
    
    cp ctsm5.3.065_transient_lhc*.clm2.r.1985-01-01-00000.nc $rest_dir
    cp ctsm5.3.065_transient_lhc*.clm2.r.2024-01-01-00000.nc $rest_dir

    cd $SCRATCH

done

fi

# ===============================================

if [ "$do_ssp" -eq 1 ]; then

cd $SCRATCH

ens_list=`ls -d ctsm5.3.065_transient_SSP370_lhc*`

for member in $ens_list
do
    echo $member
    cd ${member}/run/
    cp ctsm5.3.065_transient_SSP370_lhc*.clm2.h* $hist_dir

    cp ctsm5.3.065_transient_SSP370_lhc*.clm2.r.2101-01-01-00000.nc $rest_dir
    
    cd $SCRATCH

done

fi

# ===============================================

if [ "$do_spin" -eq 1 ]; then

cd $SCRATCH

# AD
#ens_list=`ls -d ctsm5.3.065_transient_AD_lhc*`
#for member in $ens_list
#do
#    echo $member
#    cd ${member}/run/
#    cp ctsm5.3.065_transient_AD_*.clm2.h0a* $spin_dir
#    cd $SCRATCH
#done

# SASU
#ens_list=`ls -d ctsm5.3.065_transient_SASU_lhc*`
#for member in $ens_list
#do
#    echo $member
#    cd ${member}/run/
#    cp ctsm5.3.065_transient_SASU_*.clm2.h0a* $spin_dir
#    cd $SCRATCH
#done

# postSASU
ens_list=`ls -d ctsm5.3.065_transient_postSASU_lhc*`
for member in $ens_list
do
    echo $member
    cd ${member}/run/
    cp ctsm5.3.065_transient_postSASU_*.clm2.h0a* $spin_dir
    cd $SCRATCH
done

fi

