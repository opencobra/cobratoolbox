% The COBRAToolbox: testCreateBilevelMILPproblem.m
%
% Purpose:
%     - createBilevelMILPproblem builds the single-level mixed-integer linear problem that is
%     equivalent to a bilevel reaction-deletion problem (outer: knockouts and objective; inner: flux
%     balance), with optional constraints, measured fluxes and previous solutions to exclude.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/design/createBilevelMILPproblem.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateBilevelMILPproblem'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a small network with 2 metabolites and 4 reactions; reactions 2 and 3 may be deleted (integer),
% reaction 1 carries a fixed-flux constraint and the pair (1, 2) of the integer reactions is a
% forward/backward match
model.S = [1 -1  0  0; ...
           0  1 -1 -1];
model.ub = [10; 10; 10; 10];
model.c = [0; 0; 1; 0];
cLinear = [0; 0; 1; 0];
cInteger = [0; 0];
selRxns = [0; 1; 1; 0];
selRxnMatch = [1 2];
constrOpt.rxnInd = 1;
constrOpt.values = 5;
constrOpt.sense = 'E';
options.vMax = 1000;
options.numDel = 1;
options.numDelSense = 'L';

problem = createBilevelMILPproblem(model, cLinear, cInteger, selRxns, selRxnMatch, constrOpt, [], options);

%% size and variable types

% variables: 4 fluxes, 2 binaries, 2 dual variables for the metabolites, 4 + 2 further dual
% variables and 1 constraint dual = 15; rows: 17
assert(isequal(size(problem.A), [17 15]));
assert(strcmp(problem.vartype, 'CCCCBBCCCCCCCCC'));
assert(isequal(size(problem.b), [17 1]) && numel(problem.csense) == 17);
assert(isequal(problem.contSolInd, 1:4) && isequal(problem.intSolInd, [5 6]));

%% senses and right-hand sides

assert(strcmp(problem.csense, 'EEEELLLGGGGGGLLEL'));
% mass balance rows are equalities with zero right-hand side; the fixed flux constraint has value 5
assert(isequal(problem.b(1:3), [0; 0; 5]));
% the knockout budget row: -(number of forward reactions) + numDel = -1 + 1
assert(problem.b(end) == 0);

%% bounds

assert(isequal(problem.lb', [0 0 0 0 0 0 -1000 -1000 0 0 0 0 -1000 -1000 -1000]));
assert(isequal(problem.ub', [1000 1000 1000 1000 1 1 1000 1000 1000 1000 1000 1000 1000 1000 1000]));

%% objective

% the linear objective on the fluxes and the integer cost on the binaries
assert(isequal(problem.c', [0 0 1 0 zeros(1, 11)]));

%% the knockout budget row counts the forward integer reactions

lastRow = full(problem.A(end, :));
% the matched pair removes reaction 1 of the integer set from the count
assert(isequal(lastRow(5:6), [0 -1]) && nnz(lastRow) == 1);

%% the sense of the fixed-flux constraint sets the bounds of its dual variable

% the dual variable of the constraint is the last variable (15)
for sense = {'E', 'L', 'G', 'X'}
    constr = constrOpt;
    constr.sense = sense{1};
    p = createBilevelMILPproblem(model, cLinear, cInteger, selRxns, selRxnMatch, constr, [], options);
    switch sense{1}
        case 'L'
            assert(p.lb(15) == 0 && p.ub(15) == 1000);
        case 'G'
            assert(p.lb(15) == -1000 && p.ub(15) == 0);
        otherwise
            assert(p.lb(15) == -1000 && p.ub(15) == 1000);
    end
end

%% measured fluxes and previous solutions

measOpt.rxnSel = [0; 0; 1; 0];
measOpt.values = 2;
measOpt.weights = 3;
previous = [1; 0; 1; 0];
problem = createBilevelMILPproblem(model, cLinear, cInteger, selRxns, selRxnMatch, [], measOpt, options, previous);
% two deviation variables for the measured flux and rows for it and for the previous solution
assert(size(problem.A, 2) == 16);
assert(strcmp(problem.vartype(15:16), 'CC'));
% objective weights of the two deviation variables
assert(isequal(problem.c(15:16)', [3 3]));
% the last row excludes the previous solution
assert(problem.csense(end) == 'G' && problem.b(end) == 1);

% change the directory
cd(currentDir)
