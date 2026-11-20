% The COBRAToolbox: testFilterEcosystemScenarios.m
%
% Purpose:
%     - filterEcosystemScenarios(simulations, params) selects the scenarios (file names) of a
%       table of simulations whose alpha, input constraint, energy level, substrate
%       combination and objective match the non-empty filters of params; a filter that matches
%       no scenario is ignored; when no objective is asked for, scenarios with an objective
%       are discarded; scenarios containing a flagged text are discarded; the names are
%       changed to those of the result files ('_a0_' -> '_a00_', '_a0.' and '_a0,' -> '_a0',
%       '_a1_' -> '_a10_') and sorted by input Fe, then by name.
%     - This test uses a hand-built table of nine scenarios that covers each of these rules
%       and checks the selections worked out by hand from the documentation: no filter, all
%       filters together, an objective, flags, an empty objective, filters without matches,
%       numeric columns with NaN (as readtable returns them), cell columns with NaN or empty
%       entries, and the documented errors.
%
% Function under test:
%     src/analysis/ecosystem/filterEcosystemScenarios.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-built table.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFilterEcosystemScenarios'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% nine scenarios, text columns as in simulations_pareto4.csv (decimal commas). Rows 6 to 9
% have the alpha values 0, 1, 0.6 and 0.8 whose names are changed ('_a0_', '_a1_', '_a0.',
% '_a0,'); row 4 has an objective; row 3 another input constraint
names = {'Alpha', 'Substrate combination', 'input constraint', 'Input Fe', 'Energy level', 'Filename', 'Objective'};
simulations = cell2table({ ...
    '0,2', '0.5_Fe_medium_0.5_S_medium', 'biocons', '0,5', 'Medium', 'sce_a02_biocons_50Fe_50S', ''; ...
    '0,4', '0.5_Fe_medium_0.5_S_medium', 'biocons', '0,5', 'Medium', 'sce_a04_biocons_50Fe_50S', ''; ...
    '0,2', '0.5_Fe_medium_0.5_S_medium', 'uncons', '0,5', 'Medium', 'sce_a02_uncons_50Fe_50S', ''; ...
    '0,2', '0.5_Fe_medium_0.5_S_medium', 'biocons', '0,5', 'Medium', 'sce_a02_biocons_50Fe_50S_maxATP', 'maxATP'; ...
    '0,2', '0.75_Fe_high_0.25_S_high', 'biocons', '0,75', 'High', 'sce_a02_biocons_75Fe_25S', ''; ...
    '0', '0.25_Fe_low_0.75_S_low', 'biocons', '0,25', 'Low', 'sce_a0_biocons_25Fe_75S', ''; ...
    '1', '0.1_Fe_low_0.9_S_low', 'biocons', '0,1', 'Low', 'sce_a1_biocons_10Fe_90S', ''; ...
    '0,6', '0.4_Fe_high_0.6_S_high', 'biocons', '0,4', 'High', 'sce_a0.6_biocons_40Fe_60S', ''; ...
    '0,8', '0.6_Fe_medium_0.4_S_medium', 'biocons', '0,6', 'Medium', 'sce_a0,8_biocons_60Fe_40S', ''}, ...
    'VariableNames', names);

% every scenario without an objective, renamed and sorted by input Fe (0.1, 0.25, 0.4, 0.5,
% 0.5, 0.5, 0.6, 0.75), then by name within equal input Fe (names are text: exact comparisons)
allWithoutObjective = {'sce_a10_biocons_10Fe_90S'; 'sce_a00_biocons_25Fe_75S'; ...
    'sce_a06_biocons_40Fe_60S'; 'sce_a02_biocons_50Fe_50S'; 'sce_a02_uncons_50Fe_50S'; ...
    'sce_a04_biocons_50Fe_50S'; 'sce_a08_biocons_60Fe_40S'; 'sce_a02_biocons_75Fe_25S'};

%% no filter: every substrate combination and energy level; the scenario with an objective is discarded

% default substrate combinations (nine Fe/S fractions) at the three energy levels match all
% nine rows; with no objective asked for, '_maxATP' becomes a flag and row 4 is discarded
assert(isequal(filterEcosystemScenarios(simulations, struct()), allWithoutObjective));
% an objective given as {''} means no objective
assert(isequal(filterEcosystemScenarios(simulations, struct('obj', {{''}})), allWithoutObjective));

