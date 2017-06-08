%% OptForce Tutorial
% Sebastián N. Mendoza F. May 30th, 2017. snmendo@uc.cl

% In this tutorial we will run optForce. For a detailed description of the
% procedure, please see[1]: Ranganathan S, Suthers PF, Maranas CD (2010)
% OptForce: An Optimization Procedure for Identifying All Genetic
% Manipulations Leading to Targeted Overproductions. PLOS Computational
% Biology 6(4): e1000744. https://doi.org/10.1371/journal.pcbi.1000744.

% Briefly, the problem is to find a set of interventions of size "K" such
% that when these interventions are applied to a wild-type strain, the
% mutant created will produce a particular target of interest in a higher
% rate than the wild-type strain. The interventions could be knockouts
% (lead to zero the flux for a particular reaction), upregulations(increase
% the flux for a particular reaction) and downregulations (decrease the
% flux for a particular reaction). 

% This prodecure consists on three steps:
% 1) Perform FVA in both wild type and mutant strains 
% 2) Find the must sets, i.e, reactions that MUST increase or decrease
% their flux in order to achieve the phenotype in the mutant strain.
% 3) Find the interventions needed that will ensure a increased production
% of the target of interest 

% For example, imagine that we would like to increase the production of
% succinate in Escherichia coli. Which are the interventions needed to
% increase the production of succinate? We will approach this problem in
% this tutorial and we will see how each of the three steps are solved.

% In this tutorial we will run steps 2 and 3 in GAMS and we will use MATLAB
% to call GAMS. Therefore, GAMS must be intalled in the system before
% running this turorial. After GAMS installation, we have to add tha path
% where GAMS in located
global TUTORIAL_INIT_CB;
global CBT_MILP_SOLVER;
if ~isempty(TUTORIAL_INIT_CB) && TUTORIAL_INIT_CB==1
    initCobraToolbox
    changeCobraSolver('gurobi','all');
end
if isempty(CBT_MILP_SOLVER)
    changeCobraSolver('gurobi','all');
end

pathTutorial = which('tutorial_OptForceG.m');
pathstr = fileparts(pathTutorial);
cd(pathstr)
% Now that we have added GAMS path we can start with the modelling

%% Modelling 
% First we load the model. This model comprises only 90 reactions, which
% describe the central metabolism of E. coli [2]. Then, we change the
% objective function to maximize biomass ("R75"). We also change the lower
% bounds, so E. coli will be able to consume glucose, oxygen, sulfate,
% ammomium, citrate and glycerol. 

model = []; load('AntCore');
model.c(strcmp(model.rxns, 'R75')) = 1;
model = changeRxnBounds(model, 'EX_gluc', -100, 'l'); 
model = changeRxnBounds(model, 'EX_o2', -100, 'l'); 
model = changeRxnBounds(model, 'EX_so4', -100, 'l'); 
model = changeRxnBounds(model, 'EX_nh3', -100, 'l'); 
model = changeRxnBounds(model, 'EX_cit', -100, 'l'); 
model = changeRxnBounds(model, 'EX_glyc', -100, 'l'); 

% We define an ID for this run. Each time you run the functions associated
% to the optForce procedure, some folders will be generated to store inputs
% and ouputs. These folder will be located in the folder defined in your
% run ID. Thus if your runID is ''TestOptForce", the structure of the
% folder will be the following:

% ??? CurrentFolder
% |   ??? TestOptForce
% |   |   ??? Inputs
% |   |   ??? Outputs

% To avoid the generation of inputs and outputs folders, set keepInputs =
% 0, printExcel = 0, printText = 0 and keepGamsOutputs = 0 Also, a report
% of the run is generated each time you run the functions associated to the
% optForce procedure. So, the idea is to give a different runID each time
% you run the functions, so you will be able to see the report (inputs
% used, outputs generated, errors in the run) for each run. We define then
% our runID

runID = 'TestOptForce';

%% Step 1: Flux Variability Analysis 
% We run the first step which consist on performing a FVA for both
% wild-type and mutant strains

%We define constraints for each strain
Constr_WT = struct('rxnList', {{'R75'}}, 'rxnValues', 14, 'rxnBoundType', 'b');
Constr_MT = struct('rxnList', {{'R75', 'EX_suc'}}, 'rxnValues', [0,155.55], 'rxnBoundType', 'bb');

