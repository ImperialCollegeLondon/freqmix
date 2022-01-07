%% Example 4

% Looking at a single signal.
% Performing scan from 0-40hz
% Perform cluster test on triplets to account for multiple hypothesis testing.

%% create synthetic data

% set hyperparameters for data
time = 20; % seconds
fs = 500; % sampling frequency
n_channels = 1; % number of channels
n_samples = 1; % number of patients (2 signals per patient)

% generate data using function
[signals,group_labels,signal_ids,signal_names,patient_ids] = construct_synthetic_data_grouplevel(n_samples, 'time', time,...
                                                                                                'n_channels',n_channels,'sampling_rate',fs,...
                                                                                                'n_groups',1);

%% Construct main objects and load data 

% define a configuration file
cfg = freqmix.config.config_experiments('data_type','eeg',...
                                     'frequency_range',[0 30],...
                                     'sampling_frequency',fs,...
                                     'test_quadruplets',true,...
                                     'test_triplets',true,...
                                     'test_harmonics',true,...
                                     'parallel',false,...
                                     'n_workers',1,...
                                     'downsampling_frequency',20,...
                                     'between_channels',false,...
                                     'channels',{'Oz'},...
                                     'group_test',false,...
                                     'individual_test',true);

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

exp = exp.run();

% or run each part separately: 
% exp = exp.run_frequencymixing();
% exp = exp.run_statistics();
% exp = exp.run_plotting();


%% save data

save('synthetic_individual_signal_analysis.mat','exp')

%% load data

load('synthetic_individual_signal_analysis.mat')





