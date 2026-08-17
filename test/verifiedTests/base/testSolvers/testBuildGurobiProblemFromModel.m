% The COBRAToolbox: testBuildGurobiProblemFromModel.m
%
% Purpose:
%     - Characterization test that PINS the current model->native-Gurobi-struct
%       mapping performed by buildGurobiProblemFromModel, which currently has no
%       direct test (feature 017-buildgurobifrommodel-tests). Asserts EXISTING
%       behaviour (Constitution Principle III characterization mode); it must
%       not change buildGurobiProblemFromModel or buildOptProblemFromModel.
%
% Authors:
%     - Generated for feature 017-buildgurobifrommodel-tests, 2026-08-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildGurobiProblemFromModel'));
cd(fileDir);

% buildGurobiProblemFromModel is solver-independent (pure struct construction on
% top of buildOptProblemFromModel); it never calls gurobi() itself, so no
% prepareTest solver requirement is declared.

model1 = buildToyModel1();
optProblem1 = buildOptProblemFromModel(model1);
gurobiModel1 = buildGurobiProblemFromModel(model1);

%% User Story 1: native-Gurobi field mapping

% the constructed struct carries exactly these fields
expectedFields = {'A', 'obj', 'rhs', 'lb', 'ub', 'sense', 'modelsense'};
assert(all(ismember(expectedFields, fieldnames(gurobiModel1))));
assert(numel(fieldnames(gurobiModel1)) == numel(expectedFields));

% A/obj/rhs/lb/ub pass through from optProblem, dense for the vector fields
assert(isequal(full(gurobiModel1.A), full(optProblem1.A)));
assert(isequal(gurobiModel1.obj, full(double(optProblem1.c))));
assert(isequal(gurobiModel1.rhs, full(optProblem1.b)));
assert(isequal(gurobiModel1.lb, full(optProblem1.lb)));
assert(isequal(gurobiModel1.ub, full(optProblem1.ub)));

% osense == -1 (maximization) maps to modelsense 'max'
assert(isequal(gurobiModel1.modelsense, 'max'));

model2 = buildToyModel2();
gurobiModel2 = buildGurobiProblemFromModel(model2);

% osense == 1 (minimization) maps to modelsense 'min'
assert(isequal(gurobiModel2.modelsense, 'min'));

%% User Story 2: constraint-sense translation

% csense = ['E';'L';'G'] maps to sense = ['=';'<';'>'] in row order
assert(isequal(gurobiModel1.sense, ['='; '<'; '>']));

% an all-'E' model leaves the unconditional default in place for every row
modelAllE = model1;
modelAllE.csense = ['E'; 'E'; 'E'];
gurobiModelAllE = buildGurobiProblemFromModel(modelAllE);
assert(isequal(gurobiModelAllE.sense, ['='; '='; '=']));

%% User Story 3: optional verify argument

% verify omitted, false, and true are identical on a structurally valid model
gurobiModel1Default = buildGurobiProblemFromModel(model1);
gurobiModel1False = buildGurobiProblemFromModel(model1, false);
gurobiModel1True = buildGurobiProblemFromModel(model1, true);
assert(isequal(gurobiModel1Default, gurobiModel1False));
assert(isequal(gurobiModel1Default, gurobiModel1True));

% verify = true on a structurally invalid model reproduces the existing error
invalidModel = model1;
invalidModel.lb = [0; 0]; % length mismatch vs. 3 reactions
assert(verifyCobraFunctionError('buildGurobiProblemFromModel', 'inputs', {invalidModel, true}));

% change the directory back
cd(currentDir);


function model = buildToyModel1()
    % Tiny 3-metabolite/3-reaction toy model exercising all three csense
    % values ('E','L','G') and a maximization objective.
    model = struct();
    model.rxns = {'R1'; 'R2'; 'R3'};
    model.mets = {'A'; 'B'; 'C'};
    model.S = [1, -1, 0; 0, 1, -1; -1, 0, 1];
    model.lb = [0; 0; 0];
    model.ub = [10; 1000; 1000];
    model.c = [0; 0; 1];
    model.b = [0; 0; 0];
    model.csense = ['E'; 'L'; 'G'];
    model.osenseStr = 'max';
end

function model = buildToyModel2()
    % Same shape as buildToyModel1, but a minimization objective, isolating
    % the modelsense == 'min' branch.
    model = struct();
    model.rxns = {'R1'; 'R2'; 'R3'};
    model.mets = {'A'; 'B'; 'C'};
    model.S = [1, -1, 0; 0, 1, -1; -1, 0, 1];
    model.lb = [0; 0; 0];
    model.ub = [10; 1000; 1000];
    model.c = [0; 0; 1];
    model.b = [0; 0; 0];
    model.csense = ['E'; 'L'; 'G'];
    model.osenseStr = 'min';
end
