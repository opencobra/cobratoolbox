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
    rxnsMets=findRxnsFromMets(model,Name_met);
    formulas = printRxnFormula(model,rxnsMets,false);

    for j=1:numel(formulas)
        metaboliteList = parseRxnFormula(formulas{j});
        [baseMetNames,compSymbols,uniqueMetNames,uniqueCompSymbols] = parseMetNames(metaboliteList);

        if sum(strcmp(baseMetNames,[Name_met(1:end-3)]))== 2 && sum(strcmp(uniqueMetNames,[Name_met(1:end-3)]))== 1
            if ~isempty(compFlag)
                if sum(strcmp(uniqueCompSymbols,compFlag))== 1
                    TrspRxns(end+1)=rxnsMets(j);
                end
            else
                TrspRxns(end+1)=rxnsMets(j);
            end
        end
    end
end
