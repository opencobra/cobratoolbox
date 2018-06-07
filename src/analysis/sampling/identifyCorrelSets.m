function [setsSorted, setNoSorted, setSize] = identifyCorrelSets(model, sample, corrThr, R, onlyEx)
% Identifies correlated reaction sets from sampling data
%
% USAGE:
%
%    [sets, setNumber, setSize] =  identifyCorrelSets(model, sample, corrThr, R)
%
% INPUTS:
%    model:        COBRA model structure
%    sample:       Sample to be used to identify correlated sets
%
% OPTIONAL INPUTS:
%    corrThr:      Minimum correlation (:math:`R^2`) threshold (Default = 1-1e-8)
%    R:            Correlation coefficient
%    onlyEx:       Logical value that indicates if the correlated sets will
%                  be only regarding exchange reactions (Default = false).
%
% OUTPUTS:
%    sets:         Sorted cell array of sets (largest first)
%    setNumber:    List of set numbers for each reaction in model (0 indicates
%                  that there is no set)
%    setSize:      List of set sizes
%
% .. Author: - Markus Herrgard 9/15/06

if nargin < 3 || isempty(corrThr)
    corrThr = 1 - 1e-8;
end

nRxns = length(model.rxns);

% Calculate correlation coefficients
if nargin < 4 || isempty(R)
    R = corrcoef(sample');
    R = R - eye(nRxns);
end

if nargin < 5 || isempty(onlyEx)
    onlyEx = false;
end

% Define adjacency matrix
adjMatrix = (abs(R) >= corrThr);

% Only work with reactions that are correlated with others
if onlyEx
    selCorrelRxns = logical(zeros(length(model.rxns), 1));
    selCorrelRxns(strmatch('EX_', model.rxns)) = true;
    selCorrelRxns = selCorrelRxns & any(adjMatrix)';
else
    selCorrelRxns = any(adjMatrix)';
end
rxnList = model.rxns(selCorrelRxns);
adjMatrix = adjMatrix(selCorrelRxns, selCorrelRxns);

% Construct set number index
hasSet = false(size(rxnList));
currSetNo = 0;
setNoTmp = zeros(size(rxnList));
for i = 1:length(rxnList)
    if ~hasSet(i)
        currSetNo = currSetNo + 1;
        setMembers = find(adjMatrix(i, :));
        hasSet(setMembers) = true;
        hasSet(i) = true;
        setNoTmp(setMembers) = currSetNo;
        setNoTmp(i) = currSetNo;
    end
end
setNo = zeros(size(model.rxns));
[tmp, index1, index2] = intersect(model.rxns, rxnList);
setNo(index1) = setNoTmp(index2);

% Construct list of sets
if onlyEx
    c = 0;
    for i = 1:max(setNo)
        if length(find(setNo == i)) > 1
            c = c + 1;
            sets{c}.set = find(setNo == i);
            sets{c}.names = model.rxns(sets{c}.set);
            setSize(c) = length(sets{c}.set);
        end
    end
else
    for i = 1:max(setNo)
        sets{i}.set = find(setNo == i);
        sets{i}.names = model.rxns(sets{i}.set);
        setSize(i) = length(sets{i}.set);
    end
end

% Sort everything
[setSize, sortInd] = sort(setSize');
sortInd = flipud(sortInd);
setsSorted = sets(sortInd);
setNoSorted = zeros(size(setNo));
for i = 1:length(sortInd)
    setNoSorted(setNo == sortInd(i)) = i;
end
setSize = flipud(setSize);
setsSorted = setsSorted';
