classdef config_spectrum < freqmix.config.config_base
    %CONFIG_SPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties       
        spectrum_method = 'wavelet' % or 'hilbert'
        wavelet_parameters = {'morlet',15}
        sampling_frequency
        freq_bin_size = 1;
        min_freq = 0;
        max_freq = 1;       
    end
    
    methods
        function obj = config_spectrum()
            %CONFIG_SPECTRUM Construct an instance of this class
            %   Detailed explanation goes here

        end
        

    end
end

