% The COBRAToolbox: testCalculateGR.m
%
% Purpose:
%     - calculateGR turns the gene rules of a model into arithmetic expressions (or becomes +, and
%     becomes *), substitutes gene values, evaluates them and flags reactions whose value exceeds
%     0.9.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/design/TrimGdel/calculateGR.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 64, the flag -1 for an empty expression: empty rules are replaced by the text 1 earlier,
%     so no expression is ever empty.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateGR'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'r1'; 'r2'; 'r3'};
model.genes = {'g1'; 'g2'};
model.grRules = {'g1 or g2'; 'g1 and g2'; ''};
gvalue = {'g1', 0.5; 'g2', 0.8};

%% expressions, values and flags

grRules = calculateGR(model, gvalue);
assert(isequal(size(grRules), [3 4]));
assert(isequal(grRules(:, 1), {'g1 or g2'; 'g1 and g2'; '1'}));
assert(isequal(grRules(:, 2), {'0.5 + 0.8'; '0.5 * 0.8'; '1'}));
assert(abs(grRules{1, 3} - 1.3) < 1e-12 && abs(grRules{2, 3} - 0.4) < 1e-12 && grRules{3, 3} == 1);
% values above 0.9 are flagged
assert(isequal(cell2mat(grRules(:, 4)), [1; 0; 1]));

% change the directory
cd(currentDir)
