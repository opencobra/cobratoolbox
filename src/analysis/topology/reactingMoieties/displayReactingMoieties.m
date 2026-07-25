function displayReactingMoieties(reacting)
% Print a summary and the per-reaction tables of reacting moieties to the command window
%
% USAGE:
%
%    displayReactingMoieties(reacting)
%
% INPUT:
%    reacting:    structure describing reacting moieties, with fields:
%
%                   * .selectedReactionNames - cell/string array of reaction names
%                   * .reactMoietyTables - cell array of per-reaction moiety tables (one per selected reaction)

rxnList = reacting.selectedReactionNames;
nRxn = numel(rxnList);

summary = table('Size',[nRxn 4], ...
    'VariableTypes',["string","double","double","double"], ...
    'VariableNames',["Reaction","NumFormed","NumBroken","Total"]);

for k = 1:nRxn

    T = reacting.reactMoietyTables{k};

    summary.Reaction(k) = string(rxnList{k});
    summary.NumFormed(k)= sum(T.BondChange=="formed");
    summary.NumBroken(k)= sum(T.BondChange=="broken");
    summary.Total(k)    = height(T);
end

disp("Reacting moieties summary:")
disp(summary)

for k = 1:nRxn
    fprintf("\n=== Reacting moiety %d (reaction %s) ===\n",k,rxnList{k});
    disp(reacting.reactMoietyTables{k});
end

end