function [triplet_type] = triplet_type(phases)
%TRIPLET_TYPE Summary of this function goes here
%   Detailed explanation goes here

types = [1 -1 1;...
        1 -1 -2;...
        1 -2 1;...
        1 -2 -1;...
        2 -1 -2;...
        2 -2 -1;...
        1 -2 -2;...
        1 -2 2];

permutations = perms([1,2,3]);


scores = zeros([6, 8]);
for p = 1:size(permutations,1)
    for t = 1:size(types,1)  
        
        perm = wrapToPi(types(t,:) * phases(permutations(p,:),:));
        scores(p,t) = sum(abs(perm));
        
    end
       
end

[~,triplet_type] = min(min(abs(scores),[],1));


end

