% function corr_fcmat_grp = calc_FCmat_corr_intra()

% This function calculates the Pearson correlation between FC matrices 
% generated with two different parcellations with the same amount of parcels.
%
% Inputs: setup - path to where the setup structure (look at code/setup.m) is saved
%					
% Outputs: list of correlations, with one entry per subject
%		   raincloud plot of the correlation values

% get global variables
run1_dir = '/home/ptha53/kg98/Priscila/honours/GPIP_run-01/indiv_parcellation/100_results';
run2_dir = '/home/ptha53/kg98/Priscila/honours/GPIP_run-02/GPIP/indiv_parcellation';
subj = ["sub-1001" "sub-1044" "sub-1086" "sub-2042" "sub-4010" "sub-1002" "sub-1045" "sub-1087" "sub-2044" "sub-4014" "sub-1003" "sub-1047" "sub-1088" "sub-2045" "sub-4022" "sub-1004" "sub-1048" "sub-1089" "sub-2046" "sub-4023" "sub-1006" "sub-1050" "sub-1091" "sub-2048" "sub-4024" "sub-1009" "sub-1051" "sub-1093" "sub-2049" "sub-4027" "sub-1010" "sub-1052" "sub-1094" "sub-2052" "sub-4028" "sub-1012" "sub-1054" "sub-1095" "sub-2062" "sub-4029" "sub-1013" "sub-1056" "sub-1098" "sub-2065" "sub-4030" "sub-1015" "sub-1057" "sub-1099" "sub-3001" "sub-1018" "sub-1060" "sub-1105" "sub-3002" "sub-4035" "sub-1019" "sub-1061" "sub-2001" "sub-3009" "sub-4037" "sub-1020" "sub-1064" "sub-2004" "sub-3020" "sub-4038" "sub-1021" "sub-2005" "sub-3021" "sub-4047" "sub-1022" "sub-1066" "sub-2006" "sub-3022" "sub-4048" "sub-1024" "sub-1067" "sub-2007" "sub-3025" "sub-4049" "sub-1025" "sub-1068" "sub-2008" "sub-3026" "sub-4050" "sub-1026" "sub-1070" "sub-2010" "sub-3027" "sub-4053" "sub-1027" "sub-1071" "sub-2012" "sub-3028" "sub-4059" "sub-1029" "sub-1072" "sub-2014" "sub-3029" "sub-4063" "sub-1031" "sub-1073" "sub-2015" "sub-3030" "sub-4064" "sub-1074" "sub-2016" "sub-3031" "sub-4069" "sub-1033" "sub-1075" "sub-2019" "sub-3032" "sub-4072" "sub-1034" "sub-1076" "sub-2022" "sub-3034" "sub-4074" "sub-1035" "sub-1077" "sub-2023" "sub-3035" "sub-4075" "sub-1036" "sub-1078" "sub-2029" "sub-3040" "sub-4088" "sub-1038" "sub-1079" "sub-2031" "sub-4002" "sub-4091" "sub-1039" "sub-1080" "sub-2033" "sub-4003" "sub-1040" "sub-1081" "sub-2038" "sub-4004" "sub-1041" "sub-1082" "sub-2040" "sub-4005" "sub-1043" "sub-1083" "sub-4006"];

% calculate correlations
corr_fcmat_grp = zeros(1,length(subj));
corr_fcmat_ind = zeros(1,length(subj));

for s = 1:length(subj)
    ts_lh = dlmread(append(run2_dir,'/gpip_annot/run-01/',subj(s),'_run-02_gpip_7N_avgts_lh.dat')); % read avg ts file for left hemisphere
	ts_rh = dlmread(append(run2_dir,'/gpip_annot/run-01/',subj(s),'_run-02_gpip_7N_avgts_rh.dat')); % read avg ts file for right hemisphere
	ts=[ts_lh ts_rh];
    FC_run2 = corr(ts(:,:));
    
    % remove dropout ROIs and save matrix
    FC_run2([ROI_exc],:) = [];
    FC_run2(:,[ROI_exc]) = [];
   
    
    ind_run1 = readmatrix(append(run1_dir,'/GPIP/fc/',subj(s),'_fc.txt'));
    ind_run2 = FC_run2;
    ind_run1 = ind_run1(find(triu(ones(length(ind_run1),length(ind_run1)),1)));
    ind_run2 = ind_run2(find(triu(ones(length(ind_run2),length(ind_run2)),1)));
    c = corr(ind_run2,ind_run1, 'Type', 'Spearman');
    corr_fcmat_ind(1,s) = c;
    
    
    ts_lh = dlmread(append(run2_dir,'/schaefer/',subj(s),'_run-02_gpip_7N_avgts_lh.dat')); % read avg ts file for left hemisphere
	ts_rh = dlmread(append(run2_dir,'/schaefer/',subj(s),'_run-02_gpip_7N_avgts_rh.dat')); % read avg ts file for right hemisphere
	ts=[ts_lh ts_rh];
    FC_run2 = corr(ts(:,:));
    
    % remove dropout ROIs and save matrix
    FC_run2([ROI_exc],:) = [];
    FC_run2(:,[ROI_exc]) = [];
   
    
    grp_run1 = readmatrix(append(run1_dir,'/Schaefer/fc/',subj(s),'_fc.txt'));
    grp_run2 = FC_run2;
    grp_run1 = grp_run1(find(triu(ones(length(grp_run1),length(grp_run1)),1)));
    grp_run2 = grp_run2(find(triu(ones(length(grp_run2),length(grp_run2)),1)));
    c = corr(grp_run2,grp_run1, 'Type', 'Spearman');
    corr_fcmat_grp(1,s) = c;
end

% plots raincloud plot of correlations 
c = '#39ac73';
figure;
raincloud_plot(corr_fcmat_grp,c);
xlabel('correlation coefficient');
ylabel('subjects');
