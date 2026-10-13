% The COBRAToolbox: testMakeSAMMIparseVector.m
%
% Purpose:
%     - makeSAMMIparseVector writes reaction lists (and optionally their fluxes) as the text vector
%     that the SAMMI web tool reads: [["name",["rxn","flux"],...],...].
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/visualization/SAMMIM/makeSAMMIparseVector.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeSAMMIparseVector'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% reactions only

entries = struct('name', 'M1', 'rxns', {{'r1'; 'r2'}});
assert(strcmp(makeSAMMIparseVector(entries), '[["M1",["r1"],["r2"]]]'));

%% reactions with fluxes

entries = struct('name', 'M1', 'rxns', {{'r1'; 'r2'}}, 'flux', [1.5; 2]);
assert(strcmp(makeSAMMIparseVector(entries), '[["M1",["r1","1.5"],["r2","2"]]]'));

%% several entries; an empty flux becomes NaN

entries(1).name = 'A';
entries(1).rxns = {'r1'};
entries(1).flux = [];
entries(2).name = 'B';
entries(2).rxns = {'r2'; 'r3'};
entries(2).flux = [0.1; 3];
assert(strcmp(makeSAMMIparseVector(entries), '[["A",["r1","NaN"]],["B",["r2","0.1"],["r3","3"]]]'));

%% several entries without fluxes

entries = struct('name', {'A', 'B'}, 'rxns', {{'r1'; 'r2'}, {'r3'}});
assert(strcmp(makeSAMMIparseVector(entries), '[["A",["r1"],["r2"]],["B",["r3"]]]'));

% change the directory
cd(currentDir)
