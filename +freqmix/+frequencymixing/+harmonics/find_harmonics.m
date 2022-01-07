function [harmonics] = find_harmonics(freqs,freq_gap,min_freq)
%FIND_HARMONICS Summary of this function goes here
    
    freqs(freqs<min_freq) = [];   
    
    n = length(freqs);


    harmonics = [];
    cnt = 0;
    
    for k = 1:n   
        for i = k+1:n
            if freqs(k)*2 == freqs(i)
                if abs(freqs(k)-freqs(i))>=freq_gap
                    cnt = cnt+1;
                    harmonics(cnt,:) = [freqs(k), freqs(i)];
                end
                
            end
        end
    end
        
    
    harmonics = sortrows(harmonics,[1,2]);
end

