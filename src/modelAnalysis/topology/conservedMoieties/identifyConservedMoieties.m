function [L,Lambda,moietyFormulas,instances2mets,instances2moieties,atoms2instances,M] = identifyConservedMoieties(model,ATN)
% Identifies conserved moieties in a metabolic network (model) by graph
% theoretical analysis of the corresponding atom transition network (ATN).
%
% [L,Lambda,moietyFormulas,moieties2mets,moieties2vectors,atoms2moieties,M] = identifyConservedMoieties(model,ATN);
%
% INPUTS
% model .... Structure with following fields:
% .S          .... The m x n stoichiometric matrix for the metabolic
%                  network 
% .mets       .... An m x 1 array of metabolite identifiers. Should match
%                  metabolite identifiers in rxnfiles.
% .rxns       .... An n x 1 array of reaction identifiers. Should match
%                  rxnfile names in rxnFileDir.
% ATN .... Structure with following fields:
% .A           ... A p x q sparse incidence matrix for the atom transition
%                  network, where p is the number of atoms and q is
%                  the number of atom transitions.
% .mets        ... A p x 1 cell array of metabolite identifiers to link
%                  atoms to their metabolites. The order of atoms is the
%                  same in A as in the molfile for each metabolite.
% .rxns        ... A q x 1 cell array of reaction identifiers to link atom
%                  transitions to their reactions. The order of atom
%                  transitions is the same in A as in the rxnfile (with
%                  atom mappings) for each reaction.
% .elements    ... A p x 1 cell array of element symbols for atoms in A.
%
% OUTPUTS
% L                  ... An m x r matrix of r moiety vectors in the left null
%                        space of S.
% Lambda             ... The u x v incidence matrix of the moiety supergraph
%                        where each connected component is a moiety graph.
% moietyFormulas     ... m x r cell array with chemical formulas of moieties 
% instances2mets     ... u x 1 vector mapping moieties (rows of Lambda) to
%                        metabolites (rows of S)
% instances2moieties ... u x 1 vector mapping moieties (rows of Lambda) to
%                        moiety vectors (columns of L)
% atoms2instances    ... p x 1 vector mapping atoms (rows of A) to moieties
%                        (rows of Lambda)
% M                  ... Moiety vectors that are not in the left null space of
%                        S. Should be empty.
% 
% June 2015, Hulda S. Haraldsdóttir

rbool = ismember(model.rxns,ATN.rxns); % True for reactions included in ATN
mbool = any(model.S(:,rbool),2); % True for metabolites in ATN reactions

S = sparse(model.S(mbool,rbool));
[~,atoms2mets] = ismember(ATN.mets,model.mets(mbool));
[~,trans2rxns] = ismember(ATN.rxns,model.rxns(rbool));

clear model

A = sparse(ATN.A);
elements = ATN.elements;

clear ATN

[nMets] = size(S,1);
[nAtoms] = size(A,1);

xt = 1:size(A,2);

% Convert incidence matrix to adjacency matrix
[row1,col1] = find(A == 1);
[row2,col2] = find(A == -1);
adj = sparse([row1;row2],[row2;row1],ones(size([row1;row2]))); % Convert incidence matrix to adjacency matrix

% Find connected components. Each component corresponds to an "atom conservation relation".
if license('test','Bioinformatics_Toolbox')
    [nComps,a2c] = graphconncomp(adj,'DIRECTED',false);
    components = cell(nComps,1);
    for i = 1:nComps
        components{i} = find(a2c == i);
    end
else
    % components = connectedComponents(adj); % Matlab implementation of Tarjan's algorithm. Does not work for large networks due to Matlab limitations on stack size.
    components = find_conn_comp(adj);
    nComps = length(components);
end

clear adj % conserve memory

% Construct moiety matrix
L = sparse(nComps,nMets); % Initialize moiety matrix.
for i = 1:nComps
    metIdx = atoms2mets(components{i});
    t = tabulate(metIdx);
    L(i,t(:,1)) = t(:,2); % One vector per atom conservation relation.
end

