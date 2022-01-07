%Paul Rubenstein, 2015
%Code for Lancaster interaction with timeseries
%Returns matrix with (i,j)th entry given by (i,+)
%ie we sum along the rows
function [matrix] = rowsum(gram_matrix)
n=size(gram_matrix);
n=n(1);
matrix = repmat(sum(gram_matrix,2),[1,n]);
end