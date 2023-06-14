function [adj_ind, adj_grp] = make_adj_matrix(setup)
% This script saves an adjacency matrix from NBS output 
% for more details seehttps://www.nitrc.org/projects/nbs/

% set path to nbs output
load((setup), 'OUTPUT_DIR');

nbs_ind = load(append(OUTPUT_DIR,'/ind_nbs.mat'));
nbs_grp = load(append(OUTPUT_DIR,'/grp_nbs.mat'));

% save adjacency matrices
adj_ind=nbs_ind.nbs.NBS.con_mat{1}+nbs_ind.nbs.NBS.con_mat{1}';
dlmwrite(append(OUTPUT_DIR,'/adj_ind.txt'),full(adj_ind),'delimiter',' ','precision','%d');

adj_grp=nbs_grp.nbs.NBS.con_mat{1}+nbs_grp.nbs.NBS.con_mat{1}';
dlmwrite(append(OUTPUT_DIR,'/adj_grp.txt'),full(adj_grp),'delimiter',' ','precision','%d');




