%Paul Rubenstein, 2015
%Code for Lancaster interaction with timeseries
%Returns matrix with (i,j)th entry given by (+,+)
%ie we sum all elements
function [matrix] = sumsum(gram_matrix)
n=size(gram_matrix);
n=n(1);
matrix = repmat(sum(sum(gram_matrix)),[n,n]);
end