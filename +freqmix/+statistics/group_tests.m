function [all_comparisons] = group_tests(data, mixing, mixing_type, config)

import freqmix.statistics.hypothesis_tests.*
import freqmix.statistics.utils.*

% set initial parameters
alpha = config.alpha_group;
paired = config.paired;
equal_variance = config.equal_variance;
cluster_alpha = config.cluster_alpha;
permute_spatially = config.permute_spatially;
num_permutations = config.n_permutations;
num_trials = height(data);
tThreshold = abs(tinv(alpha, num_trials-1));

% set parameters specific to mixing type
if isequal(mixing_type,'harmonic')
    unique_mixing = mixing{1}(:,1:4);
elseif isequal(mixing_type,'triplet')
    unique_mixing = mixing{1}(:,1:6);    
elseif isequal(mixing_type, 'quadruplet')
    unique_mixing = mixing{1}(:,1:8);    
end
n_mix = height(unique_mixing);

% identify groups
[groups, group_ids] = unique(data.group_id);
group_names = data.group_name(group_ids);

% check more than one group
if length(groups)==1
    error('Group comparison requires more than one group.')
end
    
    
% identify all group comparisons to perform
group_comparisons = perms(groups);
group_comparisons = unique(group_comparisons(:,1:2),'rows');

% combine all test values
all_test_vals = [];
for i = 1:length(mixing)
    all_test_vals(:,i) = mixing{i}.hoi;
end

all_comparisons = {};
for k = 1:size(group_comparisons,1)
    
    % identify comparison to perform
    comparison = group_comparisons(k,:);
    all_comparisons{k,1} = group_names(comparison(1));
    all_comparisons{k,2} = group_names(comparison(2));
    
    % create arrays of hoi values 
    testvals = cell(2,1);    
    for i = 1:length(comparison)
        testvals{i} = all_test_vals(:,data.group_id==comparison(i));
    end

    % hypothesis tests on each mix
    if paired
        % if paired then subtract pairs from each other
        t_value_vector = simpleTTest((testvals{1}-testvals{2}),0);
    else
        t_value_vector = simpleTTest2(testvals{1},testvals{2},equal_variance);
    end

    % one-tailed
    idx_sig = (t_value_vector > tThreshold); 
    sig_mixing = unique_mixing(idx_sig,:);
    original_id = linspace(1,height(unique_mixing),height(unique_mixing));
    original_id = original_id(idx_sig);

    % construct adjacency matrix betwen significant mixing
    adjacency_matrix = mix_distance(sig_mixing, config, mixing_type);

    % find clusters
    [cc_orig, real_cluster_tsum] = find_clusters(t_value_vector, idx_sig, adjacency_matrix,...
                                                                  original_id, unique_mixing);

    % repeat process for permuted triplet table
    perm_cluster_distribution = [];

    for p = 1:num_permutations 

        % permute between samples
        shuffle = randsample(1:size(all_test_vals,2),size(all_test_vals,2)) ;
        all_test_vals_perm = all_test_vals(:,shuffle);

        % permute between frequencies and channels
        if permute_spatially==true
            shuffle = randsample(1:size(all_test_vals,1),size(all_test_vals,1)) ;
            all_test_vals_perm = all_test_vals_perm(shuffle,:);
        end

        % split into the two groups again
        testvals_perm = cell(length(groups),1);
        for i = 1:length(groups)
            testvals_perm{i} = all_test_vals_perm(:,data.group_id==groups(i));
        end

        if paired
            % if paired then subtract pairs from each other
            t_value_vector_perm = simpleTTest((testvals_perm{1}-testvals_perm{2}),0);
        else
            % if not paired then subtract mean of other group
            t_value_vector_perm = simpleTTest2(testvals_perm{1},testvals_perm{2},equal_variance);
        end    


        idx_sig = (t_value_vector_perm > tThreshold);
        sig_mixing = unique_mixing(idx_sig,:);
        original_id = linspace(1,height(unique_mixing),height(unique_mixing));
        original_id = original_id(idx_sig);

        % construct adjacency matrix betwen significant mixing
        adjacency_matrix = mix_distance(sig_mixing, config, mixing_type);

        % find clusters
        [~, cluster_tsum] = find_clusters(t_value_vector_perm, idx_sig, adjacency_matrix,...
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
    significant_mixing.teststats = t_value_vector;
    significant_mixing = significant_mixing(significant_mixing.clusterhvalue==1,:);
    
    % store unique mixing for the group comparison
    all_comparisons{k,3} = significant_mixing;
    all_comparisons{k,4} = t_value_vector;
end

%tmap = unique(triplet_table(:,5:10));
%tmap.testStats = t_value_vector;

end



