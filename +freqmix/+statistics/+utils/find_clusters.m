function [cc_orig, cluster_tsum] = find_clusters(t_value_vector, idx_sig, adjacency_matrix, original_id, unique_mixing)
%FIND_CLUSTERS Summary of this function goes here
%   Detailed explanation goes here
import freqmix.statistics.utils.*

t_vals_sig = t_value_vector(idx_sig);
significant_entries = ones(length(t_vals_sig),1); %(t_vals_sig > tThreshold);
cc_orig = graphconncomp(significant_entries,graph(adjacency_matrix));



% mapping the ids of each triplet to the original ids
for i = 1:length(cc_orig.PixelIdxList)
    cc_orig.PixelIdxList{i} = original_id(cc_orig.PixelIdxList{i});
end


% computing sum of testStat for each cluster
cluster_tsum = [];
for i = 1:length(cc_orig.PixelIdxList)  
    cluster_triplets = unique_mixing(cc_orig.PixelIdxList{i},:);    
    sum_t = 0;
    for tr = 1:height(cluster_triplets)
        sum_t = sum_t + t_vals_sig(tr);
    end    
    cluster_tsum(i) = sum_t;    
end

end

