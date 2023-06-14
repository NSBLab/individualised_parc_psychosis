function percentage_vertices_changed = calc_vertices_change(setup,ROI)

% Calculates the percentage of vertices that were allocated to different
% parcels between parcellation method. Then separates them between
% patients and controls.

% Inputs: setup - path to where the setup structure (look at code/setup.m) is saved
%         ROI (OPTIONAL) - list of ROIs that are meant to be excluded

% Outputs: percentage_vertices_changed.patients - percentage of vertices
%                              that were relabeled in patients.
%          percentage_vertices_changed.controls - percentage of vertices
%                              that were relabeled in controls.

% grab global variables
load(setup);

%% create an empty matrix for percentage change results
p_change = nan(length(subj), 1);

%% loading labels and concatenating right and left hemispheres for group annot
[~, label_lh_group, colortable_lh_group] = read_annotation(grp_annot_lh);
[~, label_rh_group, colortable_rh_group] = read_annotation(grp_annot_rh);
label_group_orig = cat(1,label_lh_group,label_rh_group);

if nargin == 2
    % getting colortable code for excluded regions
    vert_r = [];
    vert_l = [];
    for r = 1:length(ROI)
        if ROI(r) > n_parc/2
            rr = ROI(r)-((n_parc/2)-1);
            v = colortable_rh_group.table(rr,5);
            vert_r(1,end+1) = v; %#ok<*AGROW>
        else
            rr = ROI(r)+1;
            v = colortable_lh_group.table(rr,5);
            vert_l(1,end+1) = v;
        end
    end
    vert = cat(2,vert_l,vert_r);
end

%%
for s = 1:length(subj)

    % get labels for individualised parcellation
    [~, label_lh_ind, ~] = read_annotation(append(PARC_DIR_IND,'/lh.sub-',num2str(subj(s)),'_Rest_gpip_labels.annot'));
    [~, label_rh_ind, ~] = read_annotation(append(PARC_DIR_IND,'/rh.sub-',num2str(subj(s)),'_Rest_gpip_labels.annot'));
    label_ind = cat(1,label_lh_ind,label_rh_ind);

    % change backround values on schaefer to 0 to match individualised labels
    label_group = label_group_orig;
    label_group(label_group==65793) = 0; % remove background

    if nargin == 2 % remove vertices that were removed for both parcellations in each ROI
        for ii = 1:length(vert)
            exc_group = ismember(label_group, vert(ii));
            exc_ind = ismember(label_ind, vert(ii));
            exc_vert = exc_group & exc_ind;
            label_group(exc_vert) = [];
            label_ind(exc_vert) = [];

        end
    end

    % check how many vertices have different labels between groups
    p_change(s) = (nnz(label_group~=label_ind)/length(label_ind));

end

%%
percentage_vertices_changed.controls = p_change( ismember(subj,controls) )';
percentage_vertices_changed.patients = p_change( ismember(subj,patients) )';

subplot(3,2,[1 3]); hold on ;
raincloud_plot(percentage_vertices_changed.controls, '#92E3FF') ;
raincloud_plot_3(percentage_vertices_changed.patients, '#90BCC8');
xlabel('proportion of vertices'); ylabel('subjects');
legend('control', 'patients'); hold off
