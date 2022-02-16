classdef config_frequencymixing < freqmix.config.config_base
    %MIXING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        frequency_range = []
        frequencies = []
        
        channels = {'none'} % channels to mix
        
        harmonics = []
        triplets = []
        quadruplets = []
        
        test_harmonics = false
        test_triplets = true
        test_quadruplets = false
        
        % dependence test parameters
        sigma = 2
        n_bootstraps = 10000
        alpha = 0.05 
        downsampling_frequency = 20;
        
        % computational resources
        use_gpu = true;
        parallel = true;
        n_workers = 4;
        
        % constraints on frequency mixing
        freq_bin_size = 1;
        frequency_gap = 2;
        min_frequency = 0;
        within_channels = true; % compute frequency mixing within channels
        between_channels = true; % compute frequency mixing between channels
        
        % triplet types
        triplet_type = true; % return the closest triplet type for each
        
        save_progression = false; % save results for signals when they complete in temp files
        load_progression = false; % load results for signals from temp files
        
        tolerance = 3; % rounding tolerance for matching frequencies
    end
    
    methods
        function obj = config_frequencymixing()
            %MIXING Construct an instance of this class
            %   Detailed explanation goes here
            obj.check_tests();
        end
        
        function obj = update_config(obj)
          
            % check logic
            obj = obj.check_tests();
            
            % check frequencies
            obj = obj.check_frequencies();
            
            % check quadruplets are present
            if obj.test_quadruplets

                if isempty(obj.quadruplets)
                    [obj.quadruplets, obj.triplets, obj.harmonics] = freqmix.frequencymixing.quadruplets.find_quadruplets(obj.frequencies,...
                                                                       obj.frequency_gap,...
                                                                       obj.min_frequency);
                else
                    [~, obj.triplets, obj.harmonics] = freqmix.frequencymixing.quadruplets.find_quadruplets(obj.frequencies,...
                                                                       obj.frequency_gap,...
                                                                       obj.min_frequency);
                end
            end
            % to add here: only get those triplets associqated with
            % quadruplets
            if obj.test_triplets
                if isempty(obj.triplets)
                    obj.triplets = freqmix.frequencymixing.triplets.find_triplets(obj.frequencies,...
                                                                       obj.frequency_gap,...
                                                                       obj.min_frequency);  
                end                
            end
                
            if obj.test_harmonics
                if isempty(obj.harmonics)
                    obj.harmonics = freqmix.frequencymixing.harmonics.find_harmonics(obj.frequencies,...
                                                                       obj.frequency_gap,...
                                                                       obj.min_frequency); 
                end                
            end    
            
            
        end    
        
        function obj = check_tests(obj)            
            if obj.test_quadruplets && ~obj.test_triplets
                obj.test_triplets = true;
            end
        end
        
        function obj = check_frequencies(obj)
            if isempty(obj.frequency_range) && isempty(obj.frequencies)
                if isempty(obj.quadruplets) && isempty(obj.triplets) && isempty(obj.harmonics)
                    obj.frequency_range = [0 45]; % default to scan between 0-45 hz
                end
            end
            
            if obj.frequency_gap < obj.freq_bin_size
                obj.freq_bin_size = obj.frequency_gap;
            end            
            
            if isempty(obj.frequencies)
                if isempty(obj.quadruplets) && isempty(obj.triplets) && isempty(obj.harmonics)
                    obj.frequencies = obj.frequency_range(1):obj.freq_bin_size:obj.frequency_range(2);
                elseif ~isempty(obj.quadruplets)
                    obj.frequencies = unique(obj.quadruplets);
                elseif ~isempty(obj.triplets)
                    obj.frequencies = unique(obj.triplets);
                elseif ~isempty(obj.harmonics)
                    obj.frequencies = unique(obj.harmonics); 
                end
                    
            end            
        end

    end
end

