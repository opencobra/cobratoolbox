% The COBRAToolbox: testAddLopLawConstraints.m
%
% Purpose:
%     - test, whether added constraints actually lead to loopless
%     solutions.
%
% Function under test:
%     src/analysis/thermo/thermoFBA/addLoopLawConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation; a toy model with a loop, needs a MILP solver for the loop law.
%     connectedRxnsByEFM is replaced by a stub: it needs EFMtool, which is not distributed.
%
% Coverage exemptions:
%     None apart from the lines of the defects below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A wrong input ends with an unassigned output
%       SEVERITY: error
%       TRIGGER: MILPproblem = addLoopLawConstraints(LPproblem, model) with fewer variables than reactions, or a rxnIndex of the wrong size or out of bounds
%       OBSERVED: a message is displayed, then the caller gets an error because MILPproblem was not assigned; the comment in the source notes this
%       EXPECTED: an error that names the problem, or the output assigned
%       LINES: 94, 98, 102
%     - DEFECT: Method 3 without a vartype returns numbers instead of characters
%       SEVERITY: wrong-result
%       TRIGGER: addLoopLawConstraints(LPproblem, model, rxnIndex, 3) with no LPproblem.vartype
%       OBSERVED: vartype starts as [] and character assignments store their codes, 67 and 66
%       EXPECTED: a character vector, as with methods 1 and 2
%       LINES: 333
%
% Authors:
%     - Thomas Pfau Oct 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddLoopLawConstraints.m'));

% anything written by the solvers goes to a temporary folder
workDir = tempname;
mkdir(workDir);
restoreFolder = onCleanup(@() leaveWorkDir(currentDir, workDir));
cd(workDir);

% require a MILP solver; skip gracefully if none is available
prepareTest('needsMILP', true);

% set the tolerance
tol = 1e-4;

loopToyModel = createToyModelForgapFind();
LPproblem = buildOptProblemFromModel(loopToyModel);
nRxns = numel(loopToyModel.rxns);
solverPkgs = {'tomlab_cplex', 'gurobi', 'ibm_cplex','glpk'};
methods = [1,2];
options = [false, true];
R4objective = double(ismember(loopToyModel.rxns,'R4')); %This should not be able to carry flux under looplaw constraints.
NormalObjective = double(loopToyModel.c ~= 0);

for k = 1:length(solverPkgs)
    solverOk = changeCobraSolver(solverPkgs{k}, 'all', 0);
    if solverOk
        fprintf([' > Running testAddLoopLawConstraints with ' solverPkgs{k} '...']);
        for method = methods
            for reduce_vars = options
                %Test original objective
                LPproblem.c = NormalObjective;
                MILPProblem = addLoopLawConstraints(LPproblem,loopToyModel,1:nRxns,method,reduce_vars);
                sol = solveCobraMILP(MILPProblem);
                assert(abs(sol.obj - 1000) < tol); %This can carry a flux of 1000
                assert(all(abs(sol.full(ismember(loopToyModel.rxns,{'R4','R5','R6'}))) < tol)); %The loop is not part of the solution and can't carry flux.
                LPproblem.c = R4objective;
                MILPProblem = addLoopLawConstraints(LPproblem,loopToyModel,1:nRxns,method,reduce_vars);
                sol = solveCobraMILP(MILPProblem);
                assert(abs(sol.obj) < tol); %There can't be any flux on this.
            end
        end
        fprintf('Done.\n');
    end
end

% define the solver packages to be used to run this test
fprintf('Done.\n');

% The sections below use the first solver that works, and replace functions from a temporary folder
for k = 1:length(solverPkgs)
    if changeCobraSolver(solverPkgs{k}, 'all', 0)
        break
    end
end
stubDir = tempname;
mkdir(stubDir);
removeStubDir = onCleanup(@() rmdir(stubDir, 's'));
LPproblem.c = NormalObjective;

%% Default arguments: method 2, and all the reactions as the variables of the problem
defaultProblem = addLoopLawConstraints(LPproblem, loopToyModel, 1:nRxns);
nBinary = nnz(defaultProblem.vartype == 'B');
assert(nBinary > 0 && size(defaultProblem.A, 2) == nRxns + 2*nBinary, ...
    'The default must be method 2, with a binary and a continuous variable per internal reaction.');
