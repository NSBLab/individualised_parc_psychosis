function inter_parcel_fc = calc_inter_parcel_fc(setup)

load(setup);

subj_run_2 = [];
subj_folder = dir(fullfile(run_02_surface, 'sub*'));
for s = 1:length(subj_folder)
    sub = regexprep(subj_folder(s).name, 'sub-','');
    subj_run_2(s) = str2num(sub);
end


[vertices_lh_grp, label_lh_grp, colortable_lh_grp] = read_annotation(grp_annot_lh);
[vertices_rh_grp, label_rh_grp, colortable_rh_grp] = read_annotation(grp_annot_rh);
parc_grp = cat(1,label_lh_grp,label_rh_grp);
background_grp = find(parc_grp==65793);
parc_grp(parc_grp==65793) = [];
mask_grp = parc_grp~=parc_grp';

for s = 1:length(subj_run_2);
    subj_run_2(s)
%% read left and right timeseries and join them
img_lh = MRIread(append(run_02_surface,'/sub-',num2str(subj_run_2(s)),'/sub-',num2str(subj_run_2(s)),'_run-02_lh_medialwall_fillin.mgz'));
img_rh = MRIread(append(run_02_surface,'/sub-',num2str(subj_run_2(s)),'/sub-',num2str(subj_run_2(s)),'_run-02_rh_medialwall_fillin.mgz'));
ts_l = squeeze(img_lh.vol);
ts_r = squeeze(img_rh.vol);
ts = cat(1,ts_l,ts_r);

%% read parcellation labels
[~, label_lh_ind, ~] = read_annotation(append(PARC_DIR_IND,'/lh.sub-',num2str(subj_run_2(s)),'_Rest_gpip_labels.annot'));
[~, label_rh_ind, ~] = read_annotation(append(PARC_DIR_IND,'/rh.sub-',num2str(subj_run_2(s)),'_Rest_gpip_labels.annot'));
parc_ind = cat(1,label_lh_ind,label_rh_ind);

% remove background vertices
ts_ind = ts';
ts_ind(:,parc_ind==0) = [];
parc_ind(parc_ind==0) = [];
ts_grp = ts';
ts_grp(:,background_grp) = [];

% compute vertex level fc matrix
fc_ind = corr(ts_ind);
fc_grp = corr(ts_grp);

% calculate the mean inter-parcel FC
mask_ind = parc_ind~=parc_ind';
mean_ind = mean(fc_ind(mask_ind));
mean_grp = mean(fc_grp(mask_grp));

inter_parcel_fc.ind(s,1) = mean_ind;
inter_parcel_fc.grp(s,1) = mean_grp;
end
