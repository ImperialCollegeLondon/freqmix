classdef config_experiments < freqmix.config.config_base
    %EXPERIMENTS Summary of this class goes here
    %   Detailed explanation goes here

    properties
        name = 'experiment_configuration'
        date = date
        
        config_frequencymixing = freqmix.config.config_frequencymixing
        config_spectrum = freqmix.config.config_spectrum
        config_statistics = freqmix.config.config_statistics
        config_data = freqmix.config.config_data
        config_plotting = freqmix.config.config_plotting
        
        tasks = struct('frequencymixing',true,'statistics',true,'plotting',true)

        verbose = true
        logging = true
    end
    
    methods
        function obj = config_experiments(varargin)
            %EXPERIMENTS Configuration for an experiment
            
            obj = obj.set_defaults();
            obj = obj.parse_varargin(varargin); 
        end   
        
        function obj = set_defaults(obj)
            
            obj.config_frequencymixing = freqmix.config.config_frequencymixing;
            obj.config_spectrum = freqmix.config.config_spectrum;
            obj.config_statistics = freqmix.config.config_statistics;
            obj.config_data = freqmix.config.config_data;  
            obj.config_plotting = freqmix.config.config_plotting;
            
        end
        

        function obj = parse_varargin(obj,arguments)            
          
            % config experiment
            p = inputParser;p.KeepUnmatched=true;
            addParameter(p,'name',obj.name,@isstring); % name
            parse(p,arguments{:});  
            for i = 1:length(p.Parameters)
                obj.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end    
            
            % config data 
            p = inputParser;p.KeepUnmatched=true;
            addParameter(p,'precision',obj.config_data.precision,@ischar); % precision of data
            addParameter(p,'gpu_array',obj.config_data.gpu_array); % use gpu array     
            parse(p,arguments{:});  
            for i = 1:length(p.Parameters)
                obj.config_data.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end      
            
            % config frequency mixing
            p = inputParser;p.KeepUnmatched=true;
            addParameter(p,'frequency_range',obj.config_frequencymixing.frequency_range,@ismatrix); % quadruplets to test
            addParameter(p,'harmonics',obj.config_frequencymixing.harmonics,@ismatrix); % harmonics to test
            addParameter(p,'triplets',obj.config_frequencymixing.triplets,@ismatrix); % triplets to test
            addParameter(p,'quadruplets',obj.config_frequencymixing.quadruplets,@ismatrix); % quadruplets to test
            addParameter(p,'test_harmonics',obj.config_frequencymixing.test_harmonics,@ismatrix); % harmonics to test
            addParameter(p,'test_triplets',obj.config_frequencymixing.test_triplets,@ismatrix); % triplets to test
            addParameter(p,'test_quadruplets',obj.config_frequencymixing.test_quadruplets,@ismatrix); % quadruplets to test
            addParameter(p,'sigma',obj.config_frequencymixing.sigma,@isfloat); % sigma for dependence test
            addParameter(p,'n_bootstraps',obj.config_frequencymixing.n_bootstraps,@isfloat); % number of boostraps
            addParameter(p,'alpha',obj.config_frequencymixing.alpha,@isfloat); % alpha level for significance 
            addParameter(p,'frequency_gap',obj.config_frequencymixing.frequency_gap,@isfloat); % gap between frequencies in dependence tests
            addParameter(p,'min_frequency',obj.config_frequencymixing.min_frequency,@isfloat); % minimim frequency to consider in mixing
            addParameter(p,'downsampling_frequency',obj.config_frequencymixing.downsampling_frequency,@isfloat); % frequency of downsampling for test
            addParameter(p,'use_gpu',obj.config_frequencymixing.use_gpu); % use gpu arrays
            addParameter(p,'parallel',obj.config_frequencymixing.parallel); % use parallel computing
            addParameter(p,'n_workers',obj.config_frequencymixing.n_workers,@isfloat); % parallel workers
            addParameter(p,'within_channels',obj.config_frequencymixing.within_channels); % compute fm within channels
            addParameter(p,'between_channels',obj.config_frequencymixing.between_channels); % compute fm between channels
            addParameter(p,'channels',obj.config_frequencymixing.channels); % channels to mix
            addParameter(p,'freq_bin_size',obj.config_frequencymixing.freq_bin_size,@isfloat); % frequency bin size
            parse(p,arguments{:});  
            for i = 1:length(p.Parameters)
                obj.config_frequencymixing.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end                    
                        
            % config spectrum
            p = inputParser;p.KeepUnmatched=true;      
            addParameter(p,'spectrum_method',obj.config_spectrum.spectrum_method,@ischar); % method for spectrum
            addParameter(p,'wavelet_parameters',obj.config_spectrum.wavelet_parameters,@iscell); % sigma for wavelet decomposition
            addParameter(p,'sampling_frequency',obj.config_spectrum.sampling_frequency,@isfloat); % sampling frequency of time-series
            addParameter(p,'min_freq',obj.config_spectrum.min_freq,@isfloat); % min frequency for spectrum
            addParameter(p,'max_freq',obj.config_spectrum.max_freq,@isfloat); % max frequency for spectrum
            addParameter(p,'freq_bin_size',obj.config_spectrum.freq_bin_size,@isfloat); % frequency bin size
            parse(p,arguments{:});  
            for i = 1:length(p.Parameters)
                obj.config_spectrum.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end         
            
            % config statistics
            p = inputParser;p.KeepUnmatched=true;            
            addParameter(p,'use_gpu',obj.config_statistics.use_gpu); % use gpu arrays
            addParameter(p,'parallel',obj.config_statistics.parallel); % use parallel computing
            addParameter(p,'equal_variance',obj.config_statistics.equal_variance); % equal variance in t-tests
            addParameter(p,'permute_spatially',obj.config_statistics.permute_spatially); % permutations in freq space
            addParameter(p,'paired',obj.config_statistics.paired); % paired t-tests
            addParameter(p,'freq_bin_size',obj.config_statistics.freq_bin_size,@isfloat); % frequency bin size
            addParameter(p,'n_permutations',obj.config_statistics.n_permutations,@isfloat); % number of permutations
            addParameter(p,'cluster_alpha',obj.config_statistics.cluster_alpha,@isfloat); % alpha for clusters
            addParameter(p,'alpha_group',obj.config_statistics.alpha_group,@isfloat); % alpha for cluster perm test 
            addParameter(p,'alpha_regression',obj.config_statistics.alpha_regression,@isfloat); % alpha for cluster perm test  
            addParameter(p,'alpha_individual',obj.config_statistics.alpha_individual,@isfloat); % alpha for cluster perm test  
            addParameter(p,'harmonics',obj.config_statistics.harmonics); % statistical tests on harmonics 
            addParameter(p,'triplets',obj.config_statistics.triplets); % statistical tests on triplets 
            addParameter(p,'quadruplets',obj.config_statistics.quadruplets); % statistical tests on quadruplets 
            addParameter(p,'group_test',obj.config_statistics.group_test); % perform group cluster tests 
            addParameter(p,'regression_test',obj.config_statistics.regression_test); % perform regression cluster tests 
            addParameter(p,'individual_test',obj.config_statistics.individual_test); % perform individual cluster tests 
            addParameter(p,'surrogate_test',obj.config_statistics.surrogate_test); % perform surrogate tests 
            parse(p,arguments{:});  
            for i = 1:length(p.Parameters)
                obj.config_statistics.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end 

            % config plotting
            p = inputParser;p.KeepUnmatched=true; 
            addParameter(p,'folder',obj.config_plotting.folder); % plotting folder
            parse(p,arguments{:});  
            for i = 1:length(p.Parameters)
                obj.config_plotting.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end 
            
            % update configs with new settings
            obj = obj.update_configs();
            
            
        end
        
        function obj = update_configs(obj)
            % update configs based on chosen parameters
            CONFIGS_EXPECTED = {'config_frequencymixing','config_spectrum','config_statistics','config_data','config_plotting'};
            for cfg = CONFIGS_EXPECTED
                obj.(cfg{1}) = obj.(cfg{1}).update_config();
            end
            
            % corroborate details between configs
            obj = obj.corroborate_configs();
        end
        
        function obj = corroborate_configs(obj)
            % set details of configs based on others
            
            % spectrum details    
            if ~isempty(obj.config_frequencymixing.triplets)
                obj.config_spectrum.min_freq = 0;%min(obj.config_frequencymixing.triplets,[],'all');         
                obj.config_spectrum.max_freq = max(obj.config_frequencymixing.triplets,[],'all');
            end
            
            if ~isempty(obj.config_frequencymixing.harmonics)
                if max(obj.config_frequencymixing.harmonics,[],'all') > obj.config_spectrum.max_freq
                    obj.config_spectrum.max_freq = max(obj.config_frequencymixing.harmonics,[],'all');
                end
            end
            
            % ensure spectrum bin size is same size as frequency gap
            if obj.config_frequencymixing.freq_bin_size < obj.config_spectrum.freq_bin_size
                obj.config_spectrum.freq_bin_size = obj.config_frequencymixing.freq_bin_size;
            end
            
            % 
            if ~obj.config_frequencymixing.test_harmonics
               obj.config_statistics.harmonics = 0;
            end
            
            if ~obj.config_frequencymixing.test_triplets
               obj.config_statistics.triplets = 0;

            end 
            
            if ~obj.config_frequencymixing.test_quadruplets
               obj.config_statistics.quadruplets = 0;

            end
            
            if ~isempty(obj.config_frequencymixing.freq_bin_size)
               obj.config_statistics.freq_bin_size = obj.config_frequencymixing.freq_bin_size;
            end
           
                        
        end
        
    end
end

