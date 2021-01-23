function [leakingRxns]=identifyLeakingReactions(model)

% Performs fastLeakTest for all microbes
% Code: [LeakRxns] = fastLeakTest(model, testRxns)

Leaking_DMRxns=[];
% for finished models (constraint adjustment done)
% find exchanges and sinks
selExch = findExcRxns(model);
[LeakRxns,modelTested] = fastLeakTest(model,model.rxns(selExch), true);
[Rxns]=printRxnFormula(modelTested);
k=1;
for j=1:length(LeakRxns)
    %check the leaking metabolites, what reactions are causing them to leak?
    if strmatch('EX',LeakRxns{j})
        modelTested=changeObjective(modelTested,LeakRxns{j});
        FBA=optimizeCbModel(modelTested,'max','one');
        for l=1:length(modelTested.rxns)
            Leaking_DMRxns{1,1}='Rxns';
            Leaking_DMRxns{1,2}='Formulas';
            Leaking_DMRxns{1,3}=(LeakRxns{j});
            Leaking_DMRxns{1,4}='Closed_FBA';
            if FBA.x(l)> 0.0001
                Leaking_DMRxns{k+1,1}=modelTested.rxns(l);
                Leaking_DMRxns{k+1,2}=Rxns(l);
                Leaking_DMRxns{k+1,3}=FBA.x(l);
                k=k+1;
            elseif FBA.x(l)< -0.0001
                Leaking_DMRxns{k+1,1}=modelTested.rxns(l);
                Leaking_DMRxns{k+1,2}=Rxns(l);
                Leaking_DMRxns{k+1,3}=FBA.x(l);
                k=k+1;
            else
                continue;
            end
        end
    end
    % test which of these reactions are responsible for the leaking
    for i=2:length(Leaking_DMRxns)
        modelClose=changeRxnBounds(modelTested,Leaking_DMRxns{i},0,'b');
        FBA=optimizeCbModel(modelClose,'max');
        Leaking_DMRxns{i,4}=FBA.f;
    end
    biomassReaction = model.rxns{strncmp('biomass', model.rxns, 7)};
    [massImbalancedRxns, chargeImbalancedRxns, imbalancedRxnMets, metsMissingFormulas] = testModelMassChargeBalance(model, true, biomassReaction);
    
    % Identify the unbalanced reactions that are responsible
    ProbablyRespRxns=intersect(string(massImbalancedRxns(2:end,1)),string(Leaking_DMRxns(2:end,1)));
end

end
