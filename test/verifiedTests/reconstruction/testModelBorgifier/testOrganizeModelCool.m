% The COBRAToolbox: testOrganizeModelCool.m
%
% Purpose:
%     - organizeModelCool reorders the metabolites (most connected first, grouped by name without
%     compartment) and the reactions (exchange reactions last) of a model, and reorders all
%     dependent fields.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/organizeModelCool.m
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
fileDir = fileparts(which('testOrganizeModelCool'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four metabolites (two compartments of a) and four reactions, the last one an exchange
model.mets = {'a[c]'; 'b[c]'; 'a[e]'; 'c[c]'};
model.metNames = {'A'; 'B'; 'A'; 'C'};
model.rxns = {'r1'; 'r2'; 'r3'; 'EX_a'};
model.rxnNames = {'R1'; 'R2'; 'R3'; 'X'};
model.S = [-1  0  0  0; ...
            1 -1  0  0; ...
            0  0 -1  1; ...
            0  1  1  0];
model.lb = [1; 2; 3; 4];
model.ub = [10; 20; 30; 40];
model.c = [1; 0; 0; 0];
model.metCharge = [-1; 0; 1; 2];

ordered = organizeModelCool(model);

%% order of metabolites and reactions

% b[c] has two reactions (like a[e] and c[c]), the first in order is chosen; then the metabolites
% with the same name as the next most connected metabolite (a) follow together
assert(isequal(ordered.mets, {'b[c]'; 'a[c]'; 'a[e]'; 'c[c]'}));
assert(isequal(ordered.metNames, {'B'; 'A'; 'A'; 'C'}));
assert(isequal(ordered.metCharge, [0; -1; 1; 2]));
assert(isequal(ordered.rxns, {'r1'; 'r3'; 'r2'; 'EX_a'}));
assert(isequal(ordered.rxnNames, {'R1'; 'R3'; 'R2'; 'X'}));

%% dependent fields follow

assert(isequal(ordered.lb, [1; 3; 2; 4]) && isequal(ordered.ub, [10; 30; 20; 40]));
assert(isequal(ordered.c, [1; 0; 0; 0]));
assert(isequal(full(ordered.S), [ 1  0 -1  0; ...
                                 -1  0  0  0; ...
                                  0 -1  0  1; ...
                                  0  1  1  0]));

%% models that carry the fields per sub-model

multi = model;
multi.Models.m1.rxns = {'r1'; 'r2'; 'r3'; 'EX_a'};
multi.Models.m1.mets = {'a[c]'; 'b[c]'; 'a[e]'; 'c[c]'};
multi.lb = struct('m1', [1; 2; 3; 4]);
multi.ub = struct('m1', [10; 20; 30; 40]);
multi.c = struct('m1', [1; 0; 0; 0]);
orderedMulti = organizeModelCool(multi);
assert(isequal(orderedMulti.Models.m1.rxns, {'r1'; 'r3'; 'r2'; 'EX_a'}));
assert(isequal(orderedMulti.Models.m1.mets, {'b[c]'; 'a[c]'; 'a[e]'; 'c[c]'}));
assert(isequal(orderedMulti.lb.m1, [1; 3; 2; 4]) && isequal(orderedMulti.ub.m1, [10; 30; 20; 40]));

%% the reordered model describes the same network

original = model.S(:, [1 3 2 4]);
assert(isequal(full(ordered.S), full(original([2 1 3 4], :))));

% change the directory
cd(currentDir)
