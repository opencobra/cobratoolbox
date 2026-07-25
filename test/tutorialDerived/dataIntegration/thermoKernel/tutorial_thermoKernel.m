%% Extract a thermodynamically consistent subnetwork from a given model
%% *Author(s): Ronan M.T. Fleming, School of Medicine, University of Galway*
%% *Reviewer(s):* 
% 
%% 
% # Identify the largest subset of a model that admits a thermodynamically consistent 
% flux
% # Specify a random subset of active/inactive reactions and present/absent 
% metabolites
% # Compute the smallest thermodynamically consistent subnetwork containing 
% a list of present metabolites and active reactions, and not containing a list 
% of absent metabolites and inactive reactions

[solverOK,solverInstalled]=changeCobraSolver('ibm_cplex','all');
%[solverOK,solverInstalled]=changeCobraSolver('gurobi','all');
%[solverOK,solverInstalled]=changeCobraSolver('ibm_cplex','QP');
%% Load model

modelToLoad='circularToy';
modelToLoad='ecoli_core';
modelToLoad='modelRecon3MitoOpen';
modelToLoad='Recon3DModel';
%modelToLoad='iDopa';
%% 
% Load a model

driver_thermoModelLoad
%% Stoichiometric consistency

if ~isfield(model,'SConsistentRxnBool')  || ~isfield(model,'SConsistentMetBool')
    massBalanceCheck=0;
    %massBalanceCheck=1;
    printLevel=2;
    [SConsistentMetBool, SConsistentRxnBool, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model,stoichConsistModel]...
        = findStoichConsistentSubset(model, massBalanceCheck, printLevel);
else
    %Extract stoich consistent submodel
    if any(~model.SConsistentMetBool)
        rxnRemoveMethod='inclusive';%maintains stoichiometric consistency
        [stoichConsistModel, rxnRemoveList] = removeMetabolites(model, model.mets(~model.SConsistentMetBool),rxnRemoveMethod);
        SConsistentRxnBool2=~ismember(model.rxns,rxnRemoveList);
        if ~all(model.SConsistentRxnBool==SConsistentRxnBool2)
            error('inconsistent reaction removal')
        end
        try
            stoichConsistModel = removeUnusedGenes(stoichConsistModel);
        catch ME
            disp(ME.message)
        end
    else
        stoichConsistModel = model;
    end
end

[nMet,nRxn]=size(stoichConsistModel.S)
%% Flux consistency

fluxConsistentParam.method='fastcc';%can handle additional constraints
fluxConsistentParam.printLevel=1;
[~,~,~,~,stoichConsistModel]= findFluxConsistentSubset(stoichConsistModel,fluxConsistentParam);
%% 
% Extract flux consistent submodel

if any(~stoichConsistModel.fluxConsistentRxnBool)
    rxnRemoveList = stoichConsistModel.rxns(~stoichConsistModel.fluxConsistentRxnBool);
    stoichFluxConsistModel = removeRxns(stoichConsistModel, rxnRemoveList,'metRemoveMethod','exclusive','ctrsRemoveMethod','inclusive');
    try
        stoichFluxConsistModel = removeUnusedGenes(stoichFluxConsistModel);
        catch ME
        disp(ME.message)
    end
else
    stoichFluxConsistModel = stoichConsistModel;
end
[nMet,nRxn]=size(stoichFluxConsistModel.S)
%% Thermodynamic consistency

%save('debug_prior_to_findThermoConsistentFluxSubset.mat')
%return
param.printLevel = 1;
param.relaxBounds=0;
param.acceptRepairedFlux=1;
[thermoFluxConsistentMetBool,thermoFluxConsistentRxnBool,stoichFluxConsistModel,stoichFluxThermoConsistModel] = findThermoConsistentFluxSubset(stoichFluxConsistModel,param);
%% 
% Size of the largest flux, stoich and thermo consistent submodel

[nMet,nRxn]=size(stoichFluxThermoConsistModel.S)
save(['~/work/sbgCloud/programModelling/projects/thermoModel/results/thermoKernel/' modelToLoad '_stoichFluxThermoConsistModel.mat'],'stoichFluxThermoConsistModel')
%%
%modelToLoad='Recon3DModel';
load(['~/work/sbgCloud/programModelling/projects/thermoModel/results/thermoKernel/' modelToLoad '_stoichFluxThermoConsistModel.mat'],'stoichFluxThermoConsistModel')
%% Nullspace
% Nullspace is necessary for backup check of thermodynamic consistency using 
% thermoFlux2QNty 

[stoichFluxThermoConsistModel,rankK,nnzK,timeTaken] = internalNullspace(stoichFluxThermoConsistModel);
rankK
%% Data to define a thermodynamically consistent subnetwork
% Setup random data to select a random subset

param.n=200;
[rankMetConnectivity,rankMetInd,rankConnectivity] = rankMetabolicConnectivity(stoichFluxThermoConsistModel,param);
%%
[nMet,nRxn]=size(stoichFluxThermoConsistModel.S);
rxnWeights=rand(nRxn,1)-0.5;
rxnWeights(~stoichFluxThermoConsistModel.SConsistentRxnBool)=0;

coreRxnBool=rxnWeights<-0.45;
removeRxnBool=rxnWeights>0.45;
if 0
    rxnWeights(rxnWeights>0.4)=1;
    rxnWeights(rxnWeights<-0.4)=-1;
end
rxnWeights(rxnWeights>=-0.4 & rxnWeights<=0.4)=0;
hist(rxnWeights,40)
metWeights=rand(nMet,1)-0.5;
metWeights(rankMetInd(1:200))=0;
coreMetBool=metWeights<-0.45;
removeMetBool=metWeights>0.45;
if 0
    metWeights(metWeights>0.4)=1;
    metWeights(metWeights<-0.4)=-1;
