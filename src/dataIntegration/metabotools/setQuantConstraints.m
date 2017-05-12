function [ResultsAllCellLines,OverViewResults] = setQuantConstraints(model, samples, tol, minGrowth, obj, no_secretion, no_uptake, medium, addExtraExch, addExtraExch_value, path, epsilon)
% This function takes a model and quantitative extracellular metabolomic
% data and returns a model in which the data is integrated as constraints.
% It requires as input the output of the script ... and the output can be
% the input for the analysis functions in this toolbox.
%
% USAGE:
%
%    [ResultsAllCellLines, OverViewResults] = setQuantConstraints(model, samples, tol, minGrowth, obj, no_secretion, no_uptake, medium, addExtraExch, addExtraExch_value, path, epsilon)
%
% INPUTS:
%       model:                Global metabolic model (Recon)
%       samples:              Vector specifying the samples used (there must be an output file of function .... for each sample)
%       tol:                  Cutoff value for small numbers (e.g., -1e-8). All number smaller than tol will be treated as zero
%       minGrowth:            Will be the lower bound of the objective function (e.g., 0.008). Forces the output model(s) to be able to produce a minimal objective value
%       obj:                  Objective function, e.g. `biomass_reaction2`
%       no_secretion:         Define metabolites that should not be secreted (e.g., {`EX_o2(e)`})
%       no_uptake:            Define metabolites that should not be consumed (e.g., {`EX_o2s(e)`, `EX_h2o2(e)`})
%       medium:               Define if certain exchanges should be excluded from minimization of exchanges (e.g., {}, if no medium except the exometabolomic data has been defined)
%       addExtraExch:         After adding secretions, models are still not growing, this variable allows one to recover exchanges with a defined small value
%       addExtraExch_value:   e.g. 1 as arbitrary small flux value / the resulting ub = 1, lb = -1.
%       path:                 Location of the .mat files for samples.
%       epsilon: (not used)
%
% OUTPUTS:
%       ResultsAllCellLines:  Structure that contains pruned and unpruned model, Vector of the Exchange_reactions, the exchange reactions added by `minExCard`, `minFLux` and `maxFlux` of the added reactions, maximal objective value, and the results of the gene deletion
%       OverViewResults:      Overview of model statistics, e.g., number of reactions, metabolites, genes, number of essential genes, min and max objective values for easy comparison between sets of models
%
%
% Depends on `changeRxnBounds`, `fluxVariability`, `optimizeCbModel`, `generateCompactExchModel` as well its dependent functions `pruneModel`, `findMinCardModel`, `findOptExchRxns`
%
% .. Author: - Maike K. Aurich 18/02/15

cntO=1;
% Set overview variable
OverViewResults{1,cntO} ='cell line';cntO = cntO+1;
OverViewResults{1,cntO} = 'num Added Rxns';cntO = cntO+1;
OverViewResults{1,cntO} = 'num rxns pruned model';cntO = cntO+1;
OverViewResults{1,cntO} = 'num mets pruned model';cntO = cntO+1;
OverViewResults{1,cntO} = 'num genes pruned model';cntO = cntO+1;
OverViewResults{1,cntO} = 'max growth rate';cntO = cntO+1;
OverViewResults{1,cntO} = 'num exch rxns';cntO = cntO+1;
OverViewResults{1,cntO} = 'O2 requirement';cntO = cntO+1;
OverViewResults{1,cntO} = 'extra Exchanges Added';cntO = cntO+1;
OverViewResults{1,cntO} = 'num recovered exchanges';cntO = cntO+1;

