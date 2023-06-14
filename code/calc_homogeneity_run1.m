function homogeneity = calc_homogeneity_run1(setup,ROI_exc)
% This function calculate cortical functional homogeneity, normalised by
% parcel size and plots rainclouds for results

% Inputs: Inputs: setup - path to where the setup structure (look at code/setup.m) is saved
%                 ROI_exc: list of regions to be excluded - OPTIONAL

% Outputs: homogeneity - structure with a list of homogeneity scores for
%                        individualised and group-based parcellation for  
%                        every control and for every patient
%                      - raincloud plot with scores for every group and
%                        parcellation

% set global variables
load(setup);

% set list of subjects that have a 2
subj = [];
subj_folder = dir(fullfile(run_02_surface, 'sub*'));
for s = 1:length(subj_folder)
    sub = regexprep(subj_folder(s).name, 'sub-','');
    subj(s) = str2num(sub);
end

%% get Nx1 group parcellation
    [vertices_lh_grp, label_lh_grp, colortable_lh_grp] = read_annotation(grp_annot_lh);
    [vertices_rh_grp, label_rh_grp, colortable_rh_grp] = read_annotation(grp_annot_rh);
    parc_grp = cat(1,label_lh_grp,label_rh_grp);
    parc_grp(parc_grp==65793) = 0; % change background label to 0
    parc_grp1 = parc_grp;

for s = 1:length(subj)
%    if ismember(subj(s), subj_run_2)
	    parc_grp = parc_grp1;
	    
	    %% get a NxT data matrix 
	    img_lh = MRIread(append(IMG_DIR,'/sub-',num2str(subj(s)),'/sub-',num2str(subj(s)),'_run-01_lh_medialwall_fillin.mgz'));
	    img_rh = MRIread(append(IMG_DIR,'/sub-',num2str(subj(s)),'/sub-',num2str(subj(s)),'_run-01_rh_medialwall_fillin.mgz'));
	    data_l = squeeze(img_lh.vol);
	    data_r = squeeze(img_rh.vol);
	    data = cat(1,data_l,data_r);

	
	    %% get Nx1 ind parcellation
	    [vertices_lh_ind, label_lh_ind, colortable_lh_ind] = read_annotation(append(PARC_DIR_IND,'/lh.sub-',num2str(subj(s)),'_Rest_gpip_labels.annot'));
	    [vertices_rh_ind, label_rh_ind, colortable_rh_ind] = read_annotation(append(PARC_DIR_IND,'/rh.sub-',num2str(subj(s)),'_Rest_gpip_labels.annot'));
	    parc_ind = cat(1,label_lh_ind,label_rh_ind);
	    
	    %% calculate mean FC homogeneity
	    fc_hom_grp = calc_cortical_homogeneity(parc_grp, data, 'mean_FC');
	    fc_hom_ind = calc_cortical_homogeneity(parc_ind, data, 'mean_FC');
	    
	    % remove ROIs and verticecs in them 
	    if nargin >= 2
	    	fc_hom_grp(ROI_exc,:) = [];
	    	fc_hom_ind(ROI_exc,:) = [];
	       	hom_grp_not_size(:,s) = fc_hom_grp;
            hom_ind_not_size(:,s) = fc_hom_ind;
	    	for r = 1:length(ROI_exc)
	        	if ROI_exc(r) > n_parc/2
	            	rr = ROI_exc(r)-(n_parc/2)+1; % change per parc
	            	v = colortable_rh_grp.table(rr,5);
	            	parc_ind(parc_ind==v) = [];
	            	parc_grp(parc_grp==v) = [];
	        	else
	            	rr = ROI_exc(r)+1;
	            	v = colortable_lh_grp.table(rr,5);
	            	parc_ind(parc_ind==v) = [];
	            	parc_grp(parc_grp==v) = [];
	        	end
	    	end
	    end
	    
	    hom_grp_size = calc_mean_parcel_size_normalized(fc_hom_grp,parc_grp);
	    hom_ind_size = calc_mean_parcel_size_normalized(fc_hom_ind,parc_ind);
	    
	    %% add it to the results matrix
	    Hom_ind(s) = hom_ind_size;
	    Hom_grp(s) = hom_grp_size;
	end
%end
hom_ind_pat = [];
hom_ind_con = [];
hom_grp_pat = [];
hom_grp_con = [];

for s = 1:length(subj)
%	if ismember(subj(s), subj_run_2)
    	if ismember(subj(s),patients)
    	    hom_ind_pat(end+1) = Hom_ind(s);
    	    hom_grp_pat(end+1) = Hom_grp(s);
    	elseif ismember(subj(s),controls)
    	    hom_ind_con(end+1) = Hom_ind(s);
    	    hom_grp_con(end+1) = Hom_grp(s);
    	end
%    end
end

% plot reaincloud plots for homogeneity
%figure ; hold on ; raincloud_plot(hom_grp_pat, '#ff0202') ; raincloud_plot_3(hom_ind_pat, '#2c7bb6') ; raincloud_plot_1(hom_grp_con, '#ff9191') ; raincloud_plot_2(hom_ind_con, '#abd9e9'); xlabel('homogeneity');

% organise output variables
homogeneity.ind_patients = hom_ind_pat;
homogeneity.ind_controls = hom_ind_con;
homogeneity.grp_patients = hom_grp_pat;
homogeneity.grp_controls = hom_grp_con;
homogeneity.ind_per_parcel = hom_ind_not_size;
homogeneity.grp_per_parcel = hom_grp_not_size;
