%% Create a generic subnetwork from Recon 3D 
% *Author(s): Ines Thiele, Ronan M. T. Fleming, Systems Biochemistry Group, 
% LCSB, University of Luxembourg.*
% 
% *Reviewer(s): Almut Heinken, Catherine M. Clancy, LCSB, University of Luxembourg.*
% 
% In this tutorial, we show how to create a generic subnetwork from Recon 
% 3D that can still perform all metabolic test functions as well as has physiologically 
% defined ATP yield from defined carbon sources. The resulting model does not 
% contain a specified list of reactions, except if they are still needed for the 
% aforementioned tasks, and that is flux consistent.
%% EQUIPMENT SETUP
%% *Initialize The COBRA Toolbox.*
% Initialize The Cobra Toolbox using the |initCobraToolbox| function.

initCobraToolbox
%% *Setting the *optimization* solver.*
% This tutorial will be run with a |'glpk'| package, which is a linear programming 
% ('|LP'|) solver. The |'glpk'| package does not require additional instalation 
% and configuration.

% solverName='glpk';
% solverType='LP'; 
% changeCobraSolver(solverName,solverType);
%% 
% However, for the analysis of large models, such as Recon 3D, it is not 
% recommended to use the |'glpk'| package but rather an industrial strength solver, 
% such as the |'gurobi'| package. For detailed information, refer to The Cobra 
% Toolbox <https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md 
% solver instalation guide>. 
% 
% If tutorial will analyse a Recon model then change solver to gurobi: 

solverName='gurobi';
solverType='LP'; 
changeCobraSolver(solverName,solverType);
%% 
% A solver package may offer different types of optimization programmes 
% to solve a problem. The above example used a LP optimization, other types of 
% optimization programmes include; mixed-integer linear programming ('|MILP|'), 
% quadratic programming ('|QP|'), and mixed-integer quadratic programming ('|MIQP|').

warning off MATLAB:subscripting:noSubscriptsSpecified
%% PROCEDURE
% *Load the model.*
% 
% In this tutorial, the used model is the generic model of human metabolism, 
% Recon 3D [1]. If Recon 3D is not available, please use Recon 2 [2] provided 
% in The Corba Toolbox. Other COBRA models may be download the from the <https://vmh.uni.lu/#downloadview 
% Virtual Metabolic Human> webpage and save to your prefered directory.
% 
% Before proceeding with the simulations, the path for the model needs to 
% be set up.

pathModel = 'fork-cobratoolbox/test/models/';  % If using Recon 3 model and as neccessary, admend the path to Recon 3 model.
filename= 'Recon2.0model.mat'; % If using Recon 3 model, admend filename. 

if ~isempty(regexp(filename,'Recon3'));
    load([pathModel, filename])
    model = modelRecon3model;
    model.csense(1:size(model.S,1),1)='E';
    clear modelRecon3model;
else
    load([pathModel, filename])
    model = Recon2model;
    model.csense(1:size(model.S,1),1)='E';
    clear Recon2model;
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
% Identify the model reactions that are needed to ensure that all carbon 
% sources result in a physiologically relevant ATP yield. (Note that this function 
% uses sparseFBA, i.e., alternative solutions may exist but are not considered 
% here.)

[Table_csourcesOri, TestedRxnsC, Perc] = testATPYieldFromCsources(model);
%% 
% Identify the model reactions that are needed to ensure that all metabolic 
% functions can have a non-zero flux. (Note that this function uses sparseFBA, 
% i.e., alternative solutions may exist but are not considered here.)

[TestSolutionOri,TestSolutionNameClosedSinks, TestedRxnsClosedSinks, PercClosedSinks] = Test4HumanFctExt(model,'all',0);
TestedRxns = unique([TestedRxnsC; TestedRxnsClosedSinks]);
TestedRxnsX = intersect(model.rxns,TestedRxns); 
%% 
% Next we remove all human metabolic reactions (HMRs)  (i.e., those reactions 
% originating from HMR 2.0 [3] and that start with 'HMR_') that are not needed 
% for the aforementioned tasks. Applicable to Recon 3 only.

HMR = model.rxns(strmatch('HMR_',model.rxns));
HMR_NE = setdiff(HMR,TestedRxnsX);
model.lb(find(ismember(model.rxns,HMR_NE))) = 0;
model.ub(find(ismember(model.rxns,HMR_NE))) = 0;
%% 
% We will also remove all drug module reactions, i.e., those ones with the 
% term 'Xeno' in the subsystem, mostly originating from [4]. Applicable to Recon 
% 3 only.

DM = model.rxns(strmatch('Xeno',model.subSystems));
model.lb(find(ismember(model.rxns,DM))) = 0;
model.ub(find(ismember(model.rxns,DM))) = 0;
DMt = (strmatch('Transport of Xenobiotic',model.rxnNames));
model.lb(DMt) = 0;
model.ub(DMt) = 0;
%% 
% We will also remove all reactions from  the 'Peptide metabolism' subsystem. 
% Applicable to Recon 3 only.

DM = model.rxns(strmatch('Peptide metabolism',model.subSystems));
model.lb(find(ismember(model.rxns,DM))) = 0;
model.ub(find(ismember(model.rxns,DM))) = 0;
%% 
% Now we will ensure that the reversibility of each reaction is in accordance 
% to the defined lower bound.

model.rev(find(model.lb<0))=1;
model.rev(find(model.lb>=0))=0;
%% 
% We will use the method FASTCORE, '|fastcc'|, to ensure a flux-consistent 
% subnetwork [5].

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
% Size of the original Recon model:

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
% [1] Brunk, E. et al. Recon 3D: A resource enabling a three-dimensional view 
% of gene variation in human metabolism. (submitted) 2017.
% 
% [2] Thiele I., Swainston N., Fleming R.M.T., et al. (2013) A community-driven 
% global reconstruction of human metabolism. Nat. Biotechnol., 31, 419–425.
% 
% [3] Mardinoglu A., Agren R., Kampf C., et al. (2014) Genome-scale metabolic 
% modelling of hepatocytes reveals serine deficiency in patients with non-alcoholic 
% fatty liver disease. Nat. commun., 5, 3083.
% 
% [4] Sahoo S, Haraldsdóttir HS, Fleming RM, Thiele I. Modeling the effects 
% of commonly used drugs on human metabolism. FEBS J. 2015 Jan;282(2):297-317.
% 
% [5] Vlassis N, Pacheco MP, Sauter T. Fast reconstruction of compact context-specific 
% metabolic network models. PLoS Comput Biol. 2014 Jan;10(1).