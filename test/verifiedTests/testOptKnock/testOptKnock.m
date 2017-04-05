% The COBRAToolbox: testOptKnock.m
%
% Purpose:
%     - tests the basic functionality of optKnock
%
% Authors:
%     - CI integration: Laurent Heirendt March 2017
%
% Note:
%     - The solver libraries must be included separately

global CBTDIR

%save original directory
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptKnock'));
cd(fileDir);

% set the tolerance
tol = 1e-3;

% load model
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');
model = changeRxnBounds(model, 'EX_o2(e)', 0, 'l'); % anaerobic
model = changeRxnBounds(model, 'EX_glc(e)', -20, 'l'); % set glucose uptake to 20

% selectedRxns (don't want to knockout biomass or exchange rxns)
selectedRxns = {model.rxns{1}, model.rxns{3:5}, model.rxns{7:8}, ...
                model.rxns{10}, model.rxns{12}, model.rxns{15:16}, model.rxns{18}, ...
                model.rxns{40:41}, model.rxns{44}, model.rxns{46}, model.rxns{48:49}, ...
                model.rxns{51}, model.rxns{53:55}, model.rxns{57}, model.rxns{59:62}, ...
                model.rxns{64:68}, model.rxns{71:77}, model.rxns{79:83}, ...
                model.rxns{85:86}, model.rxns{89:95}}';

%set OptKnock condition and target
minGrowthRate = 0.05;

% default OptKnock settings
options.numDelSense = 'L';
options.vMax = 1000;
options.solveOptKnock = true;

% Set up the lower limit on growth rate and ATPM flux
biomassRxnName = 'Biomass_Ecoli_core_w_GAM';
constrOpt.sense = 'GE'; % 'G' greater,'E' equal,'L' less
constrOpt.values = [minGrowthRate 8.39];
constrOpt.rxnList = {biomassRxnName, 'ATPM'};

% Previous solutions that should not be repeated again
previousSolution = [];

% Run OptKnock (change this for different simulations)
options.targetRxn= 'EX_succ(e)';
options.numDel = 5;
substrateRxn = 'EX_glc(e)';

% change or set a time limit
maxTime = 3600; %time in seconds
changeCobraSolverParams('MILP', 'timeLimit', maxTime);

% define the solver packages to be used to run this test
solverPkgs = {'gurobi6', 'tomlab_cplex'};

for k = 1:length(solverPkgs)

    % change the COBRA solver
    solverOK = changeCobraSolver(solverPkgs{k}, 'MILP', 0);

    if solverOK == 1

        fprintf('   Testing optKnock using %s ... ', solverPkgs{k});

        % the function that actually runs optknock
        [optKnockSol,bilevelMILPproblem] = OptKnock(model, selectedRxns, options, constrOpt, previousSolution, 0, 'optknocksol');

        % tag for the solution
        optKnockSol.substrateRxn = substrateRxn;
        optKnockSol.targetRxn = options.targetRxn;
        optKnockSol.numDel = options.numDel;

        %get biomass reaction number
        biomassRxnID = find(strcmp(biomassRxnName, bilevelMILPproblem.model.rxns));

        %check the result from OptKnock
        [growthRate, minProd, maxProd] = testOptKnockSol(model, optKnockSol.targetRxn, optKnockSol.rxnList);

        % check if valid_sln or unsound_sln
        assert(abs(optKnockSol.obj - maxProd) / maxProd < tol);
        assert((optKnockSol.full(biomassRxnID) - growthRate) / growthRate < tol);

        %result display
        fprintf('\n\nSubstrate = %s  \nTarget reaction= %s \n', optKnockSol.substrateRxn , options.targetRxn);
        fprintf('Optknock solution is: %f \n\n', optKnockSol.obj );
        optKnockSol.rxnList

        assert(all(ismember(optKnockSol.rxnList, {'ACALD'; 'ALCD2x'; 'GLUDy'; 'LDH_D'; 'PFL'; 'THD2'})));

        % output a success message
        fprintf('Done.\n');
    end
end

%return to original directory
cd(currentDir);
