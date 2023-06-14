load(setup, 'subj', 'patients', 'controls');
fc_pat_v_ind = [];
fc_pat_v_grp = [];
fc_con_v_ind = [];
fc_con_v_grp = [];
fc_pat_ind = [];
fc_pat_grp = [];
fc_con_ind = [];
fc_con_grp = [];

for s = 1: length(subj)
    if ismember(subj(s), patients)
        fc_ind = dlmread(append('/home/ptha53/kg98/Priscila/honours/GPIP_run-01/indiv_parcellation/100_results/GPIP/fc/sub-',num2str(subj(s)),'_fc.txt'));
        fc_grp = dlmread(append('/home/ptha53/kg98/Priscila/honours/GPIP_run-01/indiv_parcellation/100_results/Schaefer/fc/sub-',num2str(subj(s)),'_fc.txt'));
        fc_pat_v_ind(:,end+1) = fc_ind(find(triu(ones(length(fc_ind), length(fc_ind)),1)));
        fc_pat_ind(:,:,end+1) = fc_ind;
        fc_pat_v_grp(:,end+1) = fc_grp(find(triu(ones(length(fc_grp), length(fc_grp)),1)));
        fc_pat_grp(:,:,end+1) = fc_grp;
    elseif ismember(subj(s), controls)
        fc_ind = dlmread(append('/home/ptha53/kg98/Priscila/honours/GPIP_run-01/indiv_parcellation/100_results/GPIP/fc/sub-',num2str(subj(s)),'_fc.txt'));
        fc_grp = dlmread(append('/home/ptha53/kg98/Priscila/honours/GPIP_run-01/indiv_parcellation/100_results/Schaefer/fc/sub-',num2str(subj(s)),'_fc.txt'));
        fc_con_v_ind(:,end+1) = fc_ind(find(triu(ones(length(fc_ind), length(fc_ind)),1)));
        fc_con_ind(:,:,end+1) = fc_ind;
        fc_con_v_grp(:,end+1) = fc_grp(find(triu(ones(length(fc_grp), length(fc_grp)),1)));
        fc_con_grp(:,:,end+1) = fc_grp;
    end
end



mean_pat_ind = mean(fc_pat_ind,3);
mean_pat_grp = mean(fc_pat_grp,3);
mean_con_ind = mean(fc_con_ind,3);
mean_con_grp = mean(fc_con_grp,3);

mean_pat_ind_v = mean(fc_pat_v_ind');
mean_pat_grp_v = mean(fc_pat_v_grp');
mean_con_ind_v = mean(fc_con_v_ind');
mean_con_grp_v = mean(fc_con_v_grp');

[con_ind_so I] = sort(mean_con_ind_v);
pat_ind_so = mean_pat_ind_v(I);
[con_grp_so I] = sort(mean_con_grp_v);
pat_grp_so = mean_pat_grp_v(I);

subplot(3,2,5) ; hold on ; scatter(1:length(pat_ind_so), pat_ind_so, 'marker','.');
scatter(1:length(con_ind_so), con_ind_so, 'marker','.'); 
legend('patients', 'controls'); title('individualized'); hold off;
subplot(3,2,3) ; hold on ; scatter(1:length(pat_grp_so), pat_grp_so, 'marker','.');
scatter(1:length(con_grp_so), con_grp_so, 'marker','.'); 
legend('patients', 'controls'); title('group-based'); hold off

clim = [-0.2 1];
figure; subplot(2,2,1) ; imagesc(mean_pat_ind, clim) ; colorbar ; title('ind patients');
subplot(2,2,2) ; imagesc(mean_con_ind, clim) ; colorbar; title('ind controls');
subplot(2,2,3) ; imagesc(mean_pat_grp, clim) ; colorbar; title('grp patients');
subplot(2,2,4) ; imagesc(mean_con_grp, clim) ; colorbar; title('grp controls');

