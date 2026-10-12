% The COBRAToolbox: testIspolymer.m
%
% Purpose:
%     - ispolymer should tell whether a chemical formula contains a polymer placeholder (X, R,
%     FULLR, FULLR2 or FULLR3). It currently fails for every input, so this file only documents the
%     defect.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/ispolymer.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 14-17 and 20 of ispolymer.m (the whole body) are uncovered: every call errors, see the defect
%     below. The test only checks that the function is on the path, so that the defect entry stays
%     attached to an existing function.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Always errors because the element list contains names with digits
%       SEVERITY: error
%       TRIGGER: any formula, for example ispolymer('C6H12O6')
%       OBSERVED: the list includes FULLR2 and FULLR3; numAtomsOfElementInFormula rejects element
%         names that contain numbers (Element must not contain numbers), so the call errors for
%         every formula (an empty formula errors with an index error)
%       EXPECTED: true when the formula contains a polymer placeholder, false otherwise
%       LINES: 14-20
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIspolymer'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% the function exists (it cannot be tested further, see the header)

% every call of ispolymer errors, so no behaviour can be asserted; this check only keeps the
% documented defect attached to an existing function
assert(exist('ispolymer', 'file') == 2);

% change the directory
cd(currentDir)
