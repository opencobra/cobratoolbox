function [L,M,comp_mat,xi,xj] = findConservedMoieties(S,mets,intRxnBool,A,atomMets,reverseTransitionBool)

S_int = S(:,intRxnBool);

inc = abs(A(:,~reverseTransitionBool)); % Convert directed atom transition network to an undirected graph
adj = inc2adj(inc); % Convert incidence matrix to adjacency matrix
comp_mat = find_conn_comp(adj); % Find connected components

L = sparse(length(comp_mat),length(mets));
M = sparse(length(comp_mat),length(mets));
for i = 1:length(comp_mat)
    l = sparse(1,length(mets));
    comp = comp_mat{i};
    
    for j = 1:length(comp)
        midx = ismember(mets,atomMets(comp(j)));
        l(midx) = l(midx) + 1;
    end
    
    if all(l*S_int == 0)
        L(i,:) = l;
    else
        M(i,:) = l;
    end
end

[L,xi,xj] = unique(L,'rows');
L = L(any(L,2),:);
xi = xi(any(L,2));
M = unique(M,'rows');
M = M(any(M,2),:);