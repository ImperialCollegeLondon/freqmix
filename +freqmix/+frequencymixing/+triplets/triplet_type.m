function [triplet_type] = triplet_type(phases)
%TRIPLET_TYPE Summary of this function goes here
%   Detailed explanation goes here

types = [1 -1 -1;...
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
%[~,best_perm] = min(min(abs(scores),[],2));


end

function test_type1()

triplet_compositions = {'r1', 'r2', 'e2';
                        'r1', 'e2', 'r2';
                        'h1', 'e1', 'e2';
                        'e1', 'r1', 'r2';
                        'e1', 'h2', 'e2';
                        'e1', 'e2', 'h2'};

preds = [];
for c = 1:size(triplet_compositions,1)
    
    trips = triplet_compositions(c, permutations(best_perm,:));  
    disp(trips)

    syms r1 r2 e1 e2 h1 h2
    eqn1 = r1 + r2 == e1;
    eqn2 = r1 - r2 == e2;
    eqn3 = 2*r2 == h2;
    eqn4 = 2*r1 == h1;    
    
    eqn5 = eval(trips{1}) == freqs(1);
    eqn6 = eval(trips{2}) == freqs(2);
    eqn7 = eval(trips{3}) == freqs(3); 
    [A,B] = equationsToMatrix([eqn1, eqn2, eqn3, eqn4, eqn5, eqn6, eqn7], [r1 r2 e1 e2 h1 h2]);
    X = linsolve(A,B);
    preds(c,:) = X;
  
   
end


end

function test_type2()


triplet_compositions = {'h1', 'h2', 'e2';
                        'e1', 'e2', 'r2'};
                    

preds = [];
for c = 1:size(triplet_compositions,1)
    
    trips = triplet_compositions(c, permutations(best_perm,:));  
    disp(trips)

    syms r1 r2 e1 e2 h1 h2
    eqn1 = r1 + r2 == e1;
    eqn2 = r1 - r2 == e2;
    eqn3 = 2*r2 == h2;
    eqn4 = 2*r1 == h1;    
    
    eqn5 = eval(trips{1}) == freqs(1);
    eqn6 = eval(trips{2}) == freqs(2);
    eqn7 = eval(trips{3}) == freqs(3); 
    [A,B] = equationsToMatrix([eqn1, eqn2, eqn3, eqn4, eqn5, eqn6, eqn7], [r1 r2 e1 e2 h1 h2]);
    X = linsolve(A,B);
    preds(c,:) = X;
  
   
end

end







