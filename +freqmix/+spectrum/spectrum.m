classdef spectrum
    %SPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        config
        
        times
        freqs
        spectra     
        
        
    end
    
    methods
        function obj = spectrum(config)
            %SPECTRUM Construct an instance of this class
            obj.config = config;         
            
        end
        
        function obj = compute_spectrum(obj,data)
            
            if isempty(obj.config.freqs)
                obj.freqs = obj.config.min_freq+obj.config.freq_bin_size:obj.config.freq_bin_size:obj.config.max_freq;
                obj.config.freqs = obj.config.min_freq+obj.config.freq_bin_size:obj.config.freq_bin_size:obj.config.max_freq;
            end
            
            if isequal(obj.config.spectrum_method,'wavelet')
                spectrum_ = freqmix.spectrum.WaveletTransform(data,...
                                                        1/obj.config.sampling_frequency,...
                                                        obj.config.freqs,...
                                                        'WAVELETSPEC',obj.config.wavelet_parameters);
                                                    
            elseif isequal(obj.config.spectrum_method,'hilbert')
                spectrum_ = freqmix.spectrum.HilbertTransform(data,...
                                                        1/obj.config.sampling_frequency,...
                                                        obj.config.freqs);                  
            end
            

                                                
            obj.times = spectrum_.Times;
            obj.freqs = spectrum_.Freqs;
            obj.spectra = spectrum_.Spectrum;
            
        end
    end
end

