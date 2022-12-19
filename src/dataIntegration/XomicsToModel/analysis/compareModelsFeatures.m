function [comparisonResults, comparisonTable] = compareModelsFeatures(models, param)
% Compare the information of different COBRA models including dimentions,
% essential pathways, main energy sources, etc.
%
% USAGE:
%
%    [comparisonResults, comparisonTable] = compareModelsFeatures(models, param)
%
% INPUT:
%    models:    Struct file containing the models to compare
%    param:     a structure containing the parameters for the function:
%       * .comparisons -﻿Cell array indicating the type of comparison that
%          will be performed (Default: all):
%           - 'compartments': Check the metabolites on each of the cellular
%             compartments.
%           - 'uniqueElements': Check the genes, metabolites and reactions
%             present unique for each model.
%           - 'fluxAnalysis': Uses the selected objective function to predict
%             the flux in different metabolic pathways
%           - 'sparseFBA': Identify the number of essential reactions per
%             model
%           - 'predictiveCapacity': Using the selected objective function,
%             test the predictive capacity of the models
%       * .objectives -﻿The objective that will be used, includes the
%          optimization of reactions or objectives (Default:
%          unWeightedTCBMflux):
%          - 'unWeighted0norm' min 0-norm unweighted.
%          - 'Weighted0normGE' min 0-norm weighted by the gene expression.
%          - 'unWeighted1norm' min 1-norm unweighted
%          - 'Weighted1normGE' min 1-norm weighted by the gene expression
%          - 'unWeighted2norm' min 2-norm unweighted
%          - 'Weighted2normGE' min 2-norm weighted by the gene expression
%          - {'unWeightedTCBMflux'} unweighted thermodynamic constraint
%            based modelling for fluxes
%          - 'unWeightedTCBMfluxConc' unweighted thermodynamic constraint
%            based modelling for fluxes and concentrations
%       * .groups - Uses a common string to group the models together
%          (e.g., 'controlGroup')
%       * .printLevel - Verborese level
%       * .trainingSet - Table with the training set. It includes the
%          reaction identifier, the reaction name, the measured mean flux,
%          standard deviation of the flux, the flux units, and the platform
%          used to measure it (Required for test 'flux').
%
% OUTPUTS:
%
%	comparisonResults: Struct array with all data obtained
%	comparisonTable: Table summarising the analysis


if ~isfield(param, 'objectives')
    param.objectives = 'all';
end
if ~isfield(param, 'comparisons')
    param.comparisons = 'all';
end
if ~isfield(param, 'groups')
    param.groups = [];
end
if ~isfield(param, 'printLevel')
    param.printLevel = 1;
end
if ~isfield(param, 'trainingSet')
    param.trainingSet = [];
end

% List objectives
if ismember('all', param.objectives)
    param.objectives = {'unWeightedTCBMflux'};
    %     param.objectives = {'unWeighted0norm'; 'Weighted0normGE'; 'Weighted0normBBF'; ...
    %         'unWeighted1norm'; 'Weighted1normGE';  'Weighted1normBBF';...
    %         'unWeighted2norm'; 'Weighted2normGE'; 'Weighted2normBBF'; ...
    %         'unWeightedTCBMfluxConc';'unWeightedTCBMfluxConcNorm';'weightedTCBM';'weightedTCBMt'};
end

% List comparisons
if any(strcmp(param.comparisons, 'all'))
    param.comparisons = {'compartments'; 'uniqueElements'; 'fluxAnalysis'; ...
        'predictiveCapacity'};
end

%% Make groups and identify the metabolites on each compartment for each model

modelsToCheck = fieldnames(models);
assert(length(modelsToCheck) > 1, 'Two or more models are required for the comparison')

