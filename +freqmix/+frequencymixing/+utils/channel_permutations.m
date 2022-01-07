function [channel_ids] = channel_permutations(channels,type)
%GET_CHANNEL_PERMUTATIONS Summary of this function goes here
%   Detailed explanation goes here


n_channels = length(channels);
channels = 1:n_channels;
channels = channels(:);  

cnt = 0;
channel_ids = [];


if isequal(type, 'harmonic')
    
    for ch1 = 1:length(channels)
        for ch2 = 1:length(channels)
            cnt = cnt+1;
            channel_ids(cnt,:) = [channels(ch1),channels(ch2)];        
        end
    end
elseif isequal(type, 'triplet')
    
    for ch1 = 1:length(channels)
        for ch2 = 1:length(channels)
            for ch3 = 1:length(channels)   
                cnt = cnt+1;
                channel_ids(cnt,:) = [channels(ch1),channels(ch2),channels(ch3)] ;
            end
        end
    end  
elseif isequal(type, 'quadruplet')
    
    for ch1 = 1:length(channels)       
        for ch2 = 1:length(channels)
            for ch3 = 1:length(channels)  
                for ch4 = 1:length(channels)
                    cnt = cnt+1;
                    channel_ids(cnt,:) = [channels(ch1),channels(ch2),channels(ch3),channels(ch4)] ;
                end
            end
        end
    end   
    
end
    

end
