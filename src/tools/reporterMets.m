function [normScore, nRxnsMet, nRxnsMetUni, rawScore] = reporterMets(model, data, nRand, pValFlag, nLayers, metric, dataRxns, inclExchFlag)
% Implements the reporter metabolites algorithm by Patil &
% Nielsen
%
% USAGE:
%
%    [normScore, nRxnsMet, nRxnsMetUni, rawScore] = reporterMets(model, data, nRand, pValFlag, nLayers, metric, dataRxns)
%
% INPUTS:
%    model:          Metabolic network reconstruction structure
%    data:           Data matrix/vector
%    nRand:          Number of randomizations
%    pValFlag:       The data are p-values and should be converted to z-scores
%    nLayers:        Number of reaction layers around each metabolite considered (default = 1)
%    metric:         Metric used to evaluate score
%                    ('default','mean', 'median', 'std', 'count')
%    dataRxns:       Reaction list for the data file (if different from the
%                    model reactions)
%    inclExchFlag:   Flag for exchange reactions
%
% OUTPUTS:
%    normScore:      Normalized scores for each metabolite
%    nRxnsMet:       Number of reactions connected to each metabolite
%    nRxnsMetUni:
%    rawScore:       Raw unnormalized scores
%
% .. Authors: Markus Herrgard 7/20/06

if nargin < 3
    nRand = 1000;
end

if nargin < 4
    pValFlag = false;
end

if nargin < 5
    nLayers = 1;
end

if nargin < 6 || isempty(metric)
    metric = 'default';
end

if nargin < 7
    dataRxns = model.rxns;
else
    if isempty(dataRxns)
        dataRxns = model.rxns;
    end
end

if nargin < 8
    inclExchFlag = false;
end

if pValFlag
    error('Not implemented yet')
    % minP = min(min(data(data ~= 0)));
    % data(data == 0) = minP;
    % data = -norminv(data, 0, 1);
end

[nRxnsTot, nData] = size(data);

% Handle case where more than one rxn is associated with a
% data value
if iscell(dataRxns{1})
    for j = 1:length(dataRxns)
        dataRxnTmp = dataRxns{j};
        selModelRxn = ismember(model.rxns, dataRxnTmp);
        dataModelRxnMap(j, :) = selModelRxn';
    end
    dataModelRxnMap = sparse(dataModelRxnMap);
end

excInd = find(findExcRxns(model), 1);

% Compute raw scores
for i = 1:length(model.mets)
    rxnInd = find(model.S(i, :) ~= 0)';
    for j = 2:nLayers
        metInd = find(any(model.S(:, rxnInd) ~= 0, 2));
        rxnInd = union(rxnInd, find(any(model.S(metInd, :) ~= 0, 1)));
    end
    rxnInd = setdiff(rxnInd, excInd);
    if (nargin < 7)
        dataRxnInd = false(length(dataRxns), 1);
        dataRxnInd(rxnInd) = true;
        nRxnsMetUni(i) = sum(rxnInd);
    else
        if (~iscell(dataRxns{1}))
            dataRxnInd = ismember(dataRxns, model.rxns(rxnInd));
            nRxnsMetUni(i) = length(unique(dataRxns(dataRxnInd)));
        else
            dataRxnInd = any(full(dataModelRxnMap(:, rxnInd)), 2);
            nRxnsMetUni(i) = sum(dataRxnInd);
        end
    end
    nRxnsMet(i) = sum(dataRxnInd);

    if nRxnsMet(i) == 0
        rawScore(i, :) = zeros(1, nData);
    else
        if (sum(dataRxnInd) == 1)
            switch metric
                case {'default', 'mean', 'median'}
                    rawScore(i, :) = data(dataRxnInd, :);
                case 'std'
                    rawScore(i, :) = zeros(1, nData);
                case 'count'
                    rawScore(i, :) = data(dataRxnInd, :) ~= 0;
            end
        else
            switch metric
                case 'default'
                    rawScore(i, :) = nansum(data(dataRxnInd, :)) / sqrt(nRxnsMet(i));
                case 'mean'
                    rawScore(i, :) = nanmean(data(dataRxnInd, :));
                case 'median'
                    rawScore(i, :) = nanmedian(data(dataRxnInd, :));
                case 'std'
                    rawScore(i, :) = nanstd(data(dataRxnInd, :));
                case 'count'
                    rawScore(i, :) = nansum(data(dataRxnInd, :) ~= 0);
            end
        end
    end
end
nRxnsMet = nRxnsMet';
nRxnsMetUni = nRxnsMetUni';

nRxnsUni = unique(nRxnsMet);

% Do randomization
normScore = zeros(length(rawScore), nData);
if (~isempty(nRand))
    for i = 1:length(nRxnsUni)
        nRxns = nRxnsUni(i);
        if (nRxns > 0)
            randScore = [];
            for j = 1:nRand
                % Sample with replacement
                randInd = randi([1 nRxnsTot], nRxns, 1);  % randint no longer exists
                if (length(randInd) == 1)
                    switch metric
                        case {'default', 'std', 'mean', 'median'}
                            randScore(j, :) = data(randInd, :);
                        case 'count'
                            randScore(j, :) = data(randInd, :) ~= 0;
                    end
                else
                    switch metric
                        case 'default'
                            randScore(j, :) = nansum(data(randInd, :)) / sqrt(nRxns);
                        case 'mean'
                            randScore(j, :) = nanmean(data(randInd, :));
                        case 'median'
                            randScore(j, :) = nanmedian(data(randInd, :));
                        case 'std'
                            randScore(j, :) = nanstd(data(randInd, :));
                        case 'count'
                            randScore(j, :) = nansum(data(randInd, :) ~= 0);
                    end
                end
            end
            randMean = mean(randScore);
            randStd = std(randScore);
            metInd = find(nRxnsMet == nRxns);
            normScore(metInd, :) = (rawScore(metInd, :) - repmat(randMean, length(metInd), 1)) ./ repmat(randStd, length(metInd), 1);
        end
    end
else
    normScore = rawScore;
end
