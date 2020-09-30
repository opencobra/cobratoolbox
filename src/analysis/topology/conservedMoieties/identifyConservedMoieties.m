function [L, M, moietyFormulas, moieties2mets, moieties2vectors, atoms2moieties, mtrans2rxns, atrans2mtrans,mbool,rbool,V,E,C] = identifyConservedMoieties(model, ATN, method)
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
%                             * .atns = `q` x 1 unique identity of each atom in a
%                               metabolite (may omit hydrogens if they are not
%                               mapped)
%                             * .rxns - A `q x 1` cell array of reaction identifiers to link atom
%                               transitions to their reactions. The order of atom
%                               transitions is the same in `A` as in the `rxnfile` (with
%                               atom mappings) for each reaction.
%                             * .elements - A `p x 1` cell array of element symbols for atoms in `A`.
%
% OUTPUTS
%    L:                     An `m x r` matrix of r moiety vectors in the left null
%                           space of `S`.
%    M:                     The `p x q` incidence matrix of the moiety graph
%                           where each connected component is a moiety subgraph.
%
%    moietyFormulas:        `r x 1` cell array with chemical formulas of
%                           each moiey
%
%    moieties2mets:         `p x 1` vector mapping moiety instances (rows of `M`) to
%                           metabolites (rows of S)
%    moieties2vectors:      `p x 1` vector mapping moiety instances (rows of `M`) to
%                           moiety vectors (columns of `L`)
%    atoms2moieties:        `p x 1` vector mapping atoms (rows of `A`) to
%                           moiety instances (rows of `M`)
%    mtrans2rxns:           'q x 1' vector mapping moiety transitions
%                           (columns of M) to reactions (columns of S)
%    atrans2mtrans:         'q x 1' vector mapping atom transitions
%                           (columns of A) to moiety transitions (columns
%                           of M)
%    mbool:                 `m x 1` Boolean, true for metabolites in ATN reactions
%    rbool:                 `n x 1` Boolean, true for reactions included in ATN
%    V:                     The `m x p` matrix that maps each metabolite to an 
%                           instance of a moiety in the moiety graph.
%    E:                     The `q x n` matrix that maps each moiety
%                           transition to its corresponding reaction
%    C:                     An `r x c` matrix that maps r moieties to c
%                           connected components of an atom transition graph
%
% .. Authors: - Hulda S. Haraldsdóttir, June 2015 (original version)
%               Ronan M.T. Fleming, Sept 2020, compute conserved moieties
%               as described in:
%
% Ghaderi, S., Haraldsdóttir, H.S., Ahookhosh, M., Arreckx, S., and Fleming, R.M.T. (2020). 
% Structural conserved moiety splitting of a stoichiometric matrix. Journal of Theoretical Biology 499, 110276.


if ~exist('method','var')
    %use the new implementation by default.
    method='isomorphism';
end

bool = contains(model.mets,'#');
if any(bool)
    error('No metabolite can have an id with a # character in it.')
end

colNonZeroCount=(ATN.A~=0)'*ones(size(ATN.A,1),1);
if any(colNonZeroCount~=2)
    error('ATN.A does not correspond to a graph')
end
rbool = ismember(model.rxns,ATN.rxns); % True for reactions included in ATN
mbool = any(model.S(:,rbool),2); % True for metabolites in ATN reactions

N = sparse(model.S(mbool,rbool)); % Stoichometric matrix of atom mapped reactions
[~,atoms2mets] = ismember(ATN.mets,model.mets(mbool));
[~,atrans2rxns] = ismember(ATN.rxns,model.rxns(rbool));

%clear model

A = sparse(ATN.A);
elements = ATN.elements;

%clear ATN
[nMets,nRxns]=size(model.S);
[nMappedMets,nMappedRxns] = size(N);
[nAtoms, nAtrans] = size(A);