[L,xi,xj] = unique(L,'rows','stable'); % Retain only unique atom conservation relations. Identical atom conservation relations belong to the same moiety conservation relation.
L = L'; % Moiety vectors to columns

leftNullBool = ~any(S'*L); % Indicates vectors in the left null space of S.
M = L(:,~leftNullBool);
L = L(:,leftNullBool);
xi = xi(leftNullBool);

if ~isempty(M)
    warning('Not all moiety vectors are in the left null space of S. Check that atom transitions in A match the stoichiometry in S.');
end

% Construct incidence matrix for moiety supergraph
nVectors = size(L,2); % Number of moiety conservation relations (unique moiety vectors)
nMoieties = sum(sum(L)); % Total number of nodes in moiety supergraph
nEdges = sum(any(A([components{xi}],:))); % Total number of edges in moiety supergraph

moietyFormulas = cell(nVectors,1); % Cell array with chemical formulas of moieties
instances2mets = zeros(nMoieties,1); % Vector mapping moieties (rows of Lambda) to metabolites (rows of S)
instances2moieties = zeros(nMoieties,1); % Vector mapping moieties (rows of Lambda) to moiety vectors (columns of L)
atoms2instances = zeros(nAtoms,1); % Vector mapping atoms (rows of A) to moieties (rows of Lambda)

Lambda = sparse(nMoieties,nEdges); % Moiety supergraph
firstrow = 1;
firstcol = 1;

for i = 1:nVectors
    
    % Add moiety graph to moiety supergraph
    comp1 = components{xi(i)};
    mgraph1 = A(comp1,any(A(comp1,:)));
    [nrows,ncols] = size(mgraph1);
    rowidx = firstrow:(firstrow + nrows - 1);
    colidx = firstcol:(firstcol + ncols - 1);
    Lambda(rowidx,colidx) = mgraph1;
    firstrow = firstrow + nrows;
    firstcol = firstcol + ncols;
    
    % Map moieties to metabolites
    mets1 = atoms2mets(comp1);
    instances2mets(rowidx) = mets1;
    
    % Map edges in first component to reactions
    rxns1 = trans2rxns(xt(any(A(comp1,:))));
    
    % Map moieties to moiety vectors
    instances2moieties(rowidx) = i;
    
    % Map atoms to moieties
    atoms2instances(comp1) = rowidx; % Map atoms in first atom component of current moiety conservation relation to rows of lambda
    
    % Initialize element array for moiety
    e = unique(elements(comp1));
    
    idx = setdiff(find(xj == i),xi(i)); % Indices of other atom components in current moiety conservation relation
    
    if ~isempty(idx)
        
        for j = idx' % Loop through other atom components in current moiety conservation relation
            comp2 = components{j};
            mgraph2 = A(comp2,any(A(comp2,:)));
            mets2 = atoms2mets(comp2); % map atoms to metabolites
            rxns2 = trans2rxns(xt(any(A(comp2,:)))); % map edges to reactions
            e = [e; unique(elements(comp2))];
            
            if (all(mets2 == mets1) && all(rxns2 == rxns1)) && all(all(mgraph2 == mgraph1))
                atoms2instances(comp2) = rowidx; % map atoms to moieties
            else % isomorphic atoms may not be in the same order in both components
                [~,row1] = sort(mets1);
                [~,row2] = sort(mets2);
                row2row = sortrows([row2 row1],1); % mets2 = mets1(row2row)
                
                [~,col1] = sort(rxns1);
                [~,col2] = sort(rxns2);
                col2col = sortrows([col2 col1],1); % rxns2 = rxns1(col2col)
                
                if all(all(mgraph2 == mgraph1(row2row,col2col)))
                    atoms2instances(comp2) = rowidx(row2row); % map atoms to moieties
                else
                    warning('atom graphs not isomorphic'); % Hopefully we never get here. Complicates things.
                end
            end
        end
    end
    
    % Format chemical formula of moiety
    f = tabulate(e);
    f([f{:,2}]'==1,2) = {''};
    f = f(:,1:2)';
    moietyFormulas{i} = sprintf('%s%d',f{:});
end

