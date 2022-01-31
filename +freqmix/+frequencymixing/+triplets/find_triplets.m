function [triplets] = find_triplets(freqs,freq_gap,min_freq)
%FIND_TRIPLETS Find all possible triplets 
    
    tol = 3;
    
    freqs(freqs<min_freq) = [];   
    
    n = length(freqs);


    triplets = [];
    cnt = 0;
    
    for k = 1:n       
        for i = k+1:n   
           for j = i+1:n 
              if round(freqs(k) + freqs(i),tol) == round(freqs(j),tol)
                 if  round(abs(freqs(i)-freqs(j)),tol)>=freq_gap && round(abs(freqs(k)-freqs(i)),tol)>=freq_gap && round(abs(freqs(k)-freqs(j)),tol)>=freq_gap

                    cnt = cnt + 1;
                    triplets(cnt,:) = [freqs(k),freqs(i),freqs(j)];

                 end
              end          
           end
        end

    end
    
    triplets = sortrows(triplets,[1,2,3]);

end

