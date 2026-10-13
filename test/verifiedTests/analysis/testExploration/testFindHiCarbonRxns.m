% The COBRAToolbox: testFindHiCarbonRxns.m
%
% Purpose:
%     - findHiCarbonRxns lists the reactions that act on a non-currency metabolite with at least a
%     given number of carbons, the reactions that involve no carbon, and the carbon count of every
%     metabolite.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/findHiCarbonRxns.m
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
fileDir = fileparts(which('testFindHiCarbonRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a small model: glucose (6 carbons), water and ATP (currency metabolites), pyruvate (3 carbons),
% ammonium (currency), and two metabolites without carbon
model.mets = {'glc_D[c]'; 'h2o[c]'; 'atp[c]'; 'pyr[c]'; 'nh4[c]'; 'x[c]'; 'y[c]'};
model.metFormulas = {'C6H12O6'; 'H2O'; 'C10H12N5O13P3'; 'C3H3O3'; 'H4N'; ''; 'H2'};
model.rxns = {'r1'; 'r2'; 'r3'; 'r4'};
%                 r1  r2  r3  r4
model.S = [-1  0  0  0; ... % glc_D
           -1  0  0  0; ... % h2o
           -1  0  0  0; ... % atp
            1  0 -1  0; ... % pyr
            0  0  0 -1; ... % nh4
            0 -1  0  1; ... % x
            0  1  0  0];    % y

%% carbon count of every metabolite

[~, ~, nCarbon] = findHiCarbonRxns(model, 3);
% the formula must begin with C followed by a number; the others count as zero carbons
assert(isequal(nCarbon, [6; 0; 10; 3; 0; 0; 0]));

%% reactions with a metabolite at or above the carbon threshold

% threshold 3: glucose (r1) and pyruvate (r1, r3); ATP has 10 carbons but is a currency metabolite
hiCarbonRxns = findHiCarbonRxns(model, 3);
assert(isequal(hiCarbonRxns, {'r1'; 'r3'}));
% threshold 4: only glucose
hiCarbonRxns = findHiCarbonRxns(model, 4);
assert(isequal(hiCarbonRxns, {'r1'}));
% threshold 7: nothing qualifies
hiCarbonRxns = findHiCarbonRxns(model, 7);
assert(isempty(hiCarbonRxns));

%% reactions without carbon

% r2 converts x into y, two non-currency metabolites without carbon; r4 also uses the
% currency metabolite nh4, so it is not listed
[~, zeroCarbonRxns] = findHiCarbonRxns(model, 3);
assert(isequal(zeroCarbonRxns, {'r2'}));

% change the directory
cd(currentDir)
