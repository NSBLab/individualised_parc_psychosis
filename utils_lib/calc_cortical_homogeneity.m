function homogeneity_parcel = calc_cortical_homogeneity(parc, data, metric)
% calc_cortical_parc_metrics.m
%
% Calculate cortical parcellation homogeneity based on the strength of 
% within functional connectivity.
%
% Inputs: parc               : parcellation [Nx1]
%                              N = number of vertices
%         data               : fMRI time series data [NxT]
%                              T = time points
%         metric             : performance metric to calculate (string)
%                              Possible metrics:
%                              'mean_zFC' = average of zFC within a parcel
%                              'mean_FC' = average of FC within a parcel
%
% Output: homogeneity_parcel : homogeneity value per parcel [num_parcelsx1]
%
% Original: James Pang, Monash University, 2022

%%

if nargin<3
    metric = 'mean_FC';
end

num_vertices = size(parc,1);
parcels = unique(parc(parc>0));
num_parcels = length(parcels);

homogeneity_parcel = zeros(num_parcels,1);
size_data = size(data);

for parcel_ind = 1:num_parcels
    parcel_interest = parcels(parcel_ind);
    ind_parcel = find(parc==parcel_interest);

    if size_data(1)==num_vertices
        data_parcel = data(ind_parcel,:)';
        T = size_data(2);
    elseif size_data(2)==num_vertices
        data_parcel = data(:,ind_parcel);
        T = size_data(1);
    end
    data_parcel_normalized = calc_normalize_timeseries(data_parcel);
    data_parcel_normalized(isnan(data_parcel_normalized)) = 0;

    FC = data_parcel_normalized'*data_parcel_normalized;
    FC = FC/T;
    zFC = atanh(FC);
        
    FC(isnan(FC)) = 0;
    zFC(isnan(zFC)) = 0;
    
    if strcmpi(metric, 'mean_zFC')
        triu_ind = find(triu(ones(size(zFC)),1));
        homogeneity_parcel(parcel_ind) = mean(zFC(triu_ind));
    elseif strcmpi(metric, 'mean_FC')
        triu_ind = find(triu(ones(size(FC)),1));
        homogeneity_parcel(parcel_ind) = mean(FC(triu_ind));
    end
end
    
function data_normalized = calc_normalize_timeseries(data)
% calc_normalize_timeseries.m
%
% Normalize timeseries with respect to mean and std
%
% Input: data         : fMRI data [TxN]
%                       T = length of time
%                       N = number of points
%
% Output: data_normalized
%
% Original: James Pang, Monash University, 2022

%%

T = size(data,1);
data_normalized = detrend(data, 'constant');
data_normalized = data_normalized./repmat(std(data_normalized),T,1);
