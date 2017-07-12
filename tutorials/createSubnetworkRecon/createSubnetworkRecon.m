%% Create a generic subnetwork from Recon 3D 
% *Author(s): Ines Thiele, Ronan M. T. Fleming, Systems Biochemistry Group, 
% LCSB, University of Luxembourg.*
% 
% *Reviewer(s): Almut Heinken, University of Luxembourg.*
% 
% In this tutorial, we show how to create a generic subnetwork from Recon 
% 3D that can still perform all metabolic test functions as well as has physiologically 
% defined ATP yield from defined carbon sources. The resulting model does not 
% contain a specified list of reactions, except if they are still needed for the 
% aforementioned tasks, and that is flux consistent.
%% EQUIPMENT SETUP
% If necessary, initialize the cobra toolbox:

initCobraToolbox
%% 
% For solving linear programming problems in FBA analysis, certain solvers 
% are required:

% changeCobraSolver ('glpk', 'all', 1);
changeCobraSolver ('tomlab_cplex', 'all', 1);
%% 
% This tutorial can be run with |'glpk'| package as linear programming solver, 
% which does not require additional instalation and configuration. However, for 
% the analysis of large models, such as Recon 3, it is not recommended to use 
% |'glpk'| but rather industrial strenght solvers, such as the |'gurobi'| package. 
% For detail information, refer to the solver instalation guide: <https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md 
% https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md>

warning off MATLAB:subscripting:noSubscriptsSpecified
%% PROCEDURE
% Before proceeding with the simulations, the path for the model needs to be 
% set up. In this tutorial, the used model is the generic model of human metabolism, 
% Recon 3 [1]. If Recon 3 is not available, please use Recon 2.

if exist('2017_04_28_Recon3dForCurrentDistribution.mat','file')==2
    filename = '2017_04_28_Recon3dForCurrentDistribution.mat';
    load(filename);
    model=modelRecon3model;
    clear modelRecon3model;
    model.csense(1:size(model.S,1),1)='E';
else
    filename2='Recon2.0model.mat';
    if exist('Recon2.0model.mat','file')==2
        load(filename2);
        model=Recon2model;
        clear Recon2model;
        model.csense(1:size(model.S,1),1)='E';
    end
end
%% 
% Set the lower bounds on all biomass reactions and sink/demand reactions 
% to zero.

model.lb(find(ismember(model.rxns,'biomass_reaction')))=0;
model.lb(find(ismember(model.rxns,'biomass_maintenance_noTrTr')))=0;
model.lb(find(ismember(model.rxns,'biomass_maintenance')))=0;
DMs = (strmatch('DM_',model.rxns));
model.lb(DMs) = 0;
Sinks = (strmatch('sink_',model.rxns));
model.lb(Sinks) = 0;
model.ub(Sinks) = 1000;
%% 
% Test, which model reactions are needed to ensure that all carbon sources 
% result in a physiologically relevant ATP yield. Note that this function uses 
% sparseFBA, i.e., alternative solutions may exist but are not considered here.

[Table_csourcesOri, TestedRxnsC, Perc] = testATPYieldFromCsources(model);
%% 
% Test, which model reactions are needed to ensure that all metabolic functions 
% can have a non-zero flux. Note that this function uses sparseFBA, i.e., alternative 
% solutions may exist but are not considered here.

[TestSolutionOri,TestSolutionNameClosedSinks, TestedRxnsClosedSinks, PercClosedSinks] = Test4HumanFctExt(model,'all',0);
TestedRxns = unique([TestedRxnsC; TestedRxnsClosedSinks]);
TestedRxnsX = intersect(model.rxns,TestedRxns); 
%% 
% In this example, we aim to remove all HMR reactions (i.e., those reactions 
% originating from HMR 2.0 [2] and that start with 'HMR_') that are not needed 
% for the aforementioned tasks.

HMR = model.rxns(strmatch('HMR_',model.rxns));
HMR_NE = setdiff(HMR,TestedRxnsX);
model.lb(find(ismember(model.rxns,HMR_NE))) = 0;
model.ub(find(ismember(model.rxns,HMR_NE))) = 0;
%% 
% We will also remove all drug module reactions, i.e., those ones with the 
% term 'Xeno' in the subsystem, mostly originating from [3].

DM = model.rxns(strmatch('Xeno',model.subSystems));
model.lb(find(ismember(model.rxns,DM))) = 0;
model.ub(find(ismember(model.rxns,DM))) = 0;
DMt = (strmatch('Transport of Xenobiotic',model.rxnNames));
model.lb(DMt) = 0;
model.ub(DMt) = 0;
%% 
% We will also remove all reactions from  the 'Peptide metabolism' subsystem.

DM = model.rxns(strmatch('Peptide metabolism',model.subSystems));
model.lb(find(ismember(model.rxns,DM))) = 0;
model.ub(find(ismember(model.rxns,DM))) = 0;
%% 
% Now we will ensure that the reversibility of each reaction is in accordance 
% to the defined lower bound.

model.rev(find(model.lb<0))=1;
model.rev(find(model.lb>=0))=0;
%% 
% We will use fastcc [4[, to ensure a flux-consistent subnetwork.

param.epsilon=1e-4;
param.modeFlag=0;
%param.method='null_fastcc';
param.method='fastcc';
printLevel=3;
[fluxConsistentMetBool,fluxConsistentRxnBool,fluxInConsistentMetBool,fluxInConsistentRxnBool,modelOut] = findFluxConsistentSubset(model,param,printLevel-1);
%% 
% And remove the flux inconsistent reactions from the model.

modelConsistent = removeRxns(model,model.rxns(find(fluxInConsistentRxnBool)));
%% 
% We will now update the GPR associations. 

modelConsistent.genes = [];
modelConsistent.rxnGeneMat = [];
modelgrRule = modelConsistent.grRules;
for i = 1 : length(modelgrRule)
    if ~isempty(modelgrRule{i})
        modelConsistent = changeGeneAssociation(modelConsistent,modelConsistent.rxns{i},modelgrRule{i});
    end
end
%% 
% Save the resulting model.

save('SubNetworkRecon.mat','modelConsistent')
%% 
% Size of the original Recon:

[nMet,nRxn] = size(model.S);
fprintf('%6s\t%6s\n','#mets','#rxns'); fprintf('%6u\t%6u\t%s%s\n',nMet,nRxn,' total in Recon')
%% 
% Size of the resulting Recon subnetwork:

[nMet,nRxn] = size(modelConsistent.S);
fprintf('%6s\t%6s\n','#mets','#rxns'); fprintf('%6u\t%6u\t%s%s\n',nMet,nRxn,' total in Recon subnetwork')
%% 
% Consider to evaluate the resulting model with the tutorial modelProperties 
% and modelSanityChecks to ensure proper functioning of the generic subnetwork 
% of Recon.
%% References
%  [1] Brunk, E. et al. Recon 3D: A resource enabling a three-dimensional view 
% of gene variation in human metabolism. (submitted) 2017.
% 
% [2] HMR 2.0
% 
% [3] Drug module.
% 
% [4] FastCore.