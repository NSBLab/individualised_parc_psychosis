module purge
module load fsl

export StudyFolder=/home/ptha53/kg98/Priscila/honours/hcp_output_preFS
export Subject=sub-${s}
export fMRIRes=2
export fMRIName=task-rest_run-${r}_bold

flirt -interp spline \
-in ${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore.nii.gz \
-ref ${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore.nii.gz \
-applyisoxfm ${fMRIRes} \
-out ${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore.${fMRIRes}.nii.gz

applywarp --interp=spline \
-i ${StudyFolder}/${Subject}/MNINonLinear/Results/${fMRIName}/${fMRIName}_hp2000.ica/filtered_func_data_clean.nii.gz \
-r ${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore.${fMRIRes}.nii.gz \
-w ${StudyFolder}/${Subject}/MNINonLinear/xfms/standard2acpc_dc.nii.gz \
-o ${StudyFolder}/${Subject}/T1w/Results/${fMRIName}/${fMRIName}_hp2000_clean_native.nii.gz
