function fc_separation = calc_fc_separation(setup, ROI_exc)
% This function calculates activity separation between regions for both
% parcellation types. Separation is deifned by the mean Pearson's
% coefficient of correlatun of activity between each pair of vertices that
% were not allocated to the same region
% Inputs: setup - path to where the setup structure (look at code/setup.m) is saved
%         ROI_exc: list of regions to be excluded - OPTIONAL
% Outputs: fc_separation - structure with a list of separation metric per 
%                          subject for each parcellation type. 


%% load variables
load(setup)

[~, label_lh_grp, colortable_lh_grp] = read_annotation(grp_annot_lh);
[~, label_rh_grp, colortable_rh_grp] = read_annotation(grp_annot_rh);
parc_grp = cat(1,label_lh_grp,label_rh_grp);
parc_grp(parc_grp==65793) = 0; % change background label to 0

%% make parcel code for removed ROIs = 0;
if nargin==2
    ROI_exc_code = [];
    for r = 1:length(ROI_exc)
        if ROI_exc(r) > n_parc/2
            rr = ROI_exc(r)-(n_parc/2)+1; % change per parc
            v = colortable_rh_grp.table(rr,5);
            ROI_exc_code(end+1) = v;
        else
            rr = ROI_exc(r)+1;
            v = colortable_lh_grp.table(rr,5);
            ROI_exc_code(end+1) = v;
        end
    end
    ROI_exc_code(end+1) = 0;
end


for s = 1:length(subj)
    
    % read matrix not averaged timeseries
    %% get a NxT data matrix 
	img_lh = MRIread(append(IMG_DIR,'/sub-',num2str(subj(s)),'/sub-',num2str(subj(s)),'_run-01_lh_medialwall_fillin.mgz'));
	img_rh = MRIread(append(IMG_DIR,'/sub-',num2str(subj(s)),'/sub-',num2str(subj(s)),'_run-01_rh_medialwall_fillin.mgz'));
	data_l = squeeze(img_lh.vol);
	data_r = squeeze(img_rh.vol);
	data = cat(1,data_l,data_r);
    
    fc = corr(data');

	%% get Nx1 ind parcellation
	[~, label_lh_ind, ~] = read_annotation(append(PARC_DIR_IND,'/lh.sub-',num2str(subj(s)),'_Rest_gpip_labels.annot'));
	[~, label_rh_ind, ~] = read_annotation(append(PARC_DIR_IND,'/rh.sub-',num2str(subj(s)),'_Rest_gpip_labels.annot'));
	parc_ind = cat(1,label_lh_ind,label_rh_ind); 
    
    %% make a mask of differences: 0s for equal labels and 1s for different
%     mask_ind = ones(length(parc_ind), length(parc_ind));
%     mask_grp = ones(length(parc_grp), length(parc_grp));
%     
%     mask_ind(parc_ind==parc_ind') = 0;
%     mask_grp(parc_grp==parc_grp') = 0;

    mask_ind = (parc_ind ~= parc_ind');
    mask_grp = (parc_grp ~= parc_grp');
    
    % also remove ROI_exc
    if nargin==2
%         for c = 1:length(ROI_exc_code)
%             mask_ind(parc_ind==ROI_exc_code(c),:) = 0;
%             mask_ind(:,parc_ind'==ROI_exc_code(c)) = 0;
%             mask_grp(parc_grp==ROI_exc_code(c),:) = 0;
%             mask_grp(:,parc_grp'==ROI_exc_code(c)) = 0;
%         end
        
        parc_ind_exc = ismember(parc_ind, ROI_exc_code); % find the values of parc to exclude
        mask_ind = mask_ind .* ~(parc_ind_exc + parc_ind_exc'); % set those values (in either dimension) to 0

        parc_grp_exc = ismember(parc_grp, ROI_exc_code); 
        mask_grp = mask_grp .* ~(parc_grp_exc + parc_grp_exc');

    end
    
    %% apply the mask to the FC matrix
    fc_ind_inter = fc(logical(mask_ind));
    fc_grp_inter = fc(logical(mask_grp));
   
    % get mean FC
    sep_ind(s) = mean(fc_ind_inter(:));
    sep_grp(s) = mean(fc_grp_inter(:)); %#ok<*AGROW> 
end
fc_separation.ind = sep_ind;
fc_separation.grp = sep_grp;
