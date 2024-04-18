function [] = plot_quadruplets(mixing,config)
%PLOT_TRIPLETS Summary of this function goes here
%   Detailed explanation goes here

% extract frequencies and channels from table
mixing_combinations = config.mixing_combinations.quadruplet;

% plot 3d scatters
plot_3d_scatter(mixing,config);

% plot 2d scatters
plot_2d_scatter(mixing,config);


% plot frequency band mixing relationships
plot_number_quadruplets_bands(mixing,mixing_combinations,config);
plot_tstat_bands(mixing, mixing_combinations, config);

% plot channel mixing relationships
plot_number_quadruplets_channels(mixing,mixing_combinations,config);
plot_tstat_channels(mixing,mixing_combinations,config);





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
        saveas(gca, [config.folder,'quadruplets_3d_scatter',config.ext])
        close all;
    end
end


function plot_2d_scatter(mixing,config)
    % plot 3d scatter of triplet mixing
    import freqmix.plotting.utils.*
    
    quad = mixing{:,1:4};
    r1 = quad(:,1);r2 = quad(:,2);e1 = quad(:,3);e2 = quad(:,4);            

    figure;          
    scatter(r1,r2); 
    
    xlabel('f1 (Hz)');ylabel('f2 (Hz)');
    title(['Frequency mixing roots'])        
    xlim([config.min_freq config.max_freq]); ylim([config.min_freq config.max_freq]);
    grid on;
    plot_params(gca)
    if config.saveplot
        saveas(gca, [config.folder,'quadruplets_2d_scatter_roots',config.ext])
        close all;
    end
    
    figure;          
    scatter(e1,e2); 
    
    xlabel('f\Delta (Hz)');ylabel('f\Sigma (Hz)');
    title(['Frequency mixing emergents'])        
    xlim([config.min_freq config.max_freq]); ylim([config.min_freq config.max_freq]);
    grid on;
    plot_params(gca)
    if config.saveplot
        saveas(gca, [config.folder,'quadruplets_2d_scatter_emergents',config.ext])
        close all;
    end    
end


function plot_number_quadruplets_bands(mixing, mixing_combinations, config)
% plot network of frequency bands weighted by number of quadruplets
import freqmix.plotting.utils.*

bands = config.bands;

[~, ~ ,band_ids] = get_bands(bands);

%%% plotting roots as network %%%

% get normalisation from all tested triplets
banded_tested_quadruplets = convert_to_freq_bands(mixing_combinations(:,1:2),bands);                
for band = 1:size(bands,2)
    n_tested_quads_band(band) = sum(sum(banded_tested_quadruplets==band));
end

%  get number of triplets in each band and normalise
banded_quadruplets = convert_to_freq_bands(mixing{:,1:2},bands);                
max_edge = 0;
for band = 1:size(bands,2)
    n_quads_band(band) =sum(sum(banded_quadruplets==band))/n_tested_quads_band(band);
end

% create figure
f = figure; 
s1 = subplot(2, 3, [1 2 4 5]); 
set(gcf, 'Position',  [1000, 1000, 800, 400])
p = generate_skeleton_graph(band_ids);

% generate graph (harmonic using only roots)
g = generate_harmonic_graph(banded_quadruplets,banded_tested_quadruplets,band_ids);    
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
if max(n_quads_band)~=0
    MarkerSize = 30*n_quads_band'/max(n_quads_band,[],'all');  
    MarkerSize(MarkerSize==0) = 0.01;
    MarkerSize(isnan(MarkerSize)) = 0.01;    
    p.MarkerSize = MarkerSize ;
end
%p.EdgeLabel=g.Edges.Weight;
p.EdgeColor = [0 0 0];
p.EdgeAlpha = 1;
if config.title
    title(['Frequency bands: # roots normalised']); 
end
plot_params(gca);

% add patch for edge width
s2=subplot(2, 3, [3]);axis off
hu = patch([1.5 3 3], [0.8 0.9 0.7], [0 0 0]); 


%%%% plotting emergents as barchart %%%%% 

% get normalisation from all tested triplets
banded_tested_quadruplets = convert_to_freq_bands(mixing_combinations(:,3:4),bands);                
for band = 1:size(bands,2)
    n_tested_quads_band(band) = sum(sum(banded_tested_quadruplets==band));
end

%  get number of triplets in each band and normalise
banded_quadruplets = convert_to_freq_bands(mixing{:,3:4},bands);                
for band = 1:size(bands,2)
    n_quads_band(band) =sum(sum(banded_quadruplets==band))/n_tested_quads_band(band);
