function [distance_matrix] = freq_distance(freq_list, cut_off)
%COMPUTE_FREQ_DISTANCE Summary of this function goes here
%   Detailed explanation goes here


distance_matrix = squareform(pdist(freq_list));
distance_matrix(distance_matrix>cut_off) = -1;
distance_matrix(distance_matrix>=0) = 1;
distance_matrix(distance_matrix<0) = 0;


end

