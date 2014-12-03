function [groupStat,groupList,groupCnt,zScore] = calcGroupStats(data,groups,statName,groupList,randStat,nRand)
%calcGroupStats Calculate statistics such as mean or standard deviation for
%subgroups of a population
%
% [groupStat,groupList,groupCnt,zScore] =
% calcGroupStats(data,groups,statName,groupList,randStat,nRand)
%
% data      Matrix of data (individuals x variables)
% groups    Group identifier for each individual
% statName  Name of the statistic to be computed for each group:
%               'mean': mean value for group (default)
%               'std': standard deviation for group
%               'median': median for group
%               'count': sum total of variable values for group
% groupList List of group identifiers to be considered (optional, default
%           all values occurring in groups)
% randStat  Perform randomization analysis
% nRand     # of randomizations
%
% Group identifier can be either strings or numerical values
%
% groupStat     Matrix of group statistic values for each group and variable
% groupList     List of group identifiers considered
% groupCount    Number of individuals in a group
%
% Markus Herrgard 2006

[nItems,nSets] = size(data);

if (nargin < 3)
    statName = 'mean';
end
if (nargin < 4)
    groupList = unique(groups);
end
if (isempty(groupList))
    groupList = unique(groups);
end
if (nargin < 5)
    randStat = false;
end
if (nargin < 6)
    nRand = 1000;
end

if iscell(groups)
    cellFlag = true;
else
    cellFlag = false;
end

for i = 1:length(groupList)
    if (cellFlag)
        selGroup = strcmp(groups,groupList{i});
    else
        selGroup = (groups == groupList(i));
    end
    selData = data(selGroup,:);
    groupCnt(i) = sum(selGroup);
    groupStat(i,:) = calcStatInternal(groupCnt(i),selData,statName,nSets);
end

groupCnt = groupCnt';

if (randStat)
    groupCntList = unique(groupCnt);

    zScore = zeros(length(groupList),nSets);

    for i = 1:length(groupCntList)
        thisGroupCnt = groupCntList(i);
        selGroups = find(groupCnt == thisGroupCnt);
        if (thisGroupCnt > 0)
            for j = 1:nRand
                randInd = randperm(nItems);
                randData = data(randInd(1:thisGroupCnt),:);
                groupStatRand(j,:) = calcStatInternal(thisGroupCnt,randData,statName,nSets);
            end
            groupStatRandMean = nanmean(groupStatRand);
            groupStatRandStd = nanstd(groupStatRand);
            nGroups = length(selGroups);
            zScore(selGroups,:) = (groupStat(selGroups,:)-repmat(groupStatRandMean,nGroups,1))./repmat(groupStatRandStd,nGroups,1);
        end
    end
end

function groupStat = calcStatInternal(groupCnt,data,statName,nSets)

if (groupCnt > 0)
    switch lower(statName)
        case 'mean'
            if (groupCnt > 1)
                groupStat = nanmean(data);
            else
                groupStat = data;
            end
        case 'std'
            if (groupCnt > 1)
                groupStat = nanstd(data);
            else
                groupStat = zeros(1,nSets);
            end
        case 'median'
            if (groupCnt > 1)
                groupStat = nanmedian(data);
            else
                groupStat = data;
            end
        case 'count'
            if (groupCnt > 1)
                groupStat = nansum(data);
            else
                groupStat = data;
            end
    end

else
    groupStat = ones(1,nSets)*NaN;
end
