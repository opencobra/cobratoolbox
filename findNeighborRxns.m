function [neighborRxns,neighborGenes,mets] = findNeighborRxns(model,rxns, asSingleArray, order, commonMets, withComp)

%findNeighborRxns Identifies the reactions and the corresponding genes 
%that are adjacent (having a common metabolite) to a reaction of interest.
%Useful for characterizing the network around an orphan reaction.
%
% [neighborRxns,neighborGenes,mets] = findNeighborRxns(model,rxns, asSingleArray, order, commonMets, withComp)
%
%INPUTS
% model         COBRA model structure
% rxns          the target reaction as a string or multiple reactions as cell array
% asSingleArray If false, then return cell array of cell arrays with neighbor reactions
%               for one particular connecting metabolite and input reaction combination.
%               Else just return all neighbors in one cell array. (Default = false)
% order         maximal order of neighbors to be returned (default = 1)
%               order >=2 only works with asSingleArray = true
%               Neighborhoods of order >=2 will usually also return the input reactions.
% commonMets    Cell array of common metabolites, that should not count as edges between reactions.
%               Use {''} if no such metabolite should be included.
%               (default = {'atp', 'adp', 'h', 'h2o', 'pi', 'ppi'})
% withComp      if commonMets already have a compartment identifier, e.g. 'atp[m]', then true (default=false)
%OUTPUTS
% neighborRxns  the neighboring rxns in the network, (having common
%               metabolites)
% neighborGenes the gprs associated with the neighbor rxns
% mets          the metabolites in the target reaction
%
% Jeff Orth
% 10/11/09
%
% Nikos Ignatiadis 10/7/2013 now provides more options, e.g. common metabolites and order of neighbors

% set defaults
if ~exist('order','var') || isempty(order) || order < 1
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

% start to find neighbors
for i = 1:numel(rxns)
	% count cells already filled, so new values can be added below
	runningRxnIndex  = numel(neighborRxns);
	runningGeneIndex = numel(neighborGenes);
	rxn = rxns{i};

	%get the metabolites in the rxn and exclude common ones
	metIndex = find(model.S(:,findRxnIDs(model,rxn)));
	metIndex = setdiff(metIndex,commonMetsIndex);


	%get the rxns for each met
	nRxnIndexs = {};
	for i = 1:length(metIndex)
    	nRxnIndexs{i} = find(model.S(metIndex(i),:));
	end 

	% remove target rxn from list
	for i = 1:length(metIndex);
    	nRxnIndexs{i} = setdiff(nRxnIndexs{i},findRxnIDs(model,rxn));
	end

	for i = 1:length(metIndex)
    	neighborRxns{runningRxnIndex + i} = model.rxns(nRxnIndexs{i});
	end

	%get genes for each rxn
	for i = 1:length(metIndex)
    	neighborGenes{runningGeneIndex + i} = model.grRules(nRxnIndexs{i});
	end

	mets = unique([mets; model.mets(metIndex)]);
end


if asSingleArray
	neighborRxnsTmp  = neighborRxns;
	neighborGenesTmp = neighborGenes;
	neighborRxns  = {}; 
	neighborGenes = {};
	for i=1:numel(neighborRxnsTmp)
		neighborRxns  = [neighborRxns; neighborRxnsTmp{i}];
		neighborGenes = [neighborGenes; neighborGenesTmp{i}];
	end
	neighborRxns  = unique(neighborRxns);
	neighborGenes = unique(neighborGenes);
	% remove empty GPR
	neighborGenes= neighborGenes(~cellfun(@isempty, neighborGenes));
end

% recursively find higher order neighbors
if order >=2 & asSingleArray
	[recursiveNeighborRxns, recursiveNeighborGenes, recursiveMets] = ...
		findNeighborRxns(model, neighborRxns', asSingleArray, order -1 ,  commonMets);
	neighborRxns = unique([neighborRxns; recursiveNeighborRxns]);
	neighborGenes = unique([neighborGenes; recursiveNeighborGenes]);
	mets = unique([mets; recursiveMets]);
end

end


