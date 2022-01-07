function [quadruplets, triplets, harmonics] = find_quadruplets(freqs,freq_gap,min_freq)
%FIND_QUADRUPLETS Find all quadruplets given 1 Hz frequencies

% Outputs all the necessary triplets required to test to identify
% dependence in the quadruplets.
    tol = 3;

    n = length(freqs);
    freqs = round(freqs,tol);
    
    quadruplets = [];
    triplets = [];
    harmonics = [];
    
    cnt_quadruplet = 0;
    cnt_triplet = 0;
    cnt_harmonic = 0;
    
    for i = 1:n
        for j = i+1:n
            
            p = round(freqs(i) + freqs(j),tol);
            k = round(freqs(j) - freqs(i),tol);
            
            if p<=max(freqs)

                vec = [freqs(i),freqs(j),k,p];
                dists = abs(pdist(vec',@(x,y) x-y));
                
                if  all(dists >= freq_gap) && all(vec>=min_freq) && all(ismember(vec,freqs))
                    cnt_quadruplet = cnt_quadruplet + 1;
                    quadruplets(cnt_quadruplet,:) = vec;
                    
                    cnt_triplet = cnt_triplet + 1;
                    triplets(cnt_triplet,:) = sort([freqs(i),freqs(j),k]);
                    
                    cnt_triplet = cnt_triplet + 1;
                    triplets(cnt_triplet,:) = sort([freqs(i),freqs(j),p]);
                    
                    cnt_triplet = cnt_triplet + 1;
                    triplets(cnt_triplet,:) = sort([freqs(i),k,p]);
                    
                    cnt_triplet = cnt_triplet + 1;
                    triplets(cnt_triplet,:) = sort([freqs(j),k,p]);  
                    
                    cnt_harmonic = cnt_harmonic + 1;
                    harmonics(cnt_harmonic,:) = sort([freqs(i),freqs(i)*2]);
                    
                    cnt_harmonic = cnt_harmonic + 1;                    
                    harmonics(cnt_harmonic,:) = sort([freqs(j),freqs(j)*2]);
                    
                end 
            end
                
        end
    end
    
    triplets = sortrows(triplets,[1,2,3]);
    triplets = unique(triplets,'rows'); 
    
    harmonics = sortrows(harmonics,[1,2]);
    harmonics = unique(harmonics,'rows');    

end

