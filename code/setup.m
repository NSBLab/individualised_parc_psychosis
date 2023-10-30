% This script set up parameters that will be used later in function
%% set up
clear all; close all; clc
gpip_dir = '/full/path/to/directory/with/output/from/indiv/parcellation';
setup_par.GPIP_DIR	= gpip_dir; % directory with all the outputs from GPIP
setup_par.IMG_DIR = append(gpip_dir,'/surface'); % directory with the clean, processed surfaces 
setup_par.PARC_DIR_IND	= append(gpip_dir,'/gpip_annot'); % directory with the annotation files for grp and in parcellation and ind averaged timeseries 
setup_par.OUTPUT_DIR = '/full/path/to/output/directory'; % where you are going to save your ouputs
setup_par.n_parc = 100; % parcellation scale
setup_par.patients = [1001 1002 1003 1004];	% list of patients
setup_par.controls = [1005 1006 1007 1008 1009 1010]; % list of controls
setup_par.grp_annot_lh = '/full/path/to/group-based/parcellation/Schaefer2018/Parcellations/FreeSurfer5.3/fsaverage5/label/lh.Schaefer2018_100Parcels_7Networks_order.annot'; % path and file name to group parcellation annot - left hemisphere
setup_par.grp_annot_rh = '/full/path/to/group-based/parcellation/Schaefer2018/Parcellations/FreeSurfer5.3/fsaverage5/label/rh.Schaefer2018_100Parcels_7Networks_order.annot';% path adn file name to group parcellation annot - right hemisphere
setup_par.run_02_surface = '/full/path/to/out-of-sample/fMRIs'; % path to out of sample images (eg.: run-02) used for homogeneity calculation
% save subject list
subj = [];
subj_folder = dir(fullfile(setup_par.IMG_DIR, 'sub*'));
for s = 1:length(subj_folder)
    sub = regexprep(subj_folder(s).name, 'sub-','');
    subj(s) = str2num(sub);
end
setup_par.subj = subj;

% save structure
mkdir(setup_par.OUTPUT_DIR)
save(append(setup_par.OUTPUT_DIR,'/setup.mat'), '-struct', 'setup_par')

