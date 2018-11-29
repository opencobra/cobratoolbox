function [TrspRxns] = findTrspRxnFromMet(model, metList, compFlag)
% Find transport reactions for defined metabolites. Option available to
% define the compartment of the transport
%
% USAGE:
%
%    [TrspRxns] = findTrspRxnFromMet(model, metList, compFlag)
%
% INPUTS:
%    model:       COBRA model structure
%    metList:     metabolites list
%
% OPTIONAL INPUT:
%    compFlag:    compartment of the transport (e.g. 'c', cytosol)
%
% OUTPUT:
%    TrspRxns:    List of transporters reactions
%
% .. Author: - Anne Richelle May 2017

if nargin < 3
    compFlag={};
end

TrspRxns={};
for i=1:numel(metList)

    formulas={};
    Name_met=metList{i};

    % Find the reactions involving the metabolite
    origMetPos = ismember(model.mets,Name_met);
    rxnMetIDs = model.S(origMetPos,:) ~=0;
    relReacs = model.rxns(rxnMetIDs);
    targetsubs = model.S(origMetPos,rxnMetIDs) < 0;
    targetProd = model.S(origMetPos,rxnMetIDs) > 0;
    [~,metID] = extractCompartmentsFromMets(Name_met);        
    otherpos = cellfun(@(x) ~isempty(strfind(x,metID)) && isempty(strfind(x,Name_met)),model.mets);
    otherS = model.S(otherpos,rxnMetIDs);
    if ~isempty(compFlag)
        matchComp = ismember(model.metComps(otherpos),compFlag);
    else
        matchComp = true(sum(otherpos),1);
    end
    othersubs = any(otherS(matchComp,:) < 0,1);
    otherProd = any(otherS(matchComp,:) > 0,1);
    rels = othersubs & targetProd | otherProd & targetsubs;
    TrspRxns = [TrspRxns,relReacs(rels)];   
end
