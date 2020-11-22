function isConsistent = checkModelPreFBA(model,param)
%checks if a model is (stoichiometrically and flux) consistent, which are
%necessary conditions prior to FBA
%
% INPUT
% model     COBRA model, or a fileName containing a model
%
% OPTIONAL INPUT
% param     parameters
%
% OUTPUT
% isConsistent  {1,0} if stoichiometrically and flux consistent, or not
%

% Ronan Fleming 2020

if ~exist('model','var')
    model='Recon3DModel_301.mat';
end

if ~exist('param','var')
    param = struct;
end

if ~isfield(param,'printLevel')
    param.printLevel = 0;
end

if isstruct(model)
    modelName=model.modelID;
else
    model = readCbModel(model);
    modelName=model.modelID;
end

printLevel = param.printLevel;

massBalanceCheck=0;
[SConsistentMetBool,SConsistentRxnBool,SInConsistentMetBool,SInConsistentRxnBool,unknownSConsistencyMetBool,unknownSConsistencyRxnBool,model]...
    =findStoichConsistentSubset(model,massBalanceCheck,printLevel);

[nMet,nRxn]=size(model.S);
if printLevel>1
    fprintf('%6s\t%6s\n','#mets','#rxns')
    fprintf('%6u\t%6u\t%s\n',nMet,nRxn,' totals.')
    if isfield(model,'SIntMetBool')
        fprintf('%6u\t%6u\t%s\n',nnz(~model.SIntMetBool),nnz(~model.SIntRxnBool),' heuristically exchange.')
    end
end

checksPassed=0;
%Check that all heuristically non-exchange reactions are also stoichiometrically consistent

%exchange reactions
model.EXRxnBool=strncmp('EX_', model.rxns, 3)==1;
%demand reactions going out of model
model.DMRxnBool=strncmp('DM_', model.rxns, 3)==1 & ~(strcmp('DM_atp(c)',model.rxns) | strcmp('DM_atp_c_',model.rxns) | strcmp('ATPM',model.rxns));
%sink reactions going into or out of model
model.SinkRxnBool=strncmp('sink_', model.rxns, 5)==1;
%amalgamate
bool=~(model.EXRxnBool | model.DMRxnBool | model.SinkRxnBool);
if nnz(bool & model.SIntRxnBool & model.SConsistentRxnBool)==nnz(model.SConsistentRxnBool)
    checksPassed=checksPassed+1;
    if printLevel>1
        fprintf('%6u\t%6u\t%s\n',nnz(model.SIntMetBool),nnz(model.SIntRxnBool),' All internally stoichiometrically consistent. (Check 1: minimum cardinality of conservation relaxation vector.)');
    end
end

%Check for mass leaks or siphons in the stoichiometrically consistent part
%There should be no leaks or siphons in the stiochiometrically consistent part
modelBoundsFlag=0;
leakParams.epsilon=getCobraSolverParams('LP', 'feasTol')*100;
leakParams.eta = getCobraSolverParams('LP', 'feasTol')*100;
leakParams.method='dc';
[leakMetBool,leakRxnBool,siphonMetBool,siphonRxnBool,leakY,siphonY,statp,statn]...
    =findMassLeaksAndSiphons(model,model.SConsistentMetBool,model.SConsistentRxnBool,modelBoundsFlag,leakParams,printLevel);

if nnz(leakMetBool)==0 && nnz(leakRxnBool)==0 && nnz(siphonMetBool)==0 && nnz(siphonRxnBool)==0
    checksPassed=checksPassed+1;
    if printLevel>1
        fprintf('%6u\t%6u\t%s\n',nnz(leakMetBool | siphonMetBool),nnz(leakRxnBool | siphonRxnBool),' No internal leaks or siphons. (Check 2: leak/siphon tests.)');
    end
end

%Check that the maximal conservation vector is nonzero for each the
%internal stoichiometric matrix
%maxCardinalityConsParams.method = 'dc';
%maxCardinalityConsParams.method = 'quasiConcave';
maxCardinalityConsParams.method = 'optimizeCardinality';
maxCardinalityConsParams.epsilon=getCobraSolverParams('LP', 'feasTol')*100;%1/epsilon is the largest mass considered, needed for numerical stability
maxCardinalityConsParams.theta = 0.5;
maxCardinalityConsParams.eta=getCobraSolverParams('LP', 'feasTol');

[maxConservationMetBool,maxConservationRxnBool,solution]=maxCardinalityConservationVector(model.S(:,model.SConsistentRxnBool), maxCardinalityConsParams);
if nnz(maxConservationMetBool)==size(model.S,1) && nnz(maxConservationRxnBool)==nnz(model.SConsistentRxnBool)
    checksPassed=checksPassed+1;
    if printLevel>1
        fprintf('%6u\t%6u\t%s\n',nnz(maxConservationMetBool),nnz(maxConservationRxnBool),' All internally stoichiometrically consistent. (Check 3: maximim cardinality conservation vector.)');
    end
end

%Check that each of the reactions in the model (with open external reactions) is flux consistent
modelOpen=model;
modelOpen.lb(~model.SIntRxnBool)=-1000;
modelOpen.ub(~model.SIntRxnBool)= 1000;
param.epsilon=getCobraSolverParams('LP', 'feasTol')*100;
param.modeFlag=0;
param.method='null_fastcc';
[fluxConsistentMetBool,fluxConsistentRxnBool,fluxInConsistentMetBool,fluxInConsistentRxnBool,modelOpen] = findFluxConsistentSubset(modelOpen,param,printLevel-2);

if nnz(fluxConsistentMetBool)==size(model.S,1) && nnz(fluxConsistentRxnBool)==size(model.S,2)
    checksPassed=checksPassed+1;
    if printLevel>1
        fprintf('%6u\t%6u\t%s\n',nnz(fluxConsistentMetBool),nnz(fluxConsistentRxnBool),' All flux consistent. (Check 4: maximim cardinality constrained right nullspace.)');
    end
end

if checksPassed==4
    %save the model with open exchanges as the default generic
    %model
    model=modelOpen;
    if printLevel>0
        fprintf('%s\n','Open external reactions is stoichiometrically and flux consistent.')
    end
end

isConsistent = checksPassed==4;

if isConsistent
    fprintf('\n%s\n',['model in ' modelName ' is stoichiometrically consistent, and flux consistent with open external reactions']);
    fprintf('%s\n',['i.e. model in ' modelName ' is ready for flux balance analysis. GREAT!!!!']);
else
    disp(checksPassed)
    fprintf('%s\n',['model in ' modelName ' is either NOT stoichiometrically consistent or NOT flux consistent with open external reactions.']);
    fprintf('%s\n',['i.e. model in ' modelName ' may not be suitable for flux balance analysis.']);
    fprintf('%s\n',['see https://opencobra.github.io/cobratoolbox/stable/tutorials/tutorialReconToFBAmodel.html']);
end


