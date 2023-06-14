function [ind_tdist, grp_tdist] = plot_NBS_tdist(setup)

% This script plots the t-distribution for the the unthresholded t-matrices computed using NBS
% Input - directory for setup file (string)
% Output - histogram of t-distributions

% load OUTPUT_DIR
load((setup), 'OUTPUT_DIR');


%% load and name the t-stats matrices for each NBS test
IND = load(append(OUTPUT_DIR,'/ind_nbs.mat'));
ind = IND.nbs.NBS.test_stat;

GRP = load(append(OUTPUT_DIR,'/grp_nbs.mat'));
grp = GRP.nbs.NBS.test_stat;

%% create a vector with the upper triangle values of the t-matrix
ind_tdist = ind( triu(true(size(ind)),1) );
grp_tdist = grp( triu(true(size(grp)),1) );



figure;
subplot(3,1,[1,2]);
h = histfit(ind_tdist);
set(h(1),'facecolor','#0072BD','facealpha',.4, 'edgealpha', 0); set(h(2),'color', '#0072BD','LineWidth',3);
hold on
legend('GPIP');
g = histfit(grp_tdist);
set(g(1),'facecolor','#EDB120','facealpha',.4, 'edgealpha',0); set(g(2), 'color', '#D95319','LineWidth',3);
legend('individualized','','group-based','');
xline(mean(ind_tdist), '--', 'color', '#0072BD',   'LineWidth',2);
xline(mean(grp_tdist), '--', 'color', '#D95319', 'LineWidth',2);
xlabel('t-value');
ylabel('edges');
box off

       
