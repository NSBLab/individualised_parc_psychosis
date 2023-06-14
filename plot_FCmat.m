function plot_FCmat(setup,ts,parc,ROI_exc)

% Generates FC matrices and plots them 
% Inputs: ts - matrix with averaged timeseries for every subject [txn_parcxs]
%         t = timepoints
%         n_parc = number of parcels, before ROI exclusion
%         s = number of subjects

%         setup - path to where the setup structure (look at code/setup.m) is saved

%         ROI_exc - list of ROI that you want to exclude - OPTIONAL

%         parc - string delineating which parcellation you used for this data

% This function doesn't have any outputs, as it save FC matrices and plots
% to ouput directory

% get global variables
load(setup);

mkdir (append(OUTPUT_DIR,'/FC'));
mkdir (append(OUTPUT_DIR,'/FC/',parc));
mkdir (append(OUTPUT_DIR,'/FC_plots'));
for s = 1:length(subj)
    
    % calculate correlation and save matrix
    FC = corr(ts(:,:,s));
    
    % remove dropout ROIs and save matrix
    if nargin == 4
        FC([ROI_exc],:) = [];
        FC(:,[ROI_exc]) = [];
    end
    writematrix(FC, append(OUTPUT_DIR,'/FC/',parc,'/sub-',num2str(subj(s)),'_fc_matrix.txt'));

    % plot FC matrix
    clims = [-1 1];
    imagesc(FC, clims);
    colormap('jet');
    colorbar;
    ylabel('Node');
    title(append(num2str(subj(s)),' ', parc), 'FontSize', 8);
    print(append(OUTPUT_DIR,'/FC_plots/sub-',num2str(subj(s)),'_',parc,'_fc_matrix.png'), '-dpng');
end               

