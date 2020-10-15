function [L, M, moietyFormulae, moieties2mets, moiety2isomorphismClass, atrans2isomorphismClasses, mtrans2rxns, atrans2mtrans,mbool,rbool,V,E,I2C] = identifyConservedMoieties(model, ATM, options)
% Identifies conserved moieties in a metabolic network (model) by graph
% theoretical analysis of the corresponding atom transition network (ATM).
%
%
% USAGE:
%
%    [L, M, moietyFormulae, moieties2mets, moiety2isomorphismClass, atrans2isomorphismClasses, mtrans2rxns, atrans2mtrans] = identifyConservedMoieties(model, ATM)
%
% INPUTS:
%    model:                 Structure with following fields:
%
%                             * .S - The `m x n` stoichiometric matrix for the metabolic network
%                             * .mets - An `m x 1` array of metabolite identifiers. Should match
%                               metabolite identifiers in rxnfiles.
%                             * .rxns - An `n x 1` array of reaction identifiers. Should match
%                               `rxnfile` names in `rxnFileDir`.
%    ATM:                   Structure with following fields:
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
%    moietyFormulae:        `r x 1` cell array with chemical formulas of
%                           each moiey
%
%    moieties2mets:             `p x 1` vector mapping moiety instances (rows of `M`) to
%                                metabolites (rows of S)
%    moiety2isomorphismClass:   `p x 1` vector mapping moiety instances (rows of `M`) to
%                               isomorphism class vectors (columns of `L`)
%    atrans2moiety:        `p x 1` vector mapping atoms (rows of `A`) to
%                           moiety instances (rows of `M`)
%    mtrans2rxns:           'q x 1' vector mapping moiety transitions
%                           (columns of M) to reactions (columns of S)
%    atrans2mtrans:         'q x 1' vector mapping atom transitions
%                           (columns of A) to moiety transitions (columns
%                           of M)
%    mbool:                 `m x 1` Boolean, true for metabolites in ATM reactions
%    rbool:                 `n x 1` Boolean, true for reactions included in ATM
%    V:                     The `m x p` matrix that maps each metabolite to an
%                           instance of a moiety in the moiety graph.
%    E:                     The `q x n` matrix that maps each moiety
%                           transition to its corresponding reaction
%    C:                     An `r x c` matrix that maps r moieties to c
%                           connected components of an atom transition graph
%
% .. Authors: - Ronan M.T. Fleming, Sept 2020, compute conserved moieties
%               as described in:
%
% Ghaderi, S., Haraldsdóttir, H.S., Ahookhosh, M., Arreckx, S., and Fleming, R.M.T. (2020).
% Structural conserved moiety splitting of a stoichiometric matrix. Journal of Theoretical Biology 499, 110276.

if ~exist('options','var')
    options=[];
end

if ~isfield(options,'sanityChecks')
    options.sanityChecks=1;
end
sanityChecks = options.sanityChecks;

bool = contains(model.mets,'#');
if any(bool)
    error('No metabolite can have an id with a # character in it.')
end

rbool = ismember(model.rxns,ATM.Edges.Rxn); % True for reactions included in ATM
mbool = ismember(model.mets,ATM.Nodes.Met); % True for reactions included in ATM

N = sparse(model.S(mbool,rbool)); % Stoichometric matrix of atom mapped reactions

[nMets,nRxns]=size(model.S);
[nMappedMets,nMappedRxns] = size(N);
nAtoms = size(ATM.Nodes,1);
nTransInstances = size(ATM.Edges,1);