switch method
    case 'isomorphism'
    % Convert the atom transition graph into matlab graph structure, retaining
    % the name of the nodes and edges where they correspond to each
    % pair of atoms involved in an atom transition, except in the instance that
    % atom transition is duplicated (in either direction), in which case retain
    % the node and edge lablels corresponding to the first instance of that
    % atom transition
    % Ronan Fleming, 2020.
    
    %take into account that atom transition graph is not directed
    F = -min(A,0); %forward
    R =  max(A,0); %reverse
    %find the unique atom transitions
    [~,uniqueAtomTransitions,~] = unique((F+R)','rows');
    
    [ah,~] = find(A == -1); % head node indices
    [at,~] = find(A == 1); % tail node indices
    
    headTail = [ah,at];%take into account that atom transition network is not directed
    headTailUnique = headTail(uniqueAtomTransitions,:);
    
    % G = graph(EdgeTable) specifies graph edges (s,t) in node pairs. s and t can specify node indices or node names.
    % The EdgeTable input must be a table with a row for each corresponding pair of elements in s and t.
    EdgeTable = table(headTailUnique,'VariableNames',{'EndNodes'});
    EdgeTable.firstRxns = ATN.rxns(uniqueAtomTransitions);
    
    %generate a unique id for each atom by concatenation of the metabolite,
    %atom and element
    atoms=cell(nAtoms,1);
    for i=1:nAtoms
        atoms{i}=[ATN.mets{i}  '#' num2str(ATN.atns(i)) '#' ATN.elements{i}];
    end
    NodeTable = table(atoms,num2cell((1:nAtoms)'),'VariableNames',{'Name','AtomIndex'});
    
    %atom transition graph as a matlab graph object
    ATG = graph(EdgeTable,NodeTable);
    
    % Find connected components of underlying undirected graph.
    % Each component corresponds to an "atom conservation relation".
    if verLessThan('matlab','8.6')
        error('Requires matlab R2015b+')
    else
        components = conncomp(ATG); % Use built-in matlab algorithm. Introduced in R2015b.
        nComps = max(components);
    end

    %create a subgraph from each component
    subgraphs=cell(nComps,1);
    for i = 1:nComps
        subgraphs{i,1}=subgraph(ATG,components==i);
    end
    
    compElements = cell(nComps, 1); % Element for each atom conservation relation
    for i = 1:nComps
        aName=subgraphs{i,1}.Nodes.Name{1};
        [tok,rem]=strtok(aName,'#');
        [tok,rem]=strtok(rem,'#');
        [tok,rem]=strtok(rem,'#');
        compElements{i}=tok;
    end
        
    %remove the element and atom identifier from the node labels of each subgraph
    deidentifiedSubgraphs=subgraphs;
    for i = 1:nComps
        try
            nNodes=size(deidentifiedSubgraphs{i,1}.Nodes,1);
            for j=1:nNodes
                deidentifiedSubgraphs{i,1}.Nodes.Name{j} = strtok(deidentifiedSubgraphs{i,1}.Nodes.Name{j},'#');
            end
        catch
            EndNodes=deidentifiedSubgraphs{i,1}.Edges.EndNodes;
            [plt,~] = size(EndNodes);
            for p=1:plt
                EndNodes{p,1} = strtok(EndNodes{p,1},'#');
                EndNodes{p,2} = strtok(EndNodes{p,2},'#');
                %Edges{p,3}.firstRxns{p} = Edges{p,3};
            end
            T=table(EndNodes(:,1),EndNodes(:,2));
            [T,ia]=unique(T);
            Edges = table([T.Var1,T.Var2],'VariableNames',{'EndNodes'});
            Edges.firstRxns = deidentifiedSubgraphs{i,1}.Edges.firstRxns(ia);
            deidentifiedSubgraphs{i,1}=graph(Edges);
        end
    end
    
    % Map atoms to moieties, while identifying the moieties
    % atoms2moieties: `p x 1` vector mapping atoms (rows of `A`) to
    % moiety instances (rows of `M`)
    atoms2moieties = zeros(nAtoms,1);
    
    xi = []; %index of first subgraph in each isomorphism class
    xj = zeros(nComps,1); %indices of subgraphs identical to first in each isomorphism class
    %identify the isomorphic subgraphs
    if ~verLessThan('matlab', '9.1')
        C = false(1,nComps);
        isomorphismClassNumber=1;
        excludedSubgraphs=false(nComps,1);
        for i = 1:nComps
            %check that the first subgraph is not already in an isomorphism
            %class
            if excludedSubgraphs(i)==0
                %iterate through the second subgraphs
                for j = 1:nComps
                    %dont check a subgraph against itself
                    if i~=j
                       %dont check against any subgraph that has already been excluded
                        if excludedSubgraphs(j)==0
                            %test for graph isomorphism including of the
                            %metabolite labels of the nodes
                            if isisomorphic(deidentifiedSubgraphs{i,1},deidentifiedSubgraphs{j,1},'NodeVariables','Name')
                                C(isomorphismClassNumber,j)=1;
                                excludedSubgraphs(j)=1;
                                xj(j)=isomorphismClassNumber;
                                %save the indices of the atoms corresponding to
                                %this moiety
                                atoms2moieties(cell2mat(subgraphs{j,1}.Nodes.AtomIndex))=isomorphismClassNumber;
                            end
                        end
                    else
                        %include the current first graph in this isomorphism
                        %class
                        C(isomorphismClassNumber,j)=1;
                        %save index of first subgraph in the isomorphism
                        %class
                        xi = [xi;j];
                        xj(j)=isomorphismClassNumber;
                        %save the indices of the atoms corresponding to
                        %this moiety
                        atoms2moieties(cell2mat(subgraphs{i,1}.Nodes.AtomIndex))=isomorphismClassNumber;
                    end
                end
                %search for the next isomorphism class
                isomorphismClassNumber = isomorphismClassNumber +1;
            end
        end
    else
        error('Computing graph isomorphism requires matlab 9.1+');
    end
    nIsomorphismClasses = size(C,1);
    
    %moiety formula
    moietyFormulas=cell(nIsomorphismClasses,1);
    for i = 1:nIsomorphismClasses
        elementTable = tabulate(compElements(C(i,:)==1)); % elements in moiety i
        formula='';
        for j=1:size(elementTable,1)
            formula= [formula elementTable{j,1} num2str(elementTable{j,2})];
        end
        if 1      
            %requires https://uk.mathworks.com/matlabcentral/fileexchange/29774-stoichiometry-tools
            try
                moietyFormulas{i} = hillformula(formula);
            catch
                fprintf('%s\n',['Could not generate a chemical formulas in Hill Notation from: ' formula])
                moietyFormulas{i} = formula;
            end
        else
            moietyFormulas{i}=formula;
        end
    end
    
    %construct moiety matrix
    Lmat = sparse(nIsomorphismClasses,nMappedMets);
    for i = 1:nIsomorphismClasses
        for j=1:nComps
            if C(i,j)==1
                DeidentifiedNames=subgraphs{j}.Nodes.Name;
                
                for k = 1:size(DeidentifiedNames,1)
                    DeidentifiedNames{k}=strtok(DeidentifiedNames{k},'#');
                end
                %Necessary in case there is more than one moiety in any metabolite,
                %and if there is, increment the moiety matrix
                
                % Example: 'o2[c]#1#O' and  'o2[c]#2#O' both transition to
                % 'h2o[c]#1#O' in reaction 'alternativeR2' and reaction 'R1'
                % respectively.
                %             {'o2[c]#1#O'       ,'tyr_L[c]#8#O'    ,'R1';
                %              'o2[c]#1#O'       ,'h2o[c]#1#O'      ,'alternativeR2'; ***
                %              'o2[c]#2#O'       ,'h2o[c]#1#O'      ,'R1';            ***
                %              'o2[c]#2#O'       ,'34dhphe[c]#10#O' ,'alternativeR2';
                %              'tyr_L[c]#8#O'    ,'34dhphe[c]#8#O'  ,'alternativeR2';
                %              '34dhphe[c]#8#O'  ,'dopa[c]#8#O'     ,'R3';
                %              '34dhphe[c]#10#O' ,'dopa[c]#10#O'    ,'R3'}
                
                try
                    %add a moiety incidence for each time the moiety appears in a metabolite
                    for k=1:size(DeidentifiedNames,1)
                        %not all metabolites are involved in atom mapped
                        %reactions
                        metBool = strcmp(DeidentifiedNames{k},model.mets(mbool));
                        Lmat(i,metBool) = Lmat(i,metBool) + 1;
                    end
                catch ME
                    disp(ME.message)
                    k
                    DeidentifiedNames{k}
                end
                
                moietyConservationTest = ones(1,size(N,1))*diag(Lmat(i,:))*N;
                if any(moietyConservationTest~=0)
                    error('Moiety conservation violated.')
                end
                
                break
            end
        end
    end
    
    leftNullBool=(Lmat*N)==0;
    if any(~leftNullBool)
        warning('Not all moiety vectors are in the left null space of S. Check that atom transitions in A match the stoichiometry in S.');
    end
    
    L = Lmat'; % Moiety vectors to columns
    
    % Extract moiety graph from atom transition network
    [isMoiety, moieties2vectors] = ismember(components,xi);
    isMoietyTransition = any(A(isMoiety, :), 1);
    M = A(isMoiety, isMoietyTransition);
    
    % Map moieties to moiety vectors
    moieties2vectors = moieties2vectors(isMoiety);
    
    % Map between moiety graph and metabolic network
    moieties2mets = atoms2mets(isMoiety);
    mtrans2rxns = atrans2rxns(isMoietyTransition);

    case 'leftNull'
    % Convert incidence matrix to adjacency matrix for input to graph
    % algorithms
    % Hulda's 2015 code
    if 1
        [ah,~] = find(A == -1); % head nodes
        [at,~] = find(A == 1); % tail nodes
        adj = sparse([at;ah],[ah;at],ones(size([at;ah])));
    else
        %Graph Laplacian
        La = A*A';
        %Degree matrix
        D = diag(diag(La));
        
        if 0
            [ah,~] = find(A == -1); % head nodes
            [at,~] = find(A == 1); % tail nodes
            adj = sparse([at;ah],[ah;at],ones(size([at;ah])));
            if norm(full(adj - (D - La)))~=0
                error('failed to convert to adjacency matrix')
            end
        end
        adj = D - La;
        clear D La;
    end
    
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
    L = sparse(nComps, nMappedMets); % Initialize moiety matrix.
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
    C=[];
end

% This code can be used to test that both old and new approaches of
% creating the matlab graph object return a graph that is isomorphic 
% (not with respect to labelling).
% if ~exist('adj','var')
%     adj = adjacency(ATG);
% end
% G = graph(adj);
% P = isomorphism(ATG,G); %P should not be empty;

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

%Moiety graph decomposition
[m, n] = size(N);
[p, q] = size(M);

%     S = sparse(i,j,s,m,n,nzmax) uses vectors i, j, and s to generate an
%     m-by-n sparse matrix such that S(i(k),j(k)) = s(k), with space
%     allocated for nzmax nonzeros.  
%%%%  Vectors i, j, and s are all the same length.  
%     Any elements of s that are zero are ignored, along with the
%     corresponding values of i and j.  Any elements of s that have duplicate
%     values of i and j are added together.  The argument s and one of the
%     arguments i or j may be scalars, in which case the scalars are expanded
%     so that the first three arguments all have the same length.

V = sparse(moieties2mets, (1 : p)', ones(p, 1), m, p); % Matrix mapping moieties to mapped metabolites
E = sparse((1 : q)', mtrans2rxns, ones(q, 1), q, n); % Matrix mapping moiety transitions to mapped reactions

% Remove reverse directions of bidirectional moiety transitions
F = speye(q, q);
isForward = true(q, 1);
for j = 1:n
    isSubstrate = ismember(moieties2mets, find(N(:,j) < 0));
    isReverse = (mtrans2rxns == j) & any(M(isSubstrate,:) > 0, 1)';
    isForward(isReverse) = false;
end
F = F(:, isForward);
M = M * F;
E = F' * E;
mtrans2rxns = mtrans2rxns(isForward);

%test the decomposition
res = V*V'*N - V*M*E;
if norm(max(max(abs(res))))>0
    error('Moiety graph decomposition not exact')
end