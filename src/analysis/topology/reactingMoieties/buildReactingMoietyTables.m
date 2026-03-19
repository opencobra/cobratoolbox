function reacting = buildReactingMoietyTables(reacting, formedBondsTable, brokenBondsTable)

rxnList = reacting.selectedReactionNames;
reacting.reactMoietyTables = cell(numel(rxnList),1);

for k = 1:numel(rxnList)

    rxn = string(rxnList(k));   % ← FIXED LINE

    F = formedBondsTable(strcmp(string(formedBondsTable.rxns), rxn), :);
    B = brokenBondsTable(strcmp(string(brokenBondsTable.rxns), rxn), :);

    if ~isempty(F)
        F.BondChange = repmat("formed", height(F), 1);
    end
    if ~isempty(B)
        B.BondChange = repmat("broken", height(B), 1);
    end

    T = [F; B];

    if isempty(T)
        reacting.reactMoietyTables{k} = table();
        continue
    end

    T = movevars(T,"BondChange","Before",1);

    dropCols = intersect(T.Properties.VariableNames,...
        {'Trans','TransInstIndex','dirTransInstIndex'});
    T(:,dropCols) = [];

    isHeadEE = ismember(string(T.HeadBondElmts),"E-E");
    isTailEE = ismember(string(T.TailBondElmts),"E-E");

    n = height(T);
    BondEndNodes = zeros(n,2);
    BondElmts    = strings(n,1);
    BondStr      = strings(n,1);

    for i = 1:n

        if isHeadEE(i) && ~isTailEE(i)
            BondEndNodes(i,:) = T.EndNodes(i,:);
            BondElmts(i)      = string(T.TailBondElmts(i));
            BondStr(i)        = string(T.TailBond(i));

        elseif isTailEE(i) && ~isHeadEE(i)
            BondEndNodes(i,:) = T.EndNodes(i,:);
            BondElmts(i)      = string(T.HeadBondElmts(i));
            BondStr(i)        = string(T.HeadBond(i));

        else
            BondEndNodes(i,:) = T.EndNodes(i,:);
            BondElmts(i)      = string(T.TailBondElmts(i));
            BondStr(i)        = string(T.TailBond(i));
        end
    end

    T.BondEndNodes = BondEndNodes;
    T.BondElmts    = BondElmts;
    T.Bond         = BondStr;

    dropCols2 = intersect(T.Properties.VariableNames,...
        {'HeadBondIndex','TailBondIndex','HeadBond','TailBond',...
         'HeadBondElmts','TailBondElmts','EndNodes',...
         'HeadMet','TailMet','HeadMetBondTypes','TailMetBondTypes'});

    T(:,dropCols2) = [];

    T = movevars(T,{'BondEndNodes','BondElmts','Bond'},'After','BondChange');

    reacting.reactMoietyTables{k} = T;
end
end