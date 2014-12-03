function ATN = buildAtomTransitionNetwork(S,rxnFileDir,mets,rxns,lb,ub,intRxnBool)
% Builds an atom transition network corresponding to a metabolic
% network from reaction stoichiometry and atom mappings
%
% ATN = generateAtomTransitionNetwork(S,AMMs,lb,ub,mets,rxns);
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
% intRxnBool ... An n x 1 logical vector indicating which reactions in S
%                are internal. If omitted, all reactions including more
%                than one metabolite will be considered internal.
%
% OUTPUTS
% ATN  .... Structure with following fields:

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

% Extract the part of S involving atom mapped reactions
intRxnBool(ismember(rxns,aRxns)) = true;
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

% Initialize variables for keeping track of reaction pairs
uMets = {};
uElements = {};
refPairs = sparse([]);

% Build atom transition network
for i = 1:length(aRxns)
    disp(i)
    rxn = aRxns{i};
    if strcmp(rxn,'3AIBtm (Case Conflict)')
        rxn = '3AIBTm'; % Debug: Ubuntu file manager Files renames file due to existence of the reaction 3AIBtm
    end
    
    % Read atom mapping from rxnfile
    [atomMets,metEls,metNrs,rxnNrs,reactantBool,instances,rxnPairs] = readAtomMappingFromRxnFile(rxn,rxnFileDir);
    
    % Check that stoichiometry in rxnfile matches the one in S
    [rxnMets,~,xj] = unique(atomMets);
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
    
    [uRxnMets,xi] = unique(regexprep(rxnMets,'(\[\w\])$',''));
    uAtomMets = regexprep(atomMets,'(\[\w\])$','');
    uAtomMets = uAtomMets(ismember(xj,xi));
    uMetEls = metEls(ismember(xj,xi));
    uInstances = instances(ismember(xj,xi));
    
    newMets = uRxnMets(~ismember(uRxnMets,uMets));
    if ~isempty(newMets)
        pBool = ismember(uAtomMets,newMets) & uInstances == 1;
        pMets = uAtomMets(pBool);
        pElements = uMetEls(pBool);
        
        uMets = [uMets; pMets];
        uElements = [uElements; pElements];
    end
    
    [p1,q1] = size(refPairs);
    p2 = length(uMets);
    q2 = q1 + sum(reactantBool)^2;
    
    newRefs = spalloc(p2,q2,nnz(refPairs) + nnz(rxnPairs));
    newRefs(1:p1,1:q1) = refPairs;
    refPairs = newRefs;
    
    % Check for reocurring reaction pairs
%     iterate = true;
%     while iterate
%         iterate = false;
        
        for j = 1:size(rxnPairs,2)
            
            rid = unique(atomMets(rxnPairs(:,j) ~= 0 & reactantBool));
            rcount = unique(instances(rxnPairs(:,j) ~= 0 & reactantBool));
            urid = regexprep(rid,'(\[\w\])$','');
            pid = unique(atomMets(rxnPairs(:,j) ~= 0 & ~reactantBool));
            pcount = unique(instances(rxnPairs(:,j) ~= 0 & ~reactantBool));
            upid = regexprep(pid,'(\[\w\])$','');
            
            if ~strcmp(urid,upid)
                rPair = spalloc(length(uMets),1,sum(rxnPairs(:,j) ~= 0));
                rPair(ismember(uMets,urid)) = rxnPairs(ismember(atomMets,rid) & instances == rcount,j);
                rPair(ismember(uMets,upid)) = rxnPairs(ismember(atomMets,pid)  & instances == pcount,j);
                
                refPairBool = any(refPairs(ismember(uMets,urid),:),1) & any(refPairs(ismember(uMets,upid),:),1);
                refSumBool = sum(refPairs ~= 0) == sum(rPair ~= 0);
                refElBool = false(1,size(refPairs,2));
                for k = 1:size(refPairs,2)
                    if refSumBool(k)
                        refElBool(k) = all(strcmp(sort(uElements(refPairs(:,k) ~= 0)),sort(uElements(rPair ~= 0))));
                    end
                end
                
                if any(refPairBool & refSumBool & refElBool)
                    refBool = refPairBool & refSumBool & refElBool;
                    refPair = refPairs(:,refBool);
                    
                    if ~all(rPair == refPair)
%                         iterate = true;
                        
                        newRefPair = spalloc(length(atomMets),1,sum(refPair ~= 0));
                        newRefPair(ismember(atomMets,rid) & instances == rcount) = refPair(ismember(uMets,urid));
                        newRefPair(ismember(atomMets,pid) & instances == pcount) = refPair(ismember(uMets,upid));
                        refPair = newRefPair;
                        rPair = rxnPairs(:,j);
                        
                        for k = find(refPair ~= 0 & reactantBool)'
                            ridx2 = k;
                            pidx2 = find(refPair == refPair(ridx2) & ~reactantBool);
                            
                            ridx1 = rxnNrs == rxnNrs(pidx2) & reactantBool;
                            pidx1 = rxnNrs == rxnNrs(ridx2) & ~reactantBool;
                            
                            newRxnNrs = rxnNrs;
                            newRxnNrs(pidx2) = rxnNrs(ridx2);
                            newRxnNrs(pidx1) = rxnNrs(ridx1);
                            rxnNrs = newRxnNrs;
                        end
                    end
                    
                else
                    refPairs(:,find(~any(refPairs,1),1,'first')) = rPair;
                end
            end
        end
%     end
    
    refPairs = refPairs(:,any(refPairs));
    
    % Add atom transitions to A
    tIdxs = n1+1:n2;
    for j = 1:nRxnTransitions
        tIdx = tIdxs(j);
        
        headBool = ismember(tMets,atomMets(rxnNrs == j & reactantBool)) & (tMetNrs == metNrs(rxnNrs == j & reactantBool)); % Row in A corresponding to the reactant atom
        tailBool = ismember(tMets,atomMets(rxnNrs == j & ~reactantBool)) & (tMetNrs == metNrs(rxnNrs == j & ~reactantBool)); % Row in A corresponding to the product atom
        
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