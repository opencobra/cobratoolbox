function [model, deletedSEEDRxns] = deleteSeedGapfilledReactions(model, biomassReaction)
% Part of the DEMETER pipeline. Deletes reactions gapfilled by the Model
% SEED pipeline that are no longer needed after the reconstruction was
% refined.
%
% INPUT
% model             COBRA model structure
% biomassReaction   Biomass reaction abbreviation
%
% OUTPUT
% model             COBRA model structure
% deletedSEEDRxns   deleted gapfilled reactions
%
% .. Authors:
% Almut Heinken and Stefania Magnusdottir, 2016-2019

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

tol = 1e-8;

gfRxns = model.rxns(find(strcmp(model.grRules,'')));
gfRxns = union(gfRxns, model.rxns(strncmp('Unknown', model.grRules, length('Unknown'))));
gfRxns = union(gfRxns, model.rxns(strncmp('0000000.0.peg', model.grRules, length('0000000.0.peg'))));
gfRxns = union(gfRxns, model.rxns(strncmp('AUTOCOMPLETION', model.grRules, length('AUTOCOMPLETION'))));
gfRxns = union(gfRxns, model.rxns(strncmp('INITIALGAPFILLING', model.grRules, length('INITIALGAPFILLING'))));

% not consider exchange, demand, and sink reactions
gfRxns(find(strncmp(gfRxns,'EX_',3)),:)=[];
gfRxns(find(strncmp(gfRxns,'DM_',3)),:)=[];
gfRxns(find(strncmp(gfRxns,'sink_',5)),:)=[];

% only consider reactions that were already in draft reconstructions
translateRxns = readtable('ReactionTranslationTable.txt', 'Delimiter', '\t');
translateRxns=table2cell(translateRxns);
gfRxns=intersect(gfRxns,translateRxns(:,2));

noDelete = {biomassReaction; 'O2t'; 'O2t5i'; 'CO2t'; 'MG2abc'; 'H2Ot'; 'L2A6ODs'; 'G5SADs'; 'AOBUTDs'; 'ACGAMK'; 'DM_atp_c_'; 'FE3abc'; 'SO4t2'; 'TSULabc'; 'PDHbr'; 'PDHc'; 'INDOLEt2r'; 'SUCCt2r'; 'PHEt2r'; 'TRPt2r'};
checkDelete = setdiff(gfRxns, noDelete);

transp = {  % delete exchange reaction with following transporters
            'AHCYSts', 'EX_ahcys(e)'
            'ALAHISabc', 'EX_alahis(e)'
            'ALALEUabc', 'EX_alaleu(e)'
            'CBIabc', 'EX_cbi(e)'
            'CGLYabc', 'EX_cgly(e)'
            'CHORt', 'EX_chor(e)'
            'CMPt2', 'EX_cmp(e)'
            'COAt', 'EX_coa(e)'
            'Cut1', 'EX_cu2(e)'
            'CYTDt4', 'EX_cytd(e)'
            'DATPt', 'EX_datp(e)'
            'DDCAt', 'EX_ddca(e)'
            'DGSNt2', 'EX_dgsn(e)'
            'DGTPt', 'EX_dgtp(e)'
            'DPCOAt', 'EX_dpcoa(e)'
            'DTMPt', 'EX_dtmp(e)'
            'DTTPti', 'EX_dttp(e)'
            'ETHAt2', 'EX_etha(e)'
            'G6Pt6_2', 'EX_g6p(e)'
            'GLYC3Pt', 'EX_glyc3p[e]'
            'HDCEAtr', 'EX_hdcea(e)'
            'MALTHPabc', 'EX_malthp(e)'
            'MALTHXabc', 'EX_malthx(e)'
            'MK7te', 'EX_mqn7(e)'
            'NADPt', 'EX_nadp(e)'
            'OCDCAt2', 'EX_ocdca(e)'
%             'PTRCt2', 'EX_ptrc(e)'
            'SALCt2', 'EX_salc(e)'
            'THMMPt2', 'EX_thmmp(e)'
            'TTDCAt2', 'EX_ttdca(e)'
            'UREAt', 'EX_urea(e)'
            };
cnt = 1;
deletedSEEDRxns = {};
model = changeRxnBounds(model, model.rxns(strmatch('EX_', model.rxns)), -1000, 'l');
model = changeRxnBounds(model, 'EX_o2(e)', 0, 'l');

% minFlux = zeros(size(model.rxns));
% maxFlux = zeros(size(model.rxns));
% % reaction vector is not sorted, so cannot run fastFVA on all reactions at
% % once
% for n = 1:length(model.rxns)
%     model = changeObjective(model, model.rxns{n});
%     sol = optimizeCbModel(model, 'max');
%     maxFlux(n) = sol.f;
%     sol = optimizeCbModel(model, 'min');
%     minFlux(n) = sol.f;
% end