%% all filters together

% alpha 0.2 (rows 1, 3, 4, 5), biocons (all but row 3), Medium (rows 1-4, 9), 0.5 Fe and
% 0.5 S at medium energy (rows 1-4): rows 1 and 4; row 4 has an objective
params = struct('alpha', 0.2, 'cons', {{'biocons'}}, 'energy', {{'Medium'}}, 'subCombs', [0.5 0.5]);
assert(isequal(filterEcosystemScenarios(simulations, params), {'sce_a02_biocons_50Fe_50S'}));

%% an objective: only scenarios with that objective, none discarded for having one

% alpha 0.2 or 0.4 (rows 1-5) and objective maxATP given as text (row 4)
params = struct('alpha', [0.2 0.4], 'obj', 'maxATP');
assert(isequal(filterEcosystemScenarios(simulations, params), {'sce_a02_biocons_50Fe_50S_maxATP'}));

%% flags: scenarios containing a flagged text are discarded

expected = allWithoutObjective(~strcmp(allWithoutObjective, 'sce_a02_uncons_50Fe_50S'));
assert(isequal(filterEcosystemScenarios(simulations, struct('flag', {{'uncons'}})), expected));

%% filters without matches are ignored

% an input constraint that no scenario has: the filter is dropped
assert(isequal(filterEcosystemScenarios(simulations, struct('cons', {{'missing'}})), allWithoutObjective));
% a substrate combination that no scenario has, and no other filter: nothing is selected
scenarios = filterEcosystemScenarios(simulations, struct('subCombs', [0.3 0.7]));
assert(iscell(scenarios) && isempty(scenarios));
% the same with the energy level Medium: the energy filter alone selects rows 1-4 and 9
scenarios = filterEcosystemScenarios(simulations, struct('subCombs', [0.3 0.7], 'energy', {{'Medium'}}));
assert(isequal(scenarios, {'sce_a02_biocons_50Fe_50S'; 'sce_a02_uncons_50Fe_50S'; ...
    'sce_a04_biocons_50Fe_50S'; 'sce_a08_biocons_60Fe_40S'}));

%% numeric columns: input Fe as numbers, objective all NaN (an empty column read by readtable)

% the NaN objectives become empty, so no scenario has an objective and none is discarded:
% row 4 is selected too (sorted after its prefix 'sce_a02_biocons_50Fe_50S')
simulationsNumeric = simulations;
simulationsNumeric.('Input Fe') = [0.5; 0.5; 0.5; 0.5; 0.75; 0.25; 0.1; 0.4; 0.6];
simulationsNumeric.Objective = NaN(9, 1);
expected = [allWithoutObjective(1:4); {'sce_a02_biocons_50Fe_50S_maxATP'}; allWithoutObjective(5:8)];
assert(isequal(filterEcosystemScenarios(simulationsNumeric, struct()), expected));

%% cell column with NaN and empty entries (mixed columns): they count as empty

simulationsMixed = simulations;
simulationsMixed.Objective = {NaN; []; NaN; 'maxATP'; NaN; NaN; []; NaN; NaN};
assert(isequal(filterEcosystemScenarios(simulationsMixed, struct()), allWithoutObjective));

%% errors: missing params, simulations not a table, missing variables, params not a structure

assert(verifyCobraFunctionError('filterEcosystemScenarios', 'inputs', {simulations}, ...
    'testMessage', 'simulations and params must be provided.'));
assert(verifyCobraFunctionError('filterEcosystemScenarios', 'inputs', {{1}, struct()}, ...
    'testMessage', 'simulations must be a table.'));
assert(verifyCobraFunctionError('filterEcosystemScenarios', 'inputs', {simulations(:, 1:3), struct()}, ...
    'testMessage', 'simulations does not have the variables: Energy level, Filename, Input Fe, Objective'));
assert(verifyCobraFunctionError('filterEcosystemScenarios', 'inputs', {simulations, 1}, ...
    'testMessage', 'params must be a structure.'));

% change the directory
cd(currentDir)