% We  run the FVA analysis for both strains
[minFluxes_WT, maxFluxes_WT, minFluxes_MT, maxFluxes_MT]=FVAOptForce(model, Constr_WT, Constr_MT);
disp([minFluxes_WT, maxFluxes_WT, minFluxes_MT, maxFluxes_MT])
% Now, the run the second step of OptFoce.
%% Step 2: Find Must Sets
% A) Finding first order must sets Fow now, only functions to find first
% and second order must sets are supported. As depicted in Fig. 1, the
% first order must sets are MUSTU and MUSTL; and second order must sets are
% MUSTUU, MUSTLL and MUSTUL

% We define constraints
constrOpt = struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100,0,155.5]');
% We then run the functions findMustLWithGAMS.m and findMustUWithGAMS.m
% that will find mustU and mustL sets, respectively.
% Important: To run these function you will need a solver able to solve
% Mixed Integer Linear Programming (MILP or MIP) problems. Some popular
% options are: cplex and gurobi. You can see which gams solvers are
% available in your systems to solve MIP problems by running
% checkGAMSSolvers('MIP')
solvers = checkGAMSSolvers('MIP'); disp(solvers);
disp(solvers)

% We run then findMustLWithGAMS.m and findMustUWithGAMS.m. Here, the
% following inputs are provided (they are showed by order): model,
% minFluxesW, maxFluxesW, constrOpt were defined before. 
% solverName = 'cplex' // runID = 'TestOptForce' // outputFolder = '' //
% outputFileName = '' // printExcel = 1 // printText = 1 // printReport = 1
% // keepInputs = 1 // keepGamsOutputs = 1 // verbose = 0

[mustLSet, pos_mustL] = findMustLWithGAMS(model, minFluxes_WT, maxFluxes_WT, 'constrOpt', constrOpt, ...
'solverName', 'cplex', 'runID', runID, 'outputFolder', 'OutputsFindMustL', 'outputFileName', 'MustL', ...
'printExcel', 1, 'printText', 1, 'printReport', 1, 'keepInputs', 1, 'keepGamsOutputs', 1, 'verbose', 1);
disp(mustLSet)

[mustUSet, pos_mustU] = findMustUWithGAMS(model, minFluxes_WT, maxFluxes_WT, 'constrOpt', constrOpt, ...
'solverName', 'cplex', 'runID', runID, 'outputFolder', 'OutputsFindMustU', 'outputFileName', 'MustU', ...
'printExcel', 1, 'printText', 1, 'printReport', 1, 'keepInputs', 1, 'keepGamsOutputs', 1, 'verbose', 1);
% We display the reactions that belongs to the mustU set
disp(mustUSet)

% B) Finding first order must sets
% First, we define the reactions that will be exluded from the analysis. It
% it suggested to eliminate reactions found in the previous step as well as
% exchange reactions
constrOpt = struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');
exchangeRxns = model.rxns(cellfun(@isempty, strfind(model.rxns,'EX_')) == 0);
excludedRxns = unique([mustUSet; mustLSet; exchangeRxns]);
mustSetFirstOrder = unique([mustUSet; mustLSet]);

% Now, we run the functions for finding second order must sets

[mustUU, pos_mustUU, mustUU_linear, pos_mustUU_linear] = findMustUUWithGAMS(model, minFluxes_WT, maxFluxes_WT, ...
     'constrOpt', constrOpt, 'excludedRxns', excludedRxns, 'mustSetFirstOrder', mustSetFirstOrder, 'solverName', 'cplex',...
    'runID', runID, 'outputFolder', 'OutputsFindMustUU', 'outputFileName', 'MustUU' , 'printExcel', 1, 'printText', 1, ...
    'printReport', 1, 'keepInputs', 1, 'keepGamsOutputs', 1, 'verbose', 1);
% We display the reactions that belongs to the mustUU set
disp(mustUU)

[mustLL, pos_mustLL, mustLL_linear, pos_mustLL_linear] = findMustLLWithGAMS(model, minFluxes_WT, maxFluxes_WT, ...
     'constrOpt', constrOpt, 'excludedRxns', excludedRxns, 'mustSetFirstOrder', mustSetFirstOrder, 'solverName', 'cplex',...
    'runID', runID, 'outputFolder', 'OutputsFindMustLL', 'outputFileName', 'MustLL' , 'printExcel', 1, 'printText', 1, ...
    'printReport', 1, 'keepInputs', 1, 'keepGamsOutputs', 1, 'verbose', 1);
