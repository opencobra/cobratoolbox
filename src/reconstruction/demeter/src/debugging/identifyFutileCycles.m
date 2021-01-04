function [futileCycleReactions]=identifyFutileCycles(model)

initCobraToolbox(false)
solverOK=changeCobraSolver('ibm_cplex','LP');
% prevent creation of log files
changeCobraSolverParams('LP', 'logFile', 0);

% load Western diet
WesternDiet = readtable('WesternDietAGORA2.txt', 'Delimiter', '\t');
WesternDiet=table2cell(WesternDiet);
WesternDiet=cellstr(string(WesternDiet));

FutileCyclesTest={};
% apply Western diet
model = useDiet(model,WesternDiet);
model=changeRxnBounds(model,'EX_o2(e)',0,'l');
model_old=model;
model=changeObjective(model,'DM_atp_c_');
FBAorg=optimizeCbModel(model_old,'max');
Rxns=printRxnFormula(model);
for i=1:length(model.rxns)
    if ~strcmp(model.rxns{i},'DM_atp_c_')
        modelTest=model;
        FutileCyclesTest{i,1}=model.rxns{i,1};
        modelTest.lb(i,1)=0;
        modelTest.ub(i,1)=0;
        FBA=optimizeCbModel(modelTest,'max');
        %     model.lb(i,1)=0;
        %     model.ub(i,1)=0;
        %     FBA=optimizeCbModel(model,'max');
        FutileCyclesTest{i,2}=Rxns{i,1};
        FutileCyclesTest{i,3}=model_old.lb(i,1);
        FutileCyclesTest{i,4}=model_old.ub(i,1);
        FutileCyclesTest{i,5}=FBA.f;
        FutileCyclesTest{i,6}=FBAorg.x(i,1);
    end
end
model=model_old;

for i=1:length(model.rxns)
    if ~strcmp(model.rxns{i},'DM_atp_c_') && ~strcmp(model.rxns{i},'ATPS4') && ~strncmp(model.rxns{i},'EX_',3)
    FutileCyclesTest{i,1}=model.rxns{i,1};
        model.lb(i,1)=0;
        model.ub(i,1)=0;
        FBA=optimizeCbModel(model,'max');
%     model.lb(i,1)=0;
%     model.ub(i,1)=0;
%     FBA=optimizeCbModel(model,'max');
    FutileCyclesTest{i,2}=Rxns{i,1};
    FutileCyclesTest{i,3}=model_old.lb(i,1);
    FutileCyclesTest{i,4}=model_old.ub(i,1);
    FutileCyclesTest{i,5}=FBA.f;
    FutileCyclesTest{i,6}=FBAorg.x(i,1);
    end
end

end
