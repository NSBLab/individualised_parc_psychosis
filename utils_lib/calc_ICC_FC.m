%function [] = calc_ICC_FC(setup, ROI_exc)

load(setup);

% get global variables
run1_dir = '/home/ptha53/kg98/Priscila/honours/GPIP_run-01/indiv_parcellation/100_results';
run2_dir = '/home/ptha53/kg98/Priscila/honours/GPIP_run-02/GPIP/indiv_parcellation';
%get subj list
subj = [];
subj_folder = dir(fullfile(run_02_surface, 'sub*'));
for s = 1:length(subj_folder)
    sub = regexprep(subj_folder(s).name, 'sub-','');
    subj(s) = str2num(sub);
end
subj(subj==1085) = [];
subj(subj==3017) = [];
subj(subj==3039) = [];
subj(subj==4057) = [];

for s = 1:length(subj)
    % read ts and calculate FC
    ts_lh = dlmread(append(run2_dir,'/gpip_annot/run-01/sub-',num2str(subj(s)),'_run-02_gpip_7N_avgts_lh.dat')); % read avg ts file for left hemisphere
	ts_rh = dlmread(append(run2_dir,'/gpip_annot/run-01/sub-',num2str(subj(s)),'_run-02_gpip_7N_avgts_rh.dat')); % read avg ts file for right hemisphere
	ts=[ts_lh ts_rh];
    ind_run2 = corr(ts(:,:));
    
    % remove dropout ROIs
    ind_run2([ROI_exc],:) = [];
    ind_run2(:,[ROI_exc]) = [];
   
    %read FC matrices for run 1
    ind_run1 = readmatrix(append(run1_dir,'/GPIP/fc/sub-',num2str(subj(s)),'_fc.txt'));
    
    %vectorise matrices
    ind_run1 = ind_run1(find(triu(ones(length(ind_run1),length(ind_run1)),1)));
    ind_run2 = ind_run2(find(triu(ones(length(ind_run2),length(ind_run2)),1)));
    
    ind_run1_s(:,s) = ind_run1;
    ind_run2_s(:,s) = ind_run2;

    
    %% do the same for group parc
    ts_lh = dlmread(append(run2_dir,'/schaefer/sub-',num2str(subj(s)),'_run-02_gpip_7N_avgts_lh.dat')); % read avg ts file for left hemisphere
	ts_rh = dlmread(append(run2_dir,'/schaefer/sub-',num2str(subj(s)),'_run-02_gpip_7N_avgts_rh.dat')); % read avg ts file for right hemisphere
	ts=[ts_lh ts_rh];
    grp_run2 = corr(ts(:,:));
    
    % remove dropout ROIs and save matrix
    grp_run2([ROI_exc],:) = [];
    grp_run2(:,[ROI_exc]) = [];
   
    
    grp_run1 = readmatrix(append(run1_dir,'/Schaefer/fc/sub-',num2str(subj(s)),'_fc.txt'));
    grp_run1 = grp_run1(find(triu(ones(length(grp_run1),length(grp_run1)),1)));
    grp_run2 = grp_run2(find(triu(ones(length(grp_run2),length(grp_run2)),1)));
    
    grp_run1_s(:,s) = grp_run1;
    grp_run2_s(:,s) = grp_run2;
end
    
%% run ICC

% make a matrix for with the FC values for every subj per edge

for edge = 1:length(ind_run1)
    ind(1,:) = ind_run1_s(edge,:);
    ind(2,:) = ind_run2_s(edge,:);
    
    [r, ~, ~, ~, ~, ~, p] = ICC(ind, 'C-1');
    
    ICC_ind.r(edge) = r;
    ICC_ind.p(edge) = p;
    
    % do same for grp
    
    grp(1,:) = grp_run1_s(edge,:);
    grp(2,:) = grp_run1_s(edge,:);
    
    [r, ~, ~, ~, ~, ~, p] = ICC(grp, 'C-1');
    ICC_grp.r(edge) = r;
    ICC_grp.p(edge) = p;
end

    

    