end

s3=subplot(2, 3, [6]);bar(n_quads_band)
%plot_params(gca);
xticklabels(band_ids);
ylabel({'# quadruplets'});
if config.title
    title(['Frequency bands: # emergents normalised']); 
end

% define position of subplots
f.Position = [500 500 540 400];
set(s1,'Units','normalized', 'position', [0 0.1 0.7 0.9]);
set(s2,'Units','normalized', 'position', [0.61 0.7 0.2 0.05]);
set(s3,'Units','normalized', 'position', [0.68 0.22 0.19 0.22]);


% annotate the edge width indicator
annotation('textbox',[0.6 0.7 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.7 0.0 0.0], ...
        'String',round(max_edge,3),'FontSize',12)
   
    
% annotate the node size indicator
annotation('textbox',[0.6 0.82 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.82 0.0 0.0], ...
        'String',round(max(n_quads_band) ,3),'FontSize',12)    
    
    
annotation('textbox',[0.65 0.71 0.25 0.1], ...
        'String',{'Node Size'},'FontSize',9,'EdgeColor','none')       

annotation('textbox',[0.64 0.59 0.25 0.1], ...
        'String',{'Edge Width'},'FontSize',9,'EdgeColor','none')       
    
    
annotation('textbox',[0.3 0.48 0.25 0.1], ...
        'String',{'Roots'},'FontSize',12,'EdgeColor','none')       

annotation('textbox',[0.68 0.41 0.25 0.1], ...
        'String',{'Products'},'FontSize',12,'EdgeColor','none')       


    

if config.saveplot
    saveas(gca, [config.folder,'quadruplets_nquad_freqbands',config.ext])
    close all;
end


end

function plot_tstat_bands(mixing, mixing_combinations, config)
% plot network of frequency bands weighted by sum of t-stats
import freqmix.plotting.utils.*

bands = config.bands;
[~, ~ ,band_ids] = get_bands(bands);

%%%% plotting roots as network %%%%% 

%create figure
f = figure; 
s1 = subplot(2, 3, [1 2 4 5]); 
set(gcf, 'Position',  [1000, 1000, 800, 400])
p = generate_skeleton_graph(band_ids);



% get normalisation from all tested triplets
banded_tested_quadruplets = convert_to_freq_bands(mixing_combinations(:,1:2),bands);                
for band = 1:size(bands,2)
    n_tested_quads_band(band) = sum(sum(banded_tested_quadruplets==band));
end

%  get number of triplets in each band and normalise
banded_quadruplets = convert_to_freq_bands(mixing{:,1:2},bands);                

teststats = mixing.teststats;

for band = 1:size(bands,2)    
    teststat_total_band(band) = sum(sum(banded_quadruplets==band,2).*teststats)/n_tested_quads_band(band);  
end

g = generate_tstat_harmonic_graph(banded_quadruplets,teststats,banded_tested_quadruplets,band_ids);  

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
    title(['Frequency bands: sum of root teststats normalised'])
end
plot_params(gca);

% add patch for edge width
s2=subplot(2, 3, [3]);axis off
hu = patch([1.5 3 3], [0.8 0.9 0.7], [0 0 0]); 



%%%% plotting emergents as barchart %%%%% 

% get normalisation from all tested triplets
banded_tested_quadruplets = convert_to_freq_bands(mixing_combinations(:,3:4),bands);                
for band = 1:size(bands,2)
    n_tested_quads_band(band) = sum(sum(banded_tested_quadruplets==band));
end

%  get number of triplets in each band and normalise
banded_quadruplets = convert_to_freq_bands(mixing{:,3:4},bands);                
for band = 1:size(bands,2)
    n_quads_band(band) =sum(sum(banded_quadruplets==band))/n_tested_quads_band(band);
end


s3=subplot(2, 3, [6]);bar(n_quads_band)
%plot_params(gca);
xticklabels(band_ids);
ylabel({'T-values sum'});
if config.title
    title(['Frequency bands: sum t-values emergents normalised']); 
end

% define position of subplots
f.Position = [500 500 540 400];
set(s1,'Units','normalized', 'position', [0 0.1 0.7 0.9]);
set(s2,'Units','normalized', 'position', [0.61 0.7 0.2 0.05]);
set(s3,'Units','normalized', 'position', [0.68 0.22 0.19 0.22]);


