function x = testOptKnock()
%testOptKnock Tests the functionality of optKnock

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));


% load model
load('ecoli_core_model.mat');
model = changeRxnBounds(model,'EX_o2(e)',0,'l'); %anaerobic
model = changeRxnBounds(model,'EX_glc(e)',-20,'l'); %set glucose uptake to 20

% selectedRxns (don't want to knockout biomass or exchange rxns)
selectedRxns = {model.rxns{1},model.rxns{3:5},model.rxns{7:8}, ...
    model.rxns{10},model.rxns{12},model.rxns{15:16},model.rxns{18}, ...
    model.rxns{40:41},model.rxns{44},model.rxns{46},model.rxns{48:49}, ...
    model.rxns{51},model.rxns{53:55},model.rxns{57},model.rxns{59:62}, ...
    model.rxns{64:68},model.rxns{71:77},model.rxns{79:83}, ...
    model.rxns{85:86},model.rxns{89:95}}';

%set OptKnock condition and target
minGrowthRate = 0.05;

% default OptKnock settings
options.numDelSense = 'L';
options.vMax = 1000;
options.solveOptKnock = true;

% Set up the lower limit on growth rate and ATPM flux
biomassRxnName = 'Biomass_Ecoli_core_N(w/GAM)-Nmet2';
constrOpt.sense = 'GE'; % 'G' greater,'E' equal,'L' less
constrOpt.values = [minGrowthRate 8.39];
constrOpt.rxnList = {biomassRxnName,'ATPM'};

% Previous solutions that should not be repeated again
previousSolution = [];

% Run OptKnock (change this for different simulations)
options.targetRxn= 'EX_succ(e)';
options.numDel = 5;
substrateRxn = 'EX_glc(e)';

% % change or set a time limit
maxTime = 3600; %time in seconds
changeCobraSolverParams('MILP','timeLimit',maxTime);

% the function that actually runs optknock
tstart = clock;
[optKnockSol,bilevelMILPproblem] = OptKnock(model,selectedRxns,options,constrOpt,previousSolution,0,'optknocksol');
tend = etime(clock,tstart)

% tag for the solution
optKnockSol.substrateRxn = substrateRxn;
optKnockSol.targetRxn=options.targetRxn;
optKnockSol.numDel=options.numDel;

%get biomass reaction number
biomassRxnID = find(strcmp(biomassRxnName,bilevelMILPproblem.model.rxns));

%check the result from OptKnock
[growthRate,minProd,maxProd] = testOptKnockSol(model,optKnockSol.targetRxn,optKnockSol.rxnList);

if (abs(optKnockSol.obj - maxProd) / maxProd < .001) && ((optKnockSol.full(biomassRxnID) - growthRate) / growthRate < .001) % acculacy must be within .1%
    slnCheck = 'valid_sln';
else slnCheck = 'unsound_sln';
end

if (maxProd - minProd) / maxProd < .001 % acculacy must be within .1%
    slnType = 'unique_point';
else slnType = 'non_unique';
end

%result display
fprintf('\n\nSubstrate = %s  \nTarget reaction= %s \n', optKnockSol.substrateRxn , options.targetRxn);
fprintf('Optknock solution is: %f \n\n', optKnockSol.obj );
optKnockSol.rxnList
fprintf('\n and the solution is: %s \n\n', slnCheck );

if all(ismember(optKnockSol.rxnList,{'ACALD';'ALCD2x';'GLUDy';'LDH_D';'PFL';'THD2'}))
    x = 1;
else
    display('OptKnock is known to work poorly with the glpk MILP solver.  This is an issue with the solver and not the COBRA toolbox.  We recommend the Tomlab/CPLEX or Gurobi solvers.');   
    x = 0;
end

 %return to original directory
 cd(oriDir);