classdef experiment
    %EXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties         
        name % name of experiment
        date  = date % date experiment was constructed    
        
        config = freqmix.config.config_experiments; % config object contains all configurations
                
        datacollection % data collection object
        
        frequencymixing % frequency mixing object
        
        statistics % statistics object
        
        plotter % plotting object
        
        logger % logger object
    end
    
    methods
        
        function obj = experiment(varargin)
            %EXPERIMENT Construct an instance of this class
            obj = obj.parse_varargin(varargin);
            obj = obj.instantiate_objects();
            obj = obj.update_configs(); % update configs of objects from master
            obj = obj.set_logger();
            
        end
        
        
        function obj = run(obj)
            %RUN main function to run frequency mixing experiment
            
            % ensure configs are updated
            obj.logger.log('Ensuring configs are updated ...');
            obj = obj.check_config();
            
            if obj.config.tasks.frequencymixing
                obj.logger.log('Running frequency mixing...');
                obj = obj.run_frequencymixing(); 
            end
            
            if obj.config.tasks.statistics
                obj.logger.log('Running statistics ...');
                obj = obj.run_statistics();          
            end
            
            if obj.config.tasks.plotting
                obj.logger.log('Running plotting ...');
                obj = obj.run_plotting();
            end
            
        end
        
        
        function obj = run_frequencymixing(obj) 
            % run frequency mixing on data collection
            obj = obj.check_config();
            obj.frequencymixing = obj.frequencymixing.run(obj.datacollection);   
        end
        
        function obj = run_statistics(obj)
            % run all statistics on frequency mixing results
            obj = obj.check_config();            
            obj.statistics = obj.statistics.run(obj.datacollection, obj.frequencymixing);
        end
        
        function obj = run_plotting(obj)
            % plot the statistics output
            obj = obj.check_config();  
            obj.plotter.run(obj.statistics); 
        end
        
        function obj = instantiate_objects(obj)
            % create main objects for experiment
            
            % create frequency mixing object
            obj.frequencymixing = freqmix.frequencymixing.frequencymixing(obj.config.config_frequencymixing,...
                                                                  obj.config.config_spectrum); 
            
            % create statistics object                                                  
            obj.statistics = freqmix.statistics.statistics(obj.config.config_statistics);  
            
            % create plotter object
            obj.plotter = freqmix.plotting.plotter(obj.config.config_plotting); 
        end
        
        function obj = set.config(obj, config)
            obj.config = config;
        end
                
        function obj = set.datacollection(obj, data)
            obj.datacollection = data;
        end
        
        function obj = set.frequencymixing(obj, frequencymixing)
            obj.frequencymixing = frequencymixing;
        end
        
        function obj = set_logger(obj)
            % define a single logger object shared across all objects
            if obj.config.logging
                
                %otl = logging.textfilelogger();
                odil = freqmix.logging.displogger();
                obj.logger = freqmix.logging.duplogger({odil});
                
                obj.frequencymixing.logger = obj.logger;
                obj.statistics.logger = obj.logger;
                obj.datacollection.logger = obj.logger;
            end
        end
        
        function obj = check_config(obj)
            % Check all configurations are present
            CONFIGS_EXPECTED = {'config_frequencymixing','config_spectrum','config_statistics','config_data','config_plotting'};
            for cfg = CONFIGS_EXPECTED
                if ~isobject(obj.config.(cfg{1}))
                    error(['Missing configuration file: ',cfg{1}])
                else
                    obj.config.(cfg{1}) = obj.config.(cfg{1}).update_config();                    
                end
            end
            
            % check channel 
            if isempty(obj.config.config_frequencymixing.channels)
                obj.config.config_frequencymixing.channels = obj.datacollection.channel_info.channel_names;
            end
            
            
        end
        
        function obj = update_configs(obj)
            obj.check_config(); % check configs are all present
            
            if ~isempty(obj.datacollection)
                obj.datacollection.config = obj.config.config_data;
            end
            
            if ~isempty(obj.frequencymixing)
                obj.frequencymixing.config_spectrum = obj.config.config_spectrum;
                obj.frequencymixing.config = obj.config.config_frequencymixing;
            end
            
            if ~isempty(obj.frequencymixing.freq_channel_combinations)
                obj.config.config_plotting.mixing_combinations = obj.frequencymixing.freq_channel_combinations;
                obj.config.config_plotting.max_freq = max(obj.frequencymixing.config.frequencies);
                obj.config.config_plotting.channels = obj.frequencymixing.config.channels;
                obj.config.config_plotting.group_info = obj.datacollection.group_info;
                obj.plotter.config = obj.config.config_plotting;
            end
            
        end
     
        function obj = parse_varargin(obj,arguments)            
          
            % parse data to experiment object
            p = inputParser;
            addParameter(p,'name',obj.name,@ischar); % name
            addParameter(p,'config',obj.config); % experiment config
            addParameter(p,'datacollection',obj.datacollection); % datacollection object
            addParameter(p,'frequencymixing',obj.frequencymixing); % frequency mixing object
            addParameter(p,'logger',obj.logger); % logger object
            parse(p,arguments{:});  
            for i = 1:length(p.Parameters)
                obj.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end   
            
        end
        
    end
end

