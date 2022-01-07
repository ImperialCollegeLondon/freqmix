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
            
            if obj.config.harmonics
                obj = obj.run_harmonic_statistics(datacollection.data, frequencymixing.harmonicmixing);
            end
            if obj.config.triplets
                obj = obj.run_triplet_statistics(datacollection.data, frequencymixing.tripletmixing);
            end
            if obj.config.quadruplets
                obj = obj.run_quadruplet_statistics(datacollection.data, frequencymixing.quadrupletmixing);
            end
        end
        
        function obj = run_harmonic_statistics(obj, data, harmonic_mixing)
            import freqmix.statistics.*
            mixing_type = 'harmonic'; 
            
            if obj.config.individual_test
                obj.harmonic_statistics.individual_test = individual_tests(harmonic_mixing, mixing_type, obj.config);
            end
            
            if obj.config.group_test
                obj.harmonic_statistics.group_test = group_tests(data, harmonic_mixing, mixing_type, obj.config);
            end
                       
            if obj.config.regression_test
                obj.harmonic_statistics.regression_test = regression_tests(data, harmonic_mixing, mixing_type, obj.config);
            end
                        
            if obj.config.surrogate_test
                % to implement
                
            end                        
            
        end
        
        function obj = run_triplet_statistics(obj, data, triplet_mixing)
            import freqmix.statistics.*            
            mixing_type = 'triplet'; 
            
            if obj.config.individual_test
                obj.triplet_statistics.individual_test = individual_tests(triplet_mixing, mixing_type, obj.config);
            end
            
            if obj.config.group_test
                obj.triplet_statistics.group_test = group_tests(data, triplet_mixing, mixing_type, obj.config);
            end
                       
            if obj.config.regression_test
                obj.triplet_statistics.regression_test = regression_tests(data, triplet_mixing, mixing_type, obj.config);
            end
                        
            if obj.config.surrogate_test
                % to implement                
            end                        
            
        end
        
        function obj = run_quadruplet_statistics(obj, data, quadruplet_mixing)
            import freqmix.statistics.*
            mixing_type = 'quadruplet'; 
            
            if obj.config.individual_test
                % to implement
            end
            
            if obj.config.group_test
                obj.quadruplet_statistics.group_test = group_tests(data, quadruplet_mixing, mixing_type, obj.config);                
            end
                       
            if obj.config.regression_test
                obj.quadruplet_statistics.regression_test = regression_tests(data, quadruplet_mixing, mixing_type, obj.config);
            end
                        
            if obj.config.surrogate_test
                % to implement                
            end                        
            
        end  

        
        
        
        
    end
    

end

