%% Create a generic subnetwork from Recon 3D 
% *Author(s): Ines Thiele, Ronan M. T. Fleming, Systems Biochemistry Group, 
% LCSB, University of Luxembourg.*
% 
% *Reviewer(s): Almut Heinken, Catherine M. Clancy, Laurent Heirendt, LCSB, 
% University of Luxembourg.*
% 
% In this tutorial, we show how to create a generic subnetwork from Recon 
% 3D that can still perform all metabolic test functions as well as has physiologically 
% defined ATP yield from defined carbon sources. The resulting model does not 
% contain a specified list of reactions, except if they are still needed for the 
% aforementioned tasks, and that is flux consistent.
%% EQUIPMENT SETUP
%% *Initialize the COBRA Toolbox*
% Initialize the Cobra Toolbox using the |initCobraToolbox| function.

% initCobraToolbox
%% *Setting the *optimization* solver*
% This tutorial will be run with a |'glpk'| package, which is a linear programming 
% ('|LP'|) solver. The |'glpk'| solver does not require additional installation 
% or configuration.

% solverName='glpk';
%% 
% However, for the analysis of large models such as Recon 3D, it is not 
% recommended to use the |'glpk'| package, but rather a commercial-grade solver, 
% such as |'gurobi'|. For detailed information, refer to The Cobra Toolbox <http://opencobra.github.io/cobratoolbox/docs/solvers.html 
% solver installation guide>. 
% 
% For the analysis of a Recon model, change the solver to |'gurobi'|: 

solverName = 'gurobi';
changeCobraSolver(solverName, 'LP');
%% PROCEDURE
% *Load the model*
% 
% In this tutorial, the used model is the generic model of human metabolism, 
% Recon 3D [1]. If Recon 3D is not available, use Recon 2 [2] provided in The 
% COBRA Toolbox. Other COBRA models may be downloaded from the <https://vmh.uni.lu/#downloadview 
% Virtual Metabolic Human> website and saved to your preferred directory.
% 
% Before proceeding with the simulations, the path for the model needs to 
% be defined.

global CBTDIR

fileName= 'Recon2.0model.mat'; % if using Recon 3 model, amend filename. 
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep fileName]);
model.csense(1:size(model.S,1),1) = 'E';
%% 
% Set the lower bounds on all biomass reactions and sink/demand reactions 
% to zero.

model.lb(find(ismember(model.rxns, 'biomass_reaction'))) = 0;
model.lb(find(ismember(model.rxns, 'biomass_maintenance_noTrTr'))) = 0;
model.lb(find(ismember(model.rxns, 'biomass_maintenance'))) = 0;
DMs = (strmatch('DM_', model.rxns));
model.lb(DMs) = 0;
Sinks = (strmatch('sink_', model.rxns));
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
% functions can have a non-zero flux. (Note that this function uses |sparseFBA|, 
% i.e., alternative solutions may exist but are not considered here.) Applicable 
% to Recon3 only.

if ~isempty(strfind(fileName, 'Recon3'))
    [TestSolutionOri,TestSolutionNameClosedSinks, TestedRxnsClosedSinks, PercClosedSinks] = test4HumanFctExt(model, 'all', 0);
    TestedRxns = unique([TestedRxnsC; TestedRxnsClosedSinks]);
    TestedRxnsX = intersect(model.rxns,TestedRxns); 
end
%% 
% Next we remove all human metabolic reactions (HMRs)  (i.e., those reactions 
% originating from HMR 2.0 [3] and that start with 'HMR_') that are not needed 
% for the aforementioned tasks. Applicable to Recon 3 only.

if ~isempty(strfind(fileName, 'Recon3'))
    HMR = model.rxns(strmatch('HMR_',model.rxns));
    HMR_NE = setdiff(HMR,TestedRxnsX);
    model.lb(find(ismember(model.rxns,HMR_NE))) = 0;
    model.ub(find(ismember(model.rxns,HMR_NE))) = 0;
end
%% 
% We will also remove all drug module reactions, i.e., those ones with the 
% term 'Xeno' in the subsystem, mostly originating from [4]. Applicable to Recon 
% 3 only.

if ~isempty(strfind(fileName, 'Recon3'))
    DM = model.rxns(strmatch('Xeno', model.subSystems));
    model.lb(find(ismember(model.rxns, DM))) = 0;
    model.ub(find(ismember(model.rxns, DM))) = 0;
    DMt = (strmatch('Transport of Xenobiotic', model.rxnNames));
    model.lb(DMt) = 0;
    model.ub(DMt) = 0;
end
%% 
% We will also remove all reactions from  the 'Peptide metabolism' subsystem. 
% Applicable to Recon 3 only.

if ~isempty(strfind(fileName, 'Recon3'))
    DM = model.rxns(strmatch('Peptide metabolism',model.subSystems));
    model.lb(find(ismember(model.rxns, DM))) = 0;
    model.ub(find(ismember(model.rxns, DM))) = 0;
end
%% 
% We will use the method FASTCORE, '|fastcc'|, to ensure a flux-consistent 
% subnetwork [5].

param.epsilon = 1e-4;
param.modeFlag = 0;
param.method = 'fastcc'; %'null_fastcc'
printLevel = 2;
[fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool, modelOut] = findFluxConsistentSubset(model, param, printLevel);
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
        modelConsistent = changeGeneAssociation(modelConsistent, modelConsistent.rxns{i}, modelgrRule{i});
    end
end
%% 
% Save the resulting model.

save('SubNetworkRecon.mat', 'modelConsistent')
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