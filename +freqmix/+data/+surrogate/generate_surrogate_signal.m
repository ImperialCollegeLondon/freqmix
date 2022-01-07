function [surrogate_signal] = generate_surrogate_signal(signal)
%GENERATE_SURROGATE_SIGNAL Summary of this function goes here
%   Detailed explanation goes here

surrogate_signal = [];
for i = 1:size(signal,2)
    surrogate_signal(:,i) = ifft(abs(fft(signal(:,i))));    
end


end

