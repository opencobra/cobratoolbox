function [L, M, moietyFormulas, instances2mets, instances2moieties, atoms2instances] = identifyConservedMoieties(model, ATN)
% Identifies conserved moieties in a metabolic network (model) by graph
% theoretical analysis of the corresponding atom transition network (ATN).
%
% USAGE:
%
%    [L, M, moietyFormulas, instances2mets, instances2moieties, atoms2instances] = identifyConservedMoieties(model, ATN)
%
% INPUTS:
%    model:                 Structure with following fields:
%
%                             * .S - The `m x n` stoichiometric matrix for the metabolic network
%                             * .mets - An `m x 1` array of metabolite identifiers. Should match
%                               metabolite identifiers in rxnfiles.
%                             * .rxns - An `n x 1` array of reaction identifiers. Should match
%                               `rxnfile` names in `rxnFileDir`.
%    ATN:                   Structure with following fields:
%
%                             * .A - A `p x q` sparse incidence matrix for the atom transition
%                               network, where `p` is the number of atoms and `q` is
%                               the number of atom transitions.
%                             * .mets - A `p x 1` cell array of metabolite identifiers to link
%                               atoms to their metabolites. The order of atoms is the
%                               same in `A` as in the molfile for each metabolite.
%                             * .rxns - A `q x 1` cell array of reaction identifiers to link atom
%                               transitions to their reactions. The order of atom
%                               transitions is the same in `A` as in the `rxnfile` (with
%                               atom mappings) for each reaction.
%                             * .elements - A `p x 1` cell array of element symbols for atoms in `A`.
%
% OUTPUTS
%    L:                     An `m x r` matrix of r moiety vectors in the left null
%                           space of `S`.
%    M:                     The `u x v` incidence matrix of the moiety supergraph
%                           where each connected component is a moiety graph.
%    moietyFormulas:        `m x r` cell array with chemical formulas of moieties
%    instances2mets:        `u x 1` vector mapping moieties (rows of `M`) to
%                           metabolites (rows of S)
%    instances2moieties:    `u x 1` vector mapping moieties (rows of `M`) to
%                           moiety vectors (columns of `L`)
%    atoms2instances:       `p x 1` vector mapping atoms (rows of `A`) to moieties
%                           (rows of `M`)
%
% .. Author: - Hulda S. Haraldsdóttir, June 2015

rbool = ismember(model.rxns,ATN.rxns); % True for reactions included in ATN
mbool = any(model.S(:,rbool),2); % True for metabolites in ATN reactions

N = sparse(model.S(mbool,rbool)); % The stoichiometric matrix of internal reactions

[~,atoms2mets] = ismember(ATN.mets,model.mets(mbool));
[~,trans2rxns0] = ismember(ATN.rxns,model.rxns(rbool));

[nMets] = size(N,1);

clear model

% convert ATN structure to directed graph
[inc,o2n] = unique(sparse(ATN.A'),'rows','stable');
inc = inc';
trans2rxns = trans2rxns0(o2n);
[nAtoms,nTrans] = size(inc);

[h,~] = find(inc == -1);
[t,~] = find(inc == 1);
edges = table([h t],trans2rxns,(1:nTrans)','VariableNames',{'EndNodes' 'Rxn' 'Transitions'});
nodes = table(atoms2mets,(1:nAtoms)',ATN.elements,'VariableNames',{'Met' 'Atom' 'Element'});
G = digraph(edges,nodes);

clear ATN inc

% Find connected components of underlying undirected graph.
% Each component corresponds to an "atom conservation relation".
adj = adjacency(G);
components = conncomp(graph(adj+adj'));

clear adj % conserve memory

% Construct moiety matrix
nComps = max(components);
L = sparse(nComps,nMets); % Initialize moiety matrix.
for i = 1:nComps
    metIdx = atoms2mets(components == i);
    t = tabulate(metIdx);
    L(i,t(:,1)) = t(:,2); % One vector per atom conservation relation.
end

[L,xi,xj] = unique(L,'rows','stable'); % Retain only unique atom conservation relations. Identical atom conservation relations belong to the same moiety conservation relation.
L = L'; % Moiety vectors to columns

leftNullBool = ~any(N'*L,1); % Indicates vectors in the left null space of S.
L = L(:,leftNullBool);
xi = xi(leftNullBool);

if any(~leftNullBool)
    warning('Not all moiety vectors are in the left null space of S. Check that atom transitions in A match the stoichiometry in S.');
end

% Construct incidence matrix for moiety supergraph
nVectors = size(L,2); % Number of moiety conservation relations (unique moiety vectors)
nMoieties = sum(sum(L)); % Total number of nodes in moiety supergraph
nEdges = numedges(subgraph(G,find(ismember(components,xi)))); % Total number of edges in moiety supergraph

moietyFormulas = cell(nVectors,1); % Cell array with chemical formulas of moieties
instances2mets = zeros(nMoieties,1); % Vector mapping moieties (rows of M) to metabolites (rows of S)
instances2moieties = zeros(nMoieties,1); % Vector mapping moieties (rows of M) to moiety vectors (columns of L)
atoms2instances = zeros(nAtoms,1); % Vector mapping atoms (rows of A) to moieties (rows of M)

M = sparse(nMoieties,nEdges); % Moiety supergraph
firstrow = 1;
firstcol = 1;

for i = 1:nVectors
    
    % construct digraph of first component
    comp1 = find(components == xi(i));
    g1 = subgraph(G,comp1);
    
    % Add moiety graph to moiety supergraph
    mgraph1 = incidence(g1);
    [nrows,ncols] = size(mgraph1);
    rowidx = firstrow:(firstrow + nrows - 1);
    colidx = firstcol:(firstcol + ncols - 1);
    M(rowidx,colidx) = mgraph1;
    firstrow = firstrow + nrows;
    firstcol = firstcol + ncols;
    
    instances2mets(rowidx) = g1.Nodes.Met; % Map moieties to metabolites
    instances2moieties(rowidx) = i; % Map moieties to moiety vectors
    atoms2instances(g1.Nodes.Atom) = rowidx; % Map atoms to moieties
    e = unique(g1.Nodes.Element); % Initialize element array for moiety
    
    idx = setdiff(find(xj == i),xi(i)); % Indices of isomorphic components
    
    if ~isempty(idx)
        
        for j = idx' % Loop through isomorphic components
            comp2 = find(components == j);
            g2 = subgraph(G,comp2);
            
            % find isomorphism that conserves metabolite and reaction
            % attributes of nodes and edges
            p = isomorphism(g1,g2,'NodeVariables','Met','EdgeVariables','Rxn');
            
            if ~isempty(p)
                g2 = reordernodes(g2,p);
                atoms2instances(g2.Nodes.Atom) = rowidx; % map atoms to moieties
            else
                warning('atom graphs not isomorphic'); % Should never get here. Something went wrong.
            end
        end
    end
    
    % Format chemical formula of moiety
    f = tabulate(e);
    f([f{:,2}]'==1,2) = {''};
    f = f(:,1:2)';
    moietyFormulas{i} = sprintf('%s%d',f{:});
end
