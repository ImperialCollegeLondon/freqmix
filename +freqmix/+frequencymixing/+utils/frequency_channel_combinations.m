function [all_combinations] = frequency_channel_combinations(freq_combs, ch_combs, within_channel, between_channel)
%FREQUENCY_CHANNEL_COMBINATIONS combine frequency and channel combinations
%   Detailed explanation goes here

% number of frequency combinations
n_fc = size(freq_combs,1);

% number of frequencies to mix
n_f = size(freq_combs,2);

% find rows with all same channel
within_channel_combs = (range(ch_combs,2)==0);

% filter combinations 
if within_channel && ~between_channel
    % remove between channel combinations
    ch_combs = ch_combs(within_channel_combs,:);    
elseif ~within_channel && between_channel
    % remove within channel combinations
    ch_combs = ch_combs(~within_channel_combs,:);    
end

% number of channel combinations
n_cc = size(ch_combs,1);

% create empty cell array to fill
all_combinations = num2cell(zeros(n_fc*n_cc, n_f*2));


% combining frequency and channel combinations
cnt = 0;
for i = 1:n_fc
    freqs = num2cell(freq_combs(i,:));
    for j = 1:n_cc
        cnt = cnt + 1;
        chans = num2cell(ch_combs(j,:));%channel_names(ch_combs(j,:));
        all_combinations(cnt, :) = [freqs,chans];
    end
end


    
    
end