for j = 1:length(samples)

    j
    %   load([path filesep 'model.mat']); %% uncomment for Recon1
    ExtraExchAdded = 0;


    FILENAME = char(samples(j,1));
    load([path filesep FILENAME '.mat'])%, 'uptake_value', 'secr_value' , 'uptake' ,'secretion', 'cell_line' );


    % Map exo-metabolomic data
    model2=model;
    model2.lb(find(ismember(model2.rxns,obj)))=minGrowth;% based on slowlest cell line in data


    % Map uptake
    for k=1:length(uptake)
        Uptake_rxns=uptake(k);
        lb = uptake_value(k,2);
        ub = uptake_value(k,3);
        model2 = changeRxnBounds(model2,Uptake_rxns,ub,'u'); %enforce uptake of metabolites taken up by cells in the experiment
        model2 = changeRxnBounds(model2,Uptake_rxns,lb,'l'); %enforce uptake of metabolites taken up by cells in the experiment

    end
    clear A sol
    model2ori=model2;
    SecretionRxnsRecovered =[];
    cnt2=1;

    % Map secretion
    for k=1:length(secretion)
        secretion_rxns= secretion(k);
        lb = secr_value(k,3);
        ub = secr_value(k,2);
        model2 = changeRxnBounds(model2, secretion_rxns,lb,'l');% enforce secretion of metabolites that are secreted by the cells in the experiment
        model2 = changeRxnBounds(model2, secretion_rxns,ub,'u');% enforce secretion of metabolites that are secreted by the cells in the experiment

        % check if model works after adding constraints
        SOL = optimizeCbModel(model2);
        if SOL.f<=abs(tol)
            sol(k,1)=SOL.f;
            secretion_rxns
            model2=model2ori; % model2ori is overwritten after each successful iteration so its not the original model (without any secretions)
            model2 = changeRxnBounds(model2, secretion_rxns,ub,'u');% set secretion of metabolite to measured upper bound nevertheless
            SecretionRxnsRecovered{cnt2,1}=secretion_rxns{1,:}; cnt2 = cnt2 +1;
        else
            sol(k,1)=SOL.f;
            model2ori=model2;
        end
    end

    % sets bounds to the lowest measured uptake/secretion rate
    for k=1:length(No_upt_secr)
        No_upt_secr_rxns= No_upt_secr(k);
        bound = min(abs([max(uptake_value(:,3));min(secr_value(:,3))]));
        model2 = changeRxnBounds(model2, No_upt_secr_rxns,-bound,'l');
        model2 = changeRxnBounds(model2, No_upt_secr_rxns,bound,'u');% sets bounds to the lowest measured uptake/secretion rate
    end



    % do not allow secretion or uptake of certain metabolites
    model2 = changeRxnBounds(model2, no_secretion,0,'u');% enforce secretion of metabolites that are secreted by the cells in the experiment
    model2 = changeRxnBounds(model2, no_uptake,0,'l');% enforce secretion of metabolites that are secreted by the cells in the experiment



    %% test if model can grow AT ALL
    SOL = optimizeCbModel(model2);
    if abs(SOL.f) < abs(tol)

        model2 = changeRxnBounds(model2, addExtraExch,-addExtraExch_value,'l');% sets bounds to the lowest measured uptake/secretion rate
        model2 = changeRxnBounds(model2, addExtraExch,addExtraExch_value,'u');% sets bounds to the lowest measured uptake/secretion rate
        ExtraExchAdded = 1;
    end


    SOL = optimizeCbModel(model2);
    if abs(SOL.f) > abs(tol)
        %Generate submodel
        [modelMin, modelPruned, Ex_Rxns] = generateCompactExchModel(model2,minGrowth);

        %added 23/07/2015
        modelPruned.c = zeros(length(modelPruned.rxns),1);
        modelPruned.c(find(ismember(modelPruned.rxns,obj)),1)=1;
        %added 23/07/2015

        sol= optimizeCbModel(modelPruned);
        Ex_RxnsAdded = Ex_Rxns;

        % remove reactions that are in uptake and secretion
        US = unique([secretion;uptake]);
        Ex_RxnsAdded(ismember(Ex_RxnsAdded,US))=[];
        [a(:,1),a(:,2)]=fluxVariability(modelPruned,1,[],Ex_RxnsAdded);


        % print Results

        ResultsAllCellLines.(samples{j}).modelPruned = modelPruned;
        ResultsAllCellLines.(samples{j}).modelMin = modelMin;
        ResultsAllCellLines.(samples{j}).Ex_Rxns = Ex_Rxns;
        ResultsAllCellLines.(samples{j}).Ex_RxnsAdded = Ex_RxnsAdded;
        ResultsAllCellLines.(samples{j}).MinMaxAddedRxns = a;
        ResultsAllCellLines.(samples{j}).maxBiomass = sol;

        ResultsAllCellLines.(samples{j}).SecretionRxnsRecovered = SecretionRxnsRecovered;

        cntO=1;
        OverViewResults{j+1,cntO} = samples{j};cntO = cntO+1;% cell line
        OverViewResults{j+1,cntO} = num2str(length(ResultsAllCellLines.(samples{j}).Ex_RxnsAdded));cntO = cntO+1;% num Added Rxns
        OverViewResults{j+1,cntO} = num2str(length(ResultsAllCellLines.(samples{j}).modelPruned.rxns));cntO = cntO+1;% num rxns
        OverViewResults{j+1,cntO} = num2str(length(ResultsAllCellLines.(samples{j}).modelPruned.mets));cntO = cntO+1;% num mets
        OverViewResults{j+1,cntO} = num2str(length(ResultsAllCellLines.(samples{j}).modelPruned.genes));cntO = cntO+1;% num genes
        OverViewResults{j+1,cntO} = num2str(ResultsAllCellLines.(samples{j}).maxBiomass.f);cntO = cntO+1;% max growth rate
        OverViewResults{j+1,cntO} = num2str(length(ResultsAllCellLines.(samples{j}).Ex_Rxns));cntO = cntO+1;% num Exchange rxns
        if ~isempty(strmatch('EX_o2(e)',ResultsAllCellLines.(samples{j}).Ex_RxnsAdded))
            OverViewResults{j+1,cntO} = num2str(1);cntO = cntO+1;% O2 requirement
        else
            OverViewResults{j+1,cntO} = num2str(0);cntO = cntO+1;% O2 requirement
        end

        OverViewResults{j+1,cntO} = num2str(ExtraExchAdded);cntO = cntO+1;% num Exchange rxns
        OverViewResults{j+1,cntO} = num2str(length(SecretionRxnsRecovered));cntO = cntO+1;% num Exchange rxns


    else
        ResultsAllCellLines.(samples{j}).model = [];
        ResultsAllCellLines.(samples{j}).AddedExchange = [];
        ResultsAllCellLines.(samples{j}).maxBiomass = [];
        cntO=1;
        OverViewResults{j+1,cntO} = samples{j};cntO = cntO+1;% cell line
    end
    clear sol Extra* addExtraExch* model2 modelMin* modelU* modelP* model2ori No* upt* secr* gr* Rxn* cnt* Blocked* h* FBA* j k m bound ans lb Close* Ex_Rxns1* Ex_Rxns2*  Sol U* Ori* i* ma* rev* t un* us* w a SOL a1 ub ToDe* ReP* Ex_* Secr* AddedExchang*
    save([path filesep 'setQuantConstraints.mat'], '-v7.3');
end

end
