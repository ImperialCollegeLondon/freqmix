%Paul Rubenstein, 2015
%Code for Lancaster interaction with timeseries
%Center gram matrix
function [centred_matrix] = empirically_centre(gram_matrix)
import freqmix.frequencymixing.utils.*
n = size(gram_matrix);
n = n(1);
%empirically centering 'by hand' or using H*K*H
%former is faster but uses more memory, latter
% is slower but uses less memory
%centred_matrix = gram_matrix - (1/n)*rowsum(gram_matrix) - (1/n)*colsum(gram_matrix) + (1/n^2)*sumsum(gram_matrix);
%H = eye(n)-(1/n)*ones(n);
%centred_matrix = H*gram_matrix*H;

centred_matrix = gram_matrix - (1/n)*rowsum(gram_matrix) - (1/n)*colsum(gram_matrix) + (1/n^2)*sumsum(gram_matrix);

end