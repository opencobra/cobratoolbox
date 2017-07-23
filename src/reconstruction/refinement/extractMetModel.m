function metabModel = extractMetModel(model, metabNames, nLayers, allCompFlag, nRxnsMetThr)
% Creates a subnetwork model around one or more metabolites
%
% USAGE:
%
%    metabModel = extractMetModel(model, metabNames, nLayers, allCompFlag, nRxnsMetThr)
%
% INPUTS:
%    model:          COBRA model structure
%    metabNames:     Metabolites to build subnetwork model around
%    nLayers:        Number of layers
%    allCompFlag:    Use all metabolites regardless of compartment
%
% OPTIONAL INPUT:
%    nRxnsMetThr:    Ignore metabolites which appear in more than `nRxnMetThr` (Default = 100)
%
% OUTPUT:
%    metabModel:     COBRA model around one or more metabolites
%
% .. Author: - Markus Herrgard 3/1/06
%              Uri David Akavia 26-Mar-2017

if (nargin < 5)
    nRxnsMetThr = 100;
end

% Filter out high degree metabolites
nRxnsMet = full(sum(model.S~=0,2));
baseMetNames = parseMetNames(model.mets);
for i = 1:length(baseMetNames)
    nRxnsMetComp(i) = sum(nRxnsMet(strcmp(baseMetNames,baseMetNames{i})));
end
nRxnsMetComp = nRxnsMetComp';
selLowDegMet = nRxnsMetComp < nRxnsMetThr;
model.S(~selLowDegMet,:) = 0;
%model.mets = model.mets(selLowDegMet); Commented out, because other fields
%aren't shrunk, which can lead to mismatch later

if (~iscell(metabNames))
    tmpMetName = metabNames;
    clear metabNames;
    metabNames{1} = tmpMetName;
end

if (allCompFlag)
    allMetNames = parseMetNames(model.mets);
    metabNames = parseMetNames(metabNames);
else
    allMetNames = model.mets;
end

metabNames = intersect(metabNames, allMetNames(selLowDegMet));
selMets = find(ismember(allMetNames,metabNames));

metS = model.S(selMets,:);
[nMet,tmp] = size(metS);
if (nMet > 1)
    selRxns = any(full(metS) ~= 0)';
else
    selRxns = (full(metS) ~= 0)';
end
for i = 1:nLayers+1
    metS = model.S(selMets,:);
    [nMet,tmp] = size(metS);
    if (nMet > 1)
        selRxns = any(full(metS) ~= 0)';
    else
        selRxns = (full(metS) ~= 0)';
    end

    if (isfield(model,'c'))
        selRxns = selRxns & ~ (model.c == 1);
    end
    nextLayerMets = find(any(model.S(:,selRxns) ~= 0,2));
    selMets = union(selMets,nextLayerMets);
end

rxnNames = model.rxns(selRxns);
metNames = model.mets(selMets);

metabModel = extractSubNetwork(model,rxnNames,metNames);
