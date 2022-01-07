function [banded_triplets] = convert_to_freq_bands(mixing, bands)
%CONVERT_TO_FREQ_BANDS Summary of this function goes here
%   Detailed explanation goes here
import freqmix.plotting.utils.*

if isequal(class(mixing),'cell')
    mixing = cell2mat(mixing);
end

[freq_bands,~,~] = get_bands(bands);


%mixing = mixing{:,:};% triplets{:,5:7};
banded_triplets = zeros(size(mixing));

for i = 1:size(mixing,1)
    for j = 1:size(mixing,2)
        val = mixing(i,j);        
        for k = 1:size(freq_bands,1)
            if (val>=freq_bands(k,1) && val<freq_bands(k,2))
                banded_triplets(i,j) = k;

            end
        end
         
    end   
end


end



