%% Example 5

% Scan of frequency mixing 0-40 hz but filtered with only 10Hz root frequency (harmonics, triplets, quadruplets). 
% Comparison of two groups with and without frequency mixing.



%% create synthetic data

% set hyperparameters for data
time = 10; % seconds
fs = 500; % sampling frequency
n_channels = 1; % number of channels
n_samples = 6; % number of patients (2 signals per patient)

% generate data using function
[signals,group_labels,signal_ids,signal_names,patient_ids] = construct_synthetic_data_grouplevel(n_samples, 'time', time,...
                                                                                                'n_channels',n_channels,'sampling_rate',fs);

%% Lets get a feel for the data by plotting

% signal with frequency mixing
y = signals{1};
y = fft(y(:,1));
f = (0:length(y)-1)*fs/length(y);
figure;plot(f,abs(y));xlim([0,30])

% signal without frequency mixing
y = signals{7};
y = fft(y(:,1));
f = (0:length(y)-1)*fs/length(y);
figure;plot(f,abs(y));xlim([0,30])

%% Construct main objects and load data 

% finding subset of quadruplets with 40Hz as a root
[quadruplets, ~, ~] = freqmix.frequencymixing.quadruplets.find_quadruplets(1:50,2,2);
quadruplets = freqmix.frequencymixing.utils.filter_by_root(quadruplets,[40]);                     

% define a configuration file
cfg = freqmix.config.config_experiments('data_type','eeg',...
                                     'quadruplets', quadruplets,...
                                     'sampling_frequency',fs,...
                                     'test_quadruplets',true,...
                                     'test_triplets',true,...
                                     'test_harmonics',true,...
                                     'parallel',false,...
                                     'n_workers',4,...
                                     'downsampling_frequency',20,...
                                     'between_channels',false,...
                                     'channels',{'Oz'});

% create a data collection and load it with data
dc = freqmix.data.datacollection(signals,...
                                'name','synthetic_scan',...
                                'channel_names',{'Oz'},...
                                'group_id', group_labels,...
                                'signal_ids', signal_ids,...
                                'sample_ids', patient_ids);

% construct experiment with configuration
exp = freqmix.experiments.experiment('name','synthetic_data',...
                                     'config',cfg,...
                                     'datacollection',dc);

%% run main frequency mixing functions                                 
% initiate frequency mixing computations
%exp = exp.run();

exp = exp.run_frequencymixing();

exp = exp.run_statistics();

exp = exp.run_plotting();

%% save data

save('synthetic_experiment.mat','exp')

%% load data

load('synthetic_experiment.mat')

%% plotting

plotting_config = exp.config.config_plotting;
mixing = exp.statistics.triplet_statistics.group_cluster_test{2,2};
plotting.plot_mixing(mixing,'config',plotting_config);