emptyArguments = addLoopLawConstraints(LPproblem, loopToyModel, 1:nRxns, [], []);
assert(isequal(size(emptyArguments.A), size(defaultProblem.A)), 'Empty arguments must take the defaults.');
noIndex = addLoopLawConstraints(LPproblem, loopToyModel);
assert(isequal(size(noIndex.A), size(defaultProblem.A)), 'rxnIndex must default to all the variables.');

%% Extra variables in the problem: the first n are taken as the fluxes
extendedProblem = LPproblem;
extendedProblem.A = [LPproblem.A, sparse(size(LPproblem.A, 1), 1)];
extendedProblem.c = [LPproblem.c; 0];
extendedProblem.lb = [LPproblem.lb; 0];
extendedProblem.ub = [LPproblem.ub; 1];
consoleText = evalc('extendedMILP = addLoopLawConstraints(extendedProblem, loopToyModel);');
assert(contains(consoleText, 'extra variables in LPproblem'), 'Extra variables must be reported.');
assert(size(extendedMILP.A, 2) == size(defaultProblem.A, 2) + 1, 'The extra variable must be kept.');

%% Wrong inputs are reported
tooFewVariables = LPproblem;
tooFewVariables.A = LPproblem.A(:, 1:end-1);
consoleText = evalc('addLoopLawConstraints(tooFewVariables, loopToyModel);');
assert(contains(consoleText, 'LPproblem must have at least as many variables as model has reactions'));
consoleText = evalc('addLoopLawConstraints(LPproblem, loopToyModel, 1:nRxns - 1);');
assert(contains(consoleText, 'rxnIndex must contain exactly n entries'));
consoleText = evalc('addLoopLawConstraints(LPproblem, loopToyModel, (1:nRxns) + 1);');
assert(contains(consoleText, 'rxnIndex out of bounds'));

%% A method that does not exist is reported
consoleText = evalc('addLoopLawConstraints(LPproblem, loopToyModel, 1:nRxns, 4, 1);');
assert(contains(consoleText, 'method not found'));

%% The other ways of finding the nullspace also make the problem loopless
% with and without reduce_vars, with and without model.SIntRxnBool
modelWithInt = findSExRxnInd(loopToyModel);
nullspaceCases = {'original', loopToyModel, 1; 'original', modelWithInt, 0; 'fastSNP', loopToyModel, 1};
for k = 1:size(nullspaceCases, 1)
    loopInfo = struct('method', nullspaceCases{k, 1});
    LPproblem.c = NormalObjective;
    [MILPProblem, loopInfoOut] = addLoopLawConstraints(LPproblem, nullspaceCases{k, 2}, 1:nRxns, 2, ...
        nullspaceCases{k, 3}, loopInfo);
    % the columns of N are internal cycles, on the internal reactions only
    assert(norm(loopToyModel.S*loopInfoOut.N, inf) < tol, 'N must be in the nullspace of S.');
    assert(all(loopInfoOut.N(~loopInfoOut.isInternal, :) == 0, 'all'), 'N must be zero off the internal reactions.');
    sol = solveCobraMILP(MILPProblem);
    assert(abs(sol.obj - 1000) < tol, 'The problem must keep the flux outside the loop.');
    LPproblem.c = R4objective;
    MILPProblem = addLoopLawConstraints(LPproblem, nullspaceCases{k, 2}, 1:nRxns, 2, nullspaceCases{k, 3}, loopInfo);
    sol = solveCobraMILP(MILPProblem);
    assert(abs(sol.obj) < tol, 'The loop must not carry flux.');
end
LPproblem.c = NormalObjective;

%% A nullspace given as input is used as it is
givenInfo = struct('method', 'original', 'N', loopInfoOut.N, 'isInternal', loopInfoOut.isInternal);
[givenProblem, givenOut] = addLoopLawConstraints(LPproblem, loopToyModel, 1:nRxns, 2, 1, givenInfo);
assert(isequal(givenOut.N, givenInfo.N), 'The given nullspace must be kept.');
assert(size(givenProblem.A, 2) == nRxns + 2*nnz(givenInfo.isInternal), ...
    'The given nullspace must decide the number of new variables.');

