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
            disp('Parsing arugments ...');
            obj = obj.parse_varargin(varargin);
            
            disp('Instantiating objects for experiment ...');   
            obj = obj.instantiate_objects();
            
            disp('Updating configuration files from master ...');               
            obj = obj.update_configs(); % update configs of objects from master
            
            disp('Setting logger ...');   
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
                obj.plotter.logger = obj.logger;
 
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
        
        
        
        
        function save_obj(obj)
            % save function when file is too large (splitting results into
            % separate mat files
            
            filename = obj.name;
            
            if strcmp(filename(end-3:end), '.mat')
                filename = filename(1:end-4);
            end
        
            [status, msg, msgID] = mkdir(filename); 
            [status, msg, msgID] = mkdir(['./' filename '/harmonicmixing/']);  
            [status, msg, msgID] = mkdir(['./' filename '/tripletmixing/']);  
            [status, msg, msgID] = mkdir(['./' filename '/quadrupletmixing/']);  

            % save harmonics
            for i = 1:length(obj.frequencymixing.harmonicmixing)
                subfile = ['./' filename '/harmonicmixing/' filename '_s' num2str(i)];                   
                sigtmp = obj.frequencymixing.harmonicmixing{i};                
                save(subfile, 'sigtmp');                
            end   
            obj.frequencymixing.harmonicmixing = {};       
            
            % save triplets
            for i = 1:length(obj.frequencymixing.tripletmixing)
                subfile = ['./' filename '/tripletmixing/' filename '_s' num2str(i)];                   
                sigtmp = obj.frequencymixing.tripletmixing{i};                
                save(subfile, 'sigtmp');                
            end   
            obj.frequencymixing.tripletmixing = {};     

            % save quadruplets
            for i = 1:length(obj.frequencymixing.quadrupletmixing)
                subfile = ['./' filename '/quadrupletmixing/' filename '_s' num2str(i)];                   
                sigtmp = obj.frequencymixing.quadrupletmixing{i};                
                save(subfile, 'sigtmp');                
            end   
            obj.frequencymixing.quadrupletmixing = {};
            
            exp = obj;
            save([filename '.mat'], getVarName(exp));
            
            function out = getVarName(var)
                out = inputname(1);
            end
            
        end
        
        function obj = load_obj(obj)            
            % loading object that was split up due to size
            
            if length(obj.frequencymixing.tripletmixing) == obj.datacollection.signal_info.n_signals
                return
            end
            
            filename = obj.name;

            % load harmonics
            if obj.frequencymixing.config.test_harmonics
                for i = 1:obj.datacollection.signal_info.n_signals                
                    subfile = ['./' filename '/harmonicmixing/' filename '_s' num2str(i)]; 
                    load(subfile, 'sigtmp');
                    obj.frequencymixing.harmonicmixing{i,1} = sigtmp;
                end
            end
            
            % load triplets
            if obj.frequencymixing.config.test_triplets
                for i = 1:obj.datacollection.signal_info.n_signals                
                    subfile = ['./' filename '/tripletmixing/' filename '_s' num2str(i)]; 
                    load(subfile, 'sigtmp');
                    obj.frequencymixing.tripletmixing{i,1} = sigtmp;
                end
            end   
            
            % load quadruplets
            if obj.frequencymixing.config.test_quadruplets
                for i = 1:obj.datacollection.signal_info.n_signals                
                    subfile = ['./' filename '/quadrupletmixing/' filename '_s' num2str(i)]; 
                    load(subfile, 'sigtmp');
                    obj.frequencymixing.quadrupletmixing{i,1} = sigtmp;
                end
            end               
            
        end
        
    end
    
    
    
    methods (Static)
        
        function obj = loadobj(s)
            % static function for loading experiment
            if isstruct(s)
                obj = s;
            else
                obj = s;
                obj = obj.load_obj();
            end 
        end
        
    end
end

