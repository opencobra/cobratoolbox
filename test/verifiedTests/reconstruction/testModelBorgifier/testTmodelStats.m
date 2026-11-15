% The COBRAToolbox: testTmodelStats.m
%
% Purpose:
%     - TmodelStats summarizes a template model (Tmodel) of modelBorgifier, or a plain model:
%       the number and share of reactions and metabolites with each annotation field of
%       TmodelFields, the number and share of metabolites per compartment, the exchange
%       reactions (one metabolite), the number of metabolites ignoring the compartment and,
%       for a Tmodel of two or more models, the reactions, metabolites and compartment-free
%       metabolites unique to each model and shared between each pair of models. The test
%       builds a two-model Tmodel of four metabolites in three compartments and three
%       reactions by hand; every expected count and share is derived by hand in the comments.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/TmodelStats.m
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
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTmodelStats'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% shares are ratios of small integers computed once; 1e-12 allows for their rounding only
tol = 1e-12;

% a Tmodel of two models m1 and m2. Metabolites (sorted, as cleanTmodel leaves them):
% a[c], a[e], b[c], c[m]; reactions: EX_a (a[e] only), R1 (a[e] -> a[c]),
% R2 (a[c] + b[c] -> c[m])
Tmodel = struct();
Tmodel.rxns = {'EX_a'; 'R1'; 'R2'};
Tmodel.mets = {'a[c]'; 'a[e]'; 'b[c]'; 'c[m]'};
Tmodel.S = sparse([0 1 -1; -1 -1 0; 0 0 -1; 0 0 1]);
% annotation fields: rxnNames is filled for 1 of 3 reactions, metNames for 3 of 4
% metabolites; the other TmodelFields fields are absent (count 0)
Tmodel.rxnNames = {'exchange of a'; ''; ''};
Tmodel.metNames = {'A'; 'A'; ''; 'C'};
% m1 has EX_a and R1, m2 all three reactions; m1 has a[c] and a[e], m2 a[c], b[c] and c[m]
Tmodel.Models.m1 = struct('rxns', logical([1; 1; 0]), 'mets', logical([1; 1; 0; 0]));
Tmodel.Models.m2 = struct('rxns', logical([1; 1; 1]), 'mets', logical([1; 0; 1; 1]));

% the share of x among n
share = @(x, n) [x, x / n];

%% statistics of a two-model Tmodel

Stats = TmodelStats(Tmodel);

% reaction annotation: one row per reaction field of TmodelFields, in its order
fields = TmodelFields;
assert(isequal(Stats.rxnInfo(:, 1), fields{1}));
assert(norm(Stats.rxnInfo{strcmp(fields{1}, 'rxns'), 2} - share(3, 3)) < tol);
assert(norm(Stats.rxnInfo{strcmp(fields{1}, 'rxnNames'), 2} - share(1, 3)) < tol);
assert(isequal(Stats.rxnInfo{strcmp(fields{1}, 'grRules'), 2}, [0 0]));

% metabolite annotation
assert(isequal(Stats.metInfo(:, 1), fields{3}));
assert(norm(Stats.metInfo{strcmp(fields{3}, 'mets'), 2} - share(4, 4)) < tol);
assert(norm(Stats.metInfo{strcmp(fields{3}, 'metNames'), 2} - share(3, 4)) < tol);
assert(isequal(Stats.metInfo{strcmp(fields{3}, 'metKEGGID'), 2}, [0 0]));

% compartments, sorted: c (a[c], b[c]), e (a[e]), m (c[m]), then the total of 4 of 4
assert(isequal(Stats.metsByComp(:, 1), {'c'; 'e'; 'm'; 'Total'}));
assert(norm(Stats.metsByComp{1, 2} - share(2, 4)) < tol);
assert(norm(Stats.metsByComp{2, 2} - share(1, 4)) < tol);
assert(norm(Stats.metsByComp{3, 2} - share(1, 4)) < tol);
assert(norm(Stats.metsByComp{4, 2} - [4, 1]) < tol);

% exchange reactions: EX_a is the only reaction with one metabolite (1 of 3)
assert(norm(Stats.exhangeRxns - share(1, 3)) < tol);

% metabolites without compartment: a, b, c
assert(Stats.uniqueMetabolites == 3);

% shared reactions. The diagonal holds the entities found only in that model, the other
% cells the entities of the row model also found in the column model, each with its share
% of the row model's entities.
% m1 = {EX_a, R1}, m2 = {EX_a, R1, R2}: m1 has none of its own (0 of 2), shares 2 of 2
% with m2; m2 has R2 of its own (1 of 3) and shares 2 of 3 with m1
assert(isequal(Stats.sharedRxns(1, :), {'[Count, %]', 'in m1', 'in m2'}));
assert(isequal(Stats.sharedRxns(:, 1), {'[Count, %]'; 'm1'; 'm2'}));
assert(norm(Stats.sharedRxns{2, 2} - [0 0]) < tol);
assert(norm(Stats.sharedRxns{2, 3} - share(2, 2)) < tol);
assert(norm(Stats.sharedRxns{3, 3} - share(1, 3)) < tol);
assert(norm(Stats.sharedRxns{3, 2} - share(2, 3)) < tol);

% shared metabolites: m1 = {a[c], a[e]}, m2 = {a[c], b[c], c[m]}: m1 has a[e] of its own
% (1 of 2) and shares a[c] (1 of 2); m2 has b[c] and c[m] (2 of 3) and shares a[c] (1 of 3)
assert(norm(Stats.sharedMets{2, 2} - share(1, 2)) < tol);
assert(norm(Stats.sharedMets{2, 3} - share(1, 2)) < tol);
assert(norm(Stats.sharedMets{3, 3} - share(2, 3)) < tol);
assert(norm(Stats.sharedMets{3, 2} - share(1, 3)) < tol);

% shared metabolites ignoring the compartment: m1 = {a}, m2 = {a, b, c}: m1 has none of its
% own and shares a (1 of 1); m2 has b and c (2 of 3) and shares a (1 of 3)
assert(norm(Stats.sharedMetsNoComp{2, 2} - [0 0]) < tol);
assert(norm(Stats.sharedMetsNoComp{2, 3} - share(1, 1)) < tol);
assert(norm(Stats.sharedMetsNoComp{3, 3} - share(2, 3)) < tol);
assert(norm(Stats.sharedMetsNoComp{3, 2} - share(1, 3)) < tol);

%% an existing Stats structure is extended, not replaced

previous = struct('rxnList', [1; 0; -1]);
Stats = TmodelStats(Tmodel, previous);
assert(isequal(Stats.rxnList, [1; 0; -1]));
assert(Stats.uniqueMetabolites == 3);

%% a Tmodel of one model: no comparison between models

oneModel = Tmodel;
oneModel.Models = rmfield(oneModel.Models, 'm2');
Stats = TmodelStats(oneModel);
assert(~isfield(Stats, 'sharedRxns') && ~isfield(Stats, 'sharedMets') && ~isfield(Stats, 'sharedMetsNoComp'));
assert(norm(Stats.exhangeRxns - share(1, 3)) < tol);

%% a plain model (no Models field) is treated as the single model 'model'

plainModel = rmfield(Tmodel, 'Models');
Stats = TmodelStats(plainModel);
assert(~isfield(Stats, 'sharedRxns'));
assert(isequal(Stats.metsByComp(:, 1), {'c'; 'e'; 'm'; 'Total'}));
assert(Stats.uniqueMetabolites == 3);

% change the directory
cd(currentDir)
