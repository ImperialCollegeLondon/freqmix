function p = generate_skeleton_graph(band_ids)

adj_skeleton = ones(length(band_ids),length(band_ids));
g_skeleton = graph(adj_skeleton,band_ids);
p = plot(g_skeleton,'Layout','circle');hold on;
p.EdgeColor = [0.1 0.1 0.1];
p.NodeColor = [0.1 0.1 0.1];
p.EdgeAlpha = 0.5;

for i=1:length(band_ids)
    highlight(p,i,neighbors(g_skeleton,i),'LineStyle', ':')
end

end

