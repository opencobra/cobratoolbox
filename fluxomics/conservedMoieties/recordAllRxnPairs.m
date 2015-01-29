function [refPairs,uMets,uElements,refPairMat,aRxns,rxnPairMat] = recordAllRxnPairs(S,rxnFileDir,mets,rxns,lb,ub,intRxnBool)
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

% Initialize variables for keeping track of reaction pairs
uMets = {};
uElements = {};
refPairs = sparse([]);
refPairMat = sparse([]);
rxnPairMat = sparse([]);

% Build atom transition network
for i = 1:length(aRxns)
    %disp(i)
    rxn = aRxns{i};
    if strcmp(rxn,'3AIBtm (Case Conflict)')
        rxn = '3AIBTm'; % Debug: Ubuntu file manager "Files" renames file due to existence of the reaction 3AIBtm
    end
    
    % Read atom mapping from rxnfile
    [atomMets,metEls,metNrs,rxnNrs,reactantBool,instances] = readAtomMappingFromRxnFile(rxn,rxnFileDir);
    rxnPairs = findRxnPairs(atomMets,metNrs,rxnNrs,reactantBool,instances);
    
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
    q2 = q1 + size(rxnPairs,2);
    
    newRefs = spalloc(p2,q2,nnz(refPairs) + nnz(rxnPairs));
    newRefs(1:p1,1:q1) = refPairs;
    refPairs = newRefs;
    
    [x1,y1] = size(refPairMat);
    x2 = x1 + size(rxnPairs,2);
    y2 = y1 + size(rxnPairs,2);
    
    newRefPairMat = spalloc(x2,y2,nnz(refPairMat) + size(rxnPairs,2));
    newRefPairMat(1:x1,1:y1) = refPairMat;
    refPairMat = newRefPairMat;
    
    [x1,y1] = size(rxnPairMat);
    x2 = x1;
    y2 = y1 + size(rxnPairs,2);
    
    newrxnPairMat = spalloc(x2,y2,nnz(rxnPairMat) + size(rxnPairs,2));
    newrxnPairMat(1:x1,1:y1) = rxnPairMat;
    rxnPairMat = newrxnPairMat;
    
    
    % Check for reocurring reaction pairs
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
            
            altPair = spalloc(length(uMets),1,sum(rxnPairs(:,j) ~= 0));
            altPair(ismember(uMets,upid) & rPair ~= 0) = metNrs((ismember(atomMets,pid)  & instances == pcount) & rxnPairs(:,j) ~= 0);
            for k = find(ismember(uMets,urid) & rPair ~= 0)'
                altPair(k) = altPair(ismember(uMets,upid) & rPair == rPair(k));
            end
            
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
                refIdxs = find(refBool);
                refPair = refPairs(:,refBool);
                
                if ~(any(all(repmat(rPair,1,size(refPair,2)) == refPair)) || any(all(repmat(altPair,1,size(refPair,2)) == refPair)))
                    refPairMat(refBool,find(~any(refPairs,1),1,'first')) = 1;
                    rxnPairMat(i,find(~any(refPairs,1),1,'first')) = 1;
                    refPairs(:,find(~any(refPairs,1),1,'first')) = rPair;
                else
                    refMatchIdx = refIdxs(all(repmat(rPair,1,size(refPair,2)) == refPair) | all(repmat(altPair,1,size(refPair,2)) == refPair));
                    rxnPairMat(i,refMatchIdx) = 1;
                end
                
            else
                refPairMat(find(~any(refPairs,1),1,'first'),find(~any(refPairs,1),1,'first')) = 1;
                rxnPairMat(i,find(~any(refPairs,1),1,'first')) = 1;
                refPairs(:,find(~any(refPairs,1),1,'first')) = rPair;
            end
        end
    end
    
    
    refPairs = refPairs(:,any(refPairs));
    refPairMat = refPairMat(any(refPairMat),any(refPairMat));
    rxnPairMat = rxnPairMat(:,any(refPairs));
end
