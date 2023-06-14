function parcels_size = calc_parcels_size(volume)
% calc_parcels_size.m
%
% Calculate volume of each parcel
%
% Input: volume        : volume to be analyzed (array)
%
% Output: parcels_size : size in voxels of each parcel (array)
%
% Original: James Pang, Monash University, 2021

%%

parcels = unique(volume(volume>0));
parcels_size = zeros(1,length(parcels));

for parcel_ind = 1:length(parcels)
    parcel_interest = parcels(parcel_ind);

    parcels_size(parcel_ind) = sum(volume==parcel_interest,'all');
end