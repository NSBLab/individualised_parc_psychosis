% This script calls functions for the analysis comparing the two parcellation,
clear; clc
% add to path directories with nescessary function, such as raincloud_plot, read_annotation, mgh_read 
addpath(genpath('/full/path/to/code/and/utils/lab'));

% load global variables
setup = '/full/path/to/setup/setup.mat';
load(setup);

'setup complete'

%% concatenate and save left and right avg timeseries for grp and ind parcellations
mkdir(append(OUTPUT_DIR,'/ts'));
for s = 1:length(subj)
	ts_lh = dlmread(append(PARC_DIR_IND,'/sub-',num2str(subj(s)),'_GPIP_run-01_gpip_7N_avgts_lh.dat')); % read avg ts file for left hemisphere
	ts_rh = dlmread(append(PARC_DIR_IND,'/sub-',num2str(subj(s)),'_GPIP_run-01_gpip_7N_avgts_rh.dat')); % read avg ts file for right hemisphere
	ts=[ts_lh ts_rh];
	ind_ts(:,:,s) = ts; %#ok<SAGROW> 
	writematrix(ts, append(OUTPUT_DIR,'/ts/sub-',num2str(subj(s)),'_ind_ts.txt')); 
end

for s = 1:length(subj)
	ts_lh = dlmread(append(GPIP_DIR,'/group_annot/sub-',num2str(subj(s)),'_Schaefer_run-01_gpip_7N_avgts_lh.dat')); % path to avg ts file for left hemisphere
	ts_rh = dlmread(append(GPIP_DIR,'/group_annot/sub-',num2str(subj(s)),'_Schaefer_run-01_gpip_7N_avgts_rh.dat')); % path to avg ts file for right hemisphere
	ts=[ts_lh ts_rh];
	grp_ts(:,:,s) = ts; %#ok<SAGROW> 
	writematrix(ts, append(OUTPUT_DIR,'/ts/sub-',num2str(subj(s)),'_grp_ts.txt')); 
end

'finished concatenating timeseries'

%% evaluate which regions present with low signal for exclusion
[sub_dropout_ind, ROI_dropout_ind] = calc_ROI_exc(setup,ind_ts,2); % defaults to looking at overall biggest pwd, can be changes to only look at second half of distribution
total_s = length(subj);
th = total_s*0.05; % use 0.05 to exclude regions that have low signal in over 5% of the subjects
ROI_exc_ind = find(ROI_dropout_ind >= th);

[sub_dropout_grp, ROI_dropout_grp] = calc_ROI_exc(setup,grp_ts,2); % defaults to looking at overall biggest pwd, can be changes to only look at second half of distribution
ROI_exc_grp = find(ROI_dropout_grp >= th);

% write the final ROI exclusion list, with regions flagged for both parcellation types
ROI_exc = union(ROI_exc_ind, ROI_exc_grp);
writematrix(ROI_exc, [OUTPUT_DIR '/ROI_exc.txt']);

append('total number of ROI for exclusion = ',num2str(length(ROI_exc)))

%% calculate homogeneity scores normalised by parcel size
homogeneity_OOS = calc_homogeneity(setup,ROI_exc); %calc homogeneity using run-02 fMRI
homogeneity_run1 = calc_homogeneity_run1(setup,ROI_exc); %calc homogeneity using run-01 fMRI - same data used for parcellation
% calc FDR corrected p-values comparinh homog per parcel bw ind and grp
% parcellations
for parc = 1:(n_parc - length(ROI_exc))
    p_homog(1,parc) = permutationTest(homogeneity_OOS.grp_per_parcel(parc,:), homogeneity_OOS.ind_per_parcel(parc,:), 5000); %#ok<SAGROW> 
end
p_fdr_homog = mafdr(p_homog, 'BHFDR', true);
homogeneity_OOS.p_fdr = p_fdr_homog;

