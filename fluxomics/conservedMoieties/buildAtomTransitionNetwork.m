function ATN = buildAtomTransitionNetwork(S,rxnFileDir,mets,rxns,lb,ub,intRxnBool)
% Builds an atom transition network corresponding to a metabolic
% network from reaction stoichiometry and atom mappings
%
% ATN = buildAtomTransitionNetwork(S,rxnFileDir,mets,rxns,lb,ub,intRxnBool)
%
% INPUTS
% S          .... The m x n stoichiometric matrix for the metabolic network
% rxnFileDir .... Path to directory containing rxnfiles with atom mappings
%                 for internal reactions in S. File names should correspond
%                 to reaction identifiers in input rxns.
% mets       .... An m x 1 array of metabolite identifiers. Should match
%                 metabolite identifiers in rxnfiles.
% rxns       .... An n x 1 array of reaction identifiers. Should match
%                 rxnfile names in rxnFileDir.
% lb         .... An n x 1 vector of lower bounds on fluxes.
% ub         .... An n x 1 vector of upper bounds on fluxes.
%
% OPTIONAL INPUTS
% intRxnBool ... An n x 1 logical array indicating which reactions in S
%                are internal. If omitted, all reactions involving more
%                than one metabolite will be considered internal.
%
% OUTPUTS
% ATN  .... Structure with following fields:
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
% .inputBool   ... A p x 1 logical array. True for input atoms, i.e., atoms
%                  in metabolites with uptake reactions.
% .outputBool  ... A p x 1 logical array. True for output atoms, i.e.,
%                  atoms in secreted metabolites.
% .reverseBool ... A q x 1 logical array. True for atom transitions that
%                  are the reverse of other transitions. Reverse
%                  transitions arise when reversible reactions are split
%                  in two.

% Format inputs
rxnFileDir = [regexprep(rxnFileDir,'(/|\\)$',''), filesep]; % Make sure input path ends with directory separator

if nargin < 7 || isempty(intRxnBool)
    intRxnBool = (sum(full(S) ~= 0) > 1)'; % Only single metabolite exchanges considered external
end

assert(size(S,1) == length(mets), 'The number of metabolite identifiers should be equal to the number of rows in S.');
assert(size(S,2) == length(rxns), 'The number of reaction identifiers should be equal to the number of columns in S.');
assert(size(S,2) == length(lb), 'The number of flux lower bounds should be equal to the number of columns in S.');
assert(size(S,2) == length(ub), 'The number of reaction identifiers should be equal to the number of columns in S.');
assert(size(S,2) == length(intRxnBool), 'The length of intRxnBool should be equal to the number of columns in S.');

% Get list of atom mapped reactions
d = dir(rxnFileDir);
d = d(~[d.isdir]);
aRxns = {d.name}';
aRxns = aRxns(~cellfun('isempty',regexp(aRxns,'(\.rxn)$')));
aRxns = regexprep(aRxns,'(\.rxn)$',''); % Identifiers for atom mapped reactions
assert(~isempty(aRxns), 'Rxnfile directory is empty or nonexistent.');

if any(strcmp(aRxns,'3AIBtm (Case Conflict)'))
    aRxns{strcmp(aRxns,'3AIBtm (Case Conflict)')} = '3AIBTm'; % Debug: Ubuntu file manager "Files" renames file due to existence of the reaction 3AIBtm
end

% Extract the part of S involving atom mapped reactions
intRxnBool(ismember(rxns,aRxns)) = true; % A reaction cannot be atom mapped unless it is balanced, in which case it should be considered internal.
abool = (ismember(rxns,aRxns) & intRxnBool); % Internal reactions in S that have atom mappings
sbool = ismember(aRxns,rxns); % Reactions with atom mappings that are included in S

assert(any(abool), 'No atom mappings found for reactions in S.\nCheck that rxnfile names match reaction identifiers in rxns.');

