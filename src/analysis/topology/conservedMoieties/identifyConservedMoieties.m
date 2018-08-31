function [L, M, moietyFormulas, moieties2mets, moieties2vectors, atoms2moieties, mtrans2rxns, atrans2mtrans] = identifyConservedMoieties(model, ATN)
% Identifies conserved moieties in a metabolic network (model) by graph
% theoretical analysis of the corresponding atom transition network (ATN).
% 
%
% USAGE:
%
%    [L, M, moietyFormulas, moieties2mets, moieties2vectors, atoms2moieties, mtrans2rxns, atrans2mtrans] = identifyConservedMoieties(model, ATN)
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
%    moietyFormulas:        `r x 1` cell array with chemical formulas of moieties
%    moieties2mets:         `u x 1` vector mapping moieties (rows of `M`) to
%                           metabolites (rows of S)
%    moieties2vectors:      `u x 1` vector mapping moieties (rows of `M`) to
%                           moiety vectors (columns of `L`)
%    atoms2moieties:        `p x 1` vector mapping atoms (rows of `A`) to moieties
%                           (rows of `M`)
%    mtrans2rxns:           'v x 1' vector mapping moiety transitions
%                           (columns of M) to reactions (columns of S)
%    atrans2mtrans:         'q x 1' vector mapping atom transitions
%                           (columns of A) to moiety transitions (columns
%                           of M)
%
% .. Author: - Hulda S. Haraldsdóttir, June 2015

rbool = ismember(model.rxns,ATN.rxns); % True for reactions included in ATN
mbool = any(model.S(:,rbool),2); % True for metabolites in ATN reactions

N = sparse(model.S(mbool,rbool)); % Stoichometric matrix of atom mapped reactions
[~,atoms2mets] = ismember(ATN.mets,model.mets);
[~,atrans2rxns] = ismember(ATN.rxns,model.rxns);

clear model

A = sparse(ATN.A);
elements = ATN.elements;

clear ATN

[nMets] = size(N,1);
[nAtoms, nAtrans] = size(A);

% Convert incidence matrix to adjacency matrix for input to graph
% algorithms
[ah,~] = find(A == -1); % head nodes
[at,~] = find(A == 1); % tail nodes
adj = sparse([at;ah],[ah;at],ones(size([at;ah])));

% Find connected components of underlying undirected graph.
% Each component corresponds to an "atom conservation relation".
if ~verLessThan('matlab','8.6')
    components = conncomp(graph(adj)); % Use built-in matlab algorithm. Introduced in R2015b.
    nComps = max(components);
elseif license('test','Bioinformatics_Toolbox')
    [nComps,components] = graphconncomp(adj,'DIRECTED',false);
else
    components_cell = find_conn_comp(adj); % Slow.
    nComps = length(components_cell);
    components = zeros(nAtoms,1);
    for i = 1:nComps
        components(components_cell{i}) = i;
    end
end

% Construct moiety matrix
L = sparse(nComps, nMets); % Initialize moiety matrix.
compElements = cell(nComps, 1); % Element for each atom conservation relation
for i = 1:nComps
    metIdx = atoms2mets(components == i);
    t = tabulate(metIdx);
    L(i, t(:, 1)) = t(:, 2); % One vector per atom conservation relation.
    compElements(i) = unique(elements(components == i));
end

[L,xi,xj] = unique(L,'rows','stable'); % Retain only unique atom conservation relations. Identical atom conservation relations belong to the same moiety conservation relation.
L = L'; % Moiety vectors to columns

