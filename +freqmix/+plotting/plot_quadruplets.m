function [] = plot_quadruplets(mixing,config)
%PLOT_TRIPLETS Summary of this function goes here
%   Detailed explanation goes here

% extract frequencies and channels from table
mixing_combinations = config.mixing_combinations.quadruplet;

% plot 3d scatters
plot_3d_scatter(mixing,config);

plot_tstat_bands_graph(mixing, mixing_combinations, config);

plot_tstat_channels_graph(mixing,mixing_combinations,config);

% save csv file of mixing
if config.savedata
    writetable(mixing,[config.folder,'significant_quadruplets.csv'])
end

end

function plot_3d_scatter(mixing,config)
    % plot 3d scatter of triplet mixing
    import freqmix.plotting.utils.*
    
    quad = mixing{:,1:4};
    figure;          
    r1 = quad(:,1);r2 = quad(:,2);e1 = quad(:,3);e2 = quad(:,4);            
    scatter3(r1,r2,e1); hold on; scatter3(r1,r2,e2);
    
    xlabel('f1 (Hz)');ylabel('f2 (Hz)');zlabel('f3 (Hz)')
    title(['Significant Quadruplets'])        
    xlim([config.min_freq config.max_freq]); ylim([config.min_freq config.max_freq]); zlim([config.min_freq config.max_freq]);
    grid on;
    plot_params(gca)
    if config.saveplot
        savefig([config.folder,'quadruplets_3d_scatter.fig'])
        close all;
    end
end


function plot_tstat_bands_graph(mixing, mixing_combinations, config)
% plot network of frequency bands weighted by sum of t-stats
import freqmix.plotting.utils.*

bands = config.bands;
[~, ~ ,band_ids] = get_bands(bands);
p = generate_skeleton_graph(band_ids);


% get normalisation from all tested triplets
banded_tested_quadruplets = convert_to_freq_bands(mixing_combinations(:,1:4),bands);                
for band = 1:size(bands,2)
    n_tested_quads_band(band) = sum(sum(banded_tested_quadruplets==band));
end

%  get number of triplets in each band and normalise
banded_quadruplets = convert_to_freq_bands(mixing{:,1:4},bands);                
max_edge = 0;
for band = 1:size(bands,2)
    n_quads_band(band) =sum(sum(banded_quadruplets==band))/n_tested_quads_band(band);
end


teststats = mixing.teststats;

for band = 1:size(bands,2)    
    teststat_total_band(band) = sum(sum(banded_quadruplets==band,2).*teststats)/n_tested_quads_band(band);  
end

g = generate_tstat_quadruplet_graph(banded_quadruplets,teststats,banded_tested_quadruplets,band_ids);  


max_edge = 0;
if max(g.Edges.Weight)>max_edge
    max_edge = max(g.Edges.Weight);
end


p = plot(g,'Layout','circle');


g.Nodes.NodeColors = teststat_total_band';
p.NodeCData = g.Nodes.NodeColors;
hcb=colorbar; ylabel(hcb,'Normalised teststats'); 
caxis([0,max(teststat_total_band,[],'all')])

if ~isempty(g.Edges.Weight)
    p.LineWidth =  10*g.Edges.Weight/max_edge;
end

if max(teststat_total_band)~=0
    MarkerSize = 30*teststat_total_band'/max(teststat_total_band,[],'all');  
    MarkerSize(MarkerSize==0) = 0.01; 
    MarkerSize(isnan(MarkerSize)) = 0.01; 
    p.MarkerSize = MarkerSize ;
end
%p.EdgeLabel=g.Edges.Weight;
p.EdgeColor = [0 0.4470 0.7410];
p.EdgeAlpha = 1;
if config.title
    title(['Frequency bands: sum of teststats normalised'])
end
plot_params(gca)
cbarrow(max_edge)

if config.saveplot    
    savefig([config.folder,'quadruplets_sumt_freqbands_network.fig'])
    close all;
end


end

function plot_tstat_channels_graph(mixing,mixing_combinations,config)
% plot network of frequency bands weighted by tstat
import freqmix.plotting.utils.*

channels = config.channels;
teststats = mixing.teststats;

for ch = 1:length(channels)
    chan = ch;    
    channel_presence = [cell2mat(mixing_combinations(:,5)),cell2mat(mixing_combinations(:,6)),cell2mat(mixing_combinations(:,7)),cell2mat(mixing_combinations(:,8))];
    n_tested_quads_ch(ch) = sum(sum(channel_presence)); %/n_tested_trips_band(band);
end

for ch = 1:length(channels)
    chan = ch;    
    channel_presence = [mixing{:,5},mixing{:,6},mixing{:,7},mixing{:,8}];
    teststat_total_ch(ch) = sum(sum(channel_presence,2).*teststats)/n_tested_quads_ch(ch);
end


channeled_quadruplets = double(mixing{:,5:8});%plotting.utils.convert_to_channel_ids(mixing(:,4:6),channels);
channeled_tested_quadruplets = cell2mat(mixing_combinations(:,5:8));%plotting.utils.convert_to_channel_ids(mixing_combinations(:,4:6),channels);

p = generate_skeleton_graph(channels);
g = generate_tstat_quadruplet_graph(channeled_quadruplets,teststats,channeled_tested_quadruplets,channels);  

max_edge = 0;
if max(g.Edges.Weight)>max_edge
    max_edge = max(g.Edges.Weight);
end

p = plot(g,'Layout','circle');
g.Nodes.NodeColors = teststat_total_ch';
p.NodeCData = g.Nodes.NodeColors;
hcb=colorbar; ylabel(hcb,'Normalised teststats'); 
caxis([0,max(teststat_total_ch,[],'all')])

if ~isempty(g.Edges.Weight)
    p.LineWidth =  10*g.Edges.Weight/max_edge;
end

if max(teststat_total_ch)~=0
    MarkerSize = 30*teststat_total_ch'/max(teststat_total_ch,[],'all');  
    MarkerSize(MarkerSize==0) = 0.01; 
    MarkerSize(isnan(MarkerSize)) = 0.01;  
    p.MarkerSize = MarkerSize ;
end
p.EdgeColor = [0 0.4470 0.7410];
p.EdgeAlpha = 1;
cbarrow(max_edge);
if config.title
    title(['Channels: sum of teststats normalised'])
end
plot_params(gca)
if config.saveplot
    savefig([config.folder,'quadruplets_sumt_channels_network.fig'])
    close all;
end



end
