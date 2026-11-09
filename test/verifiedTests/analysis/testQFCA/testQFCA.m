% The COBRAToolbox: testQFCA.m
%
% Purpose:
%     - tests the basic functionality of QFCA algorithm
%
% Function under test:
%     src/analysis/QFCA/QFCA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model, extended with isozymes.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A network that reduces to one metabolite stops with an error
%       SEVERITY: error
%       TRIGGER: the network -> A, A -> B, A -> B, B -> with QFCA(model, false, 'gurobi')
%       OBSERVED: after the merging the reduced S has one row, so R of qr(S.') is a vector, diag(R)
%         is a matrix and the rank is a vector; the next line stops with "Colon operands must be
%         real scalars"
%       EXPECTED: the flux coupling table of the network
%       LINES: 125
%
% Authors:
%     - Original file: Mojtaba Tefagh, March 2019
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% require the specified toolboxes and solvers
solvers = prepareTest('needsLP', true, 'requireOneSolverOf', {'gurobi'});

% save the current path
currentDir = pwd;

% initialize the test
testPass = fileparts(which('testQFCA.m'));
cd(testPass);
load('fctable.mat');
load('blocked.mat');

% load the model
model = getDistributedModel('ecoli_core_model.mat');
model.rev = model.lb < 0;

% set the cobra solver
solverLPOK = changeCobraSolver(solvers.LP{1}, 'LP', 0);

fprintf('\n -- Running QFCA w/o reduction and using the %s solver...\n\n', solvers.LP{1});
[~, fctableD, blockedD] = QFCA(model, false, solvers.LP{1});
assert(all(blockedD == blocked));
assert(all(fctableD(:) == fctable(:)));
fprintf('\n -- Running QFCA w/ reduction and using the %s solver...\n\n', solvers.LP{1});
[~, fctableR, blockedR] = QFCA(model, true, solvers.LP{1});
assert(all(blockedR == blocked));
assert(all(fctableR(:) == fctable(:)));

%% without a solver argument the configured COBRA LP solver is used

[~, fctableDefault, blockedDefault] = QFCA(model, false);
assert(all(blockedDefault == blocked));
assert(all(fctableDefault(:) == fctable(:)));

%% isozymes: reactions with the same column are merged before the analysis

% add an isozyme of PGI, and two reversible copies of an isolated reaction X <=> Y: their only
% possible flux is the cycle through both, which is lost when they are merged into one reaction
[nMets, nRxns] = size(model.S);
isoIndex = findRxnIDs(model, 'PGI');
modelIso = model;
modelIso.S = [model.S, model.S(:, isoIndex), sparse(nMets, 2); ...
              sparse(2, nRxns + 1), [-1, -1; 1, 1]];
modelIso.rev = [model.rev; model.rev(isoIndex); true; true];
modelIso.rxns = [model.rxns; {'PGI_isozyme'; 'cycle1'; 'cycle2'}];
modelIso.mets = [model.mets; {'X[c]'; 'Y[c]'}];
[~, fctableIso, blockedIso] = QFCA(modelIso, false, solvers.LP{1});

% no added reaction is blocked, and the original reactions keep their state
assert(all(blockedIso(1:nRxns) == blocked));
assert(all(blockedIso(nRxns + 1:end) == 0));

% the coupling table has one row per reaction that is not blocked, the added ones come last
nTable = size(fctable, 1);
assert(isequal(size(fctableIso), [nTable + 3, nTable + 3]));
isoPosition = nnz(~blocked(1:isoIndex));
isoPair = [isoPosition, nTable + 1];
cyclePair = nTable + (2:3);

% PGI and its isozyme can replace each other, so they are coupled with nothing, not even mutually
expectedRows = zeros(2, nTable + 3);
expectedRows(1, isoPair(1)) = 1;
expectedRows(2, isoPair(2)) = 1;
assert(isequal(full(fctableIso(isoPair, :)), expectedRows));
assert(isequal(full(fctableIso(:, isoPair)), expectedRows'));

% the two copies of the isolated reaction carry the same cycle flux: fully coupled to each other
% and to nothing else
assert(all(all(fctableIso(cyclePair, cyclePair) == 1)));
assert(nnz(fctableIso(cyclePair, 1:nTable + 1)) == 0);
assert(nnz(fctableIso(1:nTable + 1, cyclePair)) == 0);

% the isozyme changes nothing for the other reactions
others = setdiff(1:nTable, isoPosition);
assert(all(all(fctableIso(others, others) == fctable(others, others))));

% output a success message
fprintf('\nDone.\n');

% change the directory
cd(currentDir)