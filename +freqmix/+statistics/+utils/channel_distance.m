function [distance_matrix] = channel_distance(channel_list, cut_off)
%COMPUTE_CHANNEL_DISTANCE Summary of this function goes here
%   Detailed explanation goes here

% define parameters
%cut_off = 2; % two channels must overlap 


% define sizes
n_tri = size(channel_list,1);
distance_matrix = zeros(n_tri);

% if channel list is strings, then convert
if isequal(class(channel_list),'string')
    %n_ch = length(channel_names);
    n_ch = length(unique(channel_list));
    channel_list = cellstr(channel_list);
    dowMap = containers.Map(channel_names,linspace(1,n_ch,n_ch));
    channel_list = cell2mat(cellfun(@(x) dowMap(x), channel_list, ...
                'UniformOutput', false));
end

% how many of the channels are the same
for ch1 = 1:n_tri
    tri_ch1 = channel_list(ch1,:);
    dist = sum(eq(tri_ch1, channel_list),2);
    distance_matrix(ch1,:) = dist;
end
distance_matrix(distance_matrix < cut_off) = 0;
distance_matrix(distance_matrix >= cut_off) = 1;



end

