function [setsSorted,setNoSorted,setSize] = identifyCorrelSets(model,samples,corrThr,R)
%identifyCorrelSets Identify correlated reaction sets from sampling data
%
% [sets,setNumber,setSize] =  identifyCorrelSets(model,samples,corrThr,R)
%
%INPUTS
% model         COBRA model structure
% samples       Samples to be used to identify correlated sets
%
%OPTIONAL INPUTS
% corrThr       Minimum correlation (R^2) threshold (Default = 1-1e-8)
% R             Correlation coefficient 
%
%OUTPUTS
% sets          Sorted cell array of sets (largest first)
% setNumber     List of set numbers for each reaction in model (0 indicates
%               that there is no set)
% setSize       List of set sizes
%
% Markus Herrgard 9/15/06

if (nargin < 3)
    corrThr = 1-1e-8;
end

nRxns = length(model.rxns);

% Calculate correlation coefficients
if (nargin < 4)
    R = corrcoef(samples');
    R = R - eye(nRxns);
end

% Define adjacency matrix
adjMatrix = (abs(R) >= corrThr);

% Only work with reactions that are correlated with others
selCorrelRxns = any(adjMatrix)';
rxnList = model.rxns(selCorrelRxns);
adjMatrix = adjMatrix(selCorrelRxns,selCorrelRxns);

% Construct set number index
hasSet = false(size(rxnList));
currSetNo = 0;
setNoTmp = zeros(size(rxnList));
for i = 1:length(rxnList)
    if (~hasSet(i))
        currSetNo = currSetNo+1;
        setMembers = find(adjMatrix(i,:));
        hasSet(setMembers) = true;
        hasSet(i) = true;
        setNoTmp(setMembers) = currSetNo;
        setNoTmp(i) = currSetNo;
    end
end
setNo = zeros(size(model.rxns));
[tmp,index1,index2] = intersect(model.rxns,rxnList);
setNo(index1) = setNoTmp(index2);  

% Construct list of sets
for i = 1:max(setNo)
    sets{i}.set = find(setNo == i);
    sets{i}.names = model.rxns(sets{i}.set);
    setSize(i) = length(sets{i}.set);
end

% Sort everything
[setSize,sortInd] = sort(setSize');
sortInd = flipud(sortInd);
setsSorted = sets(sortInd);
setNoSorted = zeros(size(setNo));
for i = 1:length(sortInd)
    setNoSorted(setNo == sortInd(i)) = i;
end
setSize = flipud(setSize);
setsSorted = setsSorted';