end
metWeights(metWeights>=-0.4 & metWeights<=0.4)=0;
hist(metWeights,40)
%% 
%% 

nlt=length(coreRxnBool);
activeInactiveRxn=zeros(nlt,1);
activeInactiveRxn(coreRxnBool)=1;
activeInactiveRxn(removeRxnBool)=-1;
hist(activeInactiveRxn)
mlt=length(coreMetBool);
presentAbsentMet=zeros(mlt,1);
presentAbsentMet(coreMetBool)=1;
presentAbsentMet(removeMetBool)=-1;
if 0
    activeInactiveRxn(:)=0;
    presentAbsentMet(:)=0;
end
param.normalizeZeroNormWeights=0;

hist(presentAbsentMet)
%% Compute the smallest thermodynamically consistent subnetwork given a list of present/absent metabolites and active/inactive reactions

[tissueModel, thermoModelMetBool, thermoModelRxnBool] = thermoKernel(stoichFluxThermoConsistModel, activeInactiveRxn, rxnWeights, presentAbsentMet, metWeights,param);
%%
[nMet,nRxn]=size(tissueModel.S)
%% 
% Compare the target versus predicted model

%plotThermoCoreStats(activeInactiveRxn, presentAbsentMet, thermoModelMetBool, thermoModelRxnBool);
plotThermoKernelExtractStats(stoichFluxThermoConsistModel, activeInactiveRxn, rxnWeights, presentAbsentMet, metWeights, thermoModelMetBool, thermoModelRxnBool)
% Save weights

rxnWeightsTmp=rxnWeights;
metWeightsTmp=metWeights;
%% Submodel with just metabolites specified

metWeights=metWeightsTmp;
rxnWeights(:)=0;
[tissueModel, thermoModelMetBool, thermoModelRxnBool] = thermoKernel(stoichFluxThermoConsistModel, activeInactiveRxn, rxnWeights, presentAbsentMet, metWeights,param);
[nMet,nRxn]=size(tissueModel.S)
%% 
% Compare the target versus predicted model

plotThermoKernelExtractStats(stoichFluxThermoConsistModel, activeInactiveRxn, rxnWeights, presentAbsentMet, metWeights, thermoModelMetBool, thermoModelRxnBool)
%% Submodel with just reactions specified

rxnWeights=rxnWeightsTmp;
metWeights(:)=0;
[tissueModel, thermoModelMetBool, thermoModelRxnBool] = thermoKernel(stoichFluxThermoConsistModel, activeInactiveRxn, rxnWeights, presentAbsentMet, metWeights,param);

[nMet,nRxn]=size(tissueModel.S)
%% 
% Compare the target versus predicted model

plotThermoKernelExtractStats(stoichFluxThermoConsistModel, activeInactiveRxn, rxnWeights, presentAbsentMet, metWeights, thermoModelMetBool, thermoModelRxnBool)

%% Submodel with just active metabolites specified

metWeightsRed=metWeightsTmp;
rxnWeightsRed=rxnWeightsTmp*0;
metWeightsRed(metWeightsRed>=0)=0;
%%
[tissueModel, thermoModelMetBool, thermoModelRxnBool] = thermoKernel(stoichFluxThermoConsistModel, activeInactiveRxn, rxnWeightsRed, presentAbsentMet, metWeightsRed,param);
[nMet,nRxn]=size(tissueModel.S)
%% 
% Compare the target versus predicted model

plotThermoKernelExtractStats(stoichFluxThermoConsistModel, activeInactiveRxn, rxnWeightsRed, presentAbsentMet, metWeightsRed, thermoModelMetBool, thermoModelRxnBool)
%% Submodel with just active reactions specified

rxnWeightsRed=rxnWeightsTmp;
metWeightsRed=metWeightsTmp*0;
rxnWeightsRed(rxnWeightsRed>=0)=0;
[tissueModel, thermoModelMetBool, thermoModelRxnBool] = thermoKernel(stoichFluxThermoConsistModel, activeInactiveRxn, rxnWeightsRed, presentAbsentMet, metWeightsRed,param);

[nMet,nRxn]=size(tissueModel.S)
%% 
% Compare the target versus predicted model

plotThermoKernelExtractStats(stoichFluxThermoConsistModel, activeInactiveRxn, rxnWeightsRed, presentAbsentMet, metWeightsRed, thermoModelMetBool, thermoModelRxnBool)
%% _Acknowledgments_
% Co-funded by the European Union's Horizon Europe Framework Programme (101080997)
%% REFERENCES
% [1] Ronan M T Fleming, Hulda S Haraldsdottir, Le Hoai Minh, Phan Tu Vuong, 
% Thomas Hankemeier, Ines Thiele, Cardinality optimization in constraint-based 
% modelling: application to human metabolism, _Bioinformatics_, Volume 39, Issue 
% 9, September 2023, btad450, <https://doi.org/10.1093/bioinformatics/btad450 
% https://doi.org/10.1093/bioinformatics/btad450>
% 
% [2] Preciat, G., Wegrzyn, A. B., Luo, X., Thiele, I., Hankemeier, T., & Fleming, 
% R. M. T. (2025). XomicsToModel: omics data integration and generation of thermodynamically 
% consistent metabolic models. Nature Protocols. <https://doi.org/10.1038/s41596-025-01288-9 
% https://doi.org/10.1038/s41596-025-01288-9> 
% 
% 
% 
%