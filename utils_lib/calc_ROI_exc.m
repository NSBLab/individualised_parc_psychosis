function [subject_drop, ROI_drop] = ROI_exc(setup,ts,cf)
% calculates mean signal for each region, then finds the elbow of that
% disbtribution. It then sets the elbow as a threshold for signal
% dropout.

% Inputs: subj - subject list
%         ts - matrix with ever subject's avg timeseries [t x parc x s]
%               t = number of timpeoints
%               parc = number of parcels
%               s = number of subjects
%         cf - indicates which cutoff to use - sometimes the biggest
%              pairwise difference (pwd) is between two regions with strong
%              signal, so the function might flag the majority of the
%              as having signal dropout, in which case might be
%              beneficial to only look at pwd in the bottom half of
%              the distribution. i.e. regions with lower signal
%              1 - looks at the whole distribution - default
%              2 - looks at second half i.e. only regions w low signal
%
% Outputs: subject_drop - list of every subject and how many regions have
%                         signal dropout in each of them
%          ROI_exc - list of every region and the total amount of subjects
%                    that each region has been found to have low signal in


load(setup);

if nargin < 3
    cf = 1;
end


%% setup variables
p_len = size(ts,2); % amount of parcels
n_subj = size(ts, 3); % number of subjects
subject_drop = [reshape(subj, [], 1), nan(length(subj), 1)];


%% create a matrix with mean signal across subjects and regions

mean_ts = squeeze(mean(ts)); % p_len x n_subj - mean value across time for each roi in each subject
[b, c] = sort(mean_ts, 'descend');
mean_roi_sorted = b'; 
ind = (c+1)';


%% find subject_drop
for s = 1:n_subj

    if cf == 1; currentData = mean_roi_sorted(s,:);
    elseif cf == 2; currentData = mean_roi_sorted(s,(p_len/2)+1:end); end

    % calculate pwd - change loop for diff parcellation scales
    % find largest pwd = 'elbow' of distribution
    pwd_sub = abs(diff(currentData));
    [~, cutoff] = max(pwd_sub);

    if cf == 1; dropout_sub = ind(s, cutoff+1:end);
    elseif cf == 2; dropout_sub = ind(s, cutoff+(p_len/2):end); end

    dropout{s} = dropout_sub; %#ok<AGROW>
    subject_drop(s,2) = length(dropout{s});

end


%% find ROI_drop
% count the number of time each ROI appears in dropout
% but don't count it multiple times for each subject
temp = cellfun(@unique, dropout, 'UniformOutput', false);
ROI_drop = histcounts( cell2mat(temp), 0.5:1:(p_len+0.5) )';

end
























%%

% % % % % % mean_roi=(sub,parcels)
% % % % % for s = 1:length(subj)
% % % % %     ts_s = ts(:,:,s);
% % % % %     mean_roi_sub = mean(ts_s);
% % % % %     mean_roi(s,2:end) = mean(ts_s);
% % % % %     mean_roi(s,1) = subj(s);
% % % % %     mean_roi_sorted_sub = sort(mean_roi_sub, 'descend');
% % % % %     mean_roi_sorted(s,1:end) = mean_roi_sorted_sub;
% % % % % end
% % % % %
% % % % % for s = 1:length(subj)
% % % % %     % save the region indexes for the sorted list
% % % % %     for j = 1:p_len
% % % % %         ind(s,j) = find(mean_roi(s,:)==mean_roi_sorted(s,j));
% % % % %     end
% % % % % end



%%

% % % % % for s = 1:n_subj
% % % % %     if cf == 1
% % % % %         % calculate pwd - change loop for diff parcellation scales
% % % % %         pwd_sub = zeros(1,p_len-1);
% % % % %         for ii = 1:length(pwd_sub)
% % % % %             pwd_sub(1,ii) = (abs(mean_roi_sorted(s,ii) - mean_roi_sorted(s,ii+1)));
% % % % %         end
% % % % %         % find largest pwd = 'elbow' of distribution
% % % % %         cutoff(s,2) = find(max(pwd_sub)==pwd_sub);
% % % % %         cutoff(s,1) = subj(s);
% % % % %
% % % % %         %list the regions below the elbow
% % % % %         dropout_sub = ind(s,cutoff(s,2)+1:end);
% % % % %         dropout{s} = dropout_sub;
% % % % %         total_drop(s,1) = subj(s);
% % % % %         total_drop(s,2) = length(dropout{s});
% % % % %
% % % % %         subject_drop = total_drop;
% % % % %     end
% % % % %
% % % % %     %% calc pwd and cutoff point only looking at the second half of the
% % % % %     % ditribution
% % % % %     if cf == 2
% % % % %         sorted2(s,:) = mean_roi_sorted(s,(p_len/2)+1:end);
% % % % %
% % % % %         % calculate pwd - change loop for diff parcellation scales
% % % % %         pwd_sub2 = zeros(1,(p_len/2)-1);
% % % % %         for ii = 1:length(pwd_sub2)
% % % % %             pwd_sub2(1,ii) = abs(sorted2(s,ii) - sorted2(s,ii+1));
% % % % %         end
% % % % %         % find largest pwd = 'elbow' of distribution
% % % % %         cutoff2(s,2) = find(max(pwd_sub2)==pwd_sub2);
% % % % %         cutoff2(s,1) = subj(s);
% % % % %
% % % % %         %list the regions below the elbow
% % % % %         dropout_sub2 = ind(s,cutoff2(s,2)+(p_len/2):end);
% % % % %         dropout2{s} = dropout_sub2;
% % % % %         total_drop2(s,1) = subj(s);
% % % % %         total_drop2(s,2) = length(dropout2{s});
% % % % %
% % % % %         subject_drop = total_drop2;
% % % % %     end
% % % % % end






% % % % % %% calc how often each region appears in dropout
% % % % % % TODO assess removal of inner for loop
% % % % %
% % % % %
% % % % % if cf == 1
% % % % %     for r = 1:p_len
% % % % %         freq = 0;
% % % % %         for s = 1:length(subj)
% % % % %             if ismember(r,dropout{s})
% % % % %                 freq = freq + 1;
% % % % %             end
% % % % %         end
% % % % %         ROI_drop(r,1) = freq;
% % % % %     end
% % % % % end
% % % % %
% % % % %
% % % % % if cf == 2
% % % % %     for r = 1:p_len
% % % % %         freq = 0;
% % % % %         for s = 1:length(subj)
% % % % %             if ismember(r,dropout2{s})
% % % % %                 freq = freq + 1;
% % % % %             end
% % % % %         end
% % % % %         ROI_drop(r,1) = freq;
% % % % %     end
% % % % % end




% % % % % %% calc how often each region appears in dropout
% % % % % % TODO assess removal of inner for loop
% % % % %
% % % % % if cf == 1; distributionToAssess = dropout;
% % % % % elseif cf == 2; distributionToAssess = dropout2; end
% % % % %
% % % % % for r = 1:p_len
% % % % %     freq = 0;
% % % % %     for s = 1:length(subj); freq = freq + ismember(r,distributionToAssess{s}); end
% % % % %     ROI_drop(r,1) = freq;
% % % % % end
% % % % %
% % % % % ROI_drop;

