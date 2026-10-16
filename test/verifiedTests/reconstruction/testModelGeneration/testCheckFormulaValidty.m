% The COBRAToolbox: testCheckFormulaValidty.m
%
% Purpose:
%     - checkFormulaValidty flags metabolites that cannot have a valid chemical formula, by
%     identifier patterns (_hs, hs_, retn, vitd, rtotal, deg) or by formula symbols (R, FULLR, X),
%     and lists them.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/checkFormulaValidty.m
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
fileDir = fileparts(which('testCheckFormulaValidty'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.S = zeros(9, 1);
model.mets = {'glc[c]'; 'pe_hs[c]'; 'hs_x[c]'; 'retn[c]'; 'vitd3[c]'; 'rtotal[c]'; 'degr[c]'; 'rmet[c]'; 'xmet[c]'};
model.metFormulas = {'C6H12O6'; 'C2'; 'C3'; 'C4'; 'C5'; 'C6'; 'C7'; 'C8R'; 'C9X'};

model2 = model;
model2.mets = {'a[c]'; 'b[c]'};
model2.S = zeros(2, 1);
model2.metFormulas = {'CH4'; 'FULLRCO2'};

%% valid and flagged metabolites

[dbBool, noDocMets] = checkFormulaValidty(model);
assert(isequal(dbBool, [1; 0; 0; 0; 0; 0; 0; 0; 0]));
assert(isequal(noDocMets, model.mets(2:9)));

%% formulas with FULLR contain R and are flagged

[dbBool, noDocMets] = checkFormulaValidty(model2);
assert(isequal(dbBool, [1; 0]) && isequal(noDocMets, {'b[c]'}));

%% nothing flagged

model3 = model2;
model3.metFormulas = {'CH4'; 'H2O'};
[dbBool, noDocMets] = checkFormulaValidty(model3);
assert(all(dbBool == 1) && isempty(noDocMets));

% change the directory
cd(currentDir)
