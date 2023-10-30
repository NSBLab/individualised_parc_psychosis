Scripts to compare FC differences between patients and controls calculated by the different parcellation approaches.

These scripts are based on the output structure from [NBS](https://www.nitrc.org/projects/nbs/). 

# Scripts: 
## run_post_NBS_analyses.m:
calls scripts to compare NBS outputs between indivisulaized and froup-based parcellations.

•	**make_adj_matrix** -> creates and save binarized adjacency matrices. This matrix has 0 for connections that didn’t survive the threshold for having a significant difference between groups and 1 for the ones that did.

•	**calc_FC_cohens_d** -> calculates effect size (Cohen’s d) of mean difference of FC for every edged between patients and controls.

•	**plot_NBS_tdist** -> plots the distribution of t-values associated with the difference in connectivity strength between patients and controls for both parcellation approaches. It also calculates and plots the shift function comparing the t-distribution for the two parcellations.

## plot_in_brain (R script):
you need to install _ggseg_ and _ggplot_ before running this script. It outputs plots of the degree of dysconnectivity per parcel on the brain and of dysconnected edges grouped per network.
## plot_parcel_size_correlations:
uses full path to _setup.mat_ as input. It calculates Spearman correlation between parcel size and degree of dysconnectivity and edge dysconnectivity and plots the correlation.
