function [neighborRxns, neighborGenes, mets] = findNeighborRxns(model, rxns, asSingleArray, order, commonMets, withComp)
% Identifies the reactions and the corresponding genes
% that are adjacent (having a common metabolite) to a reaction of interest.
% Useful for characterizing the network around an orphan reaction.
%
% USAGE:
%
%    [neighborRxns, neighborGenes, mets] = findNeighborRxns(model, rxns, asSingleArray, order, commonMets, withComp)
%
% INPUTS:
%    model:            COBRA model structure
%    rxns:             the target reaction as a string or multiple reactions as cell array
%
% OPTIONAL INPUTS:
%    asSingleArray:    If false, then return cell array of cell arrays with neighbor reactions
%                      for one particular connecting metabolite and input reaction combination.
%                      Else just return all neighbors in one cell array. (Default = false)
%    order:            maximal order of neighbors to be returned (default = 1)
%                      `order >= 2` only works with `asSingleArray = true`
%                      Neighborhoods of `order >= 2` will usually also return the input reactions.
%    commonMets:       Cell array of common metabolites, that should not count as edges between reactions.
%                      Use {''} if no such metabolite should be included
%                      (default = {'atp', 'adp', 'h', 'h2o', 'pi', 'ppi'}).
%    withComp:         if `commonMets` already have a compartment identifier, e.g. 'atp[m]', then true (default=false)
%
% OUTPUTS:
%    neighborRxns:     the neighboring rxns in the network, (having common metabolites)
%    neighborGenes:    the genes associated with the neighbor `rxns`
%    mets:             the metabolites in the target reaction
%
% .. Authors:
%       - Jeff Orth 10/11/09
%       - Nikos Ignatiadis 10/7/2013 now provides more options, e.g. common metabolites and order of neighbors

if ~exist('order','var') || isempty(order) || order < 1 % set defaults
    order = 1;
end

if ~exist('asSingleArray','var') || isempty(asSingleArray)
    asSingleArray = false;
end

if ~exist('commonMets','var') || isempty(commonMets)
    commonMets = {'atp', 'adp', 'h', 'h2o', 'pi', 'ppi'};
end

if ~exist('withComp','var') || isempty(withComp)
    withComp = false;
end

% catch single reaction case
if ~iscell(rxns)
	rxns = {rxns};
end

%initialization
neighborRxns = {};
neighborGenes = {};
mets = [];

if (isempty(intersect('rxnGeneMat', fieldnames(model))))
    model = buildRxnGeneMat(model);
end

% get model ids for common mets by first mapping to their compartment specific names
if ~withComp
	commonCompartmentalizedMets = {};
	[~,~,~,compartments] =  parseMetNames(model.mets);
	for i= 1:numel(compartments)
		addedCompartmentalizedMets = cellfun(@(x) [x,'[',compartments{i},']'], commonMets, 'UniformOutput', false);
		commonCompartmentalizedMets = [commonCompartmentalizedMets, addedCompartmentalizedMets];
	end
else
	commonCompartmentalizedMets = commonMets;
end
commonMetsIndex = findMetIDs(model, commonCompartmentalizedMets);
maxMetIndex = 0;
genePos = false(size(model.genes));
neighborRxns = cell(size(0));
neighborGenes = cell(size(0));



% start to find neighbors
for i = 1:numel(rxns)
	% count cells already filled, so new values can be added below
	runningRxnIndex  = numel(neighborRxns);
	runningGeneIndex = numel(neighborGenes);
	rxn = rxns{i};
    currentRxnID = findRxnIDs(model,rxn);

	%get the metabolites in the rxn and exclude common ones
	metIndex = find(model.S(:,findRxnIDs(model,rxn)));
	metIndex = setdiff(metIndex,commonMetsIndex);

	%get the rxns for each met
	nRxnIndexs = cell(50, 1);
	for j = 1:length(metIndex)
    	nRxnIndexs{j} = find(model.S(metIndex(j),:));
        % remove target rxn from list
        nRxnIndexs{j} = setdiff(nRxnIndexs{j}, currentRxnID);
        maxMetIndex = max(length(nRxnIndexs{j}), maxMetIndex);
    	neighborRxns{runningRxnIndex + j} = model.rxns(nRxnIndexs{j});
    end

    %get genes for each rxn
    for j = 1:length(metIndex)
        allpos = logical(model.rxnGeneMat(nRxnIndexs{j}, :));
        if asSingleArray
            genePos = genePos | any(allpos', 2);
        else
        genes2 = cell(length(nRxnIndexs{j}), 1);
        for k=1:size(allpos, 1)
            genes2{k, 1} = strjoin(model.genes(allpos(k, :)), '; ');
        end
        neighborGenes{runningGeneIndex + j} = genes2;
        end
    end
    if asSingleArray
        neighborGenes = model.genes(genePos);
    end

	mets = unique([mets; model.mets(metIndex)]);
end


if asSingleArray
	neighborRxnsTmp  = neighborRxns;
	neighborRxns  = repmat({''}, maxMetIndex, 1);
    currentIndex = 1;
	for i=1:numel(neighborRxnsTmp)
        indexStep = length(neighborRxnsTmp{i});
		neighborRxns(currentIndex:(currentIndex+indexStep - 1), 1)  = neighborRxnsTmp{i};
        currentIndex = currentIndex + indexStep;
	end
	neighborRxns  = unique(neighborRxns);
	% remove empty GPR
	neighborGenes= neighborGenes(~cellfun(@isempty, neighborGenes));
    neighborRxns = neighborRxns(~cellfun(@isempty, neighborRxns));
end

% recursively find higher order neighbors
if order >=2 && asSingleArray
	[recursiveNeighborRxns, recursiveNeighborGenes, recursiveMets] = ...
		findNeighborRxns(model, neighborRxns', asSingleArray, order -1 ,  commonMets);
	neighborRxns = unique([neighborRxns; recursiveNeighborRxns]);
	neighborGenes = unique([neighborGenes; recursiveNeighborGenes]);
	mets = unique([mets; recursiveMets]);
end

end
