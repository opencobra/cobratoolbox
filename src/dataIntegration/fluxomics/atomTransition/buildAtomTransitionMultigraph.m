function ATM = buildAtomTransitionMultigraph(model, rxnfileDir, options)
% Builds a matlab digraph object representing an atom transition multigraph
% corresponding to a metabolic network from reaction stoichiometry and atom
% mappings.
%
% The multigraph nature is due to possible duplicate atom transitions,
% where the same pair of atoms are involved in the same atom transition in
% different reactions.
%
% The directed nature is due to possible duplicate atom transitions, where
% the same pair of atoms are involved in atom transitions of opposite
% orientation, corresponding to reactions in different directions.
%
% Note that A = incidence(ATM) returns a  `p` x `q` atom transition 
% directed multigraph incidence matrix where `p` is the number of atoms and 
% `q` is the number of atom transitions

% USAGE:
%
%    ATN = buildAtomTransitionNetwork(model, rxnfileDir, options)
%
% INPUTS:
%    model:         Structure with following fields:
%
%                     * .S - The `m` x `n` stoichiometric matrix for the metabolic network
%                     * .mets - An `m` x 1 array of metabolite identifiers. Should match
%                       metabolite identifiers in `rxnfiles`.
%                     * .rxns - An `n` x 1 array of reaction identifiers. Should match
%                       rxnfile names in `rxnFileDir`.
%                     * .lb -  An `n` x 1 vector of lower bounds on fluxes.
%                     * .ub - An `n` x 1 vector of upper bounds on fluxes.
%    rxnfileDir:    Path to directory containing `rxnfiles` with atom mappings
%                   for internal reactions in `S`. File names should
%                   correspond to reaction identifiers in input `rxns`.
%
% OUTPUT:
%    ATM:           Matlab digraph structure with the following tables:
%
%                   * .NodeTable — Table of node information, with `p` rows, one for each atom.
%                   * .NodeTable.Atom - unique alphanumeric id for each atom by concatenation of the metabolite, atom and element
%                   * .NodeTable.AtomIndex - unique numeric id for each atom in
%                                 atom transition multigraph
%                   * .NodeTable.Met - metabolite containing each atom
%                   * .NodeTable.AtomNumber - unique numeric id for each atom in an 
%                                             atom mapping
%                   * .NodeTable.Element - atomic element of each atom
%                       
%                   * .EdgeTable — Table of edge information, with `q` rows, one for each atom transition instance.
%                   * .EdgeTable.EndNodes - two-column cell array of character vectors that defines the graph edges     
%                   * .EdgeTable.Trans - unique alphanumeric id for each atom transition instance by concatenation of the reaction, head and tail atoms
%                   * .EdgeTable.AransIndex - unique numeric id for each atom transition instance
%                   * .EdgeTable.Rxn - reaction corresponding to each atom transition
%                   * .EdgeTable.HeadAtomIndex - head NodeTable.AtomIndex
%                   * .EdgeTable.TailAtomIndex - tail NodeTable.AtomIndex
%


% .. Authors: - Hulda S. Haraldsdóttir and Ronan M. T. Fleming, June 2015
%               Ronan M. T. Fleming, 2020 revision.

if ~exist('options','var')
    options=[];
end

if ~isfield(options,'directed')
    options.directed=0;
end

if ~isfield(options,'sanityChecks')
    options.sanityChecks=0;
end

S = model.S; % Format inputs
mets = model.mets;
rxns = model.rxns;
lb = model.lb;
ub = model.ub;
clear model

rxnfileDir = [regexprep(rxnfileDir,'(/|\\)$',''), filesep]; % Make sure input path ends with directory separator

% Get list of atom mapped reactions
d = dir(rxnfileDir);
d = d(~[d.isdir]);
aRxns = {d.name}';
aRxns = aRxns(~cellfun('isempty',regexp(aRxns,'(\.rxn)$')));
aRxns = regexprep(aRxns,'(\.rxn)$',''); % Identifiers for atom mapped reactions
assert(~isempty(aRxns), 'Rxnfile directory is empty or nonexistent.');

if any(strcmp(aRxns,'3AIBtm (Case Conflict)'))
    aRxns{strcmp(aRxns,'3AIBtm (Case Conflict)')} = '3AIBTm'; % Debug: Ubuntu file manager "Files" renames file '3AIBTm.rxn' if the file '3AIBtm.rxn' is located in the same directory (issue for Recon 2)
end

% Extract atom mapped reactions
rbool = (ismember(rxns,aRxns)); % True for atom mapped reactions

assert(any(rbool), 'No atom mappings found for model reactions.\nCheck that rxnfile names match reaction identifiers in rxns.');
fprintf('\nAtom mappings found for %d model reactions.\n', sum(rbool));
fprintf('Generating atom transition network for reactions with atom mappings.\n\n');

mbool = any(S(:,rbool),2); % True for metabolites in atom mapped reactions

