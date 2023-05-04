#!/bin/bash
set -x

DUNEVERSION=v09_74_01d00
DUNEQUALIFIER="e20:prof"
GLOBAL_ODIR="/pnfs/dune/scratch/users/pgranger/new_sample/"
STAGE="g4"
PREV_STAGE="genie"
FCL="standard_g4_dune10kt_1x2x6.fcl"

FINAL_ODIR=${GLOBAL_ODIR}/${STAGE}/
WORKDIR=${_CONDOR_SCRATCH_DIR}/work/
LOCAL_ODIR=${WORKDIR}/output/
IDIR=${GLOBAL_ODIR}/${PREV_STAGE}/
LOCAL_IDIR=${WORKDIR}/input/


if [ "$#" -ne 1 -a "$#" -ne 2 ]; then
	echo "Usage : $0 NEVENTS [RUNID]"
	exit 1
fi

NEVENTS=$1
ID=$PROCESS

if [ "$#" -eq 2 ]; then
	ID=$2
fi

source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
setup dunesw $DUNEVERSION -q $DUNEQUALIFIER

mkdir -p $WORKDIR && cd $WORKDIR

cp ${CONDOR_DIR_INPUT}/*.fcl . 2>/dev/null || : #Copying fcl files

IFILE_BASENAME=atm_${PREV_STAGE}_${ID}.root
IFILE=$IDIR/${IFILE_BASENAME}

ifdh ls $IFILE 0 || exit 0 #Check that input file exists

mkdir -p $IDIR
LOCAL_IFILE=$LOCAL_IDIR/${IFILE_BASENAME}
mkdir -p $LOCAL_IDIR
ifdh cp $IFILE $LOCAL_IFILE

OFILE=$LOCAL_ODIR/atm_${STAGE}_${ID}.root

lar -c $FCL $LOCAL_IFILE -o $OFILE -n $NEVENTS
test -f $OFILE && ifdh cp $OFILE $FINAL_ODIR/${OFILE_BASENAME}