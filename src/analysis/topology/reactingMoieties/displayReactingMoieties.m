function displayReactingMoieties(reacting)
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