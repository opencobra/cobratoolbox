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

N = sparse(model.S(mbool,rbool));
[~,atoms2mets] = ismember(ATN.mets,model.mets(mbool));
[~,trans2rxns] = ismember(ATN.rxns,model.rxns(rbool));

clear model

A = sparse(ATN.A);
elements = ATN.elements;

clear ATN

[nMets] = size(N,1);
[nAtoms, nAtrans] = size(A);

xt = 1:size(A,2);

% Find connected components of underlying undirected graph.
% Each component corresponds to an "atom conservation relation".
[h,~] = find(A == -1);
[t,~] = find(A == 1);
adj = sparse([t;h],[h;t],ones(size([t;h]))); % Convert incidence matrix to adjacency matrix

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

clear adj % conserve memory

% Construct moiety matrix
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

% Initialise index vectors to map between data structures
nVectors = size(L,2); % Number of moiety conservation relations (unique moiety vectors)
nMoieties = sum(sum(L)); % Total number of nodes in moiety supergraph
nEdges = sum(any(A(ismember(components,xi),:),1)); % Total number of edges in moiety supergraph

moietyFormulas = cell(nVectors,1); % Cell array with chemical formulas of moieties
moieties2mets = zeros(nMoieties,1); % Vector mapping moieties (rows of M) to metabolites (rows of S)
moieties2vectors = zeros(nMoieties,1); % Vector mapping moieties (rows of M) to moiety vectors (columns of L)
atoms2moieties = zeros(nAtoms,1); % Vector mapping atoms (rows of A) to moieties (rows of M)
mtrans2rxns = zeros(nEdges,1); % 'v x 1' vector mapping moiety transitions (columns of M) to reactions (columns of S)
atrans2mtrans = zeros(nAtrans,1); % 'q x 1' vector mapping atom transitions (columns of A) to moiety transitions (columns of M)

% Construct incidence matrix for moiety supergraph
M = sparse(nMoieties,nEdges); % Moiety supergraph
firstrow = 1;
firstcol = 1;

