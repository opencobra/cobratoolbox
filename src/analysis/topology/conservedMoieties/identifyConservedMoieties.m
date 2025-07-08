function [arm, moietyFormulae] = identifyConservedMoieties(model, dATM, options)
% [arm, moietyFormulae] = identifyConservedMoieties(model, dATM, options)
%
% Identifies conserved moieties in a metabolic network (model) by graph
% theoretical analysis of the corresponding directed atom transition network (dATM).
% Decomposes a stoichiometric matrix into a set of moiety transitions, that
% is
%       N = inv(M2M*M2M')*M2M*M*M2R;
%
% where
%       N   = model.S(arm.MRH.metAtomMappedBool,arm.MRH.rxnAtomMappedBool) = arm.MRH.S(arm.MRH.metAtomMappedBool,arm.MRH.rxnAtomMappedBool);
%       M2M = arm.M2M;
%       M   = incidence(arm.MTG);
%       M2R = arm.M2R;
%
% where M2M*M2M' is a diagonal matrix and each diagonal entry is the number
% of moieties in a metabolite.
%
%
% USAGE:
%
%    [arm, moietyFormulae] = identifyConservedMoieties(model, dATM, options)
%
% INPUTS:
%    model:        Structure with following fields:
%
%                    * .S - The `m x n` stoichiometric matrix for the metabolic network
%                    * .mets - An `m x 1` array of metabolite identifiers. Should match metabolite identifiers in rxnfiles.
%                    * .rxns - An `n x 1` array of reaction identifiers. Should match `rxnfile` names in `rxnFileDir`.
%
%    dATM:          Directed atom transition multigraph, obtained from buildAtomTransitionMultigraph.m
%                   A MATLAB digraph structure with the following tables and variables:
%
%                   * .Nodes — Table of node information, with `p` rows, one for each atom.
%                   * .Nodes.Atom - unique alphanumeric id for each atom by concatenation of the metabolite, atom and element
%                   * .Nodes.AtomIndex - unique numeric id for each atom in atom transition multigraph
%                   * .Nodes.mets - metabolite containing each atom
%                   * .Nodes.AtomNumber - unique numeric id for each atom in a metabolite
%                   * .Nodes.Element - atomic element of each atom
%                       
%                   * .Edges — Table of edge information, with `q` rows, one for each atom transition instance.
%                   * .Edges.EndNodes - two-column cell array of character vectors that defines the graph edges     
%                   * .Edges.Trans - unique alphanumeric id for each atom transition instance by concatenation of the reaction, head and tail atoms
%                   * .Edges.TransIndex - unique numeric id for each atom transition instance
%                   * .Edges.rxns - reaction abbreviation corresponding to each atom transition instance
%                   * .Edges.HeadAtomIndex - head Nodes.AtomIndex
%                   * .Edges.TailAtomIndex - tail Nodes.AtomIndex
%
% OPTIONAL INPUTS:
% options:       Structure with following fields:
%                * .sanityChecks {(0),1} true if additional sanity checks
%                on computations, but substantially more computation time
%
% OUTPUTS:
% arm            atomically resolved model as a matlab structure with the following fields:
%
% arm.MRH:                    Directed metabolic reaction hypergraph, i.e. standard COBRA model, with additional fields:
% arm.MRH.metAtomMappedBool:  `m x 1` boolean vector indicating atom mapped metabolites
% arm.MRH.rxnAtomMappedBool:  `n x 1` boolean vector indicating atom mapped reactions
% 
% arm.dATM:                   Directed atom transition multigraph (dATM) obtained from buildAtomTransitionMultigraph.m
% 
% arm.M2Ai:              `m` x `a` matrix mapping each mapped metabolite to one or more atoms in the directed atom transition multigraph
% arm.Ti2R:              `t` x `n` matrix mapping one or more directed atom transition instances to each mapped reaction
% arm.Ti2I               `t` x `i` matrix to map one or more directed atom transition instances to each isomorphism class
% 
% arm.ATG:  Atom transition graph, as a MATLAB graph structure with the following tables and variables:
%
%          * .Nodes — Table of node information, with `a` rows, one for each atom.
%          * .Nodes.Atom - unique alphanumeric id for each atom by concatenation of the metabolite, atom and element
%          * .Nodes.AtomIndex - unique numeric id for each atom in atom transition multigraph
%          * .Nodes.mets - metabolite containing each atom
%          * .Nodes.AtomNumber - unique numeric id for each atom in an atom mapping
%          * .Nodes.Element - atomic element of each atom
%          * .Nodes.MoietyIndex - numeric id of the corresponding moiety (arm.MTG.Nodes.MoietyIndex) 
%          * .Nodes.Component - numeric id of the corresponding connected component (rows of C2A)
%          * .Nodes.IsomorphismClass - numeric id of the corresponding isomprphism class (rows of I2C)
%          * .Nodes.IsCanonical - boolean, true if atom is within first component of an isomorphism class 
%
%          * .Edges — Table of edge information, with `u` rows, one for each atom transition instance.
%          * .Edges.EndNodes - numeric id of head and tail atoms that defines the graph edges  
%          * .Edges.Trans - unique alphanumeric id for each atom transition by concatenation of head and tail atoms
%          * .Edges.HeadAtomIndex - head Nodes.AtomIndex
%          * .Edges.TailAtomIndex - tail Nodes.AtomIndex
%          * .Edges.HeadAtom - head Nodes.Atom
%          * .Edges.TailAtom - tail Nodes.Atom
%          * .Edges.TransIndex - unique numeric id for each atom transition
%          * .Edges.Component - numeric id of the corresponding connected component (columns of T2C)
%          * .Edges.IsomorphismClass - numeric id of the corresponding isomprphism class (columns of T2I)
%          * .Edges.IsCanonical - boolean, true if atom transition is within first component of an isomorphism class 
%
% arm.M2A:  `m x a` matrix mapping each metabolite to one or more atoms in the (undirected) atom transition graph
% arm.A2R:  `u x n` matrix that maps atom transitions to reactions. An atom transition can map to multiple reactions and a reaction can map to multiple atom transitions
% arm.A2Ti: `u x t` matrix to map each atom transition (in ATG) to one or more directed atom transition instance (in dATM) with reorientation if necessary. 
% 
% arm.I2C  `i x c` matrix to map each isomorphism class (I) to one or more components (C) of the atom transition graph (ATG)
% arm.C2A  `c x a` matrix to map each connected component (C) of the atom transition graph to one or more atoms (A)
% arm.A2C  `u x c` matrix to map one or more atom transitions (T) to connected components (C) of the atom transition graph (ATG)
% 
% arm.I2A  `i x a` matrix to map each isomorphism class to one or more atoms of the atom transition graph (ATG)
% arm.A2I  `u x i` matrix to map one or more atom transitions to each isomorphism class
% 
% arm.MTG = MTG; % (undirected) moiety transition graph

% arm.MTG:  (undirected) moitey transition graph, as a MATLAB graph structure with the following tables and variables:
%
%          * .Nodes — Table of node information, with `p` rows, one for each moiety instance.
%          * .Nodes.MoietyIndex - unique numeric id of the moiety instance 
%          * .Nodes.Formula - chemical formula of the moiety (Hill notation)
%          * .Nodes.mets - abbreviation for the metabolite containing the moiety instance (arm.MRH.mets)
%          * .Nodes.Component - numeric id of the corresponding connected component (rows of C2M)
%          * .Nodes.IsomorphismClass - numeric id of the corresponding isomprphism class (rows of I2M)
%          * .Nodes.MonoisotopicMass - (Da) monoisotopic exact molecular mass the most abundant isotope of each element as specified by NIST http://physics.nist.gov/PhysRefData/Compositions/

%          * .Edges — Table of edge information, with `q` rows, one for each atom transition instance.
%          * .Edges.EndNodes - numeric id of head and tail moieties that defines the graph edges  
%          * .Edges.Formula - chemical formula of the moiety in this moiety transition (Hill notation)
%          * .Edges.rxns - the reaction from which this moiety transition was derived
%          * .Edges.Component - numeric id of the corresponding connected component (columns of M2C)
%          * .Edges.IsomorphismClass - numeric id of the corresponding isomprphism class (columns of M2I)
%          * .Edges.IsCanonical - boolean, true if moiety transition is within first component of an isomorphism class 
%          Note that M = incidence(arm.MTG); gives the p x q incidence matrix of the moitey transition graph
%
% arm.I2M  `i x p` matrix to map each isomorphism class to one or more moiety instances
% arm.M2I  `q x i`  to map one or more moiety transitions to each isomorphism class
%
% arm.M2M  `m x p` matrix to map each metabolite to one or more moiety instances
% arm.M2R  `q x n` matrix to map moiety transitions to reactions. Multiple moiety transitions can map to multiple reactions.
%
% arm.L Matrix to map isomorphism classes to metabolites. L = I2M*M2M'; Multiple isomorphism classes may map to multiple metabolites.
%
% Note: if options.sanityChecks = 1; the following are also returned
%
% arm.ATG.Edges.TransIstIndex - a numeric id the directed atom transition instance from which this atom transition was derived
% arm.ATG.Edges.orientationATM2dATM - orientation of edge with respect to the reaction from which this atom transition was derived
% arm.ATG.Edges.rxns - the reaction from which this atom transition was derived
%
% arm.MTG.Nodes.IsCanonical - boolean, true if moiety corresponds to the first component of an isomorphism class (should be all true)
% arm.MTG.Nodes.Atom - alphanumeric id of the corresponding atom in the first component of an isomorphism class 
% arm.MTG.Nodes.AtomIndex - numeric id of the corresponding atom in the first component of an isomorphism class
% arm.MTG.Edges.orientationATM2dATM - orientation of moiety transition with respect to the reaction from which this moiety transition was derived
%

% .. Authors: - Ronan M.T. Fleming, Oct 2020, compute conserved moieties
%               as described in Ghaderi et al. Decompose stoichiometic
%               matrix into its underlying moiety transition matrix
%               (unpublished).
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


%% Directed atom transition multigraph
rxnAtomMappedBool = ismember(model.rxns,dATM.Edges.rxns); % True for reactions included in dATM
metAtomMappedBool = ismember(model.mets,dATM.Nodes.mets); % True for reactions included in dATM

N = sparse(model.S(metAtomMappedBool,rxnAtomMappedBool)); % Stoichometric matrix of atom mapped reactions

[nMappedMets,nMappedRxns] = size(N);

nAtoms = size(dATM.Nodes,1);
nTransInstances = size(dATM.Edges,1);

if sanityChecks
    %double check that there is no reordering of edges
    diffIndex = diff(dATM.Nodes.AtomIndex);
    if any(diffIndex~=1)
        error('reordering of edges of moiety transition graph')
    end
end

if sanityChecks
    %double check that there is no reordering of edges
    diffIndex = diff(dATM.Edges.TransInstIndex);
    if any(diffIndex~=1)
        error('reordering of edges of moiety transition graph')
    end
end

%matrix to map each metabolite to one or more atoms
[~,atoms2mets] = ismember(dATM.Nodes.mets,model.mets(metAtomMappedBool));
M2Ai = sparse(atoms2mets,(1:nAtoms)',1,nMappedMets,nAtoms);

%matrix mapping one or more directed atom transition instances to each mapped reaction
[~,transInstance2rxns] = ismember(dATM.Edges.rxns,model.rxns(rxnAtomMappedBool));
Ti2R = sparse((1:nTransInstances)',transInstance2rxns,1,nTransInstances,nMappedRxns);


%incidence matrix of directed atom transition multigraph
Ti = incidence(dATM);

%decomposition of a stoichiometric matrix into a directed atom transition multigraph
res=M2Ai*M2Ai'*N - M2Ai*Ti*Ti2R;
if max(max(abs(res)))~=0
    error('Inconsistent directed atom transition multigraph')
end
        
% An atom transition that occurs in a reaction is an atom transition instance,
% and since identical atom transition instances can happen in a more than one
% reaction, we only need a representative atom transition.
% Convert the atom transition graph into matlab multigraph structure, retaining
% the name of the nodes and edges where they correspond to each
% pair of atoms involved in an atom transition, except in the instance that
% atom transition is duplicated (in either direction), in which case retain
% the node and edge labels corresponding to the first instance of that
% atom transition

%% Undirected atom transition multigraph

%convert to an undirected multigraph, but note that conversion from a 
%directed to undirected multigraph flips the orientation
%of some edges and changes the order of the edges
ATM = graph(dATM.Edges,dATM.Nodes);

% ATM.Edges.TransInstIndex provides an index to recover the original
% order of edges in dATM

%save the orientation of the atom transition in ATM with respect to dATM
orientationATM2dATM = zeros(nTransInstances,1);

forwardBool = all(ATM.Edges.EndNodes == dATM.Edges.EndNodes(ATM.Edges.TransInstIndex,:),2);
orientationATM2dATM(forwardBool)=1;

reverseBool = all(ATM.Edges.EndNodes == [dATM.Edges.EndNodes(ATM.Edges.TransInstIndex,2), dATM.Edges.EndNodes(ATM.Edges.TransInstIndex,1)],2);
orientationATM2dATM(reverseBool)=-1;

if sanityChecks
    if any(orientationATM2dATM==0)
        error('inconsistent aATM and ATM edge indexing')
    end
end
ATM.Edges.orientationATM2dATM = orientationATM2dATM;

%update the ATM Trans, HeadIndex, TailIndex, HeadAtom and TailAtom to match
%any reorientation of EndNodes
for i=1:nTransInstances
    if orientationATM2dATM(i)==1
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
        error('inconsistent dATM and ATM edge indexing')
    end
end

%% Atom transition graph
% [H,eind,ecount] = simplify(G)
% returns a graph without multiple edges or self-loops and
% returns edge indices eind and edge counts ecount:
% H.Edges(eind(i),:) is the edge in H that represents edge i in G.
% ecount(j) is the number of edges in G that correspond to edge j in H.
[ATG,eind,~] = simplify(ATM);
A = incidence(ATG);
nAtoms = size(ATG.Nodes,1);
nTrans = size(ATG.Edges,1);

%find the edges of ATG that correspond exactly to the edge in dATM
% LIA = ismember(A,B,'rows') for matrices A and B with the same number
% of columns, returns a vector containing true where the rows of A are
% also rows of B and false otherwise.
isTrans = ismember(ATM.Edges.TransInstIndex,ATG.Edges.TransInstIndex);

if sanityChecks
    if nnz(isTrans)~=nTrans
        error('number of atom transitions are inconsistent')
    end    
end

if sanityChecks
    %checks that the indices of ATG match the subset of ATM
    bool = ATM.Edges.TransInstIndex(isTrans) == ATG.Edges.TransInstIndex;
    if ~all(bool)
        error('inconsistent ATG -> ATM edge indexing')
    end
end

%orientation of each atom transition in ATG with respect to ATM
orientationATG2ATM = zeros(nTrans,1);

forwardBool = all(ATG.Edges.EndNodes == ATM.Edges.EndNodes(isTrans,:),2);
orientationATG2ATM(forwardBool)=1;

reverseBool = all(ATG.Edges.EndNodes == ...
    [ATM.Edges.EndNodes(isTrans,2), ATM.Edges.EndNodes(isTrans,1)],2);

orientationATG2ATM(reverseBool)=-1;

if any(reverseBool)
    warning('[ATG,eind,ecount] = simplify(ATM); has reoriented some edges')
end

if sanityChecks
    if any(orientationATG2ATM==0)
        error('inconsistent ATG -> ATM edge indexing')
    end
end

%save the orientation of the atom transition in ATG with respect to subset of dATM
orientationATG2dATM = zeros(nTrans,1);

forwardBool = all(ATG.Edges.EndNodes == dATM.Edges.EndNodes(ATG.Edges.TransInstIndex,:),2);
orientationATG2dATM(forwardBool)=1;

reverseBool = all(ATG.Edges.EndNodes == [dATM.Edges.EndNodes(ATG.Edges.TransInstIndex,2),dATM.Edges.EndNodes(ATG.Edges.TransInstIndex,1)],2);

orientationATG2dATM(reverseBool)=-1;

if sanityChecks
    if any(orientationATG2dATM==0)
        error('inconsistent ATG and dATM edge indexing')
    end
end
ATG.Edges.orientationATG2dATM = orientationATG2dATM;

%update the ATG Trans, HeadIndex, TailIndex, HeadAtom and TailAtom to match
%any reorientation of EndNodes
for i=1:nTrans
    if orientationATG2dATM(i)==-1
        ATG.Edges.HeadAtomIndex(i) = ATG.Edges.EndNodes(i,2);
        ATG.Edges.TailAtomIndex(i) = ATG.Edges.EndNodes(i,1);
        HeadAtom = ATG.Edges.TailAtom{i};
        TailAtom = ATG.Edges.HeadAtom{i};
        ATG.Edges.HeadAtom{i} = HeadAtom;
        ATG.Edges.TailAtom{i} = TailAtom;
        ATG.Edges.Trans{i} = [HeadAtom '#' TailAtom];
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
        error('inconsistent dATM and ATM edge indexing')
    end
end

%create an index for each atom transition in the atom transition graph
transIndex = (1:nTrans)';
if 1
    ATG.Edges.TransIndex=transIndex;
    %ATG.Edges = movevars(ATG.Edges,'TransIndex','After','Trans');
else
    ATG.Edges = addvars(ATG.Edges,transIndex,'NewVariableNames','TransIndex','After','Trans');
end

%% mapping of ATG to metabolic network
%map atoms to metabolites
[~, atoms2mets] = ismember(ATG.Nodes.mets,model.mets(metAtomMappedBool));
M2A =  sparse(atoms2mets,(1:nAtoms)',1,nMappedMets,nAtoms);
    
if sanityChecks
    res = M2Ai-M2A;
    if max(max(abs(res)))~=0
        error('Inconsistent mapping of atoms to metabolites')
    end

    bool = strcmp(ATG.Nodes.mets,dATM.Nodes.mets);
    if ~all(bool)
         error('inconsistent dATM and ATM node indexing')
    end
end

%map one or more atom transition instances to each atom transition
transInstanceIndex2transIndex(ATM.Edges.TransInstIndex) = transIndex(eind);
transInstanceIndex2transIndex = transInstanceIndex2transIndex';

%orientation of one or more atom transition instance with respect to each
%atom transition
dATMreorientationATG=ones(nTransInstances,1); %assume orientation unchanged initially
dATMreorientationATG(ATM.Edges.TransInstIndex)=orientationATM2dATM; % reorientation dATM > ATM
dATMreorientationATG(ATG.Edges.TransInstIndex)=dATMreorientationATG(ATG.Edges.TransInstIndex).*orientationATG2ATM; % reorientation ATM > ATG

%matrix to map each atom transition to one or more atom transition instance with reorientation if necessary 
A2Ti = sparse(transInstanceIndex2transIndex,(1:nTransInstances)',dATMreorientationATG,nTrans,nTransInstances);

if sanityChecks
    for i=1:nTrans
        transHeadAtom = ATG.Edges.HeadAtom{i};
        transTailAtom = ATG.Edges.TailAtom{i};
        bool = strcmp(transHeadAtom,dATM.Edges.HeadAtom{A2Ti(i,:)~=0}) & strcmp(transTailAtom,dATM.Edges.TailAtom{A2Ti(i,:)~=0});
        if ~all(bool)
            ind=find(bool);
            fprintf('%s%s%s%s\n','Trans: ',ATG.Edges.Trans{i},' TransInst: ',dATM.Edges.Trans{ind(1)})
            error('Inconsistent mapping of atom transition instances to each atom transition in A2Ti')
        end
    end
end

% matrix that maps atom transitions to reactions.
% an atom transition can map to multiple reactions
% a reaction can map to multiple atom transitions
% matrix mapping each atom transition to mapped reactions
A2R = A2Ti*Ti2R;

if sanityChecks
    A2R2 = sparse(nTrans,nMappedRxns);
    for i=1:nTransInstances
        rxnIndex = transInstance2rxns(i);
        transIndex = transInstanceIndex2transIndex(i);
        orientation = dATMreorientationATG(i);
        A2R2(transIndex,rxnIndex) = orientation;
    end
    
   
    res = (A2R~=0) - (A2R2~=0);
    if max(max(abs(res)))~=0
        figure;spy([A2R,A2R2])
        figure;spy(A2R - A2R2)
        figure;spy(A2R~=0 - A2R2~=0)
        error('Inconsistent mapping from atom transition to reaction')
    end
    
     if 0    
        tic
        A2R3 = sparse(nTrans,nMappedRxns);
        for j=1:nMappedRxns
            A2R3(transInstanceIndex2transIndex(transInstance2rxns==j),j)=dATMreorientationATG(transInstance2rxns==j);
        end
        toc
        
        res = (A2R~=0) - (A2R3~=0);
        if max(max(abs(res)))~=0
            figure;spy([A2R,A2R3])
            figure;spy(A2R - A2R3)
            figure;spy(A2R~=0 - A2R3~=0)
            error('Inconsistent mapping from atom transition to reaction')
        end
    end
end

%decomposition of a stoichiometric matrix into an atom transition graph
res=M2A*M2A'*N - M2A*A*A2R;
if max(max(abs(res)))~=0
    error('Inconsistent directed atom transition graph')
end

%% connected components

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
% try
     [rankN, ~, ~] = getRankLUSOL(N, 0);
% catch ME
%     warning(ME.message)
%     fprintf('%s\n','Caught the error and proceeding with rank(full(N)) instead.')
%     rankN = rank(full(N));
% end
rowRankDeficiencyN = size(N,1) - rankN;

%map isomorphism classes to components of atom transition graph
%rowRankDeficiencyN is an estimate
I2C = sparse(rowRankDeficiencyN,nComps);

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

firstSubgraphIndices = zeros(rowRankDeficiencyN,1); %index of first subgraph in each isomorphism class
subsequentSubgraphIndices = zeros(nComps,1); %indices of subgraphs identical to first in each isomorphism class
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
                        if isisomorphic(subgraphs{i,1},subgraphs{j,1},'NodeVariables','mets')
                            I2C(isomorphismClassNumber,j)=1;
                            excludedSubgraphs(j)=1;
                            subsequentSubgraphIndices(j)=isomorphismClassNumber;
                            
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
                    firstSubgraphIndices(isomorphismClassNumber) = j;
                    subsequentSubgraphIndices(j)=isomorphismClassNumber;
                    
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
firstSubgraphIndices   = firstSubgraphIndices(bool);

%define the actual number of isomorphism classes
nIsomorphismClasses = size(I2C,1);

%map ATG to connected component and isomorphism class
ATG.Nodes = addvars(ATG.Nodes,atoms2component,'NewVariableNames','Component');
ATG.Nodes = addvars(ATG.Nodes,atoms2isomorphismClass,'NewVariableNames','IsomorphismClass');
if 0
    Edges = ATG.Edges;
    Edges = removevars(Edges,'orientationATG2dATM');
    Edges = addvars(Edges,ATG.Nodes.Component(Edges.HeadAtomIndex),'NewVariableNames','Component');
    Edges = addvars(Edges,ATG.Nodes.IsomorphismClass(Edges.HeadAtomIndex),'NewVariableNames','IsomorphismClass');
    ATG = graph(Edges,ATG.Nodes);
else
    ATG.Edges.Component = ATG.Nodes.Component(ATG.Edges.HeadAtomIndex);
    ATG.Edges.IsomorphismClass = ATG.Nodes.IsomorphismClass(ATG.Edges.HeadAtomIndex);
end

%% relationship between atom transition graph  and  connected components

%matrix to map connected component to atoms
C2A = sparse(atoms2component,(1:nAtoms)',1,nComps,nAtoms);

%matrix to map one or more atom transitions to connected components
A2C = sparse((1:nTrans)',atrans2component,1,nTrans,nComps);

if sanityChecks
    %C2A is a non-negative left nullspace for A
    resL = C2A*A;
    if max(max(abs(resL)))~=0
        error('Inconsistent mapping of isomorphism class to atoms')
    end
    
    %C2A(i,:) and C2I(:,i) identify the same subgraph of the atom
    %transition graph
    for i=1:nComps
        res = diag(C2A(i,:))*A - A*diag(A2C(:,i));
        if max(max(abs(res)))~=0
            error('Inconsistent mapping of isomorphism class to atom transitions')
        end
    end
    %TODO not sure how to interpret this
    %resR = full(A*A2I);
end

%% relationship between atom transition graph and isomorphism classes 

%matrix to map each isomorphism class to one or more atoms
I2A = I2C*C2A;

if sanityChecks
    res = I2A - sparse(atoms2isomorphismClass,(1:nAtoms)',1,nIsomorphismClasses,nAtoms);
    if any(res,'all')
        error('matrix to map isomorphism classes to atom instances inconsistent')
    end
end

%matrix to map one or more atom transitions to each isomorphism class
A2I = sparse((1:nTrans)',atrans2isomorphismClass,1,nTrans,nIsomorphismClasses);

%Ti2I = sparse(nTransInstances,nIsomorphismClasses);
%matrix to map one or more directed atom transition instances to each isomorphism class
Ti2I = A2I(transInstanceIndex2transIndex,:);

if sanityChecks
    %I2A is a non-negative left nullspace basis for A
    resL = I2A*A;
    if max(max(abs(resL)))~=0
        error('Inconsistent mapping of isomorphism class to atoms')
    end
    
    %I2A(i,:) and A2I(:,i) identify the same set of isomorphic subgraphs of the atom
    %transition graph. Isomorphism preserves metabolite labels.
    for i=1:nIsomorphismClasses
        res = diag(I2A(i,:))*A - A*diag(A2I(:,i));
        if max(max(abs(res)))~=0
            error('Inconsistent mapping of isomorphism class to atom transitions')
        end
    end
    %TODO not sure how to interpret this
    %resR = full(A*A2I);
end

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



%% Moiety transition graph
%create the moiety transition graph explicitly as a
%subgraph of the atom transition graph
[isCanonical, moiety2isomorphismClass] = ismember(atoms2component,firstSubgraphIndices);
moiety2isomorphismClass = moiety2isomorphismClass(isCanonical);

if sanityChecks
    moiety2isomorphismClass2 = atoms2isomorphismClass(isCanonical);
    if any(moiety2isomorphismClass~=moiety2isomorphismClass2)
        error('Inconsistent moiety2isomorphismClass vector')
    end
end
    
ATG.Nodes = addvars(ATG.Nodes,isCanonical,'NewVariableNames','IsCanonical');
%size of the moiety instance transition graph
nMoieties=nnz(isCanonical);
isCanonicalTransition = any(A(isCanonical, :), 1)';
nMoietyTransitions = nnz(isCanonicalTransition);

if 0
    ATG.Edges = addvars(ATG.Edges,isCanonicalTransition,'NewVariableNames','IsCanonical');
else
    ATG.Edges.IsCanonical = isCanonicalTransition;
end

%draft moiety transition graph, before editing node and
%edge information
MTG = subgraph(ATG,isCanonical);
M = incidence(MTG);

MTG.Nodes.MoietyIndex = (1:nMoieties)';
MTG.Edges.MoietyTransIndex = (1:nMoietyTransitions)';

if sanityChecks
    %double check that there is no reordering of edges
    diffTransIndex = diff(MTG.Edges.TransIndex);
    if any(diffTransIndex<1)
        error('reordering of edges of moiety transition graph')
    end
end

%add moiety specific information
MTG.Nodes = removevars(MTG.Nodes,{'AtomNumber','Element','IsCanonical','Atom','AtomIndex'});
MTG.Nodes = addvars(MTG.Nodes,moietyFormulae(moiety2isomorphismClass),'NewVariableNames','Formula','After','MoietyIndex');

%          * .Edges.HeadAtom - head Nodes.Atom
%          * .Edges.TailAtom - tail Nodes.Atom
%          * .Edges.HeadAtomIndex - head Nodes.AtomIndex
%          * .Edges.TailAtomIndex - tail Nodes.AtomIndex
%          * .Edges.Trans - unique alphanumeric id for each atom transition by concatenation of head and tail atoms
%          * .Edges.TransIndex - unique numeric id for each atom transition
%          * .Edges.TransIstIndex - a numeric id the directed atom transition instance from which this atom transition was derived

if ~sanityChecks
    if 1
        %graph.Edges cannot be directly edited in a graph object, so extract,
        %edit and regenerate the graph
        %Edges = removevars(MTG.Edges,{'Trans','TransIndex','TransInstIndex','OrigTransInstIndex','HeadAtomIndex','TailAtomIndex','HeadAtom','TailAtom','orientationATM2dATM','IsCanonical','rxns'});
        Edges = removevars(MTG.Edges,{'Trans','TransIndex','TransInstIndex','dirTransInstIndex','HeadAtomIndex','TailAtomIndex','HeadAtom','TailAtom','orientationATM2dATM','IsCanonical','rxns'});%Hadjar Rahou
        %add variables
        Edges = addvars(Edges,MTG.Nodes.Formula(Edges.EndNodes(:,1)),'NewVariableNames','Formula');
        %reorder the variables 
        Nodes = MTG.Nodes(:,{'MoietyIndex','Formula','mets','Component','IsomorphismClass'}); 
        Edges = Edges(:,{'EndNodes','Formula','Component','IsomorphismClass','MoietyTransIndex'}); 
        MTG = graph(Edges,Nodes);
    else
        MTG.Edges.Formula=MTG.Nodes.Formula(MTG.Edges.EndNodes(:,1));
    end
end

%add the masses of the moieties
% Gets monoisotopic exact molecular mass for a single formula or a cell array of
% formulae using the relative atomic mass of the most abundant isotope of each element
% as specified by NIST http://physics.nist.gov/PhysRefData/Compositions/
[MTG.Nodes.MonoisotopicMass, knownMasses, unknownElements, Ematrix, elements] = getMolecularMass(MTG.Nodes.Formula);

if sanityChecks
    diffMoietyIndex = diff(MTG.Nodes.MoietyIndex);
    if ~all(diffMoietyIndex==1)
        error('Reordering of MTG nodes')
    end
    
    diffMoietyIndex = diff(MTG.Edges.MoietyTransIndex);
    if ~all(diffMoietyIndex==1)
        error('Reordering of MTG edges')
    end
end


if sanityChecks
    % Extract moiety graph directly from atom transition
    % graph incidence matrix
    [isFirstAlso, ~] = ismember(atoms2component,firstSubgraphIndices);
    if ~all(isCanonical == isFirstAlso)
        error('moiety incidence matrix does not match first component')
    end
    A = incidence(ATG);
    isFirstTransitionAlso = any(A(isFirstAlso, :), 1);
    M2 = A(isFirstAlso, isFirstTransitionAlso);
    
    [mh,~] = find(M2 == -1); % head node indices
    [mt,~] = find(M2 == 1); % tail node indices
    MTG2=graph(mh,mt);
    if ~isisomorphic(MTG,MTG2)
        error('Moiety transition graphs not isomorphic')
    end
    if 1
        M = incidence(MTG);
        res=M2-M;
        if max(max(abs(res)))~=0
            [indi,indj]=find(res);
            full(M2(indi,indj))
            full(M(indi,indj))
            error('Moiety transition graph incidence matrices are inconsistent')
        end
    end
end

%add the moiety indices for the first atoms in each moiety
moietyInd=1;
for i=1:nAtoms
    if ATG.Nodes.IsCanonical(i)
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
    MoietyIndices = subgraphs{firstSubgraphIndices(i)}.Nodes.MoietyIndex;
    for j=1:nComps
        if I2C(i,j)==1 && j~=firstSubgraphIndices(i)
            subgraphs{j}.Nodes.MoietyIndex=MoietyIndices;
        end
    end
end

%compile the moiety indices from the nodes in the subgraph into the
%atom transition graph
for i = 1:nComps
    if ~any(i==firstSubgraphIndices)
        for j=1:size(subgraphs{i}.Nodes,1)
            bool = ismember(ATG.Nodes.AtomIndex,subgraphs{i}.Nodes.AtomIndex(j));
            ATG.Nodes.MoietyIndex(bool) = subgraphs{i}.Nodes.MoietyIndex(j);
        end
    end
end

%extract the map from atoms to moiety
atoms2moiety = ATG.Nodes.MoietyIndex;

%matrix to map from moiety to atoms
Mo2A = sparse(atoms2moiety,(1:nAtoms)',1,nMoieties,nAtoms);

if sanityChecks
    for j=1:nMoieties
        if 0
            fprintf('%s\n',moietyFormulae{moiety2isomorphismClass(j)})
            tabulate(ATG.Nodes.Element(Mo2A(j,:)~=0))
        end
        moietyMetIndices=atoms2mets(Mo2A(j,:)~=0);
        
        if length(unique(moietyMetIndices))>1
            warning('single moiety incident in more than one metabolite')
        end
    end
end

%% Map between moiety graph and metabolic network
%map metabolite to moieties
moieties2mets = atoms2mets(isCanonical);

%matrix to map each metabolite to one or more moieties
M2M = sparse(moieties2mets,(1:nMoieties)', 1,nMappedMets,nMoieties);

if sanityChecks
    [~,moieties2mets2] = ismember(MTG.Nodes.mets,model.mets(metAtomMappedBool));
    if ~all(moieties2mets == moieties2mets2)
        error('Mismatch of mapping moieties to metabolites')
    end
    
    M2M2 = zeros(nMappedMets,nMoieties);
    for j=1:nMoieties
        M2M2(strcmp(model.mets(metAtomMappedBool),MTG.Nodes.mets{j}),j) = M2M2(strcmp(model.mets(metAtomMappedBool),MTG.Nodes.mets{j}),j) + 1;
    end 
    res = M2M - M2M2;
    if norm(res)~=0
        error('Mismatch of mapping moieties to metabolite')
    end

    M2M3 = zeros(nMappedMets,nMoieties);
    for j=1:nMoieties
        atomInd = find(ATG.Nodes.MoietyIndex == j);
        for k = 1:length(atomInd)
            M2M3(strcmp(model.mets(metAtomMappedBool),ATG.Nodes.mets{atomInd(k)}),j) = M2M3(strcmp(model.mets(metAtomMappedBool),ATG.Nodes.mets{atomInd(k)}),j) + 1;
        end
    end
    %Normalise each column
    M2M3 = M2M3./sum(M2M3,1);
    
    res=M2M-M2M3;
    if norm(res)~=0
        error('Matrix mapping metabolites to moieties is incorrect')
    end
end

%matrix to map moiety transitions to reactions. Multiple moiety
%transitions can map to multiple reactions.
%A2R = A2Ti*Ti2R;
M2R = A2R(isCanonicalTransition,:);

if 0
    %in general it is not possible to specify the mapping from moiety
    %transitions to reactions with a vector, because more than one moiety
    %transition can map to more than one reaction
    [~,moietyTransition2rxns]=ismember(MTG.Edges.rxns,model.rxns(rxnAtomMappedBool));
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

%% relationship between moiety transition graph and isomorphism classes 

%matrix to map each isomorphism class to one or more moieties
I2M = sparse(MTG.Nodes.IsomorphismClass,(1:nMoieties)', 1,nIsomorphismClasses,nMoieties);

%matrix to map one or more moiety transitions to each isomorphism class
M2I = sparse((1:nMoietyTransitions)',MTG.Edges.IsomorphismClass, 1,nMoietyTransitions,nIsomorphismClasses);

if sanityChecks
    %Matrix to map each isomorphism class to one or more moieties
    I2M2 = sparse(moiety2isomorphismClass,(1:nMoieties)',1,nIsomorphismClasses,nMoieties);
    
    res = I2M - I2M2;
    if max(max(abs(res)))~=0
        error('Inconsistent mapping of isomorphism class to moieties')
    end

    %I2M is a non-negative left nullspace basis for M
    resL = I2M*M;
    if max(max(abs(resL)))~=0
        error('Inconsistent mapping of isomorphism class to moieties')
    end
    
    %I2M(i,:) and M2I(:,i) identify the same subgraph of the moiety
    %transition graph
    for i=1:nIsomorphismClasses
        res = diag(I2M(i,:))*M - M*diag(M2I(:,i));
        if max(max(abs(res)))~=0
            error('Inconsistent mapping of isomorphism class to moieties')
        end
    end
    %TODO not sure how to interpret this
    %resR = full(M*M2I);
end

%matrix to map isomorphism classes to metabolites. Multiple isomorphism
%classes can map to multiple metabolites.

% I2M Matrix to map each isomorphism class to one or more moieties
% M2M Matrix to map each metabolite to one or more moieties
L = I2M*M2M';

leftNullBool=(L*N)==0;
if any(~leftNullBool,'all')
    error('Moiety basis vectors not in the in the left null space of N.');
end

if sanityChecks
    L2 = sparse(nIsomorphismClasses,nMappedMets);
    for i = 1:nIsomorphismClasses
        for j=1:nComps
            if I2C(i,j)==1
                subgraphMets=subgraphs{j}.Nodes.mets;
                
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
                        metBool = strcmp(subgraphMets{k},model.mets(metAtomMappedBool));
                        L2(i,metBool) = L2(i,metBool) + 1;
                    end
                catch ME
                    disp(ME.message)
                    disp(k)
                    disp(subgraphMets{k})
                end
                break
            end
        end
    end
    
    
    
    for i=1:nIsomorphismClasses
        moietyConservationTest = ones(1,size(N,1))*diag(L(i,:))*N;
        if any(moietyConservationTest~=0)
            error('Moiety conservation violated.')
        end
    end
    
    res = L - L2;
    if max(max(abs(res)))~=0
        error('Inconsistent moiety basis')
    end
end

if sanityChecks
    %allBiologicalElements={'C','O','P','N','S','H','Mg','Na','K','Cl','Ca','Zn','Fe','Cu','Mo','I'};
    %compare number of atoms of each element in moiety with
    %metabolites
    mappedMets = model.mets(metAtomMappedBool);
    mappedMetFormulae = model.metFormulas(metAtomMappedBool);
    
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

if 0
    d = diag(M2M*M2M');
    
    res = M2M'*diag(1./d)*M2M;
    if max(max(abs(res)))~=0
        disp('M2M''*inv(M2M*M2M'')*M2M ~=0')
    end
    
    res = I2M*M2M'*diag(1./d)*M2M*M*M2R;
    if max(max(abs(res)))~=0
        disp(['|I2M*M2M''*inv(M2M*M2M'')*M2M*M*M2R| = ' num2str(max(max(abs(res))))])
    end
end

if 0 %TODO not sure what to make of this
    %map reactions to isomorphism classes
    % I2M Matrix to map each isomorphism class to one or more moieties
    % M2M Matrix to map each metabolite to one or more moieties
    % L = I2M*M2M';
    
    % M2I Matrix to map one or more moieties to each isomorphism class 
    % M2R Matrix to map moiety transitions to reactions
    % R = M2R'*M2I;
    
    % Matrix to map reactions to isomorphism classes; Multiple isomorphism classes can map to multiple metabolites.
    R = M2R'*M2I;
    R = diag([1,1,1,-1])*R;
    res = full(N*R)
    
    R2 = A2R'*A2I;
    
    R3 = Ti2R'*Ti2I;
%     if 0
%         
%     else
%         
%         R = Ti2R'*Ti2I;
%         R2 = A2R'*A2I;
%         res = R - R2;
%         if max(max(abs(res)))~=0
%             spy(res)
%         end
%     end
    
    rightNullBool=(N*R)==0;
    if any(~rightNullBool,'all') && 0 
        error('Right Moiety basis vectors not in the in the right null space of N.');
    end
    
    for i = 1:nIsomorphismClasses
        moietyConservationTestR = ones(1,size(N,1))*N*diag(R(:,i));
        if any(moietyConservationTestR~=0)
            error('Moiety conservation violated.')
        end
    end
end

%clean up 
if ~sanityChecks
    % graph.Edges cannot be directly edited in a graph object, so extract, edit and regenerate the graph
    % arm.ATG.Edges.TransInstIndex - a numeric id the directed atom transition instance from which this atom transition was derived
    % arm.ATG.Edges.orientationATM2dATM - orientation of edge with respect to the reaction from which this atom transition was derived
    % arm.ATG.Edges.rxns - the reaction from which this atom transition was derived
    
    %ATG = graph(removevars(ATG.Edges,{'OrigTransInstIndex','TransInstIndex','orientationATM2dATM','rxns'}),ATG.Nodes);
    ATG = graph(removevars(ATG.Edges,{'dirTransInstIndex','TransInstIndex','orientationATM2dATM','rxns'}),ATG.Nodes);%Hadjar Rahou
end

%for i=1:6 Mk = diag(arm.I2M(i,:))*M; Nk = arm.M2M*Mk*arm.M2R;Nk2=diag(arm.L(i,:))*N; disp(norm(Nk-Nk2)); end

%collect outputs
model.metAtomMappedBool = metAtomMappedBool;
model.rxnAtomMappedBool = rxnAtomMappedBool;
arm.MRH = model; %directed metabolic reaction hypergraph (i.e. standard COBRA model)

arm.dATM = dATM; %directed atom transition multigraph (dATM)

arm.M2Ai = M2Ai; %matrix mapping each metabolite to one or more atoms in the directed atom transition multigraph
arm.Ti2R = Ti2R; %matrix mapping one or more directed atom transition instances to each mapped reaction
arm.Ti2I = Ti2I; % matrix to map one or more directed atom transition instances to each isomorphism class

arm.ATG  = ATG; %(undirected) atom transition graph
arm.M2A  = M2A; %matrix mapping each metabolite to one or more atoms in the (undirected) atom transition graph
arm.A2R  = A2R; %matrix that maps atom transitions to reactions. An atom transition can map to multiple reactions and a reaction can map to multiple atom transitions
arm.A2Ti = A2Ti;%matrix to map each atom transition (in ATG) to one or more directed atom transition instance (in dATM) with reorientation if necessary. 

arm.I2A = I2A;  %matrix to map each isomorphism class (I) to one or more atoms (A) of the atom transition graph (ATG)
arm.A2I = A2I;  %matrix to map one or more atom transitions (A) of the atom transition graph (ATG) to each isomorphism class (I)

arm.I2C = I2C; %matrix to map each isomorphism class (I) to one or more components (C) of the atom transition graph (ATG)

arm.C2A = C2A;   % matrix to map each connected component (C) to one or more atoms (A) of the atom transition graph (ATG)
arm.A2C = A2C;   % matrix to map one or more atom transitions (T) to connected components (C)  of the atom transition graph (ATG)

arm.MTG = MTG; % (undirected) moitey transition graph

arm.I2M = I2M; % Matrix to map each isomorphism class to one or more moieties
arm.M2I = M2I; % Matrix to map one or more moiety transitions to each isomorphism class

arm.M2M = M2M; % Matrix to map each metabolite to one or more moieties
arm.M2R = M2R; % Matrix to map moiety transitions to reactions. Multiple moiety transitions can map to multiple reactions.

arm.L =  L;    % Matrix to map isomorphism classes to metabolites. L = I2M*M2M'; Multiple isomorphism classes can map to multiple metabolites.
