%Paul Rubenstein, 2015
%Code for Lancaster interaction with timeseries
%Returns matrix with (i,j)th entry given by (+,j)
%ie we sum along the columns
function [matrix] = colsum(gram_matrix)
n=size(gram_matrix);
n=n(1);
matrix = repmat(sum(gram_matrix,1),[n,1]);
end