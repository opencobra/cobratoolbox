% The COBRAToolbox: testBuildOptProblemFromModel.m
%
% Purpose:
%     - Characterization test that PINS the current model->problem mapping performed
%       by buildOptProblemFromModel for an LP, which currently has no direct test
%       (feature 009-fba-characterization-statusmap, W7-core). Asserts EXISTING
%       behaviour (Constitution Principle III characterization mode); it must not
%       change buildOptProblemFromModel.
%     - The sections after the first one pin the coupling constraints (C, d, dsense), the extra
%       variables (E, D, evarlb, evarub, evarc), the quadratic term F, the regularised forms QRLP
%       and QRQP, input verification and the problem names of the debug mode.
%
% Function under test:
%     src/base/solvers/buildOptProblemFromModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 266-282: unreachable, the branch of an if 0 kept as a debugging aid.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Missing coupling and extra-variable fields are never built
%       SEVERITY: error
%       TRIGGER: a model with C but without d or dsense, or with E but without evarlb, evarub or evarc
%       OBSERVED: the test length(unique([toBuild, fields])) == length(fields) is always true, so the
%         list of fields to build is always cleared and the call stops on the missing field
%       EXPECTED: the missing fields created by createEmptyFields
%       LINES: 155-161
%     - DEFECT: A model with extra columns and no coupling rows gets no csense in its problem
%       SEVERITY: error
%       TRIGGER: a model with the fields E, evarlb, evarub, evarc but without C
%       OBSERVED: optProblem has no field csense, and a solver call stops on the missing field
%       EXPECTED: optProblem.csense = model.csense, as in the other three branches
%       LINES: 212-217
%     - DEFECT: The form QRQP keeps the csense of the model only
%       SEVERITY: error
%       TRIGGER: param.solveWBMmethod = QRQP
%       OBSERVED: the matrix has one row per metabolite and one per variable, but csense keeps
%         one entry per metabolite, and it drops the coupling rows
%       EXPECTED: csense with one entry per row of A, as in the form QRLP
%       LINES: 303
%     - DEFECT: The forms QRLP and QRQP lose the bounds of the extra variables
%       SEVERITY: wrong-result
%       TRIGGER: param.solveWBMmethod = QRLP or QRQP for a model with E
%       OBSERVED: lb, ub and c are rebuilt from model.lb, model.ub and model.c, so they are
%         shorter than the number of columns of A
%       EXPECTED: vectors with one entry per column of A
%       LINES: 255-256, 258, 301-302, 304
%
% Authors:
%     - Generated for feature 009-fba-characterization-statusmap, 2026-07-15.
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildOptProblemFromModel'));
cd(fileDir);

% declare the requirements: this test needs no solver, toolbox or operating system
prepareTest();

model = buildToyModel();

% buildOptProblemFromModel is solver-independent (pure model->problem construction)
optProblem = buildOptProblemFromModel(model);

% the constructed LP carries exactly these fields
expectedFields = {'A', 'b', 'ub', 'lb', 'csense', 'c', 'osense', 'names'};
assert(all(ismember(expectedFields, fieldnames(optProblem))));

% the constraint matrix is the stoichiometric matrix
assert(isequal(full(optProblem.A), full(model.S)));
assert(size(optProblem.A, 1) == numel(model.mets));
assert(size(optProblem.A, 2) == numel(model.rxns));

