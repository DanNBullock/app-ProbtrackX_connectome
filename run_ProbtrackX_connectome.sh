#!/bin/bash


bedpostDir=`jq -r '.bedpostX' config.json`
nstepsParam=`jq -r '.nsteps' config.json`
steplengthParam=`jq -r '.steplength' config.json`
nsamplesParam=`jq -r '.nsamples' config.json`
curvThreshParam=`jq -r '.cthr' config.json`
fibThreshParam=`jq -r '.fibthresh' config.json`

#should have been established in previous steps
masksDir='outMasks'


#alternatively we could just read from this
#find the ROIS that will be tracked between
declare -a ROIS2Track
for file in ${masksDir}/label_*.nii.gz
do
    ROIS2Track=("${ROIS2Track[@]}" "$file")
done

#can be run with standard probtracks but will take much longer
# OLD WAY 
#while read iNodes; do
#    probtrackx2_gpu  -x ${masksDir}/label_{$iNodes}.nii.gz --loopcheck --onewaycondition --forcedir --opd -s ${bedpostDir}/data.bedpostX/merged -m ${bedpostDir}/data.bedpostX/nodif_brain_mask --dir=${bedpostDir}/probtracksx -o #label_{$iNodes} --modeuler --cthr=${curvThreshParam} --nsteps=${nstepsParam} --steplength=${steplengthParam} --nsamples=${nsamplesParam} --fibthresh=${fibThreshParam}
#done <${subjdir}/uniqueVals.txt

#new way
echo 'Iteratively running probtrackx2_gpu for all masks'
for iFile in ${ROIS2Track}
do
    probtrackx2_gpu  -x ${masksDir}/iFile --loopcheck --onewaycondition --forcedir --opd -s ${bedpostDir}/data.bedpostX/merged -m ${bedpostDir}/data.bedpostX/nodif_brain_mask --dir=${bedpostDir}/probtracksx -o iFile --modeuler --cthr=${curvThreshParam} --nsteps=${nstepsParam} --steplength=${steplengthParam} --nsamples=${nsamplesParam} --fibthresh=${fibThreshParam}
done 

# Converts probtracks files into a matrix containing node to node connections with unthresholded data.
# May be beneficial to discard weakest streamlines as described by Shen et al. 
# Neuroimage. 2019 May 1;191:81-92. doi: 10.1016/j.neuroimage.2019.02.018. Epub 2019 Feb 7.

#Node by node calculation of streamline density 
#connection strength is calculated as the mean connection strength in each ROI in tje FDT_path file from each nodes seed.
mkdir FSL_Connectome

# reading the same file twice might cause a problem, I don't know
#old way
#while read iNodesA; do
#    while read iNodesB; do
#        fslstats ${subjdir}/probtracksx/node_{$iNodesA}.nii.gz -k ${masksDir}/label_{$iNodesB}.nii.gz -m >> ${subjdir}/FSL_Connectome/node_{$iNodesA}.txt
#    done <${subjdir}/uniqueVals.txt
#done <${subjdir}/uniqueVals.txt

#new way
echo 'Computing stats for each mask tracking output'
for iFile in ${ROIS2Track}
do
    #get the name for the row(?) file output by removing the file extension
    currFileName=  ${iFile} | sed 's/nii.gz//'
    
    fslstats ${bedpostDir}/probtracksx/${iFile} -k ${masksDir}/${iFile} -m >> FSL_Connectome/{$currFileName}.txt
    
#does this work?
paste FSL_Connectome/label_*.txt >> FSL_Connectome/FSL_Connectome.txt

mkdir output

cp FSL_Connectome/FSL_Connectome.txt output/FSL_Connectome.txt