S = S(mbool,rbool);
mets = mets(mbool);
rxns = rxns(rbool);
lb = lb(rbool);
ub = ub(rbool);

% Initialize fields of output structure
A = sparse([]);
tMets = {};
tMetNrs = [];
tRxns = {};
elements = {};

% Build atom transition network
for i = 1:length(rxns)
    
    rxn = rxns{i};
    if options.directed
        rev = (lb(i) < 0 & ub(i) > 0); % True if rxn is reversible
    else
        rev = 0;
    end
    
    % Read atom mapping from rxnfile
    [atomMets,metEls,metNrs,rxnNrs,reactantBool,instances] = readAtomMappingFromRxnFile(rxn,rxnfileDir);
    
    % Check that stoichiometry in rxnfile matches the one in S
    rxnMets = unique(atomMets);
    ss = S(:,strcmp(rxns,rxn));
    as = zeros(size(ss));
    for j = 1:length(rxnMets)
        rxnMet = rxnMets{j};
        
        if reactantBool(strcmp(atomMets,rxnMet))
            as(strcmp(mets,rxnMet)) = -max(instances(strcmp(atomMets,rxnMet)));
        else
            as(strcmp(mets,rxnMet)) = max(instances(strcmp(atomMets,rxnMet)));
        end
    end
    if ~all(as == ss)
        fprintf('\n');
        warning(['The stoichiometry of reaction %s in the rxnfile does not match that in S.\n'...
            'The stoichiometry in the rxnfile will be used for the atom transition network.'],rxn);
    end
    
    % Allocate size of variables
    newMets = rxnMets(~ismember(rxnMets,tMets));
    if ~isempty(newMets)
        pBool = ismember(atomMets,newMets) & instances == 1;
        pMets = atomMets(pBool);
        pMetNrs = metNrs(pBool);
        pElements = metEls(pBool);
        
        tMets = [tMets; pMets];
        tMetNrs = [tMetNrs; pMetNrs];
        elements = [elements; pElements];
    end
    
    
    nRxnTransitions = (rev + 1)*max(rxnNrs); % Nr of atom transitions in current reaction
    tRxns = [tRxns; repmat({rxn},nRxnTransitions,1)];
    
    [m1,n1] = size(A);
    m2 = length(tMets);
    n2 = length(tRxns);
    
    newA = spalloc(m2,n2,2*n2);
    newA(1:m1,1:n1) = A;
    A = newA;
    
    % Add atom transitions to A
    tIdxs = n1+1:n2;
    for j = 1:(1 + rev):nRxnTransitions
        tIdx = tIdxs(j);
        
        headBool = ismember(tMets,atomMets(rxnNrs == (j + rev*1)/(1 + rev) & reactantBool)) & (tMetNrs == metNrs(rxnNrs == (j + rev*1)/(1 + rev) & reactantBool)); % Row in A corresponding to the reactant atom
        tailBool = ismember(tMets,atomMets(rxnNrs == (j + rev*1)/(1 + rev) & ~reactantBool)) & (tMetNrs == metNrs(rxnNrs == (j + rev*1)/(1 + rev) & ~reactantBool)); % Row in A corresponding to the product atom
        
        headEl = elements{headBool};
        tailEl = elements{tailBool};
        assert(strcmp(headEl,tailEl),'Transition %d in reaction %d maps between atoms of different elements',j,i);
        
        A(headBool,tIdx) = -1;
        A(tailBool,tIdx) = 1;
        
        if rev % Transition split into two oppositely directed edges
            A(headBool,tIdx + 1) = 1;
            A(tailBool,tIdx + 1) = -1;
        end
    end
    
end

% Generate output structure
ATN.A = A;
[nAtoms, nAtransInstances] = size(ATN.A);
ATN.atomIndex = (1:nAtoms)';
ATN.aTransInstanceIndex = (1:nAtransInstances)';
ATN.mets = tMets;
ATN.atns = tMetNrs; %also include the unique identity of that atom in the set of atoms
ATN.rxns = tRxns;
ATN.elements = elements;

%generate a unique id for each atom by concatenation of the metabolite,
%atom and element
ATN.atoms=cell(nAtoms,1);
for i=1:nAtoms
    ATN.atoms{i}=[ATN.mets{i}  '#' num2str(ATN.atns(i)) '#' ATN.elements{i}];
end

%create a matlab graph object representing an atom transition multigraph
[ah,~] = find(A == -1); % head node indices
[at,~] = find(A == 1); % tail node indices

%generate a unique id for each atom transition incidence by concatenation
%of the reaction, head and tail atoms
ATN.atrans=cell(nAtransInstances,1);
for i=1:nAtransInstances
    ATN.atrans{i,1}=[ATN.rxns{i}  '#' ATN.atoms{ah(i)} '#' ATN.atoms{at(i)}];
end