% calc intraclass correlation coefficient between runs
ind_homog_run1 = cat(2, homogeneity_run1.ind_controls, homogeneity_run1.ind_patients);
ind_homog_run2 = cat(2, homogeneity_OOS.ind_controls, homogeneity_OOS.ind_patients);
grp_homog_run1 = cat(2, homogeneity_run1.grp_controls, homogeneity_run1.grp_patients);
grp_homog_run2 = cat(2, homogeneity_OOS.grp_controls, homogeneity_OOS.grp_patients);
ICC_ind = cat(1, ind_homog_run1, ind_homog_run2);
ICC_grp = cat(1, grp_homog_run1, grp_homog_run2);
[r_ICC_ind, ~, ~, ~, ~, ~, p_ICC_ind] = ICC(ICC_ind, 'C-1');
[r_ICC_grp, ~, ~, ~, ~, ~, p_ICC_grp] = ICC(ICC_grp, 'C-1');
homogeneity_OOS.ICC.p_ind = p_ICC_ind;
homogeneity_OOS.ICC.p_grp = p_ICC_grp;
homogeneity_OOS.ICC.r_ind = r_ICC_ind;
homogeneity_OOS.ICC_r_grp = r_ICC_grp;

save(append(OUTPUT_DIR,'/homogeneity_OOS.mat'), '-struct', 'homogeneity_OOS');

'finished calculating parcel functional homogeneity' %#ok<*NOPTS> 

%% calculate activity separation
% 30 seconds per subject
fc_separation = calc_fc_separation(setup, ROI_exc);
save(append(OUTPUT_DIR,'/fc_separation.mat'), '-struct', 'fc_separation');

'finished calculating separation'

%% calculate changes in parcel size between parcellation
parcel_size = calc_parcel_size_diff(setup, ROI_exc);
% calculate permutation p-value comparing patients and controls
patient_size_mean = mean(abs(parcel_size.patients'));
control_size_mean = mean(abs(parcel_size.controls'));
[p_parcel_size, observeddifference_size, effectsize_size] = permutationTest(patient_size_mean, control_size_mean, 5000);
% compare parcel size between patients and controls for every parcel
parcel_size.p_value = zeros(1,size(parcel_size.patients,2));
for ps = 1:length(parcel_size.p_value)
    parcel_size.p_value(1,ps) = permutationTest(parcel_size.patients(:,ps), parcel_size.controls(:,ps), 5000);
end
save(append(OUTPUT_DIR,'/parcel_size.mat'), '-struct', 'parcel_size');

% calc FDR corrected p-values comparing percentage of vertices changed per 
% parcel bw patients and controls
for parc = 1:(n_parc - length(ROI_exc))
    p_vert(1,parc) = permutationTest(parcel_size.vertice_changed_controls(:,parc), parcel_size.vertice_changed_controls(:,parc), 5000);
end
p_fdr_vert = mafdr(p_vert, 'BHFDR', true);

% add vertices changed per parcel to figure
[vert_con_sorted, I] = sort(mean(parcel_size.vertice_changed_controls,1));
vert_pat_mean = mean(parcel_size.vertice_changed_patients,1);
vert_pat_sorted = vert_pat_mean(I);

subplot(3,2,5) ; hold on ; scatter(vert_con_sorted, (1:length(vert_con_sorted)), 'marker', '.', 'MarkerEdgeColor', '#92E3FF');
scatter(vert_pat_sorted, (1:length(vert_pat_sorted)), 'marker', '.', 'MarkerEdgeColor', '#90BCC8');
xlabel('regions'); ylabel('vertices relabelled');
legend('controls', 'patients');

'finished calculating differences in parcel size'

%% calculate percentage of vertices changed and calculate p-value with permutation
relabelled_vertices_percentage2 = calc_vertices_change(setup,ROI_exc);
[p_vertices, observeddifference_vertices, effectsize_vertices] = ...
    permutationTest(relabelled_vertices_percentage.controls, relabelled_vertices_percentage.patients, 5000);
relabelled_vertices_percentage.stats.p_value = p_vertices;
relabelled_vertices_percentage.stats.effectsize = effectsize_vertices;
relabelled_vertices_percentage.p_per_parcel_fdr = p_fdr_vert;

save(append(OUTPUT_DIR,'/relabelled_vertices.mat'), '-struct', 'relabelled_vertices_percentage');

'finished calulating percentage of vertices relabelled'

%% calculate and plot FC matrices
% saves fc matrices and plots
plot_FCmat(setup,ind_ts,'ind',ROI_exc); 
plot_FCmat(setup,grp_ts,'grp',ROI_exc); 

'finished plotting FC matrices'

%% calculate FC correlation 
FC_corr = calc_FCmat_corr(setup); % outputs list of correlations per subject and raincloud plot
writematrix(FC_corr, append(OUTPUT_DIR,'/FC_corr.txt'));

'finished calculating FC matrices correlation'