for i = 1:nVectors
    
    % Add moiety graph to moiety supergraph
    comp1 = find(components == xi(i))';
    trans1 = find(any(A(comp1,:),1))';
    mgraph1 = A(comp1,trans1);
    
    [nrows,ncols] = size(mgraph1);
    rowidx = firstrow:(firstrow + nrows - 1);
    colidx = firstcol:(firstcol + ncols - 1);
    M(rowidx,colidx) = mgraph1;
    firstrow = firstrow + nrows;
    firstcol = firstcol + ncols;
    
    % Mappings
    mets1 = atoms2mets(comp1); % Map atoms to metabolites
    moieties2mets(rowidx) = mets1; % Map moieties to metabolites
    rxns1 = trans2rxns(xt(trans1)); % Map edges in first component to reactions
    moieties2vectors(rowidx) = i; % Map moieties to moiety vectors
    atoms2moieties(comp1) = rowidx; % Map atoms in first atom component of current moiety conservation relation to rows of moiety supergraph
    mtrans2rxns(colidx) = rxns1; % Map moiety transitions to reactions
    atrans2mtrans(trans1) = colidx; % Map edges in first component to moiety transitions
    
    % Initialize element array for moiety
    e = unique(elements(comp1));
    
    idx = setdiff(find(xj == i),xi(i)); % Indices of other atom components in current moiety conservation relation
    
    % The rest of the code is to map atoms to moieties and atom
    % transitions to moiety transitions
    if ~isempty(idx)
        
        for j = idx' % Loop through other atom components in current moiety conservation relation
            comp2 = find(components == j)';
            trans2 = find(any(A(comp2,:),1))';
            mgraph2 = A(comp2,trans2);
            mets2 = atoms2mets(comp2); % map atoms to metabolites
            rxns2 = trans2rxns(xt(trans2)); % map edges to reactions
            e = [e; unique(elements(comp2))];
            
            if (all(mets2 == mets1) && all(rxns2 == rxns1)) && all(all(mgraph2 == mgraph1))
                atoms2moieties(comp2) = rowidx; % map atoms to moieties
                atrans2mtrans(trans2) = colidx; % map atom transitions to moiety transitions
                continue;
            end
            
            % Attempt to match component graphs by sorting
            [mgraph1,perm] = sortrows([mets1 mgraph1]);
            mets1 = mgraph1(:,1);
            mgraph1 = mgraph1(:,2:end);
            comp1 = comp1(perm);
            rowidx = rowidx(perm);
            
            [mgraph1,perm] = sortrows([rxns1 mgraph1']);
            rxns1 = mgraph1(:,1);
            mgraph1 = mgraph1(:,2:end)';
            trans1 = trans1(perm);
            colidx = colidx(perm);
            
            [mgraph2,perm] = sortrows([mets2 mgraph2]);
            mets2 = mgraph2(:,1);
            mgraph2 = mgraph2(:,2:end);
            comp2 = comp2(perm);
            
            [mgraph2,perm] = sortrows([rxns2 mgraph2']);
            rxns2 = mgraph2(:,1);
            mgraph2 = mgraph2(:,2:end)';
            trans2 = trans2(perm);
            
            if (all(mets2 == mets1) && all(rxns2 == rxns1)) && all(all(mgraph2 == mgraph1))
                atoms2moieties(comp2) = rowidx; % map atoms to moieties
                atrans2mtrans(trans2) = colidx; % map atom transitions to moiety transitions
                continue;
            end
            
            if ~verLessThan('matlab','9.1')
                % Use Matlab's built in isomorphism algorithm. Introduced in R2016b
                % Last resort because it's slow. Should only need it in rare cases.
                [g1,o2n1] = unique(mgraph1','rows','stable'); % Matlab graphs do not support replicate edges
                g1 = g1';
                urxns1 = rxns1(o2n1);
                utrans1 = trans1(o2n1);
                [h1,~] = find(g1 < 0);
                [t1,~] = find(g1 >0);
                edges1 = table([h1 t1],urxns1,utrans1,'VariableNames',{'EndNodes' 'Rxn' 'Transition'});
                nodes1 = table(mets1,comp1,'VariableNames',{'Met' 'Atom'});
                d1 = digraph(edges1,nodes1);
                
                [g2,o2n2,n2o2] = unique(mgraph2','rows','stable');
                g2 = g2';
                urxns2 = rxns2(o2n2);
                utrans2 = trans2(o2n2);
                [h2,~] = find(g2 < 0);
                [t2,~] = find(g2 >0);
                edges2 = table([h2 t2],urxns2,utrans2,'VariableNames',{'EndNodes' 'Rxn' 'Transition'});
                nodes2 = table(mets2,comp2,'VariableNames',{'Met' 'Atom'});
                d2 = digraph(edges2,nodes2);
                
                % find isomorphism that conserves metabolite and reaction
                % attributes of nodes and edges
                p = isomorphism(d1,d2,'NodeVariables','Met','EdgeVariables','Rxn');
                
                if ~isempty(p)
                    [d2, pE] = reordernodes(d2,p);
                    trans2Map = sparse(n2o2, 1:ncols, ones(ncols, 1)); % to keep track of the order of atom transitions
                    trans2Map = trans2Map(pE, :);
                    [~, n2o2] = find(trans2Map);
                    atoms2moieties(d2.Nodes.Atom) = rowidx; % map atoms to moieties
                    atrans2mtrans(trans2(n2o2)) = colidx; % map atom transitions to moiety transitions
                else
                    warning('atom graphs not isomorphic'); % Should never get here. Something went wrong.
                end
                
            elseif license('test','Bioinformatics_Toolbox')
                [h1,~] = find(mgraph1 < 0);
                [t1,~] = find(mgraph1 > 0);
                g1 = sparse([t1;h1],[h1;t1],ones(size([t1;h1])));
                
                [h2,~] = find(mgraph2 < 0);
                [t2,~] = find(mgraph2 > 0);
                g2 = sparse([t2;h2],[h2;t2],ones(size([t2;h2])));
                
                [isIsomorphic, p] = graphisomorphism(g1, g2);
                
                if isIsomorphic
                    comp2 = comp2(p);
                    atoms2moieties(comp2) = rowidx;
                else
                    warning('atom graphs not isomorphic'); % Should never get here. Something went wrong.
                end
                
            else
                warning('Could not compute graph isomorphism');
            end
        end
    end
    
    % Format chemical formula of moiety
    f = tabulate(e);
    f([f{:,2}]'==1,2) = {''};
    f = f(:,1:2)';
    moietyFormulas{i} = sprintf('%s%d',f{:});
end