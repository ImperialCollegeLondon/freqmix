function CC = graphconncomp(significant_entries,G)

% return default struct is no entries are given
% this function should be responsible for handling the construction of CC
if isempty(significant_entries)
    CC.PixelIdxList = {};
    CC.NumObjects = 0;
    CC.cluster_pvalues = [];
    return
end

% remove edges that aren't significant
n_nodes = size(G.Nodes,1);
edges = G.Edges.EndNodes;


% finding nodes which aren't significant
non_sig = find(significant_entries==0);

idx = ismember(edges,non_sig);
edges_to_remove = any(idx,2);

edges(edges_to_remove,:) = [];

g = graph(edges(:,1),edges(:,2),[],n_nodes);

[bin,binsize] = conncomp(g,'OUtputForm','cell');


[~,I] = sort(cellfun(@length,bin),'descend');
bin = bin(I);

bin = bin(cellfun(@(x) length(x) > 1, bin));

CC.PixelIdxList = bin;
CC.NumObjects = length(bin);

end