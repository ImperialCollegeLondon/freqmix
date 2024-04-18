function [] = plot_triplets(mixing,config)
%PLOT_TRIPLETS Summary of this function goes here
%   Detailed explanation goes here

% extract frequencies and channels from table
mixing_combinations = config.mixing_combinations.triplet;

% plot 3d scatters
plot_3d_scatter(mixing,config);
plot_3d_scatter_coloured(mixing,config);

% plot frequency band relationships
plot_number_triplets_bands_graph(mixing,mixing_combinations,config);
plot_tstat_bands_graph(mixing, mixing_combinations, config);

% plot channel relationships
plot_number_triplets_channels_graph(mixing,mixing_combinations,config);
plot_tstat_channels_graph(mixing,mixing_combinations,config);

% save csv file of mixing
if config.savedata
    writetable(mixing,[config.folder,'significant_triplets.csv'])
end

end

function plot_3d_scatter(mixing,config)
    % plot 3d scatter of triplet mixing
    import freqmix.plotting.utils.*
    
    freqs = mixing{:,1:3};
    figure;          
    x = freqs(:,1);y = freqs(:,2);z = freqs(:,3);
    scatter3(x,y,z); hold on;
    xlabel('f1 (Hz)');ylabel('f2 (Hz)');zlabel('f3 (Hz)')
    if config.title
        title(['Significant Triplets']);   
    end
    xlim([config.min_freq config.max_freq]); ylim([config.min_freq config.max_freq]); zlim([config.min_freq config.max_freq]);
    grid on;
    plot_params(gca)
    if config.saveplot
        saveas(gca, [config.folder,'triplets_3d_scatter',config.ext])
        close all;
    end
end

function plot_3d_scatter_coloured(mixing,config)
    % plot 3d scatter of triplet mixing coloured by cluster
    import freqmix.plotting.utils.*
    
    figure; 
    unique_clusters = unique(mixing.cluster_id);
    for i = 1:length(unique_clusters)
        triplets_cluster = mixing(mixing.cluster_id==unique_clusters(i),:);
        trip = triplets_cluster{:,1:3};  
        x = trip(:,1);y = trip(:,2);z = trip(:,3);
        scatter3(x,y,z); hold on;
        xlabel('f1 (Hz)');ylabel('f2 (Hz)');zlabel('f3 (Hz)')
        if config.title
            title(['Significant Triplets']);   
        end   
        xlim([config.min_freq config.max_freq]); ylim([config.min_freq config.max_freq]); zlim([config.min_freq config.max_freq]);
        grid on;
        plot_params(gca)    
    end
    if config.saveplot
        saveas(gca, [config.folder,'triplets_3d_scatter_clustered',config.ext])
        close all;
    end
end


function plot_number_triplets_bands_graph(mixing, mixing_combinations, config)
% plot network of frequency bands weighted by number of triplets
import freqmix.plotting.utils.*


bands = config.bands;

[~, ~ ,band_ids] = get_bands(bands);

% get normalisation from all tested triplets
banded_tested_triplets = convert_to_freq_bands(mixing_combinations(:,1:3),bands);                
for band = 1:size(bands,2)
    n_tested_trips_band(band) = sum(sum(banded_tested_triplets==band));
end

%  get number of triplets in each band and normalise
banded_triplets = convert_to_freq_bands(mixing{:,1:3},bands);                
max_edge = 0;
for band = 1:size(bands,2)
    n_trips_band(band) =sum(sum(banded_triplets==band))/n_tested_trips_band(band);
end

% create figure
f = figure; 
s1 = subplot(2, 3, [1 2 4 5]); 
set(gcf, 'Position',  [1000, 1000, 600, 400])
p = generate_skeleton_graph(band_ids);


% generate graph
g = generate_graph(banded_triplets,banded_tested_triplets,band_ids);    
if max(g.Edges.Weight)>max_edge
    max_edge = max(g.Edges.Weight);
end

% plot network structure
node_colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880;0.3010 0.7450 0.9330];
p = plot(g,'Layout','circle', 'NodeColor', node_colors(1:length(band_ids),:));
axis off

if ~isempty(g.Edges.Weight)
    p.LineWidth =  10*g.Edges.Weight/max_edge;
end
if max(n_trips_band)~=0
    MarkerSize = 30*n_trips_band'/max(n_trips_band,[],'all');  
    MarkerSize(MarkerSize==0) = 0.01;
    MarkerSize(isnan(MarkerSize)) = 0.01;    
    p.MarkerSize = MarkerSize ;
end
%p.EdgeLabel=g.Edges.Weight;
p.EdgeColor = [0 0 0];
p.EdgeAlpha = 1;
if config.title
    title(['Frequency bands: # triplets normalised']); 
end
plot_params(gca);