RowNames = {};
if ismember('compartments', param.comparisons)
    
    [metsTotal, rxnsTotal, genesTotal, subSystemsTotal] = deal({});
    [compartments, counts] = deal([]);
    for i = 1:length(modelsToCheck)
        
        % Check the compartments of the metabolites
        mets = models.(modelsToCheck{i}).mets;
        allCompartments = regexp(mets, '\[(.*?)\]', 'match', 'once');
        [uniqueCompartments, ~, ic] = unique(allCompartments);
        compartments = [compartments; setdiff(uniqueCompartments, compartments)];
        [~, locb] = ismember(compartments, uniqueCompartments);
        metsPerCompartment = accumarray(ic, ones(size(ic)));
        counts(1:length(uniqueCompartments), i) = metsPerCompartment(locb);
        
        % Total of metabolites
        metsTotal = unique([metsTotal; mets]);
        rxnsTotal = unique([rxnsTotal; models.(modelsToCheck{i}).rxns]);
        genesTotal = unique([genesTotal; models.(modelsToCheck{i}).genes]);
        subSystemsTotal = unique([subSystemsTotal; models.(modelsToCheck{i}).subSystems]);
    end
    
    % Compartment labels
    compartments = regexprep(compartments, '\[c\]', ' cytosol');
    compartments = regexprep(compartments, '\[m\]', ' mitochondria');
    compartments = regexprep(compartments, '\[r\]', ' endoplasmatic reticulum');
    compartments = regexprep(compartments, '\[e\]', ' extracellular');
    compartments = regexprep(compartments, '\[n\]', ' nucleus');
    compartments = regexprep(compartments, '\[x\]', ' peroxisome');
    compartments = regexprep(compartments, '\[l\]', ' lysosome');
    compartments = regexprep(compartments, '\[g\]', ' golgi apparatus');
    
    % Save results
    comparisonResults.totalInModels.metsTotal = metsTotal;
    comparisonResults.totalInModels.rxnsTotal = rxnsTotal;
    comparisonResults.totalInModels.genesTotal = genesTotal;
    comparisonResults.totalInModels.subSystemsTotal = subSystemsTotal;
    comparisonResults.compartment.compartments = compartments;
    comparisonResults.compartment.counts = counts;
    
    RowNames = [RowNames; 'Metabolites'; 'Unique metabolites'; 'Reactions'; ...
        'rank(S)'; 'Genes'; 'Subsystems'; strcat('Metabolites in', ...
        comparisonResults.compartment.compartments)];
end

%% Identify unique mets, rxns, genes and subSystems

if ismember('uniqueElements', param.comparisons)
    for i = 1:length(modelsToCheck)
        
        % Select the mets, rxns, genes and subSystems on each model
        metsDiff = models.(modelsToCheck{i}).mets;
        rxnsDiff = models.(modelsToCheck{i}).rxns;
        genesDiff = models.(modelsToCheck{i}).genes;
        subSystemsDiff = models.(modelsToCheck{i}).subSystems;
        
        % Go through all the models but one (modelsToCheck{i}) to look for the
        % unique mets, rxns, genes and subSystems
        for j = setdiff(1:length(modelsToCheck), i)
            comparisonResults.unique.(modelsToCheck{j}).metsDiff = setdiff(metsDiff, models.(modelsToCheck{j}).mets);
            comparisonResults.unique.(modelsToCheck{j}).rxnsDiff = setdiff(rxnsDiff, models.(modelsToCheck{j}).rxns);
            comparisonResults.unique.(modelsToCheck{j}).genesDiff = setdiff(genesDiff, models.(modelsToCheck{j}).genes);
            comparisonResults.unique.(modelsToCheck{j}).subSystemsDiff = setdiff(subSystemsDiff, models.(modelsToCheck{j}).subSystems);
        end
    end
    RowNames = [RowNames; 'Metabolites only present in the model'; 'Reactions only present in the model';...
        'Genes only present in the model'; 'Subsystems only present in the model'];
end
%% Flux analysis

