function model = prepareModelNutrientGeneMCS(model, exchangeRxns)
% Add artificial genes for the exchange reactions and prepare model for the
% gMCS implementation which includes nutrients from the culture medium.
%
% USAGE:
%
%    model = prepareModelNutrientGeneMCS(model, exchangeRxns)
%
% INPUTS:
%    model:             Metabolic model structure (COBRA Toolbox format).
%
% OPTIONAL INPUTS:
%    exchangeRxns:      Exchange reactions to be included (default = all
%                       reactions which start by 'EX_', 'DM_' or 'sink_'
%                       and only have one metabolite involved.
%
% OUTPUTS:
%    model:             Metabolic model structure with genes for selected 
%                       exchanges (COBRA Toolbox format).
%
% EXAMPLE:
%
%    model = prepareModelNutrientGeneMCS(model, exchangeRxns);
%
% .. Authors:
%       - Inigo Apaolaza, 19/04/2020, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, 19/04/2020, University of Navarra, TECNUN School of Engineering.

if nargin<2
    exchangeRxns = [];
end


% Add genes to exchanges
if isempty(exchangeRxns)
    pos_exchanges = startsWith(model.rxns, 'EX_') + startsWith(model.rxns, 'DM_') + startsWith(model.rxns, 'sink_');
    pos_exchanges = find(pos_exchanges);
    n_all = length(pos_exchanges);
    n_mets = length(model.mets);
    % check that there is only one metabolite involved
    idx = false(n_all,1);
    for i = 1:n_all
        idx(i) = sum(model.S(:, pos_exchanges(i))==0) == n_mets-1;
    end
    pos_exchanges = pos_exchanges(idx);
else
    [~, pos_exchanges] = ismember(model.rxns, exchangeRxns);
    % check that there is only one metabolite involved
    n_all = length(pos_exchanges);
    n_mets = length(model.mets);
    idx = false(n_all,1);
    for i = 1:n_all
        idx(i) = sum(model.S(:, pos_exchanges(i))==0) == n_mets-1;
    end
    if any(~idx)
        warning('Some of the reactions inlcuded as nutrient exchange do not have only one metabolite involved')
    end
end

% perform a reaction spliting in the model and prepare it to the gMCS
% algorithm. In order to block nutrients, we need only to block the inputs,
% not the outputs.
modelRev = model;
[model, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(modelRev, 'sRxns', modelRev.rxns(pos_exchanges));
% transform index in reversible model to index in irreversible model
pos_exchanges_2 = [rev2irrev{pos_exchanges}];
% select only inputs
idx = false(length(pos_exchanges_2),1);
for i = 1:length(pos_exchanges_2)
    aux = unique(model.S(:, pos_exchanges_2(i)));
    idx(i) = length(aux(aux~=0))==1 && aux(aux~=0)>0;
end
pos_exchanges_2 = pos_exchanges_2(idx);

% % debug
% TT = table(model.rxns, model.lb, model.ub, printRxnFormula(model, 'printFlag', 0));
% TT2 = TT(setdiff(1:size(TT,1), pos_exchanges_2),:);
% TT = TT(pos_exchanges_2,:);

% add the artificial genes for the input reactions
n_all = length(pos_exchanges_2);
showprogress(0,['Adding genes for input reactions (n=' num2str(n_all) ')']);

for i = 1:n_all
    showprogress(i/n_all);
    model = changeGeneAssociation(model, model.rxns{pos_exchanges_2(i)}, ['gene_' strtok(model.rxns{pos_exchanges_2(i)}, '[')]);
end

end
