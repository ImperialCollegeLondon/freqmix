function [signals,group_labels,signal_ids,signal_names,patient_ids] = construct_synthetic_data_grouplevel(n_patients,varargin)
%CONSTRUCT_SYNTHETIC_DATA generating group level synthetic data
%   Detailed explanation goes here

    Q = 10; %irregularity parameter
    total_t = 10; %duration in seconds            
    sampling_rate = 1000; % sampling rate of signal
    noise_amplitude=3; % amplitude of noise
    amplitude = [0.5 1]; % min max amplitude of signals
    freq_mixing = {[6 8; 17 19]}; % min max frequencies of signals to mix
    n_channels = 3;
    n_groups = 2;
    
    linear_mixing = 1;
    quadratic_mixing = 1;
    cubic_mixing = 0;
    
    for argidx = 1:2:length(varargin)
       switch varargin{argidx}
           case 'time'
               total_t = varargin{argidx+1};
           case 'sampling_rate'
               sampling_rate = varargin{argidx+1};
           case 'noise'
               noise_amplitude = varargin{argidx+1};   
           case 'freqs'
               freq_mixing = varargin{argidx+1};  
           case 'amplitude'
               amplitude = varargin{argidx+1};  
           case 'n_channels'
               n_channels = varargin{argidx+1}; 
           case 'n_groups'
               n_groups = varargin{argidx+1}; 
           case 'irregularity'
               Q = varargin{argidx+1}; 
       end
    end  

    
    if length(Q)==1
       Q = repmat(Q,n_patients*n_groups,1); 
    end
    if length(noise_amplitude)==1
       noise_amplitude = repmat(noise_amplitude,n_patients*n_groups,1);
    end
    if length(amplitude)<2
        amplitude = [amplitude amplitude];
    end

    
    patients = linspace(1,n_patients,n_patients);

    cnt = 0;
    signals = {};
    group_labels = [];
    signal_ids = [];
    signal_names = {};
    patient_ids = []; 

    for pp = 1:length(patients)
        cnt = cnt+1;

        mixed_signal = [];
        for i = 1:length(freq_mixing)
            mixed_signal =+ generate_signal(freq_mixing{i},Q(cnt),sampling_rate,total_t,amplitude,n_channels, linear_mixing, quadratic_mixing, cubic_mixing);
        end       

        additive_noise = noise_amplitude(cnt)*randn(size(mixed_signal,1),size(mixed_signal,2));        
        mixed_signal = mixed_signal + additive_noise;     

        signals{cnt} = mixed_signal;
        group_labels(cnt) = 1;
        signal_ids(cnt) = cnt;
        signal_names{cnt} = ['p',num2str(pp),'_freqmix'];
        patient_ids(cnt) = pp;   

    end
    
    quadratic_mixing = 0;
    if n_groups>1
    for pp = 1:length(patients)
        cnt = cnt + 1;
        mixed_signal = [];
        for i = 1:length(freq_mixing)
            mixed_signal =+ generate_signal(freq_mixing{i},Q(cnt),sampling_rate,total_t,amplitude,n_channels,linear_mixing, quadratic_mixing, cubic_mixing);
        end       

        additive_noise = noise_amplitude(cnt)*randn(size(mixed_signal,1),size(mixed_signal,2));        
        mixed_signal = mixed_signal + additive_noise;     


        signals{cnt} = mixed_signal;
        group_labels(cnt) = 2;
        signal_ids(cnt) = cnt;
        signal_names{cnt} = ['p',num2str(pp),'_freqmix'];
        patient_ids(cnt) = pp;   

    end   
    end
    
end


function [signal] = generate_signal(freqs,Q,sampling_rate,total_t,amplitude,n_channels, linear_mixing, quadratic_mixing, cubic_mixing)
    

    % define imports
    import freqmix.data.synthetic.generate_synthetic_signal
    
    % signal 1 parameters
    params_1.Fs = sampling_rate;
    params_1.dt = 1/params_1.Fs;
    params_1.t = params_1.dt:params_1.dt:total_t;
    params_1.ctl_pts_t    = linspace(params_1.t(1),params_1.t(end),round(Q*total_t));
    params_1.IF_low       = ones(size(params_1.ctl_pts_t))*freqs(1,1);
    params_1.IF_high      = ones(size(params_1.ctl_pts_t))*freqs(1,2);
    params_1.IA_low       = ones(size(params_1.ctl_pts_t))*amplitude(1);
    params_1.IA_high      = ones(size(params_1.ctl_pts_t))*amplitude(2);
    params_1.n_signals = n_channels;


    % signal 2 parameters
    params_2.Fs = sampling_rate;
    params_2.dt = 1/params_2.Fs;
    params_2.t = params_2.dt:params_2.dt:total_t;
    params_2.ctl_pts_t    = linspace(params_2.t(1),params_2.t(end),round(Q*total_t));
    params_2.IF_low       = ones(size(params_2.ctl_pts_t))*freqs(2,1);
    params_2.IF_high      = ones(size(params_2.ctl_pts_t))*freqs(2,2);
    params_2.IA_low       = ones(size(params_2.ctl_pts_t))*amplitude(1);
    params_2.IA_high      = ones(size(params_2.ctl_pts_t))*amplitude(2);
    params_2.n_signals = n_channels; 
 
    root1 = generate_synthetic_signal(params_1);%root1 = sum(root1,1);     
    root2 = generate_synthetic_signal(params_2);%root2 = sum(root2,1);   
        
    signal = linear_mixing*(root1'+ root2')+ quadratic_mixing*(root1' + root2').^2 + cubic_mixing*(root1' + root2').^3;
end
