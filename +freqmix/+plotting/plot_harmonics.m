function [] = plot_harmonics(mixing,config)
%PLOT_TRIPLETS Summary of this function goes here
%   Detailed explanation goes here

% extract frequencies and channels from table
mixing_combinations = config.mixing_combinations.harmonic;

% plot 3d scatters
plot_2d_scatter(mixing,config);



end

function plot_2d_scatter(mixing,config)
    % plot 3d scatter of triplet mixing
    import freqmix.plotting.utils.*
    
    freqs = mixing{:,1:2};
    figure;          
    x = freqs(:,1);y = freqs(:,2);         
    scatter(x,y);
    
    xlabel('Freq1 (Hz)');ylabel('Freq1 (Hz)');
    title(['Significant Harmonics'])        
    xlim([config.min_freq config.max_freq]); ylim([config.min_freq config.max_freq]);
    grid on;
    plot_params(gca)
    if config.saveplot
        savefig([config.folder,'harmonics_2d_scatter.fig'])
        close all;
    end
end




