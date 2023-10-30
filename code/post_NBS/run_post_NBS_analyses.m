setup = '/full/path/to/setup/setup.mat';
% setup = append(setup_par.OUTPUT_DIR,'/setup.mat')
addpath(genpath('/full/path/to/directory/with/code/and/utils_fold'));

%% make adjacency matrices 
[adj_ind, adj_grp] = make_adj_matrix(setup);

%% calc effect size of mean difference of FC for every edge between patients
% and controls, for both parcellations
FC_cohens_d = calc_FC_cohens_d(setup);

%% plot distribution of t-values, calculated by NBS for both parcellations 
% and calc and plot shift function comparing both 

% plot t-distributions
[ind_tdist, grp_tdist] = plot_NBS_tdist(setup);

% calculate and plot the shift function between distributions
[ind_quantiles, grp_quantiles, quantile_diff, CI] = shifthd(grp_tdist, ind_tdist, 200, 1);

% calculate t-dist phi correlation
[r, p_corr] = corr(ind_tdist, grp_tdist,'Type','Spearman');
 
% calulate Wilcoxon signed rank test
[p,h,stats] = signrank(ind_tdist, grp_tdist);

%% calc parcel size FC correlation
parcel_size_corr = plot_parcel_size_correlations(setup);


