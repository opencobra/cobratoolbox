function [L, M, moietyFormulae, moieties2mets, moiety2isomorphismClass, atrans2isomorphismClass, moietyTransition2rxns, atransInstance2mtrans,mbool,rbool,V,E,I2C] = identifyConservedMoieties(model, dATM, options)
% Identifies conserved moieties in a metabolic network (model) by graph
% theoretical analysis of the corresponding atom transition network (dATM).
%
%
% USAGE:
%
%    [L, M, moietyFormulae, moieties2mets, moiety2isomorphismClass, atrans2isomorphismClass, moietyTransition2rxns, atrans2mtrans] = identifyConservedMoieties(model, dATM)
%
% INPUTS:
%    model:                 Structure with following fields:
%
%                             * .S - The `m x n` stoichiometric matrix for the metabolic network
%                             * .mets - An `m x 1` array of metabolite identifiers. Should match
%                               metabolite identifiers in rxnfiles.
%                             * .rxns - An `n x 1` array of reaction identifiers. Should match
%                               `rxnfile` names in `rxnFileDir`.
%    dATM:                   Structure with following fields:
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
%    moietyTransition2rxns:           'q x 1' vector mapping moiety transitions
%                           (columns of M) to reactions (columns of S)
%    atrans2mtrans:         'q x 1' vector mapping atom transitions
%                           (columns of A) to moiety transitions (columns
%                           of M)
%    mbool:                 `m x 1` Boolean, true for metabolites in dATM reactions
%    rbool:                 `n x 1` Boolean, true for reactions included in dATM
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

rbool = ismember(model.rxns,dATM.Edges.Rxn); % True for reactions included in dATM
mbool = ismember(model.mets,dATM.Nodes.Met); % True for reactions included in dATM

N = sparse(model.S(mbool,rbool)); % Stoichometric matrix of atom mapped reactions

[nMets,nRxns]=size(model.S);
[nMappedMets,nMappedRxns] = size(N);
nAtoms = size(dATM.Nodes,1);
nTransInstances = size(dATM.Edges,1);

