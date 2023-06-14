function [ICC_grp, ICC_ind] = calc_ICC_homog(setup)


addpath(genpath('/fs04/kg98/Priscila/GPIP_HCP-EP_clean'));

%% load homogeneity data
load(setup);

run1 = load(append(OUTPUT_DIR,'/homogeneity_run1.mat'));
run2 = load(append(OUTPUT_DIR,'/homogeneity.mat'));

% concat patients and controls, then run 1 and 2
grp_run1 = cat(2, run1.grp_controls, run1.grp_patients);
grp_run2 = cat(2, run2.grp_controls, run2.grp_patients);

grp = cat(1, grp_run1, grp_run2);


ind_run1 = cat(2, run1.ind_controls, run1.ind_patients);
ind_run2 = cat(2, run2.ind_controls, run2.ind_patients);

ind = cat(1, ind_run1, ind_run2);

%% run ICC 
[r, LB, UB, F, df1, df2, p] = ICC(grp, 'C-1');
ICC_grp.r = r;
ICC_grp.F = F;
ICC_grp.p = p
ICC_grp.LB = LB;
ICC_grp.UB = UB;

[r, LB, UB, F, df1, df2, p] = ICC(ind, 'C-1');
ICC_ind.r = r;
ICC_ind.F = F;
ICC_ind.p = p;
ICC_ind.LB = LB;
ICC_ind.UB = UB;
