function [subset_mixing] = filter_by_root(quadruplets, freqs)
%FILTER_BY_ROOT Summary of this function goes here
%   Detailed explanation goes here

% get only roots
roots = quadruplets(:,1:2);

% find index of quadruplets with any of the chosen frequencies
idx = any(ismember(roots,freqs),2);

% finding the slice of quadruplets by index
subset_mixing = quadruplets(idx,:);


end