%matrix mapping atoms to mapped metabolites
[~,atoms2mets] = ismember(dATM.Nodes.Met,model.mets(mbool));
M2A = sparse(atoms2mets,(1:nAtoms)',1,nMappedMets,nAtoms);

%matrix mapping atom transition instances to mapped reactions
[~,atransInstance2rxns] = ismember(dATM.Edges.Rxn,model.rxns(rbool));
Ti2R = sparse((1:nTransInstances)',atransInstance2rxns,1,nTransInstances,nMappedRxns);

% An atom transition that occurs in a reaction is an atom transition instance,
% and since identical atom transition instances can happen in a more than one
% reaction, we only need a representative atom transition.
% Convert the atom transition graph into matlab multigraph structure, retaining
% the name of the nodes and edges where they correspond to each
% pair of atoms involved in an atom transition, except in the instance that
% atom transition is duplicated (in either direction), in which case retain
% the node and edge labels corresponding to the first instance of that
% atom transition

%%%%%%%%%%%%%%%%%%%%%% Undirected atom transition multigraph %%%%%%%%%%%%%%

%convert to an undirected multigraph, but note that conversion from a 
%directed to undirected multigraph flips the orientation
%of some edges and changes the order of the edges
ATM = graph(dATM.Edges,dATM.Nodes);

% ATM.Edges.TransInstIndex provides an index to recover the original
% order of edges in dATM

if 0
    %save the orientation of the atom transition in ATM with respect to dATM
    orientationTransInstancesATM = zeros(nTransInstances,1);
    
    forwardBool = all(ATM.Edges.EndNodes == dATM.Edges.EndNodes(ATM.Edges.TransInstIndex,:),2);
    orientationTransInstancesATM(forwardBool)=1;
    
    reverseBool = all(ATM.Edges.EndNodes == [dATM.Edges.EndNodes(ATM.Edges.TransInstIndex,2), dATM.Edges.EndNodes(ATM.Edges.TransInstIndex,1)],2);
    orientationTransInstancesATM(reverseBool)=-1;
    
    if sanityChecks
        if any(orientationTransInstancesATM==0)
            error('inconsistent aATM and ATM indexing')
        end
    end
    
    %update the Trans, HeadIndex, TailIndex, HeadAtom and TailAtom to match any reorientation
    for i=1:nTransInstances
        if orientationTransInstancesATM(i)==1
            %remove the reaction prefix from the Transition name
            [~,rem]=strtok(ATM.Edges.Trans{i},'#');
            ATM.Edges.Trans{i}=rem(2:end);
        else
            ATM.Edges.HeadAtomIndex(i) = ATM.Edges.EndNodes(i,2);
            ATM.Edges.TailAtomIndex(i) = ATM.Edges.EndNodes(i,1);
            HeadAtom = ATM.Edges.TailAtom{i};
            TailAtom = ATM.Edges.HeadAtom{i};
            ATM.Edges.HeadAtom{i} = HeadAtom;
            ATM.Edges.TailAtom{i} = TailAtom;
            ATM.Edges.Trans{i} = [HeadAtom '#' TailAtom];
        end
    end
    
    if sanityChecks
        %boolean of edges whose orientation is the same
        forwardBool1 = all([ATM.Edges.HeadAtomIndex, ATM.Edges.TailAtomIndex] == ...
            [dATM.Edges.HeadAtomIndex(ATM.Edges.TransInstIndex),dATM.Edges.TailAtomIndex(ATM.Edges.TransInstIndex)],2);
        
        if ~all(forwardBool1)
            %boolean of edges whose orientation has been flipped by ATM = graph(dATM.Edges,dATM.Nodes);
            reverseBool1 = all([ATM.Edges.HeadAtomIndex, ATM.Edges.TailAtomIndex] == ...
                [dATM.Edges.TailAtomIndex(ATM.Edges.TransInstIndex),dATM.Edges.HeadAtomIndex(ATM.Edges.TransInstIndex)],2);
            error('inconsistent dATM and ATM indexing')
        end
    end
end
%%%%%%%%%%%%%%%%%%% Atom transition graph %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [H,eind,ecount] = simplify(G)
% returns a graph without multiple edges or self-loops and
% returns edge indices eind and edge counts ecount:
% H.Edges(eind(i),:) is the edge in H that represents edge i in G.
% ecount(j) is the number of edges in G that correspond to edge j in H.
[ATG,eind,ecount] = simplify(ATM);
nAtoms = size(ATG.Nodes,1);
nTrans = size(ATG.Edges,1);

%update transInstanceIndex2transIndex to account for edge reordering
transInstanceIndex2transIndex(ATM.Edges.TransInstIndex) = eind; 
transInstanceIndex2transIndex=transInstanceIndex2transIndex';

%find the edges of ATG that correspond exactly to the edge in dATM
% LIA = ismember(A,B,'rows') for matrices A and B with the same number
% of columns, returns a vector containing true where the rows of A are
% also rows of B and false otherwise.
isTrans = ismember(dATM.Edges.TransInstIndex,ATG.Edges.TransInstIndex);

%save the orientation of the atom transition in ATM with respect to dATM
orientationTransInstancesATG = zeros(nTransInstances,1);

forwardBool = all(dATM.Edges.EndNodes == ATG.Edges.EndNodes(transInstanceIndex2transIndex),2);
orientationTransInstancesATG(forwardBool)=1;

reverseBool = all(dATM.Edges.EndNodes == ...
    [ATG.Edges.EndNodes(transInstanceIndex2transIndex,2), ATG.Edges.EndNodes(transInstanceIndex2transIndex,1)],2);

orientationTransInstancesATG(reverseBool)=-1;

if sanityChecks
    if any(orientationTransInstancesATG==0)
        error('inconsistent aATM and ATG indexing')
    end
end

%update the Trans, HeadIndex, TailIndex, HeadAtom and TailAtom to match any reorientation
for i=1:nTransInstances
    if orientationTransInstancesATG(i)==1
        %remove the reaction prefix from the Transition name
        [~,rem]=strtok(ATM.Edges.Trans{i},'#');
        ATM.Edges.Trans{i}=rem(2:end);
    else
        ATM.Edges.HeadAtomIndex(i) = ATM.Edges.EndNodes(i,2);
        ATM.Edges.TailAtomIndex(i) = ATM.Edges.EndNodes(i,1);
        HeadAtom = ATM.Edges.TailAtom{i};
        TailAtom = ATM.Edges.HeadAtom{i};
        ATM.Edges.HeadAtom{i} = HeadAtom;
        ATM.Edges.TailAtom{i} = TailAtom;
        ATM.Edges.Trans{i} = [HeadAtom '#' TailAtom];
    end
end

if sanityChecks
    %boolean of edges whose orientation is the same
    forwardBool1 = all([ATM.Edges.HeadAtomIndex, ATM.Edges.TailAtomIndex] == ...
        [dATM.Edges.HeadAtomIndex(ATM.Edges.TransInstIndex),dATM.Edges.TailAtomIndex(ATM.Edges.TransInstIndex)],2);
    
    if ~all(forwardBool1)
        %boolean of edges whose orientation has been flipped by ATM = graph(dATM.Edges,dATM.Nodes);
        reverseBool1 = all([ATM.Edges.HeadAtomIndex, ATM.Edges.TailAtomIndex] == ...
            [dATM.Edges.TailAtomIndex(ATM.Edges.TransInstIndex),dATM.Edges.HeadAtomIndex(ATM.Edges.TransInstIndex)],2);
        error('inconsistent dATM and ATM indexing')
    end
end

%boolean of edges whose orientation is the same
forwardBool2 = dATM.Edges.HeadAtomIndex==ATG.Edges.HeadAtomIndex(transInstanceIndex2transIndex);
%boolean of edges whose orientation has been flipped by [ATG,eind,ecount] = simplify(ATM);
reverseBool2 = dATM.Edges.TailAtomIndex==ATG.Edges.HeadAtomIndex(transInstanceIndex2transIndex);
if sanityChecks
    bool2 = forwardBool2 | reverseBool2;
    if ~all(bool2)
        error('inconsistent aATM and ATG indexing')
    end
end
%save the relative reorientation of ATG ->-> dATM
orientationTransInstances = ones(nTransInstances,1);
orientationTransInstances(reverseBool2)= -1;


%map each atom transition to one or more atom transition instances
transIndex = (1:nTrans)';

%assume the orientation of each atom transition is the same as
%the corresponding atom transition instance
T2Ti = sparse(transInstanceIndex2transIndex,(1:nTransInstances)',1,nTrans,nTransInstances);


if sanityChecks
    for i=1:nTransInstances
        %name of atom transition instance, without reaction id
        aTransInstanceHeadAtom = dATM.Edges.HeadAtom{i};
        aTransInstanceTailAtom = dATM.Edges.TailAtom{i};
        aTransHeadAtom = ATG.Edges.TailAtom{transInstanceIndex2transIndex(i)};
        aTransTailAtom = ATG.Edges.HeadAtom{transInstanceIndex2transIndex(i)};
        if ~strcmp(aTransInstanceHeadAtom,aTransHeadAtom)
            if orientationTransInstances(i)==-1
                error('mismatch of atom transition instance and atom transition')
            end
            if ~strcmp(aTransInstanceHeadAtom,aTransTailAtom)
                error('mismatch of atom transition instance and atom transition')
                if orientationTransInstances(i)==1
                    error('mismatch of atom transition instance and atom transition')
                end
            end
        end
    end
end

%update the transition indices in the atom transition graph
if 1
    ATG.Edges.TransIndex=transIndex;
    %ATG.Edges = movevars(ATG.Edges,'TransIndex','After','Trans');
else
    ATG.Edges = addvars(ATG.Edges,transIndex,'NewVariableNames','TransIndex','After','Trans');
end

%map atoms to metabolites
[isMet, atoms2mets] = ismember(dATM.Nodes.Met,model.mets(mbool));
M2A =  sparse(atoms2mets,(1:nAtoms)',1,nMappedMets,nAtoms);

if 0
    %now take into account any reorientation
    T2Ti = sparse(transInstanceIndex2transIndex,(1:nTransInstances)',orientationTransInstances,nTrans,nTransInstances);
end

%map atom transitions to reactions.
% an atom transition can map to multiple reactions
% a reaction can map to multiple atom transitions
T2R = T2Ti*Ti2R;

if sanityChecks
    T2R2 = sparse(nTrans,nMappedRxns);
    %matrix mapping each atom transition to mapped reactions
    mappedRxn=model.rxns(rbool);
    for i = 1:nTrans
        for j = 1:nMappedRxns
            T2R2(i,j)=any(strcmp(mappedRxn{j},dATM.Edges.Rxn(T2Ti(i,:)~=0)));
        end
    end
    
    res = (T2R~=0) - (T2R2~=0);
    if max(max(abs(res)))~=0
        figure;spy([T2R,T2R2])
        figure;spy(T2R - T2R2)
        figure;spy(T2R~=0 - T2R2~=0)
        error('Inconsistent mapping from atom transition to reaction')
    end
end

%add a placeholder for the moiety indices to the atom transition graph
atoms2moiety=zeros(nAtoms,1);
ATG.Nodes = addvars(ATG.Nodes,atoms2moiety,'NewVariableNames','MoietyIndex');

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
    compElements{i}=subgraphs{i,1}.Nodes.Element{1};
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
% atrans2isomorphismClass: `p x 1` vector mapping atoms (rows of `A`) to
% connected components (rows of `L`)
atoms2isomorphismClass = zeros(nAtoms,1);

% Map atom transitions to isomorphism class
atrans2isomorphismClass = zeros(nTrans,1);

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
                        if isisomorphic(subgraphs{i,1},subgraphs{j,1},'NodeVariables','Met')
                            I2C(isomorphismClassNumber,j)=1;
                            excludedSubgraphs(j)=1;
                            xj(j)=isomorphismClassNumber;
                            
                            if sanityChecks
                                if atoms2component(subgraphs{j,1}.Nodes.AtomIndex)~=j
                                    error('inconsistent mapping of atoms to connected components')
                                end
                            end
                            
                            % Map atom transitions to connected components
                            atrans2component(subgraphs{j,1}.Edges.TransIndex)=j;
                            
                            %save the indices of the atoms corresponding to
                            %this moiety
                            atoms2isomorphismClass(subgraphs{j,1}.Nodes.AtomIndex)=isomorphismClassNumber;
                            
                            %save the indices of the atom transitions corresponding to this moiety
                            atrans2isomorphismClass(subgraphs{j,1}.Edges.TransIndex)=isomorphismClassNumber;
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
                    atrans2component(subgraphs{i,1}.Edges.TransIndex)=i;
                    
                    %save the indices of the atoms corresponding to
                    %this moiety
                    atoms2isomorphismClass(subgraphs{i,1}.Nodes.AtomIndex)=isomorphismClassNumber;
                    
                    %save the indices of the atom transitions corresponding to this moiety
                    atrans2isomorphismClass(subgraphs{i,1}.Edges.TransIndex)=isomorphismClassNumber;
                    
                    %save number of vertices in first subgraph of each isomorphism class
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
if 0
    Edges = ATG.Edges;
    Edges = addvars(Edges,ATG.Nodes.Component(Edges.HeadAtomIndex),'NewVariableNames','Component');
    Edges = addvars(Edges,ATG.Nodes.IsomorphismClass(Edges.HeadAtomIndex),'NewVariableNames','IsomorphismClass');
    ATG = graph(Edges,ATG.Nodes);
else
    ATG.Edges.Component = ATG.Nodes.Component(ATG.Edges.HeadAtomIndex);
    ATG.Edges.IsomorphismClass = ATG.Nodes.IsomorphismClass(ATG.Edges.HeadAtomIndex);
end

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

%matrix to map atom transitions to isomorphism classes
T2I = sparse((1:nTrans)',atrans2isomorphismClass,1,nTrans,nIsomorphismClasses);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create the moiety transition graph explicitly as a
%subgraph of the atom transition graph
[isFirst, moiety2isomorphismClass] = ismember(atoms2component,xi);
ATG.Nodes = addvars(ATG.Nodes,isFirst,'NewVariableNames','IsFirst');
nMoieties=nnz(isFirst);
A = incidence(ATG);
isFirstTransition = any(A(isFirst, :), 1)';
if 0
    ATG.Edges = addvars(ATG.Edges,isFirstTransition,'NewVariableNames','IsFirst');
else
    ATG.Edges.IsFirst = isFirstTransition;
end

%Map each moiety to an isomorphism class
moiety2isomorphismClass = moiety2isomorphismClass(isFirst);
%Matrix to map each moiety to an isomorphism class
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
MTG.Nodes.MoietyIndex = [1:nMoieties]';

if sanityChecks
    %double check that there is no reordering of edges
    diffTransIndex = diff(MTG.Edges.TransIndex);
    if any(diffTransIndex<1)
        error('reordering of edges of moiety transition graph')
    end
end

%add moiety specific information
MTG.Nodes = removevars(MTG.Nodes,{'AtomNumber','Element'});
MTG.Nodes = addvars(MTG.Nodes,moietyFormulae(moiety2isomorphismClass),'NewVariableNames','Formula','After','MoietyIndex');

if 0
    %graph.Edges cannot be directly edited in a graph object, so extract,
    %edit and regenerate the graph
    %         Error using graph/subsasgn (line 23)
    %         Direct editing of edges not supported. Use addedge or rmedge instead.
    %
    %         Error in identifyConservedMoieties (line 490)
    %         MTG.Edges = addvars(MTG.Edges,MTG.Edges.Name,'NewVariableNames','FirstAtomTransition','After','Rxns');
    Edges = addvars(MTG.Edges,Edges.Name,'NewVariableNames','FirstAtomTransition','After','Rxns');
    Edges = removevars(Edges,'Name');
    Edges = addvars(Edges,Nodes.Formula(Edges.EndNodes(:,1)),'NewVariableNames','Formula','After','Rxns');
    MTG = graph(Edges,MTG.Nodes);
else
    MTG.Edges.Formula=MTG.Nodes.Formula(MTG.Edges.EndNodes(:,1));
end

%size of the moiety instance transition graph
nMoietyTransitions=size(MTG.Edges,1);

if sanityChecks
    % Extract moiety graph directly from atom transition
    % graph incidence matrix
    [isFirstAlso, ~] = ismember(atoms2component,xi);
    if ~all(isFirst == isFirstAlso)
        error('moiety incidence matrix does not match first component')
    end
    A = incidence(ATG);
    isFirstTransitionAlso = any(A(isFirstAlso, :), 1);
    M = A(isFirstAlso, isFirstTransitionAlso);
    
    [mh,~] = find(M == -1); % head node indices
    [mt,~] = find(M == 1); % tail node indices
    MTG2=graph(mh,mt);
    if ~isisomorphic(MTG,MTG2)
        error('Moiety transition graphs not isomorphic')
    end
    if 1
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

%add the moiety indices for the first atoms in each moiety
moietyInd=1;
for i=1:nAtoms
    if ATG.Nodes.IsFirst(i)
        ATG.Nodes.MoietyIndex(i)=moietyInd;
        moietyInd = moietyInd + 1;
    end
end

%create a subgraph from each component
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
            bool = ismember(ATG.Nodes.AtomIndex,subgraphs{i}.Nodes.AtomIndex(j));
            ATG.Nodes.MoietyIndex(bool) = subgraphs{i}.Nodes.MoietyIndex(j);
        end
    end
end

%extract the map from atoms to moiety
atoms2moiety = ATG.Nodes.MoietyIndex;

%matrix to map from moiety to atoms
M2A = sparse(atoms2moiety,(1:nAtoms)',1,nMoieties,nAtoms);

if sanityChecks
    for j=1:nMoieties
        fprintf('%s\n',moietyFormulae{moiety2isomorphismClass(j)})
        tabulate(ATG.Nodes.Element(M2A(j,:)~=0))
        moietyMetIndices=atoms2mets(M2A(j,:)~=0);
        
        if length(unique(moietyMetIndices))>1
            warning('single moiety incident in more than one metabolite')
        end
    end
end

% Map between moiety graph and metabolic network
%map metabolite to moieties
moieties2mets = atoms2mets(isFirst);

%matrix to map one or more moiety to each metabolite
M2M = sparse(moieties2mets,(1:nMoieties)', 1,nMets,nMoieties);

if sanityChecks
    [~,moieties2mets2] = ismember(MTG.Nodes.Met,model.mets(mbool));
    if ~all(moieties2mets == moieties2mets2)
        error('Mismatch of mapping moieties to metabolites')
    end
    
    M2M2 = zeros(nMets,nMoieties);
    for j=1:nMoieties
        M2M2(strcmp(model.mets,MTG.Nodes.Met{j}),j) = M2M2(strcmp(model.mets,MTG.Nodes.Met{j}),j) + 1;
    end 
    res = M2M - M2M2;
    if norm(res)~=0
        error('Mismatch of mapping moieties to metabolite')
    end

    M2M3 = zeros(nMets,nMoieties);
    for j=1:nMoieties
        atomInd = find(ATG.Nodes.MoietyIndex == j);
        for k = 1:length(atomInd)
            M2M3(strcmp(model.mets,ATG.Nodes.Met{atomInd(k)}),j) = M2M3(strcmp(model.mets,ATG.Nodes.Met{atomInd(k)}),j) + 1;
        end
    end
    %Normalise each column
    M2M3 = M2M3./sum(M2M3,1);
    
    res=M2M-M2M3;
    if norm(res)~=0
        error('Matrix mapping metabolites to moieties is incorrect')
    end
end

%map moiety transitions to reactions
%T2R = T2Ti*Ti2R;
M2R = T2R(isFirstTransition,:);

if 0
    %in general it is not possible to specify the mapping from moiety
    %transitions to reactions with a vector, because more than one moiety
    %transition can map to more than one reaction
    [~,moietyTransition2rxns]=ismember(MTG.Edges.Rxn,model.rxns(rbool));
    M2R2 = sparse((1:nMoietyTransitions)',moietyTransition2rxns,1,nMoietyTransitions,nMappedRxns);
    %therefore it is not expected that, in general, res will be empty
    res = M2R - M2R2;
    spy(res)
end

%Moiety graph decomposition
res = M2M*M2M'*N - M2M*M*M2R;
if max(max(abs(res)))~=0
    figure;spy(res) %checks the magnitudes of the coefficients is correct
    figure;spy(((M2M*M2M'*N)~=0) - ((M2M*M*M2R)~=0)) %checks the sparsity pattern is correct
    error('Moiety graph decomposition is incorrect')
end

% Map atom transitions to moiety transitions
atransInstance2mtrans = zeros(nTransInstances,1);

[mh,~] = find(M == -1); % head nodes in moiety graph
[mt,~] = find(M == 1); % tail nodes in moiety graph

%incidence matrix of the directed multigraph representing atom transition
%instances
A = incidence(dATM);
[ah,~] = find(A == -1); % head nodes
[at,~] = find(A == 1); % tail nodes

% An atom transition instance maps to a moiety transition if its head node maps to
% the head moiety, its tail node to the tail moiety, and its from the same
% reaction
for i = 1:length(mh)
    if i==1
        pause(0.1)
    end
    inHead = ismember(ah, find(atrans2isomorphismClass == mh(i)));
    inTail = ismember(at, find(atrans2isomorphismClass == mt(i)));
    inRxn = atransInstance2rxns == moietyTransition2rxns(i);
    atransInstance2mtrans((inHead & inTail) & inRxn) = i;
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
E = sparse((1 : q)', moietyTransition2rxns, ones(q, 1), q, n); % Matrix mapping moiety transitions to mapped reactions

% Remove reverse directions of bidirectional moiety transitions
F = speye(q, q);
isForward = true(q, 1);
for j = 1:n
    isSubstrate = ismember(moieties2mets, find(N(:,j) < 0));
    isReverse = (moietyTransition2rxns == j) & any(M(isSubstrate,:) > 0, 1)';
    isForward(isReverse) = false;
end
F = F(:, isForward);
M = M * F;
E = F' * E;
moietyTransition2rxns = moietyTransition2rxns(isForward);

%test the decomposition
res = V*V'*N - V*M*E;
if max(max(abs(res)))>0
    error('Moiety graph decomposition not exact')
end


%%%%%%%%%%% isomorphism classes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%map isomorphism class to moieties
I2M = sparse(MTG.Nodes.IsomorphismClass,(1:nMoieties)', 1,nIsomorphismClasses,nMoieties);

%map moiety transitions to isomorphism class
M2I = sparse((1:nMoietyTransitions)',MTG.Edges.IsomorphismClass, 1,nMoietyTransitions,nIsomorphismClasses);




%construct moiety matrix
L = sparse(nIsomorphismClasses,nMappedMets);
for i = 1:nIsomorphismClasses
    for j=1:nComps
        if I2C(i,j)==1
            subgraphMets=subgraphs{j}.Nodes.Atom;
            
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
                for k=1:size(subgraphMets,1)
                    %not all metabolites are involved in atom mapped
                    %reactions
                    metBool = strcmp(subgraphMets{k},model.mets(mbool));
                    L(i,metBool) = L(i,metBool) + 1;
                end
            catch ME
                disp(ME.message)
                k
                subgraphMets{k}
            end
            
            if sanityChecks
                moietyConservationTest = ones(1,size(N,1))*diag(L(i,:))*N;
                if any(moietyConservationTest~=0)
                    error('Moiety conservation violated.')
                end
            end
            
            break
        end
    end
end


if sanityChecks
    leftNullBool=(L*N)==0;
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
            if L(i,j)~=0
                formulae = {moietyFormulae{i};mappedMetFormulae{j}};
                [Ematrix, ~] = getElementalComposition(formulae);
                if any(Ematrix(1,:)> Ematrix(2,:))
                    warning(['Moiety ' int2str(i) ' formula is: '   moietyFormulae{i} ' but  metabolite ' mappedMets{j} ' formula is: ' mappedMetFormulae{j}])
                end
            end
        end
    end
    
end















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