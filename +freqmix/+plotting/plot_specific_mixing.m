function [] = plot_specific_mixing(mixing, mixing_ids, config)
%PLOT_INDIVIDUAL_MIXING Summary of this function goes here
%   Detailed explanation goes here
import freqmix.plotting.utils.*

% check mixing type
n_components = sum(contains(mixing{1}.Properties.VariableNames,'Channel'));
if n_components == 2
    freqs = mixing{1}{:,1:2};
    name = [config.folder,'harmonics_'];
    x_label = 'Harmonics';
elseif n_components == 3
    freqs = mixing{1}{:,1:3};
    name = [config.folder,'triplets_'];
    x_label = 'Triplets';
elseif n_components == 4
    freqs = mixing{1}{:,1:4};
    name = [config.folder,'quadruplets_'];
    x_label = 'Quadruplets';
end

% confirm ids
if height(mixing{1}) < max(mixing_ids)
   error('The max mixing id must be smaller than the height of the mixing table.') 
end
groups = config.group_info.group_ids;

[unique_groups,b] = unique(groups);
group_names = config.group_info.group_names(b);
mixing_labels = join(cellfun(@num2str,num2cell(freqs(mixing_ids,:)),'un',0));

values = [];
for i = 1:length(mixing_ids)
    mixing_id = mixing_ids(i);
    for j = 1:length(mixing)
        values(j,i) = mixing{j}.hoi(mixing_id);
    end 
end

all_values = {};
for g = 1:length(unique_groups)
    all_values{g} = values(groups==unique_groups(g),:) ;   
end

figure;
aboxplot(all_values,'labels',mixing_labels)
legend(group_names);
ylabel('HOI');
xlabel(x_label);
if config.saveplot
    check_folder(config.folder)
    savefig([name,'boxplots.fig'])
end


end

function check_folder(folder)
    if ~isfolder(folder)
        mkdir(folder)
    end
end