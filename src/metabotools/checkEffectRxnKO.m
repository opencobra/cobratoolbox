function [FBA_Rxns_KO,ListResults] = checkEffectRxnKO(samples_to_test,fill,Genes_to_test,samples,ResultsAllCellLines)
% This function checks the effect of constraining reactions associated 
% with a single or set of genes on the ability of the model to satisfy
% an objective.
%
% USAGE:
%
%    [FBA_Rxns_KO, ListResults] = checkEffectRxnKO(samples_to_test, fill, Genes_to_test, samples, ResultsAllCellLines)
%
% INPUTS:
%      ResultsAllCellLines:   uses `modelMin`
%      samples:               Name of samples
%      samples_to_test:       Name of samples that should be tested (can be samples if all should be tested)
%      fill:                  Identifier if the `rxns` is not in the model (e.g.,100, num('NAN'))
%      Genes_to_test:         Set of genes to be tested
%      
% OUTPUTS:
%      FBA_Rxns_KO:           FBA results for constraining one reaction at a time to zero.
%      ListResults:           Reactions associated with `Genes_to_test`, same order as `FBA_Rxns_KO`.
%
% .. Authors: - Maike K. Aurich 02/07/15 (Depends on changeRxnBounds, optimizeCbModel, and findRxnsFromGenes)

n=1;

FBA_Rxns_KO = {'Reaction','FBA.f','FBA.stat'};

for j= 1:length(samples_to_test)
    get_model = find(ismember(samples, samples_to_test(j,1)));
    modelMin = eval(['ResultsAllCellLines.', char(samples(get_model,1)), '.modelMin']);
    
    if j==1
        [results,ListResults] = findRxnsFromGenes(modelMin,Genes_to_test,1,1);
    end
    
    for i=1:length(ListResults)
        if ismember(ListResults{i},modelMin.rxns)
            model1 = changeRxnBounds(modelMin, ListResults(i), 0, 'b');
            FBA = optimizeCbModel(model1);
            FBA_Rxns_KO(i+1,n) = ListResults(i);
            FBA_Rxns_KO{i+1,n+2}= FBA.stat;
            FBA_Rxns_KO{i+1,n+1}= FBA.f;
            
        else
            FBA_Rxns_KO{i+1,n+2}= fill;
            FBA_Rxns_KO{i+1,n+1}= fill;
            
        end
       
    end
    
end





