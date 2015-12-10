function ATN = buildAtomTransitionNetwork(model,rxnfileDir)
% Builds an atom transition network corresponding to a metabolic
% network from reaction stoichiometry and atom mappings
%
% ATN = buildAtomTransitionNetwork(model,rxnfileDir)
%
% INPUTS
% model .... Structure with following fields:
% .S          .... The m x n stoichiometric matrix for the metabolic
%                  network 
% .mets       .... An m x 1 array of metabolite identifiers. Should match
%                  metabolite identifiers in rxnfiles.
% .rxns       .... An n x 1 array of reaction identifiers. Should match
%                  rxnfile names in rxnFileDir.
% .lb         .... An n x 1 vector of lower bounds on fluxes.
% .ub         .... An n x 1 vector of upper bounds on fluxes.
% rxnfileDir  .... Path to directory containing rxnfiles with atom mappings
%                  for internal reactions in S. File names should
%                  correspond to reaction identifiers in input rxns.
%
% OUTPUTS
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
% June 2015, Hulda S. Haraldsdóttir and Ronan M. T. Fleming

% Format inputs
S = model.S;
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
    rev = (lb(i) < 0 & ub(i) > 0); % True if rxn is reversible
    
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
ATN.mets = tMets;
ATN.rxns = tRxns;
ATN.elements = elements;
