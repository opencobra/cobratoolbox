function futileCycleReactions=identifyFutileCycles(model)

futileCycleReactions = {};
    
% load Western diet
WesternDiet = readtable('WesternDietAGORA2.txt', 'Delimiter', '\t');
WesternDiet=table2cell(WesternDiet);
WesternDiet=cellstr(string(WesternDiet));

FutileCyclesTest={};
% apply Western diet
model = useDiet(model,WesternDiet);
model=changeObjective(model,'DM_atp_c_');
FBAorg=optimizeCbModel(model,'max');

if FBAorg.f > 150

Rxns=printRxnFormula(model);
for i=1:length(model.rxns)
    if ~strcmp(model.rxns{i},'DM_atp_c_') && ~strncmp(model.rxns{i},'ATPS',4)
        modelTest=model;
        FutileCyclesTest{i,1}=model.rxns{i,1};
        modelTest.lb(i,1)=0;
        modelTest.ub(i,1)=0;
        FBA=optimizeCbModel(modelTest,'max');
        FutileCyclesTest{i,2}=Rxns{i,1};
        FutileCyclesTest{i,3}=model_old.lb(i,1);
        FutileCyclesTest{i,4}=model_old.ub(i,1);
        FutileCyclesTest{i,5}=FBA.f;
        FutileCyclesTest{i,6}=FBAorg.x(i,1);
    end
end

FutileCyclesTest(find(cellfun(@isempty, FutileCyclesTest(:,1))),:)=[];
futileCycleReactions=FutileCyclesTest(cell2mat(FutileCyclesTest(:,5))<150,1);

end

end
