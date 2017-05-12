function compareSampleTraj(rxnNames,samples,models,nBins)
% Compares flux histograms for two or more samples
% for one or more reactions
%
% USAGE:
%
%    compareSampleTraj(rxnNames, samples, models, nBins)
%
% INPUTS:
%    rxnNames:      List of reaction names to compare
%    samples:       Samples to compare
%    models:        Cell array containing COBRA model structures
%
% OPTIONAL INPUTS:
%    nBins:         Number of bins (Default = `nSamples` / 25)

if (nargin < 4)
  [tmp,nSamples] = size(samples{1});
  bins = round(nSamples/25);
end

if (~iscell(rxnNames))
  rxnNameList{1} = rxnNames;
else
  rxnNameList = rxnNames;
end

nRxns = length(rxnNameList);
nX = ceil(sqrt(nRxns));

nY = ceil(nRxns/nX);

for j = 1:nRxns

  clear counts;
  currLB = 1e6;
  currUB = -1e6;
  for i = 1:length(models)
    id = findRxnIDs(models{i},rxnNameList{j});
    if (isempty(id))
      id = findRxnIDs(models{i},[rxnNameList{j} '_r']);
      if (isempty(id))
        error('Reaction does not exist');
      end
    end
    currLB = min(currLB,min(samples{i}(id,:)'));
    currUB = max(currUB,max(samples{i}(id,:)'));
  end

  bins = linspace(currLB,currUB,nBins);

  for i = 1:length(models)
    sampleSign = 1;
    id = findRxnIDs(models{i},rxnNameList{j});
    if (isempty(id))
      id = findRxnIDs(models{i},[rxnNameList{j} '_r']);
      sampleSign = -1;
    end
    traj(:,i) = sampleSign*samples{i}(id,:)';
  end

  subplot(nY,nX,j);
  plot(traj,'-');
  axis([0 length(traj) currLB currUB]);
  %text((currUB+currLB)/2,max(max(counts))+20,rxnNameList{j});
end
