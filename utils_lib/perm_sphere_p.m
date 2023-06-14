% Function to generate a p-value for the spatial correlation between two parcellated cortical surface maps, 
% using a set of spherical permutations of regions of interest (which can be generated using the function "rotate_parcellation").
% The function performs the permutation in both directions; i.e.: by permute both measures, 
% before correlating each permuted measure to the unpermuted version of the other measure
%
% Inputs:
% x                 one of two maps to be correlated                                                                    vector
% y                 second of two maps to be correlated                                                                 vector
% perm_id           array of permutations, from set of regions to itself (as generated by "rotate_parcellation")        array of size [n(total regions) x nrot]
% corr_type         type of correlation                                                                                 "spearman" (default) or "pearson"
%
% Output:
% p_perm            permutation p-value
%
% Franti?ek Vá?a, fv247@cam.ac.uk, June 2017 - June 2018

function p_perm = perm_sphere_p(x,y,perm_id,corr_type)

% default correlation
if nargin < 4
    corr_type = 'spearman';
end

nroi = size(perm_id,1);  % number of regions
nperm = size(perm_id,2); % number of permutations

rho_emp = corr(x,y,'type',corr_type);     % empirical correlation

% permutation of measures
x_perm = zeros(nroi,nperm);
y_perm = zeros(nroi,nperm);
for r = 1:nperm
    for i = 1:nroi
        x_perm(i,r) = x(perm_id(i,r)); % permute x
        y_perm(i,r) = y(perm_id(i,r)); % permute y
    end
end

% corrrelation to unpermuted measures
rho_null_xy = zeros(nperm,1);
for r = 1:nperm
    rho_null_xy(r) = corr(x_perm(:,r),y,'type',corr_type); % correlate permuted x to unpermuted y
    rho_null_yx(r) = corr(y_perm(:,r),x,'type',corr_type); % correlate permuted y to unpermuted x
end

% p-value definition depends on the sign of the empirical correlation
if rho_emp > 0
    p_perm_xy = sum(rho_null_xy > rho_emp)/nperm;
    p_perm_yx = sum(rho_null_yx > rho_emp)/nperm;
else
    p_perm_xy = sum(rho_null_xy < rho_emp)/nperm;
    p_perm_yx = sum(rho_null_yx < rho_emp)/nperm;
end

% average p-values
p_perm = (p_perm_xy + p_perm_yx)/2;

% print(['p = ' num2str(sum(rho.null>rho.emp)/nperm)])

end

% nroi = size(perm_id,1);  % number of regions
% nperm = size(perm_id,2); % number of permutations
% 
% rho_emp = corr(x,y,'type',corr_type);     % empirical correlation
% 
% % 1) one direction of permutation
% x_perm = zeros(nroi,nperm);
% for r = 1:nperm; for i = 1:nroi; x_perm(i,r) = x(perm_id(i,r)); end; end % permute one measure (x)
% 
% rho_null_xy = zeros(nperm,1);
% for r = 1:nperm; rho_null_xy(r) = corr(x_perm(:,r),y,'type',corr_type); end % correlate to second (unpermuted) measure (y)
% 
% % p-value definition depends on the sign of the empirical correlation
% if rho_emp > 0
%     p_perm_xy = sum(rho_null_xy > rho_emp)/nperm;
% else
%     p_perm_xy = sum(rho_null_xy < rho_emp)/nperm;
% end
% 
% % 2) second direction of permutation
% y_perm = zeros(nroi,nperm);
% for r = 1:nperm; for i = 1:nroi; y_perm(i,r) = y(perm_id(i,r)); end; end % permute one measure (y)
% 
% rho_null_yx = zeros(nperm,1);
% for r = 1:nperm; rho_null_yx(r) = corr(y_perm(:,r),x,'type',corr_type); end % correlate to second (unpermuted) measure (x)
% 
% % p-value definition depends on the sign of the empirical correlation
% if rho_emp > 0    
%     p_perm_yx = sum(rho_null_yx > rho_emp)/nperm;
% else
%     p_perm_yx = sum(rho_null_yx < rho_emp)/nperm;
% end
