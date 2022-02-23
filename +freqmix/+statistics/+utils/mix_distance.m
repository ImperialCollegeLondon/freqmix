function [adjacency_matrix] = mix_distance(mixing, config, mixing_type)
%MIX_DISTANCE Summary of this function goes here
%   Detailed explanation goes here
import freqmix.statistics.utils.*

% set parameters specific to mixing type
if isequal(mixing_type,'harmonic')
    freq_list = single(mixing{:,1:2});
    channel_list = mixing{:,3:4};
    freq_cutoff = 2*config.freq_bin_size;
    ch_cutoff = 1;
elseif isequal(mixing_type,'triplet')
    freq_list = single(mixing{:,1:3});
    channel_list = mixing{:,4:6}; 
    freq_cutoff = 2*config.freq_bin_size;
    ch_cutoff = 2;
elseif isequal(mixing_type, 'quadruplet')
    freq_list = single(mixing{:,1:4});
    channel_list = mixing{:,5:8};
    freq_cutoff = 2*config.freq_bin_size;
    ch_cutoff = 3;
end


% compute distance in frequency space
distance_matrix_freq = freq_distance(freq_list, freq_cutoff);

% compute distance in channel space
distance_matrix_channel = channel_distance(channel_list, ch_cutoff);

% combining channel and frequency distance
adjacency_matrix = distance_matrix_freq + distance_matrix_channel;
adjacency_matrix(adjacency_matrix<2) = 0;
adjacency_matrix(adjacency_matrix==2) = 1;




end

