%% Example 3

% Full scan of frequency mixing 0-40 hz (harmonics, triplets, quadruplets). 
% Regression against metadata 
% Increasing noise in signal to drown out mixing, i.e., mixing correlated
% with noise amplitude.

%% create synthetic data

% set hyperparameters for data
time = 10; % seconds
fs = 500; % sampling frequency
n_channels = 1; % number of channels
n_samples = 20; % number of patients (2 signals per patient)
noise = linspace(1,20,n_samples);
% generate data using function
[signals,group_labels,signal_ids,signal_names,patient_ids] = construct_synthetic_data_grouplevel(n_samples, 'time', time,...
                                                                                                'n_channels',n_channels,'sampling_rate',fs,...
                                                                                                'n_groups',1,...
                                                                                                'noise',noise);

metadata = noise;   

%% Lets plot and see what the signals look like

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
                                     'regression_test',true);

% create a data collection and load it with data
dc = freqmix.data.datacollection(signals,...
                                'name','synthetic_scan',...
                                'channel_names',{'Oz'},...
                                'group_id', group_labels,...
                                'signal_ids', signal_ids,...
                                'sample_ids', patient_ids,...
                                'metadata',metadata);

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

save('synthetic_regression_experiment.mat','exp')

%% load data

load('synthetic_regression_experiment.mat')





