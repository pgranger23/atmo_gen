#!/bin/bash
# set -x

DUNEVERSION=v09_74_01
DUNEQUALIFIER="e20:prof"
GLOBAL_ODIR="/pnfs/dune/scratch/users/pgranger/new_sample/"
STAGE="genie"
FCL="atm-genie.fcl"

if [ "$#" -ne 1 -a "$#" -ne 2 ]; then
	echo "Usage : $0 NEVENTS [RUNID]"
	exit 1
fi

NEVENTS=$1
ID=$PROCESS

if [ "$1" == "test" ]; then
	echo "Running in test mode. Assuming we are not in a batch job!"
	_CONDOR_SCRATCH_DIR=$(mktemp -d)
	echo "Going to work in the temp dir: $_CONDOR_SCRATCH_DIR"
	echo "Setting NEVENTS to 30 and iD to 0"
	NEVENTS=30
	ID=0

	SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) #Getting the current script dir
	CONDOR_DIR_INPUT=$SCRIPT_DIR/../fcl/ #Trick to copy all the fcl to the temp dir
fi

FINAL_ODIR=${GLOBAL_ODIR}/${STAGE}/
WORKDIR=${_CONDOR_SCRATCH_DIR}/work/
LOCAL_ODIR=${WORKDIR}/output/

if [ "$#" -eq 2 ]; then
	ID=$2
fi

source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
setup dunesw $DUNEVERSION -q $DUNEQUALIFIER

mkdir -p $WORKDIR && cd $WORKDIR
cp ${CONDOR_DIR_INPUT}/*.fcl . 2>/dev/null || : #Copying fcl files
mkdir -p $LOCAL_ODIR

OFILE=$LOCAL_ODIR/atm_${STAGE}_${ID}.root

lar -c $FCL -o $OFILE -n $NEVENTS
test -f $OFILE && ifdh cp $OFILE $FINAL_ODIR/atm_genie_${ID}.root