if ismember('fluxAnalysis', param.comparisons)
    for i = 1:length(modelsToCheck)
        
        solution = modelMultipleObjectives(models.(modelsToCheck{i}), param);
        comparisonResults.fluxAnalysis.(modelsToCheck{i}).solution = solution.(param.objectives{1});
        % Fluxes in:
        % results.fluxAnalysis.(modelsToCheck{i}).solution.v
        
        % ATP reactions
        S = full(models.(modelsToCheck{i}).S);
        atpMetsBool = ismember(regexprep(models.(modelsToCheck{i}).mets, '(\[\w\])', ''), 'atp');
        [~, rxnsProducingAtpIdx] = find(S(atpMetsBool, :) > 0);
        [~, rxnsConsumingAtpIdx] = find(S(atpMetsBool, :) < 0);        
        
        uniqueSubSystems = unique(models.(modelsToCheck{i}).subSystems);
        [rxnsPerSubSystem, subSystemMeanFlux, subSystemSDFlux, sumFlux, atpFlux] = deal(zeros(size(uniqueSubSystems)));
        for j = 1:length(uniqueSubSystems)
            
            subSystemBool = ismember(models.(modelsToCheck{i}).subSystems, uniqueSubSystems{j});
            rxnsPerSubSystem(j) = sum(subSystemBool);
            rxnsInSubsystemIdx = find(subSystemBool);
            sumFlux(j) = sum(comparisonResults.fluxAnalysis.(modelsToCheck{i}).solution.v(subSystemBool));
            subSystemMeanFlux(j) = mean(comparisonResults.fluxAnalysis.(modelsToCheck{i}).solution.v(subSystemBool));
            subSystemSDFlux(j) = std(comparisonResults.fluxAnalysis.(modelsToCheck{i}).solution.v(subSystemBool));
            
            % ATP flux per subsystem
            atpRxnInSubsystem = ismember(rxnsInSubsystemIdx, [rxnsProducingAtpIdx; rxnsConsumingAtpIdx]);
            if any(atpRxnInSubsystem)
                
                atpProduction = sum(comparisonResults.fluxAnalysis.(modelsToCheck{i}).solution.v(rxnsInSubsystemIdx(ismember(rxnsInSubsystemIdx, rxnsProducingAtpIdx))));
                atpComsumption = sum(comparisonResults.fluxAnalysis.(modelsToCheck{i}).solution.v(rxnsInSubsystemIdx(ismember(rxnsInSubsystemIdx, rxnsConsumingAtpIdx))));
                atpFlux(j) = atpProduction - atpComsumption;
            else
                atpFlux(j) = 0;
            end
        end
        
        comparisonResults.fluxAnalysis.(modelsToCheck{i}).uniqueSubSystems = uniqueSubSystems;
        comparisonResults.fluxAnalysis.(modelsToCheck{i}).sumFlux = round(sumFlux, 2);
        comparisonResults.fluxAnalysis.(modelsToCheck{i}).atpFlux = round(atpFlux, 2);
        comparisonResults.fluxAnalysis.(modelsToCheck{i}).subSystemMeanFlux = round(subSystemMeanFlux, 2);
        comparisonResults.fluxAnalysis.(modelsToCheck{i}).subSystemSDFlux = round(subSystemSDFlux, 2);
    end
    RowNames = [RowNames; 'Subsystem with more uptakes'; 'Subsystem with more secretions'; 'Main energy source'; 'More energy consumed'];
end

%% Sparse FBA

if ismember('sparseFBA', param.comparisons)
    for i = 1:length(modelsToCheck)
        
        model = models.(modelsToCheck{i});
        if ~isfield(model, 'C')
            model.C = [];
        else
            nd = model.d;
            for j = 1:length(nd)
                ncsense = length(model.csense);
                model.csense((ncsense + 1), 1) = 'G';
            end
        end
        
        % sparseFBA parameters
        osenseStr = 'none';
        checkMinimalSet = true;
        checkEssentialSet = true;
        zeroNormApprox  = 'all';
        
        % FBA gives the minimum reactionBool of active reactions
        [v, rxnbool, essentialBool]  = sparseFBA(model, osenseStr,...
            checkMinimalSet, checkEssentialSet, zeroNormApprox, param.printLevel);
        
        comparisonResults.sparseFba.(modelsToCheck{i}).v = v;
        comparisonResults.sparseFba.(modelsToCheck{i}).rxnbool = rxnbool;
        comparisonResults.sparseFba.(modelsToCheck{i}).essentialBool = essentialBool;
        
    end
    RowNames = [RowNames; 'Essential reactions (sparseFBA)'];
end

%% predictive capacity

if ismember('predictiveCapacity', param.comparisons)
    if ~isempty(param.trainingSet)
        for i = 1:length(modelsToCheck)
            [comparisonData, summary] = modelPredictiveCapacity(models.(modelsToCheck{i}), param);
            comparisonResults.predictiveCapacity.(modelsToCheck{i}).comparisonData = comparisonData;
            comparisonResults.predictiveCapacity.(modelsToCheck{i}).summary = summary;
        end
    else
        error('param.trainigSet is required in order to compare the predictive capacity')
    end
    RowNames = [RowNames; 'Qualitative predictive capacity'; 'Spearman rank'; 'Euclidean distance (measured vs predicted)'];
end

%% Make table

% Generate an empty table
varTypes = repmat({'string'}, size(modelsToCheck));
varNames = cell(modelsToCheck);
comparisonTable = table('Size', [length(RowNames) length(varTypes)], 'VariableTypes', varTypes,...
    'VariableNames', varNames, 'RowNames', RowNames);