%% LLC-EFM: reactions linked by elementary flux modes (connectedRxnsByEFM replaced by a stub)
fid = fopen(fullfile(stubDir, 'connectedRxnsByEFM.m'), 'w');
fprintf(fid, 'function rxnLink = connectedRxnsByEFM(model, conComp, rxnInLoops)\nrxnLink = getappdata(0, ''rxnLink'');\nend\n');
fclose(fid);
addpath(stubDir);
rehash path
setappdata(0, 'rxnLink', speye(nRxns));
consoleText = evalc(['[~, efmInfo] = addLoopLawConstraints(LPproblem, loopToyModel, 1:nRxns, 2, 1, ' ...
    'struct(''method'', ''LLC-EFM'', ''printLevel'', 1));']);
assert(efmInfo.useRxnLink && contains(consoleText, 'Use connections from EFMs to implement LLCs'), ...
    'The EFM connections must be used when they are found.');
[~, efmInfo] = addLoopLawConstraints(LPproblem, loopToyModel, 1:nRxns, 2, 1, struct('method', 'LLC-EFM'));
assert(efmInfo.useRxnLink, 'The EFM connections must be used without printing too.');
setappdata(0, 'rxnLink', []);
consoleText = evalc(['[~, efmInfo] = addLoopLawConstraints(LPproblem, loopToyModel, 1:nRxns, 2, 1, ' ...
    'struct(''method'', ''LLC-EFM'', ''printLevel'', 1));']);
assert(~efmInfo.useRxnLink && contains(consoleText, 'Unable to find EFMs'), ...
    'Without EFMs the connections of the nullspace must be used.');
rmpath(stubDir);
rmappdata(0, 'rxnLink');
rehash path

%% Variable types and a quadratic part of the problem are kept, in each method
fullProblem = LPproblem;
fullProblem.vartype = repmat('I', nRxns, 1);
fullProblem.F = speye(nRxns);
for method = 1:3
    extendedFull = addLoopLawConstraints(fullProblem, loopToyModel, 1:nRxns, method, 1, givenInfo);
    nTotal = size(extendedFull.A, 2);
    assert(numel(extendedFull.vartype) == nTotal && all(extendedFull.vartype(1:nRxns) == 'I'), ...
        'The variable types of the problem must be kept.');
    assert(isequal(size(extendedFull.F), [nTotal, nTotal]) && isequal(extendedFull.F(1:nRxns, 1:nRxns), fullProblem.F), ...
        'The quadratic part must be kept, padded with zeros.');
    assert(isequal(extendedFull.lb(1:nRxns), fullProblem.lb) && isequal(extendedFull.ub(1:nRxns), fullProblem.ub), ...
        'The bounds of the fluxes must be kept.');
    assert(numel(extendedFull.lb) == nTotal && numel(extendedFull.ub) == nTotal && numel(extendedFull.c) == nTotal, ...
        'Bounds and objective must cover the new variables.');
end

%% Method 3 gives double sided constraints: each sense of the problem maps onto b_L and b_U
senseProblem = fullProblem;
senseProblem.csense(1:3) = 'GLE';
senseMILP = addLoopLawConstraints(senseProblem, loopToyModel, 1:nRxns, 3, 1, givenInfo);
nRows = size(senseMILP.A, 1);
assert(numel(senseMILP.b_L) == nRows && numel(senseMILP.b_U) == nRows && isempty(senseMILP.csense), ...
    'Method 3 must state the constraints with b_L and b_U only.');
assert(all(senseMILP.b_L <= senseMILP.b_U), 'The lower sides must not exceed the upper sides.');
assert(senseMILP.b_U(1) == inf && senseMILP.b_L(2) == -inf && senseMILP.b_L(3) == senseMILP.b_U(3), ...
    'A G row must be open above, an L row open below, and an E row closed.');

%Remove the output, to keep the toolbox updateable.
fileName = [fileDir filesep 'MILPProblem.mat'];
if exist(fileName, 'file') == 2
    delete(fileName);
end

% change the directory, and remove the temporary folder
clear restoreFolder

function leaveWorkDir(folder, workDir)
% Back to the caller's folder, on every exit from this test, then remove the temporary folder.
cd(folder);
rmdir(workDir, 's');
end
