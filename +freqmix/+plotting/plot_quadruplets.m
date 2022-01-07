function [] = plot_quadruplets(mixing,config)
%PLOT_TRIPLETS Summary of this function goes here
%   Detailed explanation goes here

% extract frequencies and channels from table
mixing_combinations = config.mixing_combinations.quadruplet;

% plot 3d scatters
plot_3d_scatter(mixing,config);



end

function plot_3d_scatter(mixing,config)
    % plot 3d scatter of triplet mixing
    import freqmix.plotting.utils.*
    
    quad = mixing{:,1:4};
    figure;          
    r1 = quad(:,1);r2 = quad(:,2);e1 = quad(:,3);e2 = quad(:,4);            
    scatter3(r1,r2,e1); hold on; scatter3(r1,r2,e2);
    
    xlabel('Freq1 (Hz)');ylabel('Freq1 (Hz)');zlabel('Freq3 (Hz)')
    title(['Significant Quadruplets'])        
    xlim([config.min_freq config.max_freq]); ylim([config.min_freq config.max_freq]); zlim([config.min_freq config.max_freq]);
    grid on;
    plot_params(gca)
    if config.saveplot
        savefig([config.folder,'quadruplets_3d_scatter.fig'])
        close all;
    end
end




