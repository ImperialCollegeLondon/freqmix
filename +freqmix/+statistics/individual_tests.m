function [results] = individual_tests(mixing, mixing_type, config)

import freqmix.statistics.hypothesis_tests.*
import freqmix.statistics.utils.*

% set initial parameters
alpha = config.alpha_individual;
cluster_alpha = config.cluster_alpha;
num_permutations = config.n_permutations;

% set parameters specific to mixing type
if isequal(mixing_type,'harmonic')
    unique_mixing = mixing{1}(:,1:4);
elseif isequal(mixing_type,'triplet')
    unique_mixing = mixing{1}(:,1:6);    
elseif isequal(mixing_type, 'quadruplet')
    unique_mixing = mixing{1}(:,1:8);    
end
n_mix = height(unique_mixing);


results = {};
% loop over each signal
for k = 1:height(mixing)
    signal_mixing = mixing{k};
    
    % all test values
    pvalues = signal_mixing.pvalue;
    test_vals = signal_mixing.hoi;

    % one-tailed
    idx_sig = (pvalues < alpha); 
    sig_mixing = unique_mixing(idx_sig,:);
    original_id = linspace(1,height(unique_mixing),height(unique_mixing));
    original_id = original_id(idx_sig);    

    adjacency_matrix = mix_distance(sig_mixing, config, mixing_type);
    
    % find clusters
    [cc_orig, real_cluster_tsum] = find_clusters(test_vals, idx_sig, adjacency_matrix,...
                                                 original_id, unique_mixing);

    perm_cluster_distribution = [];
    for p = 1:num_permutations 
        
        shuffle = randsample(1:size(pvalues,1),size(pvalues,1)) ;
        pvalues_perm = pvalues(shuffle,:);
        test_vals_perm = test_vals(shuffle,:);
        
        % one-tailed
        idx_sig = (pvalues_perm < alpha); 
        sig_mixing = unique_mixing(idx_sig,:);
        original_id = linspace(1,height(unique_mixing),height(unique_mixing));
        original_id = original_id(idx_sig);    

        adjacency_matrix = mix_distance(sig_mixing, config, mixing_type);

        % find clusters
        [~, cluster_tsum] = find_clusters(test_vals_perm, idx_sig, adjacency_matrix,...
                                                     original_id, unique_mixing);
                                                 
                                                 
        % storing the sum of t-values for each cluster
        % find the largest sum of tvalues for a given permutation
        if isempty(cluster_tsum)
            perm_cluster_distribution(p) = 0;
        else
            perm_cluster_distribution(p) = max(cluster_tsum);
        end      
        
    end
    
    %compare the size of each cluster in the original data to the permutations
    pvals = [];
    for clu = 1:length(real_cluster_tsum)
        pvals(clu) = sum(perm_cluster_distribution>real_cluster_tsum(clu))/num_permutations;
    end
    cc_orig.cluster_pvalues = pvals;

    % add additional columns to original triplet table
    clusterhValue = zeros(height(unique_mixing),1);
    cluster_id = zeros(height(unique_mixing),1);
    cluster_pvals = zeros(height(unique_mixing),1);

    for i = 1:length(cc_orig.PixelIdxList)
        if pvals(i) < cluster_alpha
            clusterhValue(cc_orig.PixelIdxList{i}) = 1;%CC_orig.cluster_pvalues(i);
            cluster_id(cc_orig.PixelIdxList{i}) = i; 
            cluster_pvals(cc_orig.PixelIdxList{i}) = pvals(i);

        end
    end 
    
    significant_mixing = unique_mixing;
    significant_mixing.clusterhvalue = clusterhValue;
    significant_mixing.cluster_id = cluster_id;
    significant_mixing.pvalue = cluster_pvals;
    significant_mixing.teststats = test_vals;
    significant_mixing = significant_mixing(significant_mixing.clusterhvalue==1,:);
    
    if ~isempty(significant_mixing)
        results{k,1} = significant_mixing;
    end
end
    

end



