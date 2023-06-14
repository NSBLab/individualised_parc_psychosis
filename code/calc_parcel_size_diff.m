function parcel_size = calc_parcel_size_diff(setup, ROI_exc)
%% This script calculates the differences in parcel size between parcellations
% Inputs: setup - path to where the setup structure (look at code/setup.m) is saved
%	  ROI_exc - list of ROIs to be removed - OPTIONAL

% Outputs: parcel_size - structure containing lists of parcel size difference (given by number of vertices) for patients and for controls separately and a list with a t-value per parcel comparing its mean size in patients and controls for individualised parcellation

load(setup);

%% loading labels and concatenating right and left hemispheres for group-based annot
[~, label_lh_group, colortable_lh_group] = read_annotation(grp_annot_lh);
[~, label_rh_group, colortable_rh_group] = read_annotation(grp_annot_rh);
label_group = cat(1,label_lh_group,label_rh_group);

% create a list of unique labels without background
label_list = unique(label_group);
label_list(label_list==65793) = [];

% find the colortable code for removed parcels
rm_p_code = [];
for p = 1:length(ROI_exc)
    if ROI_exc(p) <= n_parc/2
        p1 = ROI_exc(p) + 1;
        rm_p_code(end+1) = colortable_lh_group.table(p1,5);
    end
    if ROI_exc(p) > n_parc/2
        p1 = ROI_exc(p) - (n_parc/2)+1;
        rm_p_code(end+1) = colortable_rh_group.table(p1,5);
    end
end

% remove excluded parcels from label_list
for c = 1:length(rm_p_code)
    cc = find(label_list==rm_p_code(c));
    label_list(cc) = [];
end

% get a list of indices for the included parcels
label_index_group = zeros(1,length(label_list));
for l = 1:length(label_list)
    if ismember(label_list(l),colortable_lh_group.table(:,5))
        label_index_group(1,l) = find(colortable_lh_group.table(:,5)==label_list(l))-1;
    elseif ismember(label_list(l),colortable_rh_group.table(:,5))
        label_index_group(1,l) = find(colortable_rh_group.table(:,5)==label_list(l))+((length(unique(label_group))-1)/2)-1;
    end
end

% sort index list
[~,I] = sort(label_index_group);

%set up variables that are going to cointain parcel size for individualized and group parcellations            
size_ind = zeros(length(subj),length(label_list));
size_group = zeros(length(subj),length(label_list));
parcel_diff = zeros(length(subj),length(label_list));

for s = 1:length(subj)
    %% loading labels and concatenating right and left for gpip parcellation
    [~, label_lh_ind, ~] = read_annotation(append(PARC_DIR_IND,'/lh.sub-',num2str(subj(s)),'_Rest_gpip_labels.annot'));
    [~, label_rh_ind, ~] = read_annotation(append(PARC_DIR_IND,'/rh.sub-',num2str(subj(s)),'_Rest_gpip_labels.annot'));
    label_ind = cat(1,label_lh_ind,label_rh_ind);
    
    % sum amount of vertices in assigned to each parcel
    for l = 1:length(label_list)

        parcel_ind = find(label_ind==label_list(l));
        parcel_grp = find(label_group==label_list(l));
        size_ind(s,l) = length(parcel_ind);
        size_group(s,l) = length(parcel_grp);
        parcel_diff(s,l) = sum(~ismember(parcel_ind,parcel_grp));
        
    end
    
  
        
end

% separate parcel size by controls and patients
% size_ind_controls = [];
% size_ind_patients = [];
% for s = 1:length(subj)
%     if ismember(subj(s),patients)
%         size_ind_patients(end+1,:) = size_ind(s,:);
%     elseif ismember(subj(s), controls)
%         size_ind_controls(end+1,:) = size_ind(s,:);
%     end
% end

size_ind_patients = size_ind( ismember(subj,patients) , :);
size_ind_controls = size_ind( ismember(subj,controls) , :);


% do a two-sampled t-test comparing the mean size of each parcel between
% patients and controls for individualized parcellation - for group
% parcellation everyone hase the same parcel size
tt_ind = zeros(1,length(I));

for par = 1:length(I)
    [~,~,~,stats] = ttest2(size_ind_controls(:,par),size_ind_patients(:,par));
    tt_ind(par) = stats.tstat;
end
% % % % % tt_ind_sorted = tt_ind(I);

size_diff = size_ind - size_group;
parcel_size.ttest_ind = tt_ind(I);

parcel_size.patients = (size_diff(ismember(subj, patients),:));
parcel_size.controls = (size_diff(ismember(subj, controls),:));
parcel_size.vertice_changed_patients = (parcel_diff(ismember(subj, patients),:));
parcel_size.vertice_changed_controls = (parcel_diff(ismember(subj, controls),:));

% % % % % % calculate mean size difference for each parcel between parcellation type
% % % % % size_diff = size_ind-size_group;
% % % % % size_diff_avg(2,:) = mean(size_diff);
% % % % % size_diff_avg(1,:) = label_index_group;


% separate it between patients and controls
% % % % % size_diff_patients = [];
% % % % % size_diff_controls = [];
% % % % % vertice_changed_patients = [];
% % % % % vertice_changed_controls = [];
% % % % % for s = 1:length(subj)
% % % % %     if ismember(subj(s),patients)
% % % % %         size_diff_patients(end+1,:) = size_diff(s,:);
% % % % %         vertice_changed_patients(end+1,:) = parcel_diff(s,:);
% % % % %     elseif ismember(subj(s), controls)
% % % % %         size_diff_controls(end+1,:) = size_diff(s,:);
% % % % %         vertice_changed_controls(end+1,:) = parcel_diff(s,:);
% % % % %     end
% % % % % end
% % % % % 
% % % % % parcel_size.patients = size_diff_patients;
% % % % % parcel_size.controls = size_diff_controls;
% % % % % parcel_size.ttest_ind = tt_ind_sorted;
% % % % % parcel_size.vertice_changed_controls = vertice_changed_controls;
% % % % % parcel_size.vertice_changed_patients = vertice_changed_patients;