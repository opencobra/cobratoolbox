function optForceTutorial

addpath('C:\Users\notebook\Desktop\optForceMATLAB');
cd('C:\Users\notebook\Desktop\optForceMATLAB');

model=[]; load('AntCore');
model.c(strcmp(model.rxns,'R75'))=1;
model=changeRxnBounds(model,'EX_gluc',-100,'l'); model.rev(strcmp(model.rxns,'EX_gluc'))=1;
model=changeRxnBounds(model,'EX_o2',-100,'l'); model.rev(strcmp(model.rxns,'EX_o2'))=1;
model=changeRxnBounds(model,'EX_so4',-100,'l'); model.rev(strcmp(model.rxns,'EX_so4'))=1;
model=changeRxnBounds(model,'EX_nh3',-100,'l'); model.rev(strcmp(model.rxns,'EX_nh3'))=1;
model=changeRxnBounds(model,'EX_cit',-100,'l'); model.rev(strcmp(model.rxns,'EX_cit'))=1;
model=changeRxnBounds(model,'EX_glyc',-100,'l'); model.rev(strcmp(model.rxns,'EX_glyc'))=1;

Constr_WT=struct('rxnList',{{'R75'}},'rxnValues',14,'rxnBoundType','b');
Constr_MT=struct('rxnList',{{'R75','EX_suc'}},'rxnValues',[0,155.55],'rxnBoundType','bb');

[minFluxesW, maxFluxesW, minFluxesM, maxFluxesM,~,~]=FVAOptForce(model,Constr_WT,Constr_MT);

%run first order 
runID = 'TestOptForceM2';
constrOpt=struct('rxnList',{{'EX_gluc','R75','EX_suc'}},'values',[-100,0,155.5]','sense','EEE');
[mustUSet,pos_mustU]=findMustU(model,minFluxesW,maxFluxesW,constrOpt,runID,'','',1,1,1,1,1);
[mustLSet,pos_mustL]=findMustL(model,minFluxesW,maxFluxesW,constrOpt,runID,'','',1,1,1,1,1);

%run second order 
constrOpt = struct('rxnList',{{'EX_gluc','R75','EX_suc'}},'values',[-100,0,155.5]','sense','EEE');
exchangeRxns = model.rxns(cellfun(@isempty,strfind(model.rxns,'EX_'))==0);
excludedRxns = unique([mustUSet;mustLSet;exchangeRxns]);

[mustUU, pos_mustUU, mustUU_linear, pos_mustUU_linear] = findMustUU(model, minFluxesW, ...
    maxFluxesW, constrOpt, excludedRxns, runID, '',...
    '', 1, 1, 1, 1, 1);

[mustUL, pos_mustUL, mustUL_linear, pos_mustUL_linear] = findMustUL(model, minFluxesW, ...
    maxFluxesW, constrOpt, excludedRxns, runID, '',...
    '', 1, 1, 1, 1, 1);

[mustLL, pos_mustLL, mustLL_linear, pos_mustLL_linear] = findMustLL(model, minFluxesW, ...
    maxFluxesW, constrOpt, excludedRxns, runID, '',...
    '', 1, 1, 1, 1, 1);

%create inputs for optForce
[mustU,mustL]=createMustList({'MustU.xls','MustL.xls','MustUU_list.xls'},'UDU',1,1);

%run oprForce
targetRxn = 'EX_suc';
k = 2; 
nSets = 20;
model.lb(strcmp('EX_suc',model.rxns)==1) = 15;
constrOpt=struct('rxnList',{{'EX_gluc','R75'}},'values',[-100,0],'sense','EE');
excludedRxns=struct('rxnList',{{'SUCt'}},'typeReg','U');
[optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = optForce(model,targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM,k,nSets,constrOpt,excludedRxns,runID,'','',1,1,1,1,1);
end