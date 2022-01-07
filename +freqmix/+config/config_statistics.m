classdef config_statistics < freqmix.config.config_base
    %CONFIG_STATISTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
                
        harmonics = true % statistical tests on harmonics
        triplets = true  % statistical tests on triplets     
        quadruplets = true % statistical tests on quadruplets
        
        group_test = true % group cluster tests
        regression_test = false % regression cluster tests
        individual_test = false % cluster tests on individual signals
        surrogate_test = false % cluster test vs surrogate (z-test)
        
        alpha_individual = 0.05 % alpha for perm tests
        alpha_group = 0.01 % alpha for group tests
        alpha_regression = 0.05 % alpha for regression test
        cluster_alpha = 0.05 % alpha for significant of clusters
        
        n_permutations = 10000 % number of permutations cluster tests
        paired = true % if paired samples present, then paired tests.
        permute_spatially = true % permutations in frequency + channels
        equal_variance = false; % equal variance in t-test assumption
        freq_bin_size = 1; % freq bin size (should be the same as used in spectrum)
        
        parallel = true % compute statistical tests in paralle
        use_gpu = true % use gpu arrays
        
    end
    
    methods
        function obj = config_statistics()
            %CONFIG_STATISTICS Construct an instance of this class
            %   Detailed explanation goes here
        end
        

    end
end

