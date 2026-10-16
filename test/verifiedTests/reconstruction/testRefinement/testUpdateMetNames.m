% The COBRAToolbox: testUpdateMetNames.m
%
% Purpose:
%     - updateMetNames copies metabolite names from a reference model to the metabolites of another
%     model that have the same identifier without compartment, optionally discarding the existing
%     names.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/refinement/updateMetNames.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The wipe option is always overwritten with false
%       SEVERITY: unusable-option
%       TRIGGER: a call with the third argument true, for example updateMetNames(referenceModel,
%         modelToUpdate, true)
%       OBSERVED: the default is applied when a variable called wipeExistening does not exist, which
%         is always the case, so the value passed for wipeExisting is replaced by false and the
%         existing names are never wiped
%       EXPECTED: the existing metabolite names removed when wipeExisting is true
%       LINES: 27-29
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUpdateMetNames'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

reference.mets = {'a[c]'; 'b[c]'};
reference.metNames = {'Alpha'; 'Beta'};

target.mets = {'a[e]'; 'c[c]'; 'b[e]'};
target.metNames = {'old a'; 'old c'; 'old b'};

%% names of matching metabolites are copied (compartments are ignored)

updated = updateMetNames(reference, target, false);
assert(isequal(updated.metNames, {'Alpha'; 'old c'; 'Beta'}));

%% a model without names gets empty names where nothing matches

noNames.mets = {'a[c]'; 'z[c]'};
updated = updateMetNames(reference, noNames, false);
assert(isequal(updated.metNames, {'Alpha'; ''}));

%% names with the wrong length are replaced as well

wrong = target;
wrong.metNames = {'only one'};
updated = updateMetNames(reference, wrong, false);
assert(isequal(updated.metNames, {'Alpha'; ''; 'Beta'}));

% change the directory
cd(currentDir)