% We display the reactions that belongs to the mustLL set. In this case,
% MustLL is an empty array because no reaction was found in the mustLL set.
disp(mustLL)

[mustUL, pos_mustUL, mustUL_linear, pos_mustUL_linear] = findMustULWithGAMS(model, minFluxes_WT, maxFluxes_WT, ...
     'constrOpt', constrOpt, 'excludedRxns', excludedRxns, 'mustSetFirstOrder', mustSetFirstOrder, 'solverName', 'cplex',...
    'runID', runID, 'outputFolder', 'OutputsFindMustUL', 'outputFileName', 'MustUL' , 'printExcel', 1, 'printText', 1, ...
    'printReport', 1, 'keepInputs', 1, 'keepGamsOutputs', 1, 'verbose', 1);

%We display the reactions that belongs to the mustUL set. In this case,
%MustUL is an empty array because no reaction was found in the mustUL set.
disp(mustUL)

%% Step 3: OptForce 
% We define constraints and we define "K" the number of
% interventions allowed, "n_sets" the maximum number of sets to find, and
% "targetRxn" the reaction producing the metabolite of interest (in this
% case, succinate). Additionally, we define the mustU set as the union of
% the reactions that must be upregulated in both first order and second
% order must sets; and mustL set as the union of the reactions that must be
% downregulated in both first order and second order must sets

% run optForce
constrOpt = struct('rxnList', {{'EX_gluc','R75'}}, 'values', [-100,0]);
k = 1;
nSets = 1;
targetRxn = 'EX_suc';
mustU = unique(union(mustUSet, mustUU));
mustL = unique(union(mustLSet, mustLL));
[optForceSets, posOptForceSets, typeRegOptForceSets] = optForceWithGAMS(model, targetRxn, mustU, mustL, minFluxes_WT, ...
    maxFluxes_WT, minFluxes_MT, maxFluxes_MT, 'k', k, 'nSets', nSets, 'constrOpt', constrOpt, ...
    'runID', runID, 'outputFolder', 'OutputsOptForce', 'outputFileName', 'OptForce', 'solverName', 'cplex', 'printExcel', 1, 'printText', 1, ...
    'printReport', 1, 'keepInputs', 1, 'keepGamsOutputs', 1,'verbose', 1);

% We display the reactions found by optForce
disp(optForceSets)

% The reaction found was "SUCt", i.e. a transporter for succinate (a very
% intuitive solution). Next, we will increase "k" and we will exclude
% "SUCt" from upregulations to found non-intuitive solutions. We will only
% search for the 5 best solutions, but you can try with a higher number. We
% will change the runID to save both resutls (k = 1 and K = 2) in diffetent
% folders

k = 2;
nSets = 20;
runID = 'TestOptForce2';
excludedRxns = struct('rxnList', {{'SUCt'}}, 'typeReg','U');
[optForceSets, posOptForceSets, typeRegOptForceSets] = optForceWithGAMS(model, targetRxn, mustU, mustL, minFluxes_WT, ...
    maxFluxes_WT, minFluxes_MT, maxFluxes_MT, 'k', k, 'nSets', nSets, 'constrOpt', constrOpt, 'excludedRxns', excludedRxns, ...
    'runID', runID, 'outputFolder', 'OutputsOptForce', 'outputFileName', 'OptForce', 'solverName', 'cplex', 'printExcel', 1, 'printText', 1, ...
    'printReport', 1, 'keepInputs', 1, 'keepGamsOutputs', 1,'verbose', 1);
%We display the reactions found by optForce
disp(optForceSets)

%% References 
% [1] Ranganathan S, Suthers PF, Maranas CD (2010) OptForce: An
% Optimization Procedure for Identifying All Genetic Manipulations Leading
% to Targeted Overproductions. PLOS Computational Biology 6(4): e1000744.
% https://doi.org/10.1371/journal.pcbi.1000744. [2] Maciek R. Antoniewicz,
% David F. Kraynie, Lisa A. Laffend, Joanna González-Lergier, Joanne K.
% Kelleher, Gregory Stephanopoulos, Metabolic flux analysis in a
% nonstationary system: Fed-batch fermentation of a high yielding strain of
% E. coli producing 1,3-propanediol, Metabolic Engineering, Volume 9, Issue
% 3, May 2007, Pages 277-292, ISSN 1096-7176,
% https://doi.org/10.1016/j.ymben.2007.01.003.