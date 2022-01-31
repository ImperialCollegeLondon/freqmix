classdef config_plotting < freqmix.config.config_base
    %CONFIG_STATISTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        bands = {'delta','theta','alpha','beta','low gamma'};
        saveplot = 1;
        savedata = 1;
        folder = './plots/'
        min_freq = 0;
        max_freq
        title = 0;
        
        mixing_combinations
        channels
        group_info
    end
    
    methods
        function obj = config_plotting()
            %CONFIG_STATISTICS Construct an instance of this class
            %   Detailed explanation goes here
        end
        

    end
end

