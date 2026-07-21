% The COBRAToolbox: testCharacterizeBuildOptProblemFromModel.m
%
% Purpose:
%     - Characterization test that PINS the current model->problem mapping performed
%       by buildOptProblemFromModel for an LP, which currently has no direct test
%       (feature 009-fba-characterization-statusmap, W7-core). Asserts EXISTING
%       behaviour (Constitution Principle III characterization mode); it must not
%       change buildOptProblemFromModel.
%
% Authors:
%     - Generated for feature 009-fba-characterization-statusmap, 2026-07-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCharacterizeBuildOptProblemFromModel'));
cd(fileDir);

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
