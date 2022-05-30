#!/bin/sh

#  Dan Bullock 5/30/2022; generalized version of mask extraction script produced by
#  Mark Grier, University of Minnesota Twin Cities mgrier@umn.edu

#Set path var to input parcellation
#parcFilePath=$1
parcFilePath=`jq -r '.parc' config.json`

#set path var to directory to contain mask files
#outDir=$2
outDir='outMasks'
#make it it necesary
mkdir $outDir

echo 'Determining unique labels in input parcellation'

#we can infer the number of nodes in the input parcellation using AFNI's 3dhistog
3dhistog -unq ${outDir}/uniqueVals.txt ${parcFilePath}
#but AFNI includes useless junk in the first line of that output, so we have to delete it
tail -n +2 ${outDir}/uniqueVals.txt > ${outDir}/uniqueVals.txt.tmp && mv ${outDir}/uniqueVals.txt.tmp ${outDir}/uniqueVals.txt