% add patch for edge width
s2=subplot(2, 3, [3]);axis off
hu = patch([1.5 3 3], [0.8 0.9 0.7], [0 0 0]); 

% define position of subplots
f.Position = [500 500 540 400];
set(s1,'Units','normalized', 'position', [0 0.1 0.7 0.9]);
set(s2,'Units','normalized', 'position', [0.61 0.7 0.2 0.05]);


% annotate the edge width indicator
annotation('textbox',[0.6 0.7 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.7 0.0 0.0], ...
        'String',round(max_edge,3),'FontSize',12)
    
annotation('textbox',[0.63 0.8 0.25 0.1], ...
        'String',{'Edge width:';'# triplets normalised'},'FontSize',10,'EdgeColor','none')       


    
if config.saveplot
    saveas(gca, [config.folder,'triplets_ntriplets_freqbands_network',config.ext])
    close all;
end

end

function plot_tstat_bands_graph(mixing, mixing_combinations, config)
% plot network of frequency bands weighted by sum of t-stats
import freqmix.plotting.utils.*

bands = config.bands;
[~, ~ ,band_ids] = get_bands(bands);

%create figure
f = figure; 
s1 = subplot(2, 3, [1 2 4 5]); 
set(gcf, 'Position',  [1000, 1000, 800, 400])
p = generate_skeleton_graph(band_ids);

% get normalisation from all tested triplets
banded_tested_triplets = convert_to_freq_bands(mixing_combinations(:,1:3),bands);                
for band = 1:size(bands,2)
    n_tested_trips_band(band) = sum(sum(banded_tested_triplets==band));
end

%  get number of triplets in each band and normalise
banded_triplets = convert_to_freq_bands(mixing{:,1:3},bands);                
max_edge = 0;
for band = 1:size(bands,2)
    n_trips_band(band) =sum(sum(banded_triplets==band))/n_tested_trips_band(band);
end


teststats = mixing.teststats;

for band = 1:size(bands,2)    
    teststat_total_band(band) = sum(sum(banded_triplets==band,2).*teststats)/n_tested_trips_band(band);  
end

g = generate_tstat_graph(banded_triplets,teststats,banded_tested_triplets,band_ids);  


max_edge = 0;
if max(g.Edges.Weight)>max_edge
    max_edge = max(g.Edges.Weight);
end


node_colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880;0.3010 0.7450 0.9330];
p = plot(g,'Layout','circle', 'NodeColor', node_colors(1:length(band_ids),:));
axis off

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
p.EdgeColor = [0 0 0];
p.EdgeAlpha = 1;
if config.title
    title(['Frequency bands: Normalised sum root t-values'])
end
plot_params(gca)

% add patch for edge width
s2=subplot(2, 3, [3]);axis off
hu = patch([1.5 3 3], [0.8 0.9 0.7], [0 0 0]); 


% define position of subplots
f.Position = [500 500 540 400];
set(s1,'Units','normalized', 'position', [0 0.1 0.7 0.9]);
set(s2,'Units','normalized', 'position', [0.61 0.7 0.2 0.05]);


% annotate the edge width indicator
annotation('textbox',[0.6 0.7 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.7 0.0 0.0], ...
        'String',round(max_edge,3),'FontSize',12)
    
annotation('textbox',[0.63 0.8 0.25 0.1], ...
        'String',{'Edge width:';'Normalised sum of teststats'},'FontSize',10,'EdgeColor','none')       


if config.saveplot    
    saveas(gca, [config.folder,'triplets_sumt_freqbands_network',config.ext])
    close all;
end


end


function plot_number_triplets_channels_graph(mixing,mixing_combinations,config)
% plot network of channels weighted by number of triplets
import freqmix.plotting.utils.*

channels = config.channels;

for ch = 1:length(channels)
    channel_presence = [cell2mat(mixing_combinations(:,4)),cell2mat(mixing_combinations(:,5)),cell2mat(mixing_combinations(:,6))];
    n_tested_trips_ch(ch) = sum(sum(channel_presence==ch)); %/n_tested_trips_band(band);
end

for ch = 1:length(channels)
    channel_presence = [mixing{:,4},mixing{:,5},mixing{:,6}];
    n_trips_ch(ch) = sum(sum(channel_presence==ch))/n_tested_trips_ch(ch);
end

%%% network plot for roots %%%%
f = figure; 
s1 = subplot(2, 3, [1 2 4 5]); 
set(gcf, 'Position',  [1000, 1000, 800, 400])
p = generate_skeleton_graph(channels);


channeled_triplets = double(mixing{:,4:6});%plotting.utils.convert_to_channel_ids(mixing(:,4:6),channels);
channeled_tested_triplets = cell2mat(mixing_combinations(:,4:6));%plotting.utils.convert_to_channel_ids(mixing_combinations(:,4:6),channels);

