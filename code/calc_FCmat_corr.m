function corr_fcmat = calc_FCmat_corr(setup)

% This function calculates the Pearson correlation between FC matrices 
% generated with two different parcellations with the same amount of parcels.
%
% Inputs: setup - path to where the setup structure (look at code/setup.m) is saved
%					
% Outputs: list of correlations, with one entry per subject
%		   raincloud plot of the correlation values

% get global variables
load(setup);

% calculate correlations
corr_fcmat = zeros(1,length(subj));
for s = 1:length(subj)
    grp = readmatrix(append(OUTPUT_DIR,'/FC/grp/sub-',num2str(subj(s)),'_fc_matrix.txt'));
    ind = readmatrix(append(OUTPUT_DIR,'/FC/ind/sub-',num2str(subj(s)),'_fc_matrix.txt'));
    grp = grp( triu( true(size(grp)),1 ) );
    ind = ind( triu( true(size(ind)),1 ) );
    c = corr(ind,grp);
    corr_fcmat(1,s) = c;
end


%% plots raincloud plot of correlations 
c = '#39ac73';
figure;
% subplot(3, 2, 1)
raincloud_plot(corr_fcmat,c);
xlabel('correlation coefficient');
ylabel('subjects');
