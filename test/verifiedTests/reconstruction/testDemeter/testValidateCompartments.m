% The COBRAToolbox: testValidateCompartments.m
%
% Purpose:
%     - validateCompartments(model) is a DEMETER test-suite function. It returns the
%       metabolites whose identifier contains none of the compartments [c], [e] and [p], in
%       model order, and the sorted union of the reactions in which they occur
%       (findRxnsFromMets). With no such metabolite both outputs are the empty cell {}.
%     - Expected metabolites and reactions follow by hand from the identifiers and the
%       columns of S.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/validateCompartments.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model of 5 metabolites and 4 reactions, no solver (the ledger
%     lists Tier 3; the function calls no solver).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testValidateCompartments'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% Model: R1 a[c] -> b[e]; R2 a[c] -> d[m]; R3 d[m] + e[x] -> c[p]; R4 b[e] ->
model = struct();
model.mets = {'a[c]'; 'b[e]'; 'c[p]'; 'd[m]'; 'e[x]'};
model.rxns = {'R1'; 'R2'; 'R3'; 'R4'};
model.S = sparse([-1 -1  0  0; ...
                   1  0  0 -1; ...
                   0  0  1  0; ...
                   0  1 -1  0; ...
                   0  0 -1  0]);
model.lb = zeros(4, 1);
model.ub = 1000 * ones(4, 1);

%% metabolites in other compartments and the reactions that use them
% d[m] and e[x] are not in [c], [e] or [p]; d[m] occurs in R2 and R3, e[x] in R3
[incorrectRxns, incorrectMets] = validateCompartments(model);
assert(isequal(incorrectMets, {'d[m]'; 'e[x]'}));
assert(isequal(incorrectRxns(:), {'R2'; 'R3'}));

%% a metabolite of another compartment that occurs in no reaction
% f[n] is listed, but adds no reaction
modelUnused = model;
modelUnused.mets{end + 1} = 'f[n]';
modelUnused.S(end + 1, :) = 0;
[incorrectRxns, incorrectMets] = validateCompartments(modelUnused);
assert(isequal(incorrectMets, {'d[m]'; 'e[x]'; 'f[n]'}));
assert(isequal(incorrectRxns(:), {'R2'; 'R3'}));

%% all metabolites in [c], [e] or [p]: both outputs are empty cells
modelCorrect = model;
modelCorrect.mets = {'a[c]'; 'b[e]'; 'c[p]'; 'd[c]'; 'e[e]'};
[incorrectRxns, incorrectMets] = validateCompartments(modelCorrect);
assert(iscell(incorrectRxns) && isempty(incorrectRxns));
assert(iscell(incorrectMets) && isempty(incorrectMets));

% change the directory
cd(currentDir)
