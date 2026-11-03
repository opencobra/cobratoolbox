% The COBRAToolbox: testFindMetFromCompartment.m
%
% Purpose:
%     - findMetFromCompartment returns, as a one-column cell array, the identifiers of the
%       metabolites whose identifier contains the compartment text (for example '[e]'), in model
%       order.
%       Characterization test that PINS the current behaviour (feature
%       20261102-142225-tier2-test-pilot, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the row counts asserted below were recorded from the first run on
%       2026-11-02 with ecoli_core_model (no solver). They were not derived independently, so
%       they guard consistency, not independent correctness (Tier 5). The metabolites themselves
%       are also derived independently from model.mets.
%
% Function under test:
%     src/analysis/exploration/findMetFromCompartment.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A compartment without metabolites stops with an error
%       SEVERITY: error
%       TRIGGER: a compartment that no metabolite identifier contains, for example
%         findMetFromCompartment(model, '[x]') on ecoli_core_model
%       OBSERVED: the output is only assigned inside the loop over the matches, so the call stops
%         with Output argument "compartmentMetabolites" (and possibly others) not assigned a value
%       EXPECTED: an empty list
%       LINES: 29-34
%     - DEFECT: A compartment letter without brackets matches every identifier with that letter
%       SEVERITY: limitation
%       TRIGGER: findMetFromCompartment(model, 'e')
%       OBSERVED: the text is searched anywhere in the identifiers, so 23 metabolites of
%         ecoli_core_model are returned: the 20 of [e] and 3 of [c] whose identifier contains the
%         letter e (for example pep[c]); findRxnFromCompartment puts a single letter in brackets
%         first
%       EXPECTED: the 20 metabolites of [e], as for '[e]'
%       LINES: 24
%
% Authors:
%     - Generated for feature 20261102-142225-tier2-test-pilot, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMetFromCompartment'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e)
model = getDistributedModel('ecoli_core_model.mat');

%% the metabolites of the extracellular compartment [e]

compartmentMetabolites = findMetFromCompartment(model, '[e]');

% the metabolites are exactly those whose identifier ends with [e], in model order, as one
% column (Tier-5 count, first run 2026-11-02: 20 metabolites)
assert(iscell(compartmentMetabolites) && size(compartmentMetabolites, 2) == 1);
assert(isequal(compartmentMetabolites, model.mets(endsWith(model.mets, '[e]'))));
assert(numel(compartmentMetabolites) == 20);

%% the metabolites of the cytosol [c]

compartmentMetabolites = findMetFromCompartment(model, '[c]');

% the metabolites are exactly those whose identifier ends with [c], in model order (Tier-5
% count, first run 2026-11-02: 52 metabolites); together with [e] they are all 72 metabolites
assert(isequal(compartmentMetabolites, model.mets(endsWith(model.mets, '[c]'))));
assert(numel(compartmentMetabolites) == 52);
assert(numel(compartmentMetabolites) + numel(findMetFromCompartment(model, '[e]')) == numel(model.mets));

% change the directory
cd(currentDir)