% G = graph(EdgeTable) specifies graph edges (s,t) in node pairs. s and t can specify node indices or node names.
% The EdgeTable input must be a table with a row for each corresponding pair of elements in s and t.

%
%                   * .NodeTable — Table of node information, with `p` rows, one for each atom.
%                   * .NodeTable.Atom - unique alphanumeric id for each atom by concatenation of the metabolite, atom and element
%                   * .NodeTable.AtomIndex - unique numeric id for each atom in
%                                 atom transition multigraph
%                   * .NodeTable.Met - metabolite containing each atom
%                   * .NodeTable.AtomNumber - unique numeric id for each atom in an 
%                                             atom mapping
%                   * .NodeTable.Element - atomic element of each atom
%                       
%                   * .EdgeTable — Table of edge information, with `q` rows, one for each atom transition instance.
%                   * .EdgeTable.EndNodes - two-column cell array of character vectors that defines the graph edges     
%                   * .EdgeTable.Trans - unique alphanumeric id for each atom transition instance by concatenation of the reaction, head and tail atoms
%                   * .EdgeTable.TransIstIndex - unique numeric id for each atom transition instance
%                   * .EdgeTable.Rxn - reaction corresponding to each atom transition
%                   * .EdgeTable.HeadAtomIndex - head NodeTable.AtomIndex
%                   * .EdgeTable.TailAtomIndex - tail NodeTable.AtomIndex

EdgeTable = table([ah,at],ATN.atrans,ATN.aTransInstanceIndex,ATN.rxns,ah,at,...
    'VariableNames',{'EndNodes','Trans','TransIstIndex','Rxn','HeadAtomIndex','TailAtomIndex'});

NodeTable = table(ATN.atoms,ATN.atomIndex,ATN.mets,ATN.atns,ATN.elements,...
    'VariableNames',{'Atom','AtomIndex','Met','AtomNumber','Element'});

%atom transition directed multigraph as a matlab graph object
ATM = digraph(EdgeTable,NodeTable);

if options.sanityChecks
    A = incidence(ATM);
    
    bool=~any(A,1);
    if any(bool)
        error('Atom transition matrix must not have any zero columns.')
    end
    bool=~any(A,2);
    if any(bool)
        error('Atom transition matrix must not have any zero rows.')
    end
    
    colNonZeroCount=(A~=0)'*ones(size(A,1),1);
    if any(colNonZeroCount~=2)
        error('Atom transition matrix must have two entries per column.')
    end
    
    colCount=A'*ones(size(A,1),1);
    if any(colCount~=0)
        error('Atom transition matrix must have two entries per column, -1 and 1.')
    end
    
    if 1
        [ah,~] = find(A == -1); % head nodes
        [at,~] = find(A == 1); % tail nodes
        
        headTail = [ah,at];%take into account that atom transition network is not directed
        EdgeTable = table(headTail,ATN.atrans,'VariableNames',{'EndNodes','Trans'});
        NodeTable = table(ATN.atoms,ATN.mets,ATN.atns,ATN.elements,ATN.atomIndex,'VariableNames',{'Atoms','Mets','AtomNumber','Element','AtomIndex'});
        %atom transition graph as a matlab graph object
        G = digraph(EdgeTable,NodeTable);
        
        %this fails because matlab reorders the columns of the
        %incidence matrix.
        I = incidence(G);
        headTail2=zeros(size(I,2),2);
        for i=1:size(I,2)
            headTail2(i,:) = [find(I(:,i)==-1), find(I(:,i)==1)];
        end
        
        res = headTail - headTail2;
        if any(res,'all')
            compare = [headTail, headTail2];
            error('incidence matrices not identical')
        end
        
        bool=~any(I,1);
        if any(bool)
            error('I transition matrix must not have any zero columns.')
        end
        bool=~any(I,2);
        if any(bool)
            error('I transition matrix must not have any zero rows.')
        end
        
        colNonZeroCount=(I~=0)'*ones(size(I,1),1);
        if any(colNonZeroCount~=2)
            error('I transition matrix must have two entries per column.')
        end
        
        colCount=I'*ones(size(I,1),1);
        if any(colCount~=0)
            error('I transition matrix must have two entries per column, -1 and 1.')
        end
        
        res = A - I
        [indi,indj]=find(res)
        
        if max(max(res))~=0
            error('Inconsistent atom transition graph')
        end
    end
    
    if 0
        %Graph Laplacian
        La = A*A';
        %Degree matrix
        D = diag(diag(La));
        
        res = adj + D - La;
        if max(max(res))~=0
            error('failed to convert to adjacency matrix')
        end
        
        L = laplacian(G);
        res = La - L;
        if max(max(res))~=0
            error('Inconsistent atom transition graph')
        end
        
        I = incidence(ATG);
        res = A - I;
        if max(max(res))~=0
            error('Inconsistent atom transition graph')
        end
        
        clear G D La;
    end
end