% annotate the edge width indicator
annotation('textbox',[0.6 0.7 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.7 0.0 0.0], ...
        'String',round(max_edge,3),'FontSize',12)
    
% annotate the node size indicator
annotation('textbox',[0.6 0.82 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.82 0.0 0.0], ...
        'String',round(max(teststat_total_band) ,3),'FontSize',12)    
    
    
annotation('textbox',[0.65 0.71 0.25 0.1], ...
        'String',{'Node Size'},'FontSize',9,'EdgeColor','none')       

annotation('textbox',[0.64 0.59 0.25 0.1], ...
        'String',{'Edge Width'},'FontSize',9,'EdgeColor','none')       
          

annotation('textbox',[0.3 0.48 0.25 0.1], ...
        'String',{'Roots'},'FontSize',12,'EdgeColor','none')       

annotation('textbox',[0.68 0.41 0.25 0.1], ...
        'String',{'Products'},'FontSize',12,'EdgeColor','none')       


if config.saveplot    
    saveas(gca, [config.folder,'quadruplets_sumt_freqbands',config.ext])
    close all;
end



end


function plot_number_quadruplets_channels(mixing,mixing_combinations,config)
% plot network of channels weighted by number of quadruplets
import freqmix.plotting.utils.*

channels = config.channels;



for ch = 1:length(channels)
    channel_presence = [cell2mat(mixing_combinations(:,5)),cell2mat(mixing_combinations(:,6))];
    n_tested_quads_ch(ch) = sum(sum(channel_presence==ch)); %/n_tested_trips_band(band);
end

for ch = 1:length(channels)
    channel_presence = [mixing{:,5},mixing{:,6}];
    n_quads_ch(ch) = sum(sum(channel_presence==ch))/n_tested_quads_ch(ch);
end

%%% network plot for roots %%%%
f = figure; 
s1 = subplot(2, 3, [1 2 4 5]); 
set(gcf, 'Position',  [1000, 1000, 800, 400])
p = generate_skeleton_graph(channels);

channeled_quadruplets = double(mixing{:,5:6});%plotting.utils.convert_to_channel_ids(mixing(:,4:6),channels);
channeled_tested_quadruplets = cell2mat(mixing_combinations(:,5:6));%plotting.utils.convert_to_channel_ids(mixing_combinations(:,4:6),channels);

g = generate_harmonic_graph(channeled_quadruplets,channeled_tested_quadruplets,channels);    



max_edge = 0;
if max(g.Edges.Weight)>max_edge
    max_edge = max(g.Edges.Weight);
end

node_colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880;0.3010 0.7450 0.9330];
p = plot(g,'Layout','circle', 'NodeColor', node_colors(1:length(n_quads_ch),:));
axis off


if ~isempty(g.Edges.Weight)
    p.LineWidth =  10*g.Edges.Weight/max_edge;
end
if max(n_quads_ch)~=0
    MarkerSize = 30*n_quads_ch'/max(n_quads_ch,[],'all');  
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


%%% barchart of emergents %%%%

for ch = 1:length(channels)
    chan = ch;    
    channel_presence = [cell2mat(mixing_combinations(:,7)),cell2mat(mixing_combinations(:,8))];
    n_tested_quads_ch(ch) = sum(sum(channel_presence==ch)); %/n_tested_trips_band(band);
end

for ch = 1:length(channels)
    chan = ch;    
    channel_presence = [mixing{:,7},mixing{:,8}];
    n_quads_ch(ch) = sum(sum(channel_presence==ch))/n_tested_quads_ch(ch);
end



s3=subplot(2, 3, [6]);bar(n_quads_ch)
%plot_params(gca);
xticklabels(channels);
ylabel({'# quadruplets'});
if config.title
    title(['Frequency bands: # emergents normalised']); 
end

% define position of subplots
f.Position = [500 500 540 400];
set(s1,'Units','normalized', 'position', [0 0.1 0.7 0.9]);
set(s2,'Units','normalized', 'position', [0.61 0.7 0.2 0.05]);
set(s3,'Units','normalized', 'position', [0.68 0.22 0.19 0.22]);


% annotate the edge width indicator
annotation('textbox',[0.6 0.7 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.7 0.0 0.0], ...
        'String',round(max_edge,3),'FontSize',12)
    
% annotate the node size indicator
annotation('textbox',[0.6 0.82 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.82 0.0 0.0], ...
        'String',round(max(n_quads_ch) ,3),'FontSize',12)    
    
    
