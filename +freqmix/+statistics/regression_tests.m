function [results] = regression_tests(data, mixing, mixing_type, config, varargin)

% imports
import freqmix.statistics.hypothesis_tests.*
import freqmix.statistics.utils.*

% parse variable arguments
p = inputParser;
addParameter(p,'channel',''); % channel
parse(p,varargin{:});  

% set initial parameters
alpha = config.(['alpha_' mixing_type]).alpha_group;
cluster_alpha = config.(['alpha_' mixing_type]).cluster_alpha;

permute_spatially = config.permute_spatially;
num_permutations = config.n_permutations;
num_trials = height(data);
tThreshold = abs(tinv(alpha, num_trials-1));
summative_only = config.summative_only;
intra_channel = config.intra_channel;
three_channel = config.three_channel;

% filter summative triplets
if isequal(mixing_type,'triplet')
    if summative_only
        mixing = filter_summative(mixing);
    end
end

% find id of channel name
if config.intra_channel
    channel_id = find(contains(config.channels,p.Results.channel));
end


% set parameters specific to mixing type
if isequal(mixing_type,'harmonic')
    unique_mixing = mixing{1}(:,1:4);   
    
    if intra_channel
        mixing_index = (unique_mixing.Channel1==channel_id) & (unique_mixing.Channel2==channel_id);  
    elseif three_channel
        mixing_index = (unique_mixing.Channel1~=unique_mixing.Channel2);  
    else
        mixing_index = ones([height(unique_mixing),1]);
    end
    
elseif isequal(mixing_type,'triplet')
    unique_mixing = mixing{1}(:,1:6);     
    
    if intra_channel
        mixing_index = (unique_mixing.Channel1==channel_id) & (unique_mixing.Channel2==channel_id)  & (unique_mixing.Channel3==channel_id);  
    elseif three_channel
        mixing_index = (unique_mixing.Channel1~=unique_mixing.Channel2) & (unique_mixing.Channel2~=unique_mixing.Channel3)  & (unique_mixing.Channel1~=unique_mixing.Channel3);
    else
        mixing_index = ones([height(unique_mixing),1]);
    end
    
elseif isequal(mixing_type, 'quadruplet')
    unique_mixing = mixing{1}(:,1:8);   
    
    if intra_channel
        mixing_index = (unique_mixing.Channel1==channel_id) & (unique_mixing.Channel2==channel_id)  & (unique_mixing.Channel3==channel_id)  & (unique_mixing.Channel4==channel_id);  
    elseif three_channel
        mixing_index = (unique_mixing.Channel1~=unique_mixing.Channel2) & (unique_mixing.Channel1~=unique_mixing.Channel3) & (unique_mixing.Channel1~=unique_mixing.Channel4) & (unique_mixing.Channel2~=unique_mixing.Channel3) & (unique_mixing.Channel2~=unique_mixing.Channel4) & (unique_mixing.Channel3~=unique_mixing.Channel4);
    else
        mixing_index = ones([height(unique_mixing),1]);
    end
end
n_mix = height(unique_mixing);

% extract metadata for regression
metadata = data.metadata;

% combine all test values
all_test_vals = [];
for i = 1:length(mixing)
    all_test_vals(:,i) = mixing{i}.hoi;
end

% updating 
all_test_vals = all_test_vals(find(mixing_index),:);
unique_mixing = unique_mixing(find(mixing_index),:);

% t_value_vector = zeros(n_mix,1);
% for tr = 1:n_mix   
%     t_value_vector(tr,1) = simpleCorrCoef(all_test_vals(tr,:)',metadata);
% end
t_value_vector = freqmix.statistics.hypothesis_tests.simpleCorrCoef(all_test_vals',metadata)';


tests{1} = 'positive';
tests{2} = 'negative';

% updating group names with channel ids (if intra-channel)
if intra_channel
    for t = 1:length(tests)
        tests{t} = [tests{t} '_' p.Results.channel];
    end
end


for k = 1:2
    
    if k==2
        t_value_vector = -t_value_vector;  
    end
    
    % loading results with direction of test and original t-vals
    results{k,1} = tests{k};
    
    
    idx_sig = (t_value_vector > tThreshold);
    disp(sum(idx_sig));
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
        
        %perform regression tests
%         t_value_vector_perm = zeros(n_mix,1);
%         for tr = 1:n_mix   
%             t_value_vector_perm(tr,1) = simpleCorrCoef(all_test_vals_perm(tr,:)',metadata);
%         end
        t_value_vector_perm = simpleCorrCoef(all_test_vals_perm',metadata)';
        
        
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

    % copying unique mixing and adding t-value column for storage
    tvalue_table = unique_mixing;
    tvalue_table.tvalue = t_value_vector; 
    
    % store unique mixing for the group comparison
    results{k,2} = significant_mixing;
    results{k,3} = tvalue_table;      
    
    
end

end