% right-hand side, constraint sense, and bounds pass through unchanged
assert(isequal(optProblem.b, model.b));
assert(isequal(optProblem.csense(:)', 'EE'));
assert(isequal(optProblem.c, model.c));
assert(isequal(optProblem.lb, model.lb));
assert(isequal(optProblem.ub, model.ub));

% osense is the canonical -1 for a maximization model
assert(optProblem.osense == -1);

%% a row vector csense is turned into a column, and missing fields are built
rowModel = model;
rowModel.csense = 'EE';
optProblem = buildOptProblemFromModel(rowModel);
assert(isequal(optProblem.csense, ['E'; 'E']));

bareModel = rmfield(model, {'b', 'csense', 'c', 'osenseStr'});
optProblem = buildOptProblemFromModel(bareModel);
assert(isequal(optProblem.b, [0; 0]) && isequal(optProblem.csense, ['E'; 'E']));
assert(isequal(optProblem.c, [0; 0; 0]) && optProblem.osense == -1);

% dxdt overwrites the right hand side
dxdtModel = model;
dxdtModel.dxdt = [1; 2];
optProblem = buildOptProblemFromModel(dxdtModel);
assert(isequal(optProblem.b, [1; 2]));

%% coupling constraints: rows are appended
coupledModel = model;
coupledModel.C = [1, 1, 0];
coupledModel.d = 5;
coupledModel.dsense = 'L';
optProblem = buildOptProblemFromModel(coupledModel);
assert(isequal(full(optProblem.A), [model.S; coupledModel.C]));
assert(isequal(optProblem.b, [0; 0; 5]) && isequal(optProblem.csense, ['E'; 'E'; 'L']));

%% extra variables: columns are appended (csense: defect above, not asserted)
extendedModel = model;
extendedModel.E = [1; 0];
extendedModel.evarlb = -1;
extendedModel.evarub = 2;
extendedModel.evarc = 3;
optProblem = buildOptProblemFromModel(extendedModel);
assert(isequal(full(optProblem.A), [model.S, extendedModel.E]));
assert(isequal(optProblem.b, model.b) && isequal(optProblem.c, [model.c; 3]));
assert(isequal(optProblem.lb, [model.lb; -1]) && isequal(optProblem.ub, [model.ub; 2]));

%% coupling constraints and extra variables together
fullModel = extendedModel;
fullModel.C = [1, 1, 0];
fullModel.d = 5;
fullModel.dsense = 'G';
fullModel.D = 7;
optProblem = buildOptProblemFromModel(fullModel);
assert(isequal(full(optProblem.A), [model.S, fullModel.E; fullModel.C, fullModel.D]));
assert(isequal(optProblem.b, [0; 0; 5]) && isequal(optProblem.csense, ['E'; 'E'; 'G']));
assert(isequal(optProblem.lb, [model.lb; -1]) && isequal(optProblem.c, [model.c; 3]));

%% the quadratic term, without and with extra variables
quadraticModel = model;
quadraticModel.F = speye(3);
optProblem = buildOptProblemFromModel(quadraticModel);
assert(isequal(full(optProblem.F), eye(3)));

quadraticExtended = extendedModel;
quadraticExtended.F = speye(3);
optProblem = buildOptProblemFromModel(quadraticExtended);
assert(isequal(full(optProblem.F), blkdiag(eye(3), 0)));

%% input verification
assert(isfield(buildOptProblemFromModel(model, true), 'A'));
assert(verifyCobraFunctionError('buildOptProblemFromModel', 'inputs', {struct('S', 1, 'lb', 0), true}, ...
    'testMessage', 'The input model does have inconsistent fields! Use verifyModel(model) for further information.'));

verifyQuadratic = model;
verifyQuadratic.F = sparse(ones(2, 3));
assert(verifyCobraFunctionError('buildOptProblemFromModel', 'inputs', {verifyQuadratic, true}, ...
    'testMessage', 'model.F must be a square and positive definite matrix'));

verifyDxdt = model;
verifyDxdt.dxdt = 1;
assert(verifyCobraFunctionError('buildOptProblemFromModel', 'inputs', {verifyDxdt, true}, ...
    'testMessage', 'Number of rows in model.dxdt and model.S must match'));

verifiedQuadratic = model;
verifiedQuadratic.F = speye(3);
verifiedQuadratic.dxdt = [0; 0];
assert(isfield(buildOptProblemFromModel(verifiedQuadratic, true), 'F'));

%% the forms of the problem that need nothing more than the LP or QP above
for methodCell = {'LP', 'QP', 'QPold', ''}
    param = struct('solveWBMmethod', methodCell{1});
    optProblem = buildOptProblemFromModel(model, false, param);
    assert(isequal(full(optProblem.A), full(model.S)));
end
assert(verifyCobraFunctionError('buildOptProblemFromModel', 'inputs', {model, false, struct('solveWBMmethod', 'nonsense')}, ...
    'testMessage', 'param.method unrecognised'));

%% the regularised LP QRLP: A*v + r = b and v - p = z, with the bounds moved to z
[nMet, nRxn] = size(model.S);
optProblem = buildOptProblemFromModel(model, false, struct('solveWBMmethod', 'QRLP'));
assert(isequal(size(optProblem.A), [nMet + nRxn, nMet + 3 * nRxn]));
assert(optProblem.m == nMet && optProblem.n == nRxn);
assert(numel(optProblem.b) == nMet + nRxn && numel(optProblem.csense) == nMet + nRxn);
assert(isequal(optProblem.lb(end - nRxn + 1:end), model.lb) && all(optProblem.lb(1:end - nRxn) == -inf));
assert(isequal(optProblem.ub(end - nRxn + 1:end), model.ub) && all(optProblem.ub(1:end - nRxn) == inf));
regularisedBlock = nRxn + 1:2 * nRxn + nMet;
assert(all(diag(optProblem.F(regularisedBlock, regularisedBlock)) == 100 * max(abs(model.c))));

%% the regularised QP QRQP, without and with extra variables (csense: defect above, not asserted)
quadraticModel.F = 2 * speye(3);
optProblem = buildOptProblemFromModel(quadraticModel, false, struct('solveWBMmethod', 'QRQP'));
assert(isequal(size(optProblem.A), [nMet + nRxn, nMet + 3 * nRxn]));
assert(isequal(full(optProblem.F(1:nRxn, 1:nRxn)), 2 * eye(nRxn)));
assert(all(diag(optProblem.F(regularisedBlock, regularisedBlock)) == 100 * max(abs(model.c))));
assert(optProblem.m == nMet && optProblem.n == nRxn);

% with extra variables the quadratic term has to cover all columns of A
quadraticExtended.F = 2 * speye(4);
optProblem = buildOptProblemFromModel(quadraticExtended, false, struct('solveWBMmethod', 'QRQP'));
assert(isequal(full(optProblem.F(1:4, 1:4)), 2 * eye(4)));

%% debug mode: names for mosek, without and with the optional name fields
param = struct('debug', true, 'solver', 'mosek');
optProblem = buildOptProblemFromModel(model, false, param);
assert(isequal(optProblem.names.name, 'optimizeCbModel') && isequal(optProblem.names.obj, 'R3'));
assert(isequal(optProblem.names.con, model.mets) && isequal(optProblem.names.var, model.rxns));

% no objective: the objective gets a placeholder name
noObjective = model;
noObjective.c(:) = 0;
optProblem = buildOptProblemFromModel(noObjective, false, param);
assert(isequal(optProblem.names.obj, 'noLP'));

% rows and columns without a name get a placeholder, so that the name lists fit A
optProblem = buildOptProblemFromModel(fullModel, false, param);
assert(isequal(optProblem.names.con, [model.mets; {'con_3'}]));
assert(isequal(optProblem.names.var, [model.rxns; {'var_4'}]));

% with ctrs and evars the given names are used
namedModel = fullModel;
namedModel.ctrs = {'c1'};
namedModel.evars = {'e1'};
optProblem = buildOptProblemFromModel(namedModel, false, param);
assert(isequal(optProblem.names.con, [model.mets; {'c1'}]));
assert(isequal(optProblem.names.var, [model.rxns; {'e1'}]));

% the other solvers need no names, and without debug the names are empty
optProblem = buildOptProblemFromModel(model, false, struct('debug', true, 'solver', 'gurobi'));
assert(~isfield(optProblem, 'names'));
optProblem = buildOptProblemFromModel(model, false, struct('debug', false));
assert(isempty(optProblem.names));

% change the directory back
cd(currentDir);


function model = buildToyModel()
    % Tiny linear pathway A ->(R1, ub 10) -> B (R2) -> out (R3, objective).
    model = struct();
    model.rxns = {'R1'; 'R2'; 'R3'};
    model.mets = {'A'; 'B'};
    model.S = [1, -1, 0; 0, 1, -1];
    model.lb = [0; 0; 0];
    model.ub = [10; 1000; 1000];
    model.c = [0; 0; 1];
    model.b = [0; 0];
    model.csense = ['E'; 'E'];
    model.osenseStr = 'max';
end
