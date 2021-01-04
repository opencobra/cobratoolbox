function [model, unusedExchanges] = findUnusedExchangeReactions(model)

% finds exchange reactions that are no longer used and should be deleted
% after deleting unnecessary transport reactions gapfilled by Model Seed

unusedExchanges = {};

% find the exchange reactions
ExRxns = model.rxns(strmatch('EX', model.rxns));

% find the transported metabolites
ExFormulas = printRxnFormula(model, ExRxns);

for i = 1:length(ExFormulas)
    findExMet = strsplit(ExFormulas{i, 1}, ' ');
    ExMets{i, 1} = findExMet{1, 1};
end

% now find the ones that don't participate in any other reaction
for i = 1:length(ExMets)
[rxnList, rxnFormulaList] = findRxnsFromMets(model, ExMets{i, 1}, 'printFlag', 0);
RxnsUsedIn{i, 1} = ExMets{i, 1};
RxnsUsedIn{i, 2} = rxnList;
end

% print the results
cnt = 1;
for i = 1:length(RxnsUsedIn)
    if size(RxnsUsedIn{i, 2}) < 2
        unusedExchanges(cnt, 1) = RxnsUsedIn{i, 2};
        cnt = cnt + 1;
    end
end
    model = removeRxns(model, unusedExchanges);
end
