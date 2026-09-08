function reacting = buildReactingMoietyTables(reacting, formedBondsTable, brokenBondsTable)
% Build per-reaction tables of reacting moieties (formed and broken bonds) for each selected reaction
%
% USAGE:
%
%    reacting = buildReactingMoietyTables(reacting, formedBondsTable, brokenBondsTable)
%
% INPUTS:
%    reacting:            structure describing reacting moieties, with fields:
%
%                           * .selectedReactionNames - cell/string array of reaction names to process
%                           * .reactMoietyTables - cell array of per-reaction moiety tables (populated by this function)
%    formedBondsTable:    table of formed bonds, with a `rxns` column (`.rxns`) identifying the reaction of each bond
%    brokenBondsTable:    table of broken bonds, with a `rxns` column (`.rxns`) identifying the reaction of each bond
%
% OUTPUTS:
%    reacting:            input `reacting` structure with `.reactMoietyTables` populated, one table per selected reaction
%
% NOTE:
%    `reactMoietyTables{k}` is always a typed table -- including a `BondChange`
%    column -- even for a reaction with zero reacting bonds (both `formedBondsTable`
%    and `brokenBondsTable` empty for that reaction). It is never a bare, columnless
%    `table()`; its column set matches the non-empty case exactly, just with zero rows.

rxnList = reacting.selectedReactionNames;
reacting.reactMoietyTables = cell(numel(rxnList),1);

for k = 1:numel(rxnList)

    rxn = string(rxnList(k));   % ← FIXED LINE

    F = formedBondsTable(strcmp(string(formedBondsTable.rxns), rxn), :);
    B = brokenBondsTable(strcmp(string(brokenBondsTable.rxns), rxn), :);

    % BondChange is assigned unconditionally -- including to a 0-row F/B --
    % rather than only when non-empty: F and B are always row-slices of the
    % same dBTM.Edges schema (identifyConservedReactingSubgraphs.m), so this
    % keeps both sides column-consistent before [F; B] concatenates, whether
    % zero, one, or both sides are empty. That in turn lets the rest of this
    % function's processing (below) run unconditionally: at n = height(T) ==
    % 0 every loop here is a no-op, so a reaction with no reacting bonds
    % naturally produces a table with the same typed column schema as the
    % non-empty case (never a bare, columnless table()).
    F.BondChange = repmat("formed", height(F), 1);
    B.BondChange = repmat("broken", height(B), 1);

    T = [F; B];

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