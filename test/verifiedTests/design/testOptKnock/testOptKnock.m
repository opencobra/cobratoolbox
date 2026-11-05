% The COBRAToolbox: testOptKnock.m
%
% Purpose:
%     - tests the basic functionality of optKnock
%
% Function under test:
%     src/design/OptKnock.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model, loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Without constrOpt the inner growth maximisation is lost
%       SEVERITY: wrong-result
%       TRIGGER: a solved OptKnock call without constrOpt, or with a constrOpt that omits the biomass
%         reaction; for the anaerobic model of this test, OptKnock(model, smallRxnList, smallOptions)
%       OBSERVED: createBilevelMILPproblem puts the inner objective into the dual only for the
%         reactions of constrOpt, so the status is optimal with 33.78 of EX_succ(e), no knockouts and
%         a growth of 0, although the strain without knockouts grows at 0.516 and makes no EX_succ(e)
%       EXPECTED: the production at the maximal growth of the knockout strain; the empty default
%         of constrOpt is documented as optional. Only the problem building of this input is tested.
%       LINES: 86-89
%     - DEFECT: A model with coupling constraints stops with an error
%       SEVERITY: error
%       TRIGGER: a model with the field C, for which line 60 announces that C is ignored
%       OBSERVED: the conversion with OrderReactions multiplies C by a column of reaction
%         directions (convertToIrreversible, line 182), which fails with 'Unable to perform
%         assignment because the indices on the left side are not compatible'
%       EXPECTED: the warning, then the problem without the coupling constraints
%       LINES: 112
%
% Authors:
%     - CI integration: Laurent Heirendt March 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Note:
%     - The solver libraries must be included separately

global CBTDIR

clear options

%save original directory
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptKnock'));
cd(fileDir);

% require LP and MILP solvers; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'needsMILP', true);

% set the tolerance
tol = 1e-3;

% load model
model = getDistributedModel('ecoli_core_model.mat');
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
solverPkgs = {'gurobi', 'tomlab_cplex'};

for k = 1:length(solverPkgs)

    % change the COBRA solver
    solverOKLP = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    solverOKMILP = changeCobraSolver(solverPkgs{k}, 'MILP', 0);

    if solverOKLP && solverOKMILP

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

%% Option branches, with a small candidate list so that each MILP stays short
changeCobraSolver(solvers.LP{1}, 'LP', 0);
changeCobraSolver(solvers.MILP{1}, 'MILP', 0);
smallRxnList = {'ACALD'; 'ALCD2x'; 'LDH_D'; 'PFL'; 'GLUDy'; 'THD2'};
smallOptions = struct('targetRxn', 'EX_succ(e)'); % default of at most 5 deletions

%% Missing or unknown target reaction
assert(verifyCobraFunctionError('OptKnock', 'inputs', {model, smallRxnList}, ...
                                'testMessage', 'OptKnock: No target reaction specified'));
assert(verifyCobraFunctionError('OptKnock', 'inputs', {model, smallRxnList, struct('numDel', 1)}, ...
                                'testMessage', 'No target reaction (options.targetRxn) defined'));
unknownTargetMessage = ['The reaction notInModel is not part of the model. Try using ', ...
                        'searchModel(model, ''notInModel'') to find reactions with a similar name.'];
assert(verifyCobraFunctionError('OptKnock', 'inputs', {model, smallRxnList, struct('targetRxn', 'notInModel')}, ...
                                'testMessage', unknownTargetMessage));

%% Default flags and file name, then previous solutions
% The knockouts are valid and the reported production is reached within tolerance at the maximal
% growth of the knockout strain.
defaultSol = OptKnock(model, smallRxnList, smallOptions, constrOpt);
assert(defaultSol.stat == 1);
assert(numel(defaultSol.rxnList) <= 5);
assert(all(ismember(defaultSol.rxnList, smallRxnList)));
[~, ~, defaultMaxProd] = testOptKnockSol(model, smallOptions.targetRxn, defaultSol.rxnList);
assert(abs(defaultSol.obj - defaultMaxProd) / defaultMaxProd < tol);

% the previous solution cannot be returned again, and an empty entry is ignored
assert(~isempty(defaultSol.rxnList));
secondSol = OptKnock(model, smallRxnList, smallOptions, constrOpt, {defaultSol.rxnList, {}}, false, 'optknocksol');
assert(~isequal(sort(secondSol.rxnList), sort(defaultSol.rxnList)));

%% Only build the problem, without constrOpt: no solve, with and without an initial solution
buildOptions = smallOptions;
buildOptions.solveOptKnock = false;
[builtSol, builtProblem] = OptKnock(model, smallRxnList, buildOptions);
assert(isempty(builtSol.rxnList) && isempty(builtSol.fluxes));
assert(isempty(builtProblem.x0));

% a valid initial solution sets the integer part: 0 for a knocked-out candidate, 1 otherwise,
% counted over the irreversible reactions (both directions of a reversible reaction)
buildOptions.initSolution = {'ACALD'; 'ALCD2x'};
[~, initProblem] = OptKnock(model, smallRxnList, buildOptions);
selInteger = initProblem.vartype == 'B';
assert(isequal(size(initProblem.x0), [size(initProblem.A, 2), 1]));
assert(all(ismember(initProblem.x0(selInteger), [0, 1])));
assert(all(isnan(initProblem.x0(~selInteger))));
irrevInitRxns = ~cellfun(@isempty, regexp(initProblem.model.rxns, '^(ACALD|ALCD2x)(_[fbr])?$', 'once'));
assert(nnz(initProblem.x0(selInteger) == 0) == nnz(irrevInitRxns));

% the solver accepts that start and finds the same optimum
initOptions = smallOptions;
initOptions.initSolution = defaultSol.rxnList;
initSol = OptKnock(model, smallRxnList, initOptions, constrOpt);
assert(abs(initSol.obj - defaultSol.obj) <= tol * abs(defaultSol.obj));

% an initial solution with more deletions than allowed is discarded
buildOptions.initSolution = smallRxnList;
lastwarn('');
[~, invalidInitProblem] = OptKnock(model, smallRxnList, buildOptions);
assert(contains(lastwarn, 'Initial solution not valid'));
assert(isempty(invalidInitProblem.x0));

%% Verbose flag: the size of the MILP is printed
buildOptions = rmfield(buildOptions, 'initSolution');
verboseOutput = evalc('[~, verboseProblem] = OptKnock(model, smallRxnList, buildOptions, constrOpt, [], true);');
[nConstraints, nVariables] = size(verboseProblem.A);
assert(contains(verboseOutput, sprintf('MILP problem with %d constraints', nConstraints)));
assert(contains(verboseOutput, sprintf('%d continuous variables', nVariables)));

%% A model with extra variables gives a warning, as they are ignored
% issueConfirmationWarning waits for a confirmation on a jenkins home, so it is not called there
if isempty(strfind(getenv('HOME'), 'jenkins'))
    modelExtraVars = model;
    modelExtraVars.E = sparse(numel(model.mets), 1);
    modelExtraVars.evarlb = 0;
    modelExtraVars.evarub = 0;
    modelExtraVars.evarc = 0;
    lastwarn('');
    OptKnock(modelExtraVars, smallRxnList, buildOptions);
    assert(contains(lastwarn, 'optKnock does not handle the additional constraints'));
end

%return to original directory
cd(currentDir);
