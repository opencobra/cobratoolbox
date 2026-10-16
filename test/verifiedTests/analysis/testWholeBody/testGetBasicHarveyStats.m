% The COBRAToolbox: testGetBasicHarveyStats.m
%
% Purpose:
%     - getBasicHarveyStats counts the reactions, metabolites, genes, subsystems and metabolites of
%     each body compartment of a female and a male whole-body model and returns them in a table of
%     text values.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/getBasicHarveyStats.m
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
fileDir = fileparts(which('testGetBasicHarveyStats'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% female model: 4 reactions, 2 slack metabolites, genes with transcript suffixes
female.rxns = {'r1'; 'r2'; 'r3'; 'r4'};
female.mets = {'a[c]'; 'slack_1'; 'b[bc]'; 'c[u]'; 'd[bp]'; 'e[bd]'; 'f[csf]'; 'g[d]'; 'h[fe]'; ...
               'i[sw]'; 'j[a]'; 'k[mi]'; 'slack_2[bc]'; 'b2[bc]'};
female.genes = {'g1.1'; 'g1.2'; 'g2.1'};
female.subSystems = {'s1'; 's2'; 'Dummy'; 's1'};
% male model: fewer reactions and metabolites
male.rxns = {'r1'; 'r2'};
male.mets = {'a[c]'; 'b[bc]'; 'c[u]'};
male.genes = {'g1.1'; 'g2.1'};
male.subSystems = {'s1'; 'Dummy'};

stats = getBasicHarveyStats(male, female);

%% table of counts

assert(isequal(size(stats), [16 3]));
% header row: label, female model, male model
assert(isequal(stats(1, :), {'', 'Harvetta', 'Harvey'}));
labels = stats(:, 1);
assert(strcmp(labels{2}, 'Number of Reactions') && strcmp(labels{3}, 'Number of Metabolites'));
assert(strcmp(labels{4}, 'Number of Genes (transcripts)') && strcmp(labels{5}, 'Number of Genes (unique)'));
assert(strcmp(labels{6}, 'Number of Subsystems'));

% counts (female in column 2, male in column 3)
assert(isequal(stats(2, 2:3), {'4', '2'}));
% metabolites without the slack metabolites: 14 - 2 = 12 and 3 - 0
assert(isequal(stats(3, 2:3), {'12', '3'}));
assert(isequal(stats(4, 2:3), {'3', '2'}));
% unique genes ignore the transcript suffix
assert(isequal(stats(5, 2:3), {'2', '2'}));
% subsystems: unique labels minus one for the dummy entry
assert(isequal(stats(6, 2:3), {'2', '1'}));

%% metabolites of each compartment (slack metabolites are not counted)

compartmentLabels = {'Blood compartment metabolites'; 'Urine metabolites'; 'Portal vein metabolites'; ...
    'Bile duct metabolites'; 'CSF metabolites'; 'Diet metabolites'; 'Fecal metabolites'; ...
    'Sweat metabolites'; 'Air metabolites'; 'Milk metabolites'};
assert(isequal(stats(7:16, 1), compartmentLabels));
% female: blood compartment has b[bc] and b2[bc] (the slack metabolite slack_2[bc] is not counted);
% every other compartment has one metabolite. male: blood and urine compartments one each, others none
assert(isequal(stats(7:16, 2)', {'2', '1', '1', '1', '1', '1', '1', '1', '1', '1'}));
assert(isequal(stats(7:16, 3)', {'1', '1', '0', '0', '0', '0', '0', '0', '0', '0'}));

% change the directory
cd(currentDir)
