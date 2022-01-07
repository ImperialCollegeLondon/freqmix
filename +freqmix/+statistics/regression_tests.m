function [results] = regression_tests(data, mixing, mixing_type, config)

% imports
import freqmix.statistics.hypothesis_tests.*
import freqmix.statistics.utils.*

% set initial parameters
alpha = config.alpha_regression;
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

% extract metadata for regression
metadata = data.metadata;

% combine all test values
all_test_vals = [];
for i = 1:length(mixing)
    all_test_vals(:,i) = mixing{i}.hoi;
end

t_value_vector = zeros(n_mix,1);
for tr = 1:n_mix   
    t_value_vector(tr,1) = simpleCorrCoef(all_test_vals(tr,:)',metadata);
end


tests{1} = 'positive';
tests{2} = 'negative';


for k = 1:2
    
    if k==2
        t_value_vector = -t_value_vector;  
    end
    
    % loading results with direction of test and original t-vals
    results{k,1} = tests{k};
    
    
    idx_sig = (t_value_vector > tThreshold);
    sig_mixing = unique_mixing(idx_sig,:);
    original_id = linspace(1,height(unique_mixing),height(unique_mixing));
    original_id = original_id(idx_sig);

    % construct adjacency matrix betwen significant mixing
    adjacency_matrix = mix_distance(sig_mixing, config, mixing_type);

    % find clusters
    [cc_orig, real_cluster_tsum] = find_clusters(t_value_vector, idx_sig, adjacency_matrix,...
                                                                  tThreshold, original_id, unique_mixing);

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

        % perform regression tests
        t_value_vector_perm = zeros(n_mix,1);
        for tr = 1:n_mix   
            t_value_vector_perm(tr,1) = simpleCorrCoef(all_test_vals_perm(tr,:)',metadata);
        end
        
        % convert to negative correlation
        if k==2
            t_value_vector_perm = -t_value_vector_perm;  
        end   

        idx_sig = (t_value_vector_perm > tThreshold);
        sig_mixing = unique_mixing(idx_sig,:);
        original_id = linspace(1,height(unique_mixing),height(unique_mixing));
        original_id = original_id(idx_sig);
        
        % construct adjacency matrix betwen significant mixing
        adjacency_matrix = mix_distance(sig_mixing, config, mixing_type);

        % find clusters
        [~, cluster_tsum] = find_clusters(t_value_vector_perm, idx_sig, adjacency_matrix,...
                                                            tThreshold, original_id, unique_mixing);



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
    results{k,2} = significant_mixing;
    results{k,3} = t_value_vector;  
    
    
    
end

end

