#!/bin/bash

# SBATCH --job-name=pre-FIX
# SBATCH --account=kg98
# SBATCH --ntasks=1
# SBATCH --cpus-per-task=4
# SBATCH --time=1:00:00
# SBATCH --export=ALL
# SBATCH --mem-per-cpu=16G

# script to run steps that get data from HCP Pipeline into a format that is compatible with ICA-FIX

module purge
module load fsl
module load matlab/r2021a
module load R/3.3.1


# set environments
export FSLDIR=/usr/local/fsl/6.0.5.1
FSL_FIXDIR=/usr/local/fix/1.068/bin
export FSL_FIXDIR

# make sure data is on scratch
export output_dir=/home/ptha53/kg98/Priscila/GPIP_HCP-EP_clean/HCP_Pipeline_output
export results_dir=${output_dir}/sub-${s}/MNINonLinear/Results/task-rest_run-${r}_bold

#set variables
fmri=task-rest_run-${r}_bold
cd  ${output_dir}/sub-${s}/MNINonLinear/Results/task-rest_run-${r}_bold
hp=2000
tr=`$FSLDIR/bin/fslval $fmri pixdim4`
 
echo "running highpass"
hptr=`echo "10 k $hp 2 / $tr / p" | dc -`
if [ ! -f ${fmri}_hp$hp.nii.gz ] ; then
${FSLDIR}/bin/fslmaths $fmri -Tmean ${fmri}_Tmean
${FSLDIR}/bin/fslmaths $fmri -bptf $hptr -1 -add ${fmri}_Tmean ${fmri}_hp$hp
fi

fmri=${fmri}_hp$hp


echo "running MELODIC"
mkdir -p ${fmri}.ica
$FSLDIR/bin/melodic -i $fmri -o ${fmri}.ica/filtered_func_data.ica -d -250 --nobet --report --Oall --tr=$tr


#create correct fix inputs
cd task-rest_run-${r}_bold_hp2000.ica
cp ../$fmri.nii.gz filtered_func_data.nii.gz
cp filtered_func_data.ica/mask.nii.gz mask.nii.gz
cp ../task-rest_run-${r}_bold_SBRef.nii.gz mean_func.nii.gz
mkdir -p mc
cat ../Movement_Regressors.txt | awk '{ print $4 " " $5 " " $6 " " $1 " " $2 " " $3}' > mc/prefiltered_func_data_mcf.par

${FSL_FIXDIR}/call_matlab.sh -l .fix.log -f functionmotionconfounds $tr $hp 

mkdir -p reg
cd reg
$FSLDIR/bin/imln ../../../../T1w_restore_brain highres
$FSLDIR/bin/imln ../../../../wmparc wmparc
$FSLDIR/bin/imln ../mean_func example_func
$FSLDIR/bin/makerot --theta=0 > highres2example_func.mat
if [ `$FSLDIR/bin/imtest ../../../../T2w` = 1 ] ; then
  $FSLDIR/bin/fslmaths ../../../../T1w -div ../../../../T2w veins -odt float
  $FSLDIR/bin/flirt -in ${FSL_FIXDIR}/mask_files/hcp_0.7mm_brain_mask -ref veins -out veinbrainmask -applyxfm
  $FSLDIR/bin/fslmaths veinbrainmask -bin veinbrainmask
  $FSLDIR/bin/fslmaths veins -div `$FSLDIR/bin/fslstats veins -k veinbrainmask -P 50` -mul 2.18 -thr 10 -min 50 -div 50 veins
  $FSLDIR/bin/flirt -in veins -ref example_func -applyxfm -init highres2example_func.mat -out veins_exf
  $FSLDIR/bin/fslmaths veins_exf -mas example_func veins_exf
fi

echo done ${s} ${r}