annotation('textbox',[0.65 0.71 0.25 0.1], ...
        'String',{'Node Size'},'FontSize',9,'EdgeColor','none')       

annotation('textbox',[0.64 0.59 0.25 0.1], ...
        'String',{'Edge Width'},'FontSize',9,'EdgeColor','none')       
          

annotation('textbox',[0.3 0.48 0.25 0.1], ...
        'String',{'Roots'},'FontSize',12,'EdgeColor','none')       

annotation('textbox',[0.68 0.41 0.25 0.1], ...
        'String',{'Products'},'FontSize',12,'EdgeColor','none')       




if config.saveplot    
    saveas(gca, [config.folder,'quadruplets_nemergents_channels_barchart',config.ext])
    close all;
end


end


function plot_tstat_channels(mixing,mixing_combinations,config)
% plot network of frequency bands weighted by tstat
import freqmix.plotting.utils.*

channels = config.channels;
teststats = mixing.teststats;

for ch = 1:length(channels)
    chan = ch;    
    channel_presence = [cell2mat(mixing_combinations(:,5)),cell2mat(mixing_combinations(:,6))];
    n_tested_quads_ch(ch) = sum(sum(channel_presence==ch)); %/n_tested_trips_band(band);
end

for ch = 1:length(channels)
    chan = ch;    
    channel_presence = [mixing{:,5},mixing{:,6}];
    teststat_total_ch(ch) = sum(sum(channel_presence==ch,2).*teststats)/n_tested_quads_ch(ch);
end


channeled_quadruplets = double(mixing{:,5:6});%plotting.utils.convert_to_channel_ids(mixing(:,4:6),channels);
channeled_tested_quadruplets = cell2mat(mixing_combinations(:,5:6));%plotting.utils.convert_to_channel_ids(mixing_combinations(:,4:6),channels);

f = figure; 
s1 = subplot(2, 3, [1 2 4 5]); 
set(gcf, 'Position',  [1000, 1000, 800, 400])
p = generate_skeleton_graph(channels);

g = generate_tstat_harmonic_graph(channeled_quadruplets,teststats,channeled_tested_quadruplets,channels);  

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


%%% barchart of emergents %%%%

for ch = 1:length(channels)
    chan = ch;    
    channel_presence = [cell2mat(mixing_combinations(:,7)),cell2mat(mixing_combinations(:,8))];
    n_tested_quads_ch(ch) = sum(sum(channel_presence==ch)); %/n_tested_trips_band(band);
end

for ch = 1:length(channels)
    chan = ch;    
    channel_presence = [mixing{:,7},mixing{:,8}];
    teststat_total_ch(ch) = sum(sum(channel_presence==ch,2).*teststats)/n_tested_quads_ch(ch);
end


s3=subplot(2, 3, [6]);bar(teststat_total_ch)
%plot_params(gca);
xticklabels(channels);
ylabel({'T-values sum'});
if config.title
    title(['Frequency bands: sum t-values emergents normalised']); 
end

% define position of subplots
f.Position = [500 500 540 400];
set(s1,'Units','normalized', 'position', [0 0.1 0.7 0.9]);
set(s2,'Units','normalized', 'position', [0.61 0.7 0.2 0.05]);
set(s3,'Units','normalized', 'position', [0.68 0.22 0.19 0.22]);

% annotate the edge width indicator
annotation('textbox',[0.6 0.7 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.7 0.0 0.0], ...
        'String',round(max_edge,3),'FontSize',12)
    
% annotate the node size indicator
annotation('textbox',[0.6 0.82 0.0 0.0], ...
           'String',0,'FontSize',12)
       
annotation('textbox',[0.78 0.82 0.0 0.0], ...
        'String',round(max(teststat_total_ch) ,3),'FontSize',12)    
    
    
annotation('textbox',[0.65 0.71 0.25 0.1], ...
        'String',{'Node Size'},'FontSize',9,'EdgeColor','none')       

annotation('textbox',[0.64 0.59 0.25 0.1], ...
        'String',{'Edge Width'},'FontSize',9,'EdgeColor','none')       
          

annotation('textbox',[0.3 0.48 0.25 0.1], ...
        'String',{'Roots'},'FontSize',12,'EdgeColor','none')       

annotation('textbox',[0.68 0.41 0.25 0.1], ...
        'String',{'Products'},'FontSize',12,'EdgeColor','none')    
    
    
    

if config.saveplot    
    saveas(gca, [config.folder,'quadruplets_sumt_channels',config.ext])
    close all;
end


end