% Fill the data
dataToAdd = cell(length(RowNames), length(modelsToCheck));
for i = 1:length(modelsToCheck)
    if ismember('compartments', param.comparisons)
        dataToAdd(1, i) = num2cell(numel(models.(modelsToCheck{i}).mets));
        dataToAdd(2, i) = num2cell(numel(unique(regexprep(models.(modelsToCheck{i}).mets, '(\[\w\])', ''))));
        dataToAdd(3, i) = num2cell(numel(models.(modelsToCheck{i}).rxns));
        dataToAdd(4, i) = num2cell(rank(full(models.(modelsToCheck{i}).S)));
        dataToAdd(5, i) = num2cell(numel(models.(modelsToCheck{i}).genes));
        dataToAdd(6, i) = num2cell(numel(unique(models.(modelsToCheck{i}).subSystems)));

        idx = find(ismember(RowNames, strcat('Metabolites in', comparisonResults.compartment.compartments{1})));
        if ~isempty(idx)
            dataToAdd(idx: idx + length(compartments) - 1, i) = num2cell(counts(:, i));
        end
    end
    if ismember('uniqueElements', param.comparisons)
        idx = find(ismember(RowNames, 'Metabolites only present in the model'));
        dataToAdd(idx, i) = num2cell(numel(comparisonResults.unique.(modelsToCheck{i}).metsDiff));
        dataToAdd(idx + 1, i) = num2cell(numel(comparisonResults.unique.(modelsToCheck{i}).rxnsDiff));
        dataToAdd(idx + 2, i) = num2cell(numel(comparisonResults.unique.(modelsToCheck{i}).genesDiff));
        dataToAdd(idx + 3, i) = num2cell(numel(comparisonResults.unique.(modelsToCheck{i}).subSystemsDiff));
    end
    if ismember('fluxAnalysis', param.comparisons)
        idx = find(ismember(RowNames, 'Subsystem with more uptakes'));
        moreUptakesBool = comparisonResults.fluxAnalysis.(modelsToCheck{i}).sumFlux == max(comparisonResults.fluxAnalysis.(modelsToCheck{i}).sumFlux);
        dataToAdd(idx, i) = comparisonResults.fluxAnalysis.(modelsToCheck{i}).uniqueSubSystems(moreUptakesBool);
        moreSecretionsBool = comparisonResults.fluxAnalysis.(modelsToCheck{i}).sumFlux == min(comparisonResults.fluxAnalysis.(modelsToCheck{i}).sumFlux);
        dataToAdd(idx + 1, i) = comparisonResults.fluxAnalysis.(modelsToCheck{i}).uniqueSubSystems(moreSecretionsBool);
        
        mainEnergySourceBool = comparisonResults.fluxAnalysis.(modelsToCheck{i}).atpFlux == max(comparisonResults.fluxAnalysis.(modelsToCheck{i}).atpFlux);
        dataToAdd(idx + 2, i) = comparisonResults.fluxAnalysis.(modelsToCheck{i}).uniqueSubSystems(mainEnergySourceBool);
        mostEnergyConsumedBool = comparisonResults.fluxAnalysis.(modelsToCheck{i}).atpFlux == min(comparisonResults.fluxAnalysis.(modelsToCheck{i}).atpFlux);
        dataToAdd(idx + 3, i) = comparisonResults.fluxAnalysis.(modelsToCheck{i}).uniqueSubSystems(mostEnergyConsumedBool);
    end
    if ismember('sparseFBA', param.comparisons)
        idx = find(ismember(RowNames, 'Essential reactions (sparseFBA)'));
        dataToAdd(idx, i) = num2cell(sum(comparisonResults.sparseFba.(modelsToCheck{i}).essentialBool));
    end
    if ismember('predictiveCapacity', param.comparisons)
        idx = find(ismember(RowNames, 'Qualitative predictive capacity'));
        dataToAdd(idx, i) = num2cell(round(comparisonResults.predictiveCapacity.(modelsToCheck{i}).comparisonData.comparisonStats.qualAccuracy(1), 2));
        dataToAdd(idx + 1, i) = num2cell(round(comparisonResults.predictiveCapacity.(modelsToCheck{i}).comparisonData.comparisonStats.Spearman(1), 2));
        dataToAdd(idx + 2, i) = num2cell(round(comparisonResults.predictiveCapacity.(modelsToCheck{i}).comparisonData.comparisonStats.wEuclidNorm(1), 2));
    end
    
    % Fill the data in the table
    comparisonTable.(modelsToCheck{i}) = dataToAdd(:, i);
end

if param.printLevel > 0
   display(comparisonTable)
end
end
