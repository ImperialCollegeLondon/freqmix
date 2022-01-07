function [] = plot_scan(mixing, cfg)
%PLOT_SCAN 

% check if table is empty
if isempty(mixing)
   error('The data table is empty.') 
end

% check mixing type
n_components = sum(contains(mixing.Properties.VariableNames,'Channel'));
if n_components == 2
    plot = @freqmix.plotting.plot_harmonics;
    freqs = mixing{:,1:2};
elseif n_components == 3
    plot = @freqmix.plotting.plot_triplets;   
    freqs = mixing{:,1:3};    
elseif n_components == 4
    plot = @freqmix.plotting.plot_quadruplets;
    freqs = mixing{:,1:4};    
end

% set bounds on frequencies
%config.min_freq = 1;
%config.max_freq = max(freqs,[],'all');

if isempty(cfg.max_freq) && isempty(freqs)
    cfg.max_freq=50;
elseif isempty(cfg.max_freq)
    cfg.max_freq=max(freqs,[],'all');
end


% plotting 
plot(mixing,cfg)

    
end

