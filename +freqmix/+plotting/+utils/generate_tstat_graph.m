function g = generate_tstat_graph(trips,teststats,tested_trips,band_ids)

adj = zeros(length(band_ids),length(band_ids));

for k = 1:size(trips,1)    
    tri = trips(k,:);
    tstat = teststats(k);    
    
    adj(tri(1),tri(2)) = adj(tri(1),tri(2)) + tstat;
    adj(tri(2),tri(1)) = adj(tri(2),tri(1)) + tstat;
    
    adj(tri(1),tri(3)) = adj(tri(1),tri(3)) + tstat;
    adj(tri(3),tri(1)) = adj(tri(3),tri(1)) + tstat;

    adj(tri(2),tri(3)) = adj(tri(2),tri(3)) + tstat;
    adj(tri(3),tri(2)) = adj(tri(3),tri(2)) + tstat;   
end

norm_adj = zeros(length(band_ids),length(band_ids));

for k = 1:size(tested_trips,1)    
    tri = tested_trips(k,:);
    norm_adj(tri(1),tri(2)) = norm_adj(tri(1),tri(2)) + 1;
    norm_adj(tri(2),tri(1)) = norm_adj(tri(2),tri(1)) + 1;
    
    norm_adj(tri(1),tri(3)) = norm_adj(tri(1),tri(3)) + 1;
    norm_adj(tri(3),tri(1)) = norm_adj(tri(3),tri(1)) + 1;

    norm_adj(tri(2),tri(3)) = norm_adj(tri(2),tri(3)) + 1;
    norm_adj(tri(3),tri(2)) = norm_adj(tri(3),tri(2)) + 1;      
end


adj = adj./norm_adj;
adj(isnan(adj))=0;
g = graph(adj,band_ids);


end