function mean_normalized = calc_mean_parcel_size_normalized(data, parc)
% calc_mean_parcel_size_normalized.m
%
% Calculate mean of data with parcel size normalization
%
% Inputs: data            : data to be analyzed (2D array)
%                           Note: length of data should be the number of
%                           parcels in parc
%         parc            : parcellation in either volume or surface (array)
%
% Output: mean_normalized : normalized mean (array)
%
% Original: James Pang, Monash University, 2022

%%
parcel_sizes = calc_parcels_size(parc);

if size(data,1)==length(parcel_sizes)
    parcel_sizes = parcel_sizes';
    
    norm_factor = repmat(parcel_sizes, 1, size(data,2));
    mean_normalized = nansum(data.*norm_factor, 1)./nansum(norm_factor, 1);
elseif size(data,2)==length(parcel_sizes)
    norm_factor = repmat(parcel_sizes, size(data,1), 1);
    mean_normalized = nansum(data.*norm_factor, 2)./nansum(norm_factor, 2);
end

function parcel_size = calc_parcel_size(parc)
% calc_parcels_size.m
%
% Calculate volume of each parcel
%
% Input: parc          : parcellation in either volume or surface (array)
%
% Output: parcel_size : size in voxels or vertices of each parcel (row vector)

%%
% can be sped up/sumplified using histcounts: try 
% parcel_size = histcounts( nonzeros(parc(:)) , (0:length(unique(nonzeros(parc(:)))))+0.5 );
parcels = unique(parc(parc>0));
parcel_size = zeros(1,length(parcels));

for parcel_ind = 1:length(parcels)
    parcel_interest = parcels(parcel_ind);

    parcel_size(parcel_ind) = sum(parc==parcel_interest,'all');
end
