function [L,components,xi,xj,M] = computeConservedMoieties(S,mets,intRxnBool,A,atomMets,reverseBool)
% Computes conserved metabolic moieties in the metabolic network
% represented by S, by graph theoretical analysis of the corresponding atom
% transition network, represented by A.
% 
% [L,M,comp_mat,xi,xj] =
% computeConservedMoieties(S,mets,intRxnBool,A,atomMets,reverseTransitionBool);
% 
% INPUTS
% S             ... The m x n stoichiometric matrix for the metabolic network
% mets          ... An m x 1 array of metabolite identifiers.
% intRxnBool    ... An n x 1 logical array indicating which reactions in S
%                   are internal.
% A             ... A p x q sparse incidence matrix for the atom transition
%                   network, where p is the number of atoms and q is
%                   the number of atom transitions.
% atomMets      ... A p x 1 cell array of metabolite identifiers to link
%                   atoms to their metabolites.
% reverseBool   ... A q x 1 logical array. True for atom transitions that
%                   are the reverse of other transitions. Reverse
%                   transitions arise when reversible reactions are split
%                   in two.
% 
% OUTPUTS
% L             ... An o x m matrix where each row is a nonnegative integer
%                   vector, in the left null space of S, that represents a
%                   conserved moiety.
% components    ... A cell array of atom indices in each component of the
%                   underlying graph of the atom transition network in A.
% xi            ... Cross references from L to components.
% xj            ... Cross references from components to L.
% M             ... Moiety vectors that are not in the left null space of
%                   S. Should be empty.

S_int = S(:,intRxnBool);

inc = abs(A(:,~reverseBool)); % Convert directed atom transition network to an undirected graph
adj = inc2adj(inc); % Convert incidence matrix to adjacency matrix
components = find_conn_comp(adj); % Find connected components. Each component corresponds to a conserved moiety.

% Construct moiety vectors
L = sparse(length(components),length(mets));
M = sparse(length(components),length(mets));
for i = 1:length(components)
    l = sparse(1,length(mets));
    comp = components{i};
    
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