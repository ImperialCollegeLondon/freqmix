function [channeled_triplets] = convert_to_channel_ids(triplets, channels)
%CONVERT_TO_FREQ_BANDS Summary of this function goes here
%   Detailed explanation goes here



triplets = triplets{:,:};

for i = 1:size(triplets,1)
    for j = 1:size(triplets,2)
        val = triplets(i,j);
        idx = find(contains(channels,val));
        channeled_triplets(i,j) = idx;
    end   
end


end



