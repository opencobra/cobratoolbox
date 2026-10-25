% The COBRAToolbox: testMakeSAMMIdataString.m
%
% Purpose:
%     - makeSAMMIdataString converts a table with named rows into the text of an array of arrays
%     used by the SAMMI viewer (a header row of column names followed by one row per table row).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/visualization/SAMMIM/makeSAMMIdataString.m
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
fileDir = fileparts(which('testMakeSAMMIdataString'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% two columns and two rows

tbl = array2table([1 2; 3 4], 'VariableNames', {'x', 'y'}, 'RowNames', {'r1', 'r2'});
text = makeSAMMIdataString(tbl);
assert(strcmp(text, '[[''x'',''y''],["r1","1","2"],["r2","3","4"]]'));

%% non-integer values use the short format

tbl = array2table([0.5 1e-3], 'VariableNames', {'p', 'q'}, 'RowNames', {'row'});
text = makeSAMMIdataString(tbl);
assert(strcmp(text, '[[''p'',''q''],["row","0.5","0.001"]]'));

% change the directory
cd(currentDir)