%matrix mapping atoms to mapped metabolites
[~,atoms2mets] = ismember(ATM.Nodes.Met,model.mets(mbool));
M2A = sparse(atoms2mets,(1:nAtoms)',1,nMappedMets,nAtoms);

%matrix mapping atom transition instances to mapped reactions
[~,atransInstance2rxns] = ismember(ATM.Edges.Rxn,model.rxns(rbool));
T02R = sparse((1:nTransInstances)',atransInstance2rxns,1,nTransInstances,nMappedRxns);


% An atom transition that occurs in a reaction is an atom transition instance,
% and since identical atom transition instances can happen in a more than one
% reaction, we only need a representative atom transition.
% Convert the atom transition graph into matlab multigraph structure, retaining
% the name of the nodes and edges where they correspond to each
% pair of atoms involved in an atom transition, except in the instance that
% atom transition is duplicated (in either direction), in which case retain
% the node and edge labels corresponding to the first instance of that
% atom transition

%check for duplicate edges, including those of opposite directions
if ismultigraph(ATM)
    % [H,eind,ecount] = simplify(G)
    % returns a graph without multiple edges or self-loops and
    % returns edge indices eind and edge counts ecount:
    % H.Edges(eind(i),:) is the edge in H that represents edge i in G.
    % ecount(j) is the number of edges in G that correspond to edge j in H.
    
    [ATG,eind,ecount] = simplify(ATM);
    nTrans = size(ATG.Edges,1);
    
    %remove the reaction prefix from the Transition name
    for i=1:nTrans
        [tok,rem]=strtok(ATG.Edges.Trans{i},'#');
        ATG.Edges.Trans{i}=rem(2:end);
    end
end

transInstanceIndex2transIndex = eind;
transIndex = (1:nTrans)';
if 0
    transInstanceIndex2transIndex = ATG.Edges.TransIndex(eind);
    transIndex = ATG.Edges.TransIndex;
end
T2T = sparse(transInstanceIndex2transIndex,(1:nTransInstances)',1,nTrans,nTransInstances);

if sanityChecks
    for i=1:nTransInstances
        fprintf('%s\n',int2str(i))
        fprintf('%s\n',ATG.Edges.Trans{transInstanceIndex2transIndex(i)})
        fprintf('%s\n\n',ATM.Edges.Trans{i})
    end
end

[isTrans,transIndex2transInstanceIndex] = ismember(ATG.Edges.TransIndex,ATM.Edges.TransIndex);
T2T = sparse((1:nTrans)',transIndex2transInstanceIndex,1,nTrans,nTransInstances);


%map atoms to metabolites
[isMet, atoms2mets] = ismember(ATM.mets,model.mets);

% Find connected components of underlying undirected graph.
% Each component corresponds to an "atom conservation relation".
if verLessThan('matlab','8.6')
    error('Requires matlab R2015b+')
else
    %assign the atoms of the atom transition graph into different
    %connected components
    atoms2component = conncomp(ATG)'; % Use built-in matlab algorithm. Introduced in R2015b.
    nComps = max(atoms2component);
end

%create a subgraph from each component
subgraphs=cell(nComps,1);
for i = 1:nComps
    subgraphs{i,1}=subgraph(ATG,atoms2component==i);
end

compElements = cell(nComps, 1); % Element for each atom conservation relation
for i = 1:nComps
    aName=subgraphs{i,1}.Nodes.nodeID{1};
    [tok,rem]=strtok(aName,'#');
    [tok,rem]=strtok(rem,'#');
    [tok,rem]=strtok(rem,'#');
    compElements{i}=tok;
end

%estimate for the number of conserved moieties
[rankN, ~, ~] = getRankLUSOL(N, 0);
rowRankDeficiencyN = size(N,1) - rankN;

%map isomorphism classes to components of atom transition graph
%rowRankDeficiencyN is an estimate
I2C = false(rowRankDeficiencyN,nComps);

%number of vertices in first subgraph of each isomorphism class
nVertFirstSubgraph=zeros(rowRankDeficiencyN,1);

% Map atom transitions to connected components
atrans2component = zeros(nTrans,1);

% Map atoms to isomorphism class
% atrans2isomorphismClasses: `p x 1` vector mapping atoms (rows of `A`) to
% connected components (rows of `L`)
atoms2isomorphismClass = zeros(nAtoms,1);

% Map atom transitions to isomorphism class
atrans2isomorphismClasses = zeros(nTrans,1);

xi = zeros(rowRankDeficiencyN,1); %index of first subgraph in each isomorphism class
xj = zeros(nComps,1); %indices of subgraphs identical to first in each isomorphism class
%identify the isomorphic subgraphs
if ~verLessThan('matlab', '9.1')
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
                        if isisomorphic(subgraphs{i,1},subgraphs{j,1},'NodeVariables','Mets')
                            I2C(isomorphismClassNumber,j)=1;
                            excludedSubgraphs(j)=1;
                            xj(j)=isomorphismClassNumber;
                            
                            if sanityChecks
                                if atoms2component(subgraphs{j,1}.Nodes.AtomIndex)~=j
                                    error('inconsistent mapping of atoms to connected components')
                                end
                            end
                            
                            % Map atom transitions to connected components
                            atrans2component(subgraphs{j,1}.Edges.AtransIndex)=j;
                            
                            %save the indices of the atoms corresponding to
                            %this moiety
                            atoms2isomorphismClass(subgraphs{j,1}.Nodes.AtomIndex)=isomorphismClassNumber;
                            
                            %save the indices of the atom transitions corresponding to this moiety
                            atrans2isomorphismClasses(subgraphs{j,1}.Edges.AtransIndex)=isomorphismClassNumber;
                        end
                    end
                else
                    %include the current first graph in this isomorphism
                    %class
                    I2C(isomorphismClassNumber,j)=1;
                    
                    %save index of first subgraph in the isomorphism
                    %class
                    xi(isomorphismClassNumber) = j;
                    xj(j)=isomorphismClassNumber;
                    
                    if sanityChecks
                        if atoms2component(subgraphs{j,1}.Nodes.AtomIndex)~=i
                            error('inconsistent mapping of atoms to connected components')
                        end
                    end
                    
                    % Map atom transitions to connected components
                    atrans2component(subgraphs{i,1}.Edges.AtransIndex)=i;
                    
                    %save the indices of the atoms corresponding to
                    %this moiety
                    atoms2isomorphismClass(subgraphs{i,1}.Nodes.AtomIndex)=isomorphismClassNumber;
                    
                    %save the indices of the atom transitions corresponding to this moiety
                    atrans2isomorphismClasses(subgraphs{i,1}.Edges.AtransIndex)=isomorphismClassNumber;
                    
                    %savenumber of vertices in first subgraph of each isomorphism class
                    nVertFirstSubgraph(isomorphismClassNumber)=size(subgraphs{i,1}.Nodes,1);
                end
            end
            %search for the next isomorphism class
            isomorphismClassNumber = isomorphismClassNumber +1;
        end
    end
else
    error('Computing graph isomorphism requires matlab 9.1+');
end
%remove zero rows
bool = any(I2C,2);
I2C    = I2C(bool,:);
xi   = xi(bool);

%define the actual number of isomorphism classes
nIsomorphismClasses = size(I2C,1);

%map ATG to connected component and isomorphism class
ATG.Nodes = addvars(ATG.Nodes,atoms2component,'NewVariableNames','Component');
ATG.Nodes = addvars(ATG.Nodes,atoms2isomorphismClass,'NewVariableNames','IsomorphismClass');
Edges = ATG.Edges;
Edges = addvars(Edges,ATG.Nodes.Component(Edges.HeadAtomIndex),'NewVariableNames','Component');
Edges = addvars(Edges,ATG.Nodes.IsomorphismClass(Edges.HeadAtomIndex),'NewVariableNames','IsomorphismClass');
ATG = graph(Edges,ATG.Nodes);

%matrix to map connected component to atoms
C2A = sparse(atoms2component,(1:nAtoms)',1,nComps,nAtoms);

%matrix to map isomorphism class to atoms
I2A = I2C*C2A;

if sanityChecks
    res = I2A - sparse(atoms2isomorphismClass,(1:nAtoms)',1,nIsomorphismClasses,nAtoms);
    if any(res,'all')
        error('matrix to map isomorphism classes to atom instances inconsistent')
    end
end

%matix to map atom transitions to isomorphism classes
T2I = sparse((1:nTrans)',atrans2isomorphismClasses,1,nTrans,nIsomorphismClasses);

%matrix to map atom transitions to connected components
T2C = sparse((1:nTrans)',atrans2component,1,nTrans,nComps);

%conserved moiety formula
moietyFormulae=cell(nIsomorphismClasses,1);
for i = 1:nIsomorphismClasses
    elementTable = tabulate(compElements(I2C(i,:)==1)); % elements in moiety i
    formula='';
    for j=1:size(elementTable,1)
        formula= [formula elementTable{j,1} num2str(elementTable{j,2})];
    end
    
    if 1
        %requires https://uk.mathworks.com/matlabcentral/fileexchange/29774-stoichiometry-tools
        try
            formula = hillformula(formula);
            moietyFormulae{i} = formula{1};
        catch
            fprintf('%s\n',['Could not generate a chemical formulas in Hill Notation from: ' formula])
            moietyFormulae{i} = formula;
        end
    else
        moietyFormulae{i}=formula;
    end
end

%create the moiety instance transition graph explicitly as a
%subgraph of the atom transition graph
[isFirst, moiety2isomorphismClass] = ismember(atoms2component,xi);
ATG.Nodes = addvars(ATG.Nodes,isFirst,'NewVariableNames','IsFirst');
nMoieties=nnz(isFirst);

%Map moiety instance to isomorphism class
moiety2isomorphismClass = moiety2isomorphismClass(isFirst);
%Matrix to map moieties to isomorphism classes
M2I = sparse((1:nMoieties)',moiety2isomorphismClass,1,nMoieties,nIsomorphismClasses);

if sanityChecks
    moiety2isomorphismClass2 = atoms2isomorphismClass(isFirst);
    if any(moiety2isomorphismClass~=moiety2isomorphismClass2)
        error('Inconsistent moiety2isomorphismClass vector')
    end
end

%draft moiety instance transition graph, before editing node and
%edge information
MTG = subgraph(ATG,isFirst);

%add moiety specific information
MTG.Nodes = addvars(MTG.Nodes,moietyFormulae(moiety2isomorphismClass),'NewVariableNames','Formula','After','IsomorphismClass');
MTG.Nodes = removevars(MTG.Nodes,{'Mets','Atns','Elements'});
if 1
    MTG.Nodes = addvars(MTG.Nodes,MTG.Nodes.nodeID,'NewVariableNames','FirstAtom');
    MTG.Nodes = removevars(MTG.Nodes,'nodeID');
    MTG.Nodes = addvars(MTG.Nodes,(1:nMoieties)','NewVariableNames','NodeID','Before','AtomIndex');
else
    %R2020a
    MTG.Nodes = renamevars(MTG.Nodes,'Name','FirstAtom');
end
MTG.Nodes = addvars(MTG.Nodes,[1:nMoieties]','NewVariableNames','MoietyIndex','After','NodeID');

%graph.Edges cannot be directly edited in a graph object, so extract,
%edit and regenerate the graph
%         Error using graph/subsasgn (line 23)
%         Direct editing of edges not supported. Use addedge or rmedge instead.
%
%         Error in identifyConservedMoieties (line 490)
%         MTG.Edges = addvars(MTG.Edges,MTG.Edges.Name,'NewVariableNames','FirstAtomTransition','After','Rxns');
Nodes = MTG.Nodes;
Edges = MTG.Edges;

Edges = addvars(Edges,Edges.Name,'NewVariableNames','FirstAtomTransition','After','Rxns');
Edges = removevars(Edges,'Name');
Edges = addvars(Edges,Nodes.Formula(Edges.EndNodes(:,1)),'NewVariableNames','Formula','After','Rxns');
Edges = addvars(Edges,strcat(strcat(Edges.Rxns,'#'),Edges.Formula),'NewVariableNames','Name','After','EndNodes');
MTG = graph(Edges,Nodes);
%size of the moiety instance transition graph
nMoietyTransitions=size(MTG.Edges,1);

if sanityChecks
    % Extract moiety graph directly from atom transition
    % graph incidence matrix
    [isFirst, ~] = ismember(atoms2component,xi);
    isFirstTransition = any(A(isFirst, :), 1);
    M = A(isFirst, isFirstTransition);
    
    [mh,~] = find(M == -1); % head node indices
    [mt,~] = find(M == 1); % tail node indices
    MTG2=graph(mh,mt);
    if ~isisomorphic(MTG,MTG2)
        error('Moiety transition graphs not isomorphic')
    end
    if 0
        I = incidence(MTG);
        res=M-I;
        if max(max(abs(res)))~=0
            [indi,indj]=find(res);
            full(M(indi,indj))
            full(I(indi,indj))
            error('Moiety transition graph incidence matrices are inconsistent')
        end
    end
end

%add a placeholder for the moiety indices to the atom transition graph
atoms2moiety=zeros(nAtoms,1);
ATG.Nodes = addvars(ATG.Nodes,atoms2moiety,'NewVariableNames','MoietyIndex');

%add the moiety indices for the first atoms in each moiety
moietyInd=1;
for i=1:nAtoms
    if ATG.Nodes.IsFirst(i)
        ATG.Nodes.MoietyIndex(i)=moietyInd;
        moietyInd = moietyInd + 1;
    end
end

%recreate a subgraph from each component
subgraphs=cell(nComps,1);
for i = 1:nComps
    subgraphs{i,1}=subgraph(ATG,atoms2component==i);
end

%assign the moiety indices by using the indices for the first
%component in each isomorphism class
for i=1:nIsomorphismClasses
    MoietyIndices = subgraphs{xi(i)}.Nodes.MoietyIndex;
    for j=1:nComps
        if I2C(i,j)==1 && j~=xi(i)
            subgraphs{j}.Nodes.MoietyIndex=MoietyIndices;
        end
    end
end

%compile the moiety indices from the nodes in the subgraph into the
%atom transition graph
for i = 1:nComps
    if ~any(i==xi)
        for j=1:size(subgraphs{i}.Nodes,1)
            ATG.Nodes.MoietyIndex(strcmp(ATG.Nodes.nodeID,subgraphs{i}.Nodes.nodeID(j))) = subgraphs{i}.Nodes.MoietyIndex(j);
        end
    end
end

%extract the map from atoms to moiety
atoms2moiety = ATG.Nodes.MoietyIndex;

%create the map from moiety to atoms
M2A = sparse(atoms2moiety,(1:nAtoms)',1,nMoieties,nAtoms);

if sanityChecks
    for j=1:nMoieties
        fprintf('%s\n',moietyFormulae{moiety2isomorphismClass(j)})
        tabulate(ATG.Nodes.Elements(M2A(j,:)~=0))
        moietyMetIndices=atoms2mets(M2A(j,:)~=0);
        
        if length(unique(moietyMetIndices))>1
            warning('single moiety incident in more than one metabolite')
        end
    end
end

%map metabolite to moiety
M2M = zeros(nMets,nMoieties);
for j=1:nMoieties
    atomInd = find(ATG.Nodes.MoietyIndex == j);
    for k = 1:length(atomInd)
        M2M(strcmp(model.mets,ATG.Nodes.Mets{atomInd(k)}),j) = M2M(strcmp(model.mets,ATG.Nodes.Mets{atomInd(k)}),j) + 1;
    end
end
%Normalise each column
M2M = M2M./sum(M2M,1);


%map atom transitions to isomorphism classes
H = sparse((1:nTrans)',atrans2isomorphismClasses,1,nTrans,nIsomorphismClasses);



%for i=1:nMoieties


%     S = sparse(i,j,s,m,n,nzmax) uses vectors i, j, and s to generate an
%     m-by-n sparse matrix such that S(i(k),j(k)) = s(k), with space
%     allocated for nzmax nonzeros.

%map moieties instances to isomorphism classes
K = sparse(moiety2isomorphismClass,(1:nMoieties)', 1, nIsomorphismClasses,nMoieties);


%construct moiety matrix
Lmat = sparse(nIsomorphismClasses,nMappedMets);
for i = 1:nIsomorphismClasses
    for j=1:nComps
        if I2C(i,j)==1
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
            
            if sanityChecks
                moietyConservationTest = ones(1,size(N,1))*diag(Lmat(i,:))*N;
                if any(moietyConservationTest~=0)
                    error('Moiety conservation violated.')
                end
            end
            
            break
        end
    end
end


if sanityChecks
    leftNullBool=(Lmat*N)==0;
    if any(~leftNullBool)
        warning('Not all moiety vectors are in the left null space of S. Check that atom transitions in A match the stoichiometry in S.');
    end
end

if sanityChecks
    allBiologicalElements={'C','O','P','N','S','H','Mg','Na','K','Cl','Ca','Zn','Fe','Cu','Mo','I'};
    %compare number of atoms of each element in moiety with
    %metabolites
    mappedMets = model.mets(mbool);
    mappedMetFormulae = model.metFormulas(mbool);
    
    for i=1:nIsomorphismClasses
        for j=1:nMappedMets
            if Lmat(i,j)~=0
                formulae = {moietyFormulae{i};mappedMetFormulae{j}};
                [Ematrix, elements] = getElementalComposition(formulae);
                if any(Ematrix(1,:)> Ematrix(2,:))
                    warning(['Moiety ' int2str(i) ' formula is: '   moietyFormulae{i} ' but  metabolite ' mappedMets{j} ' formula is: ' mappedMetFormulae{j}])
                end
            end
        end
    end
    
end

L = Lmat'; % Moiety vectors to columns

%         %fraction of moiety in each metabolite
%         V = sparse(nMappedMets,nMoieties);
%         for j=1:nMoieties
%             for i = 1:nMappedMets
%
%                 if C(i,j)==1
%                     DeidentifiedNames=subgraphs{j}.Nodes.Name;
%
%                     for k = 1:size(DeidentifiedNames,1)
%                         DeidentifiedNames{k}=strtok(DeidentifiedNames{k},'#');
%                     end
%                     %Necessary in case there is more than one moiety in any metabolite,
%                     %and if there is, increment the moiety matrix
%
%                     % Example: 'o2[c]#1#O' and  'o2[c]#2#O' both transition to
%                     % 'h2o[c]#1#O' in reaction 'alternativeR2' and reaction 'R1'
%                     % respectively.
%                     %             {'o2[c]#1#O'       ,'tyr_L[c]#8#O'    ,'R1';
%                     %              'o2[c]#1#O'       ,'h2o[c]#1#O'      ,'alternativeR2'; ***
%                     %              'o2[c]#2#O'       ,'h2o[c]#1#O'      ,'R1';            ***
%                     %              'o2[c]#2#O'       ,'34dhphe[c]#10#O' ,'alternativeR2';
%                     %              'tyr_L[c]#8#O'    ,'34dhphe[c]#8#O'  ,'alternativeR2';
%                     %              '34dhphe[c]#8#O'  ,'dopa[c]#8#O'     ,'R3';
%                     %              '34dhphe[c]#10#O' ,'dopa[c]#10#O'    ,'R3'}
%
%                     try
%                         %add a moiety incidence for each time the moiety appears in a metabolite
%                         for k=1:size(DeidentifiedNames,1)
%                             %not all metabolites are involved in atom mapped
%                             %reactions
%                             metBool = strcmp(DeidentifiedNames{k},model.mets(mbool));
%                             Lmat(i,metBool) = Lmat(i,metBool) + 1;
%                         end
%                     catch ME
%                         disp(ME.message)
%                         k
%                         DeidentifiedNames{k}
%                     end
%
%                     if sanityChecks
%                         moietyConservationTest = ones(1,size(N,1))*diag(Lmat(i,:))*N;
%                         if any(moietyConservationTest~=0)
%                             error('Moiety conservation violated.')
%                         end
%                     end
%
%                     break
%                 end
%             end
%         end



% Map between moiety graph and metabolic network
moieties2mets = atoms2mets(isFirst);
mtrans2rxns = atransInstance2rxns(isFirstTransition);

% This code can be used to test that both old and new approaches of
% creating the matlab graph object return a graph that is isomorphic
% (not with respect to labelling).
% if ~exist('adj','var')
%     adj = adjacency(ATG);
% end
% G = graph(adj);
% P = isomorphism(ATG,G); %P should not be empty;

% Map atom transitions to moiety transitions
atrans2mtrans = zeros(nTransInstances,1);

[mh,~] = find(M == -1); % head nodes in moiety graph
[mt,~] = find(M == 1); % tail nodes in moiety graph

% An atom transition maps to a moiety transition if its head node maps to
% the head moiety, its tail node to the tail moiety, and its from the same
% reaction
for i = 1:length(mh)
    if i==1
        pause(0.1)
    end
    inHead = ismember(ah, find(atrans2isomorphismClasses == mh(i)));
    inTail = ismember(at, find(atrans2isomorphismClasses == mt(i)));
    inRxn = atransInstance2rxns == mtrans2rxns(i);
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

V = sparse(moieties2mets, (1 : p)', ones(p, 1), m, p); % Matrix mapping mapped metabolites to moiety instances
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