#!/bin/sh

#  Dan Bullock 5/30/2022; generalized version of mask extraction script produced by
#  Mark Grier, University of Minnesota Twin Cities mgrier@umn.edu


#
#Set path var to input parcellation
#parcFilePath=$1
parcFilePath=`jq -r '.parc' config.json`

#set path var to directory to contain mask files
outDir='outMasks'
#make it it necesary
#should have been made by previous steps
#mkdir $outDir

#guess we just assume it's right here in the working directory
uValTxt=${outDir}/uniqueVals.txt

while read uValTxt; do
do
mrcalc ${parcFilePath} ${uValTxt} -eq \
	${outDir}/label_${uValTxt}.nii.gz
done
