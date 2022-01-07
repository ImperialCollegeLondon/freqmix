classdef config_base
    %CONFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dictionary
    end
    
    methods
        function obj = datasets(obj)
            %DATASETS Construct an instance of this class
            %   Detailed explanation goes here
            obj.dictionary = properties(obj);
        end
        
        function config_properties = get_properties(obj) 
            config_properties = properties(obj);
        end
        
        function obj = update_config(obj) 
        end
        
    end
end

