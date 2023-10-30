function parcel_size_corr = plot_parcel_size_correlations(setup)

% calculates spearman correlation between parcel size in individualized
% parcellation and degree of dysconnectivity per node and edge
% dysconectivity 

load((setup), 'OUTPUT_DIR');
load(append(OUTPUT_DIR,'/parcel_size.mat'));

% calculate degree of dysconnectivity per parcel
adj_ind = readmatrix(append(OUTPUT_DIR,'/adj_ind.txt'));
degree = sum(adj_ind);
% calculate correlation between degree of dysonconnectivity and parcel size
% difference bw patients and controls
[r_degree, p_degree] = corr(degree', ttest_ind','Type','Spearman');

% calculate correlation between edge dysonconnectivity and parcel size
% difference bw patients and controls
load(append(OUTPUT_DIR,'/ind_nbs.mat'));
edge_t = mean(nbs.NBS.test_stat);
[r_edge, p_edge] = corr(edge_t', ttest_ind','Type','Spearman');

parcel_size_corr.r_degree = r_degree;
parcel_size_corr.p_degree = p_degree;
parcel_size_corr.r_edge = r_edge;
parcel_size_corr.p_edge = p_edge;

%% plot correlations
% plot degree/parcel size correlation
Fit_degree = polyfit(ttest_ind,degree,1); % x = x data, y = y data, 1 = order of the polynomial i.e a straight line 
f_degree = polyval(Fit_degree, ttest_ind);
figure; subplot(2,2,3);
plot(ttest_ind, degree, 'o', ttest_ind, f_degree,'-');
xlabel('node size degree (t-value)');
ylabel('degree');

% plot edge dysconnectivity/ parcel size correlation
Fit_edge = polyfit(ttest_ind,edge_t,1); % x = x data, y = y data, 1 = order of the polynomial i.e a straight line 
f_edge = polyval(Fit_edge, ttest_ind);
subplot(2,2,4);
plot(ttest_ind, edge_t, 'o', ttest_ind, f_edge,'-');
xlabel('node size degree (t-value)');
ylabel('edge strength difference (t-value)');

% plot parcel size difference in patients and controls 
[con, I] = sort(mean(controls));
pat_m = mean(patients);
pat = pat_m(I);
subplot(2,2,[1,2]); hold on; plot((1:length(pat)), pat) ; plot(con);
legend('controls', 'patients', 'Location', 'southeast');
xlabel('node'); ylabel('size difference'); hold off