checkDelete=intersect(model.rxns,checkDelete,'stable');
try
    [minFlux, maxFlux, ~, ~] = fastFVA(model, 0, 'max', 'ibm_cplex', ...
        checkDelete, 'S');
catch
    warning('fastFVA could not run, so fluxVariability is instead used. Consider installing fastFVA for shorter computation times.');
    [minFlux, maxFlux] = fluxVariability(model, 0, 'max', checkDelete);
end

model = changeObjective(model, biomassReaction);

% first check for and remove all blocked reactions
for i = 1:size(checkDelete, 1)
    if ~isempty(find(ismember(transp(:, 1), checkDelete{i, 1})))
        if abs(minFlux(i, 1)) < tol && abs(maxFlux(i, 1)) < tol
            modelTest = changeRxnBounds(model, checkDelete{i, 1}, 0, 'b');
            FBA = optimizeCbModel(modelTest, 'max');
            if FBA.f > tol
                deletedSEEDRxns{cnt, 1} = transp{find(strcmp(transp(:,1),checkDelete{i, 1})), 1};
                deletedSEEDRxns{cnt + 1, 1} = transp{find(strcmp(transp(:,1),checkDelete{i, 1})), 2};
                cnt = cnt + 2;
            end
        end
    else
        if abs(minFlux(i, 1)) < tol && abs(maxFlux(i, 1)) < tol
            modelTest = changeRxnBounds(model, checkDelete{i, 1}, 0, 'b');
            FBA = optimizeCbModel(modelTest, 'max');
            if FBA.f > tol
                deletedSEEDRxns{cnt, 1} = checkDelete{i, 1};
                cnt = cnt + 1;
            end
        end
    end
end

% then the reactions that are not blocked but may be safely deleted
% load Western diet
WesternDiet = readtable('WesternDietAGORA2.txt', 'Delimiter', '\t');
WesternDiet=table2cell(WesternDiet);
WesternDiet=cellstr(string(WesternDiet));

% apply Western diet
modelTest = useDiet(model,WesternDiet);
for i = 1:size(checkDelete, 1)
    if ~isempty(find(ismember(transp(:, 1), checkDelete{i, 1})))  % if deleted reaction is in transporter list
        trListInd = find(ismember(transp(:, 1), checkDelete{i, 1}));
        trInd = find(ismember(modelTest.rxns, transp{trListInd, 1}));
        exInd = find(ismember(modelTest.rxns, transp{trListInd, 2}));
        savedTrLB = modelTest.lb(trInd);
        savedTrUB = modelTest.ub(trInd);
        savedExLB = modelTest.lb(exInd);
        savedExUB = modelTest.ub(exInd);
        modelTest = changeRxnBounds(modelTest, transp{trListInd, 1}, 0, 'b');
        modelTest = changeRxnBounds(modelTest, transp{trListInd, 2}, 0, 'b');
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f > 1e-6
            deletedSEEDRxns{cnt, 1} = transp{trListInd, 1};
            deletedSEEDRxns{cnt + 1, 1} = transp{trListInd, 2};
            cnt = cnt + 2;
            modelTest = removeRxns(modelTest, {transp{trListInd, 1}, transp{trListInd, 2}});
        else
            modelTest.lb(trInd) = savedTrLB;
            modelTest.ub(trInd) = savedTrUB;
            modelTest.lb(exInd) = savedExLB;
            modelTest.ub(exInd) = savedExUB;
        end
    else
        rxnInd = find(ismember(modelTest.rxns, checkDelete{i, 1}));
        savedRxnLB = modelTest.lb(rxnInd);
        savedRxnUB = modelTest.ub(rxnInd);
        modelTest = changeRxnBounds(modelTest, checkDelete{i, 1}, 0, 'b');
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f > tol
            deletedSEEDRxns{cnt, 1} = checkDelete{i, 1};
            cnt = cnt + 1;
            modelTest = removeRxns(modelTest, checkDelete{i, 1});
        else
            modelTest.lb(rxnInd) = savedRxnLB;
            modelTest.ub(rxnInd) = savedRxnUB;
        end
    end
end
model = removeRxns(model, deletedSEEDRxns);

% change back to unlimited medium
% list exchange reactions
exchanges = model.rxns(strncmp('EX_', model.rxns, 3));
% open all exchanges
model = changeRxnBounds(model, exchanges, -1000, 'l');
model = changeRxnBounds(model, exchanges, 1000, 'u');

end