if ~all(abool)
    fprintf('Atom mappings found for %d/%d internal reactions in S.\n', sum(abool), sum(intRxnBool));
    fprintf('Generating atom transition network for reactions with atom mappings.\n');
    
    % Save original inputs
    S0 = S;
    mets0 = mets;
    rxns0 = rxns;
    lb0 = lb;
    ub0 = ub;
    intRxnBool0 = intRxnBool;
    aRxns0 = aRxns;
    
    % Extract reactions with atom mappings
    mbool = any(S(:,abool),2); % Metabolites in reactions with atom mappings
    rbool = ~intRxnBool & (any(S(mbool,:))' & ~any(S(~mbool,:))'); % Exchange reactions for metabolites in reactions with atom mappings
    rbool = rbool | abool; % Internal reactions with atom mappings
    
    S = S0(mbool,rbool);
    mets = mets0(mbool);
    rxns = rxns0(rbool);
    lb = lb0(rbool);
    ub = ub0(rbool);
    intRxnBool = intRxnBool0(rbool);
    aRxns = aRxns0(sbool);
end

% Initialize fields of output structure
A = sparse([]);
tMets = {};
tMetNrs = [];
tRxns = {};
elements = {};

% Build atom transition network
for i = 1:length(aRxns)
    %disp(i)
    rxn = aRxns{i};
    
    % Read atom mapping from rxnfile
    [atomMets,metEls,metNrs,rxnNrs,reactantBool,instances] = readAtomMappingFromRxnFile(rxn,rxnFileDir);
    
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
    
    nRxnTransitions = max(rxnNrs); % Nr of atom transitions in current reaction
    tRxns = [tRxns; repmat({rxn},nRxnTransitions,1)];
    
    [m1,n1] = size(A);
    m2 = length(tMets);
    n2 = length(tRxns);
    
    newA = spalloc(m2,n2,2*n2);
    newA(1:m1,1:n1) = A;
    A = newA;
    
    % Add atom transitions to A
    tIdxs = n1+1:n2;
    for j = 1:nRxnTransitions
        tIdx = tIdxs(j);
        
        headBool = ismember(tMets,atomMets(rxnNrs == j & reactantBool)) & (tMetNrs == metNrs(rxnNrs == j & reactantBool)); % Row in A corresponding to the reactant atom
        tailBool = ismember(tMets,atomMets(rxnNrs == j & ~reactantBool)) & (tMetNrs == metNrs(rxnNrs == j & ~reactantBool)); % Row in A corresponding to the product atom
        
        headEl = elements{headBool};
        tailEl = elements{tailBool};
        assert(strcmp(headEl,tailEl),'Transition %d in reaction %d maps between atoms of different elements',j,i);
        
        A(headBool,tIdx) = -1;
        A(tailBool,tIdx) = 1;
    end
    
end

% Indicate input and output atoms
uptakeRxnBool = ~intRxnBool & (ub <= 0 | (lb < 0 & ub > 0));
inputBool = ismember(tMets,mets(any(S(:,uptakeRxnBool),2))); % True for input atoms

secretionRxnBool = ~intRxnBool & (lb >= 0 | (lb < 0 & ub > 0));
outputBool = ismember(tMets,mets(any(S(:,secretionRxnBool),2))); % True for output atoms

% Append reverse transitions for reversible reactions
reversibleRxnBool = (lb < 0 & ub > 0);
[~,t2rIdxMapping] = ismember(tRxns,rxns);
reversibleTransitionBool =  reversibleRxnBool(t2rIdxMapping);

reverseBool = false(size(A,2),1);

A = [A -A(:,reversibleTransitionBool)];
tRxns = [tRxns; tRxns(reversibleTransitionBool)];
reverseBool = [reverseBool; true(sum(reversibleTransitionBool),1)];

% Generate output structure
ATN.A = A;
ATN.mets = tMets;
ATN.rxns = tRxns;
ATN.elements = elements;
ATN.inputBool = inputBool;
ATN.outputBool = outputBool;
ATN.reverseBool = reverseBool;