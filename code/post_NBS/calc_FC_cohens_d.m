function FC_cohens_d = calc_FC_cohens_d(setup)
% This fucntion calculates the effect size, using Cohen's d, of the
% difference in FC between patients and controls using individualized or
% group-based parcellations
% Inputs: setup - string with the path to the setup.m file
% Outputs: FC_cohens_d - structure cointainmg matrices two lists: effect
% size for every edge for individualized and group-based parc
%          figure with a raincloud plot showing effect size for FC for
%          every edge


load((setup), 'OUTPUT_DIR');
%% load nbs outputs for the GLM inputs
grp = load(append(OUTPUT_DIR,'/grp_nbs.mat'));
ind = load(append(OUTPUT_DIR,'/ind_nbs.mat'));

grp_FC = grp.nbs.GLM.y;
ind_FC = ind.nbs.GLM.y;

group_labels = grp.nbs.GLM.X(:,1);

%% separate patients from controls
% for s = 1:length(group_labels)
%      if group_labels(s) == 1
%          grp_controls(s,:) = grp_FC(s,:);
%          ind_controls(s,:) = ind_FC(s,:);
%      elseif group_labels(s,:) == 0
%          grp_patients(s,:) = grp_FC(s,:);
%          ind_patients(s,:) = ind_FC(s,:);
%      end
% end

grp_controls = grp_FC(group_labels==1,:);
ind_controls = ind_FC(group_labels==1,:);

grp_patients = grp_FC(group_labels==0,:);
ind_patients = ind_FC(group_labels==0,:);


%% calculate cohens d between them 

for edge = 1:size(grp_FC,2)
    grp_d(1,edge) = computeCohen_d(grp_patients(:,edge), grp_controls(:,edge));
    ind_d(1,edge) = computeCohen_d(ind_patients(:,edge), ind_controls(:,edge));
end

FC_cohens_d.grp = grp_d;
FC_cohens_d.ind = ind_d;

% plot rainclouds 
%figure; 
%subplot(3,2, [2 4]);
raincloud_plot_pl(grp_d,'#EDB120','#D95319',0.6); 
raincloud_plot_pl(ind_d,'#0072BD','#0072BD',1.8);
xlabel('effect size');



