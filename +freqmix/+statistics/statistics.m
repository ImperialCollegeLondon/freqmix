classdef statistics
    %STATISTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        config  
        
        harmonic_statistics = struct('individual_test',[],'group_test',[],'regression_test',[],'surrogate_test',[])
        triplet_statistics = struct('individual_test',[],'group_test',[],'regression_test',[],'surrogate_test',[])
        quadruplet_statistics = struct('individual_test',[],'group_test',[],'regression_test',[],'surrogate_test',[])        
               
        logger
        
    end
    
    methods
        function obj = statistics(config)
            % STATISTICS Construct an instance of this class            
            obj.config = config;   
        end
        
        function obj = run(obj, datacollection, frequencymixing)
            % compute statistics on frequency mixing object
            obj.logger.log('Running statistics ...');
            obj = obj.update_channels(datacollection);
        
            if obj.config.harmonics
                if ~isempty(frequencymixing.harmonicmixing)
                    obj = obj.run_harmonic_statistics(datacollection.data, frequencymixing.harmonicmixing);
                end
            end
            
            if obj.config.triplets
                if ~isempty(frequencymixing.tripletmixing)
                    obj = obj.run_triplet_statistics(datacollection.data, frequencymixing.tripletmixing);
                end
            end
            
            if obj.config.quadruplets
                if ~isempty(frequencymixing.quadrupletmixing)
                    obj = obj.run_quadruplet_statistics(datacollection.data, frequencymixing.quadrupletmixing);
                end
            end
            
            obj.logger.log('All statistics finished ...');

        end
        
        function obj = run_harmonic_statistics(obj, data, harmonic_mixing)
            import freqmix.statistics.*
            mixing_type = 'harmonic'; 
            obj.logger.log('Running harmonic statistics ...');

            
            if obj.config.individual_test
                obj.harmonic_statistics.individual_test = [obj.harmonic_statistics.individual_test, individual_tests(harmonic_mixing, mixing_type, obj.config)];
            end
            
            if obj.config.group_test      
                if obj.config.intra_channel
                    % group tests within each channel separately
                    for c = 1:length(obj.config.channels)                        
                        obj.harmonic_statistics.group_test = [obj.harmonic_statistics.group_test; group_tests(data, harmonic_mixing, mixing_type, obj.config, 'channel', obj.config.channels{c})];
                    end                    
                else
                    % group tests across channels all together
                    obj.harmonic_statistics.group_test = [obj.harmonic_statistics.group_test; group_tests(data, harmonic_mixing, mixing_type, obj.config)];
                end
            end
                       
            if obj.config.regression_test
                if obj.config.intra_channel
                    % regression tests within each channel separately
                    for c = 1:length(obj.config.channels)                        
                        obj.harmonic_statistics.regression_test = [obj.harmonic_statistics.regression_test; regression_tests(data, harmonic_mixing, mixing_type, obj.config, 'channel', obj.config.channels{c})];
                    end    
                else
                    obj.harmonic_statistics.regression_test = [obj.harmonic_statistics.regression_test; regression_tests(data, harmonic_mixing, mixing_type, obj.config)];
                end
            end
                        
               
            
        end
        
        function obj = run_triplet_statistics(obj, data, triplet_mixing)
            import freqmix.statistics.*            
            mixing_type = 'triplet'; 
            obj.logger.log('Running triplet statistics ...');
            
            if obj.config.individual_test
                obj.triplet_statistics.individual_test = [obj.triplet_statistics.individual_test; individual_tests(triplet_mixing, mixing_type, obj.config)];
            end
            
            if obj.config.group_test
                if obj.config.intra_channel
                    % group tests within each channel separately
                    for c = 1:length(obj.config.channels)                        
                        obj.triplet_statistics.group_test = [obj.triplet_statistics.group_test; group_tests(data, triplet_mixing, mixing_type, obj.config, 'channel', obj.config.channels{c})];
                    end                    
                else
                    % group tests across channels all together
                    obj.triplet_statistics.group_test = [obj.triplet_statistics.group_test; group_tests(data, triplet_mixing, mixing_type, obj.config)];
                end
            end
                       
            if obj.config.regression_test
                if obj.config.intra_channel
                    % regression tests within each channel separately
                    for c = 1:length(obj.config.channels)                        
                        obj.triplet_statistics.regression_test = [obj.triplet_statistics.regression_test; regression_tests(data, triplet_mixing, mixing_type, obj.config, 'channel', obj.config.channels{c})];
                    end    
                else
                    obj.triplet_statistics.regression_test = [obj.triplet_statistics.regression_test; regression_tests(data, triplet_mixing, mixing_type, obj.config)];
                end
            end                        
                 
            
        end
        
        function obj = run_quadruplet_statistics(obj, data, quadruplet_mixing)
            import freqmix.statistics.*
            mixing_type = 'quadruplet'; 
            obj.logger.log('Running quadruplet statistics ...');
         
            if obj.config.individual_test
                % to implement
            end
            
            if obj.config.group_test
                
                if obj.config.intra_channel
                    % group tests within each channel separately
                    for c = 1:length(obj.config.channels)                        
                        obj.quadruplet_statistics.group_test = [obj.quadruplet_statistics.group_test; group_tests(data, quadruplet_mixing, mixing_type, obj.config, 'channel', obj.config.channels{c})];
                    end                    
                else
                    % group tests across channels all together
                    obj.quadruplet_statistics.group_test = [obj.quadruplet_statistics.group_test; group_tests(data, quadruplet_mixing, mixing_type, obj.config)];
                end
            end
                       
            if obj.config.regression_test
                if obj.config.intra_channel
                    % regression tests within each channel separately
                    for c = 1:length(obj.config.channels)                        
                        obj.quadruplet_statistics.regression_test = [obj.quadruplet_statistics.regression_test; regression_tests(data, quadruplet_mixing, mixing_type, obj.config, 'channel', obj.config.channels{c})];
                    end    
                else
                    obj.quadruplet_statistics.regression_test = [obj.quadruplet_statistics.regression_test; regression_tests(data, quadruplet_mixing, mixing_type, obj.config)];
                end
            end
                        
            
        end  

        
        function obj = update_channels(obj, datacollection)
            obj.config.channels = datacollection.channel_info.channel_names;
        end
        
        function obj = clear_statistics(obj)
            % clear statistics             
            obj.harmonic_statistics = struct('individual_test',[],'group_test',[],'regression_test',[],'surrogate_test',[]);
            obj.triplet_statistics = struct('individual_test',[],'group_test',[],'regression_test',[],'surrogate_test',[]);
            obj.quadruplet_statistics = struct('individual_test',[],'group_test',[],'regression_test',[],'surrogate_test',[]);               
        end
        
    end
    

end

