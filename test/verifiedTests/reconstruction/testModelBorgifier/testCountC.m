% The COBRAToolbox: testCountC.m
%
% Purpose:
%     - countC returns the number of carbon atoms in a chemical formula (the digits after the first
%     C, 1 if there is no number, 0 if there is no C); alternative formulas after / or , are
%     ignored.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/countC.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Elements whose symbol starts with C are counted as carbon
%       SEVERITY: wrong-result
%       TRIGGER: a formula with chlorine, calcium, cobalt, copper, ... and no carbon, for example
%         Cl2 or CaCl2
%       OBSERVED: the pattern C followed by digits matches the first letter of Cl, Ca, Co, Cu, ...,
%         so Cl2 gives 1 instead of 0
%       EXPECTED: 0 carbon atoms
%       LINES: 39-47
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCountC'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% formulas with carbon

assert(countC('C6H12O6') == 6);
assert(countC('CH4') == 1);              % no number after C means one atom
assert(countC('C') == 1);
assert(countC('HC2') == 2);              % carbon need not be first

%% formulas without carbon

assert(countC('H2O') == 0);

%% alternative formulas after / or , are ignored

assert(countC('C6H12O6/C5') == 6);
assert(countC('C10H8,C9') == 10);

% change the directory
cd(currentDir)