leftNullBool = ~any(N'*L,1); % Indicates vectors in the left null space of S.
L = L(:,leftNullBool);
xi = xi(leftNullBool);

if any(~leftNullBool)
    warning('Not all moiety vectors are in the left null space of S. Check that atom transitions in A match the stoichiometry in S.');
end

% Format moiety formulas
nVectors = size(L, 2);
moietyFormulas = cell(nVectors, 1);
for i = 1:nVectors
    f = tabulate(compElements(xj == i)); % elements in moiety i
    f([f{:, 2}]' == 1, 2) = {''};
    f = f(:, 1:2)';
    moietyFormulas{i} = sprintf('%s%d',f{:});
end

% Extract moiety graph from atom transition network
[isMoiety, moieties2vectors] = ismember(components,xi);
isMoietyTransition = any(A(isMoiety, :), 1);
M = A(isMoiety, isMoietyTransition);

% Map moieties to moiety vectors
moieties2vectors = moieties2vectors(isMoiety);

% Map between moiety graph and metabolic network
moieties2mets = atoms2mets(isMoiety);
mtrans2rxns = atrans2rxns(isMoietyTransition);

% Map atoms to moieties
% Need to ensure that atom components are isomorphic
atoms2moieties = zeros(nAtoms,1);

for i = 1:nVectors
    rowidx = find(moieties2vectors == i); % indices in moiety graph
    
    % First atom component in current moiety conservation relation
    comp1 = find(components == xi(i))';
    mgraph1 = adj(comp1,comp1);
    mets1 = atoms2mets(comp1); % Map atoms to metabolites
    
    atoms2moieties(comp1) = rowidx; % Map atoms in first atom component of current moiety conservation relation to rows of moiety supergraph
    
    idx = setdiff(find(xj == i),xi(i)); % Indices of other atom components in current moiety conservation relation
    
    if ~isempty(idx)
        
        for j = idx' % Loop through other atom components in current moiety conservation relation
            comp2 = find(components == j)';
            mgraph2 = adj(comp2,comp2);
            mets2 = atoms2mets(comp2); % Map atoms to metabolites
            
            % Most components will be isomorphic right off the bat because
            % of the way the atom transition network is constructed
            if all(mets2 == mets1) && all(all(mgraph2 == mgraph1))
                atoms2moieties(comp2) = rowidx; % map atoms to moieties
                continue;
            end
            
            % In rare cases, we need to permute atoms in the second
            % component.
            if ~verLessThan('matlab', '9.1')
                % Use Matlab's built in isomorphism algorithm. Introduced
                % in R2016b.
                nodes1 = table(mets1, comp1, 'VariableNames', {'Met', 'Atom'});
                d1 = digraph(mgraph1, nodes1);
                
                nodes2 = table(mets2, comp2, 'VariableNames', {'Met', 'Atom'});
                d2 = digraph(mgraph2, nodes2);
                
                % find isomorphism that conserves the metabolite attribute
                % of nodes
                p = isomorphism(d1, d2, 'NodeVariables', 'Met');
                
                if ~isempty(p)
                    d2 = reordernodes(d2,p);
                    atoms2moieties(d2.Nodes.Atom) = rowidx; % map atoms to moieties 
                else
                    warning('atom graphs not isomorphic'); % Should never get here. Something went wrong.
                end
                
            elseif license('test','Bioinformatics_Toolbox')
                [isIsomorphic, p] = graphisomorphism(mgraph1, mgraph2);
                
                if isIsomorphic
                    comp2 = comp2(p);
                    atoms2moieties(comp2) = rowidx; % map atoms to moieties 
                else
                    warning('atom graphs not isomorphic'); % Should never get here. Something went wrong.
                end
                
            else
                warning('Could not compute graph isomorphism');
            end
        end
    end
end

% Map atom transitions to moiety transitions
atrans2mtrans = zeros(nAtrans,1);

[mh,~] = find(M == -1); % head nodes in moiety graph
[mt,~] = find(M == 1); % tail nodes in moiety graph

% An atom transition maps to a moiety transition if its head node maps to
% the head moiety, its tail node to the tail moiety, and its from the same
% reaction
for i = 1:length(mh)
    inHead = ismember(ah, find(atoms2moieties == mh(i)));
    inTail = ismember(at, find(atoms2moieties == mt(i)));
    inRxn = atrans2rxns == mtrans2rxns(i);
    atrans2mtrans((inHead & inTail) & inRxn) = i;
end