g = generate_graph(channeled_triplets,channeled_tested_triplets,channels);    

max_edge = 0;
if max(g.Edges.Weight)>max_edge
    max_edge = max(g.Edges.Weight);
end

% plot network structure
node_colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880;0.3010 0.7450 0.9330];
p = plot(g,'Layout','circle', 'NodeColor', node_colors(1:length(channels),:));
axis off



if ~isempty(g.Edges.Weight)
    p.LineWidth =  10*g.Edges.Weight/max_edge;
end
if max(n_trips_ch)~=0
    MarkerSize = 30*n_trips_ch'/max(n_trips_ch,[],'all');  
    MarkerSize(MarkerSize==0) = 0.01; 
    MarkerSize(isnan(MarkerSize)) = 0.01;  
    p.MarkerSize = MarkerSize ;
end
p.EdgeColor = [0 0 0];
p.EdgeAlpha = 1;
%p.EdgeLabel=g.Edges.Weight;

if config.title
    title(['Frequency mixing within/between channels']);
end
plot_params(gca)

% add patch for edge width
s2=subplot(2, 3, [3]);axis off
hu = patch([1.5 3 3], [0.8 0.9 0.7], [0 0 0]); 


% define position of subplots
f.Position = [500 500 540 400];
set(s1,'Units','normalized', 'position', [0 0.1 0.7 0.9]);
set(s2,'Units','normalized', 'position', [0.61 0.7 0.2 0.05]);


% annotate the edge width indicator
annotation('textbox',[0.6 0.7 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.7 0.0 0.0], ...
        'String',round(max_edge,3),'FontSize',12)
    
annotation('textbox',[0.63 0.8 0.25 0.1], ...
        'String',{'Edge width:';'# triplets normalised'},'FontSize',10,'EdgeColor','none')       


if config.saveplot
    saveas(gca, [config.folder,'triplets_ntriplets_channels',config.ext]) 
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
    channel_presence = [cell2mat(mixing_combinations(:,4)),cell2mat(mixing_combinations(:,5)),cell2mat(mixing_combinations(:,6))];
    n_tested_trips_ch(ch) = sum(sum(channel_presence==ch)); %/n_tested_trips_band(band);
end

for ch = 1:length(channels)
    chan = ch;    
    channel_presence = [mixing{:,4},mixing{:,5},mixing{:,6}];
    teststat_total_ch(ch) = sum(sum(channel_presence==ch,2).*teststats)/n_tested_trips_ch(ch);
end


channeled_triplets = double(mixing{:,4:6});%plotting.utils.convert_to_channel_ids(mixing(:,4:6),channels);
channeled_tested_triplets = cell2mat(mixing_combinations(:,4:6));%plotting.utils.convert_to_channel_ids(mixing_combinations(:,4:6),channels);

f = figure; 
s1 = subplot(2, 3, [1 2 4 5]); 
set(gcf, 'Position',  [1000, 1000, 800, 400])
p = generate_skeleton_graph(channels);

g = generate_tstat_graph(channeled_triplets,teststats,channeled_tested_triplets,channels);  

max_edge = 0;
if max(g.Edges.Weight)>max_edge
    max_edge = max(g.Edges.Weight);
end

node_colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880;0.3010 0.7450 0.9330];
p = plot(g,'Layout','circle', 'NodeColor', node_colors(1:length(channels),:));
axis off

if ~isempty(g.Edges.Weight)
    p.LineWidth =  10*g.Edges.Weight/max_edge;
end

if max(teststat_total_ch)~=0
    MarkerSize = 30*teststat_total_ch'/max(teststat_total_ch,[],'all');  
    MarkerSize(MarkerSize==0) = 0.01; 
    MarkerSize(isnan(MarkerSize)) = 0.01;  
    p.MarkerSize = MarkerSize ;
end
p.EdgeColor = [0 0 0];
p.EdgeAlpha = 1;


if config.title
    title(['Channels: sum of teststats normalised'])
end
plot_params(gca)

% add patch for edge width
s2=subplot(2, 3, [3]);axis off
hu = patch([1.5 3 3], [0.8 0.9 0.7], [0 0 0]); 

f.Position = [500 500 540 400];
set(s1,'Units','normalized', 'position', [0 0.1 0.7 0.9]);
set(s2,'Units','normalized', 'position', [0.61 0.7 0.2 0.05]);


% annotate the edge width indicator
annotation('textbox',[0.6 0.7 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.7 0.0 0.0], ...
        'String',round(max_edge,3),'FontSize',12)
    
annotation('textbox',[0.63 0.8 0.25 0.1], ...
        'String',{'Edge width:';'Normalised sum of teststats'},'FontSize',10,'EdgeColor','none')       


if config.saveplot
    saveas(gca, [config.folder,'triplets_sumt_channels_network',config.ext])
    close all;
end



end


