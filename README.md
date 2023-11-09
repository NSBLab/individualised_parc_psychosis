Code for manuscript ‘[The effect of using group-averaged or individualized brain parcellations when investigating connectome dysfunction in psychosis](https://direct.mit.edu/netn/article/doi/10.1162/netn_a_00329/116662/The-effect-of-using-group-averaged-or)’

Compares **group-based** and **indivisualized parcellation** and functional connectivity differences between patients and controls resulted from both parcellations.

This code was written for analysis after processed fMRI data has been parcellated using indivisualized parcellation (GPIP) and group-based parcellation (Schaefer). 

# File Description:
**utils_folder**: folder with all the functions needed for the code to run.

**code**: folder with all the scripts you need to run for comparing parcellations.

**code/post_NBS**: folder with scripts you need for comparing FC difference between patients and controls, as assessed with NBS, based on group and indivisualized parcellation – these script are to be run after statistical analysis using the Network Based Statistics Toolbox

***Scripts were tested on Matlab 2019a and R 4.1.0***

# RUNNING THEM:
## 1st step: 'setup.m'
->	You will need to add file paths for your GPIP outputs, path and name for a group-based parcellation annotation file and patients and control ID list.

## 2nd step: 'run_main_analysis.m'
->	You will have to edit the path to this directory, to the setup.mat output and to timeseries averaged per parcel file (This should be a file a .txt or .dat file for each hemisphere with dimensions (numbers of parcels in each hemisphere x timepoints)

->	This script calls _calc_ROI_exc_, _calc_homogeneity_, _calc_fc_separation_, _calc_parcel_size_diff_, _calc_vertices_change_, _plot_FCmat_, and _calc_FMmat_corr_.
   
   o	**calc_ROI_exc** -> makes a list of ROIs with low signal in per subject. This script is an adaptation of the method described in Brown et. al. 2019 (Supps). Last argument of this is optional and lets you choose if you want to find the overall biggest pair-wise difference in BOLD signal strength or the biggest pair-wise difference in the bottom half of lowest values as a threshold for signal dropout (in many instance the biggest pwd are caused by ROIs with higher than normal average BOLD and not lower than normal, so this will flag the majority of regions as having low signal – see figures below for example)
   ![image](https://github.com/NSBLab/individualised_parc_psychosis/assets/89367888/15e1ed77-9e73-401e-9bc3-de36d05c4335)

    
   o	**calc_homogeneity** -> calculates activity homogeneity metric for every parcel, normalised by parcel size. Homogeneity is saved separate for patients and controls and p-values are calculated with permutation testing and FDR corrected. We also calculate intraclass correlation coefficient between runs.
    
   o	**calc_fc_separation** -> calculates activity separation between regions for each parcellation.
    
   o	**calc_parcel_size_diff** -> calculates difference in parcel size between parcellation schemes for patients and controls and gets a t-value comparing parcel size between patients and control. p-values are calculated using permutation testing and are FDR corrected. It also calculates how many vertices were assigned to different parcels between parcellation types.
    
   o	**calc_vertices_change** -> calculates the percentage of vertices that were relabelled by indivisualized parcellation compared to the group-based parcellation.
    
   o	**plot_FCmat** -> calculates functional connectivity matrices, based on correlation of timeseries and plots them.
    
   o	**calc_FCmat_corr** -> calculates Spearmann correlation for every subjects between group-based and individualized parcellations and plots them in a raincloud.

## 3rd step: Download and run the [NBS Toolbox](https://www.nitrc.org/projects/nbs/) to compare FC between patients and controls. 
Use the FC matrices saved at output/FC /{parc} as an input. NBS uses permutation statistics to compare the FC matrices between two different groups (patients/controls), based on the understanding that significant impacts of pathophysiology will likely span a connected network, rather than isolated edges. For more information refer to https://www.nitrc.org/projects/nbs/.

## 4th step: Run script in code/post_NBS

# Citation
If you use our code in your research, please cite us as follows:
Priscila T. Levi, Sidhant Chopra, James C. Pang, Alexander Holmes, Mehul Gajwani, Tyler A. Sassenberg, Colin G. DeYoung, Alex Fornito; The effect of using group-averaged or individualized brain parcellations when investigating connectome dysfunction in psychosis. Network Neuroscience 2023; doi: https://doi.org/10.1162/netn_a_00329

# Further information
Please contact priscila.thalenberglevi@monash.edu if you need further details.

Last updated: 10/11/23
