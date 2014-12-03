% Making an edgelist (representation of a graph) symmetric
% INPUTs: edge list, mx3
% OUTPUTs: symmetrized edge list, mx3
% GB, Last updated: October 8, 2009

function el=symmetrize_edgeL(el)

el2=[el(:,1), el(:,2)];

for e=1:size(el,1)
    ind=ismember(el2,[el2(e,2),el2(e,1)],'rows');
    if sum(ind)==0; el=[el; el(e,2), el(e,1), el(e,3)]; end
end

% Alternative: Using the adjacency matrix
% adj=edgeL2adj(el);
% adj=symmetrize(adj);
% el=adj2edgeL(adj);