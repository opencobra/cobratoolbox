% The COBRAToolbox: testCheckBalance.m
%
% Purpose:
%     - checkBalance(model, element, printLevel, fileName, missingFormulaeBool) counts the atoms
%       of one element in every metabolite formula (E) and returns the net change per reaction
%       dE = S' * E, with NaN for the reactions that involve a metabolite without a usable
%       formula and for those metabolites in E; it lists them on screen (printLevel 1, the
%       default) or in a file (printLevel -1). The test uses a hand-built seven-metabolite
%       model whose E and dE are counted by hand for C, Co, H and an absent element, with no,
%       one (not in reaction 1) and two metabolites without a formula, a non-standard formula,
%       a given missingFormulaeBool, the printed list and the file, and the errors.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/checkBalance.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-up, no solver; a hand-built model with S, mets and metFormulas, and a
%     tempname folder for the printLevel -1 file.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (The defect recorded on 2026-11-16, with exactly one metabolite without a
%     formula the wrong reactions set to NaN, was fixed by feature
%     20261120-161825-core-blocker-fixes and is tested below.)
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Full test after the fix (feature 20261120-161825-core-blocker-fixes), 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckBalance'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% seven metabolites and three reactions:
%     R1: a + c -> b + d   (glucose + phosphate -> glucose 6-phosphate + water)
%     R2: b ->             (an exchange)
%     R3: e + f -> g       (CO2 + CoCl2 -> CCoCl2O2; C and Co balanced)
model = struct();
model.mets = {'a'; 'b'; 'c'; 'd'; 'e'; 'f'; 'g'};
model.rxns = {'R1'; 'R2'; 'R3'};
model.metFormulas = {'C6H12O6'; 'C6H11O9P'; 'H3O4P'; 'H2O'; 'CO2'; 'CoCl2'; 'CCoCl2O2'};
model.S = sparse([-1  0  0;
                   1 -1  0;
                  -1  0  0;
                   1  0  0;
                   0  0 -1;
                   0  0 -1;
                   0  0  1]);

% printed output is read from a diary file, and the printLevel -1 file is written, in a
% temporary folder
outFolder = tempname;
mkdir(outFolder);
diaryFile = fullfile(outFolder, 'checkBalance.txt');

%% every formula known: E and dE counted by hand

[dE, E, missingFormulaeBool] = checkBalance(model, 'C', 0);
assert(isequal(E, [6; 6; 0; 0; 1; 0; 1]) && isequal(dE, [0; -6; 0]));
assert(isequal(missingFormulaeBool, false(7, 1)));
% Co is told apart from C, and C from Co and Cl
[dE, E] = checkBalance(model, 'Co', 0);
assert(isequal(E, [0; 0; 0; 0; 0; 1; 1]) && isequal(dE, [0; 0; 0]));
% R1 loses two hydrogens (11 + 2 - 12 - 3)
[dE, E] = checkBalance(model, 'H', 0);
assert(isequal(E, [12; 11; 3; 2; 0; 0; 0]) && isequal(dE, [-2; -11; 0]));
% an element in no formula
[dE, E] = checkBalance(model, 'Mg', 0);
assert(isequal(E, zeros(7, 1)) && isequal(dE, zeros(3, 1)));
% a net change below 1e-12 is set to exactly 0
modelThird = model;
modelThird.S(:, 3) = [0; 0; 0; 0; -1/3; -1/3; 1/3];
modelThird.S(7, 3) = modelThird.S(7, 3) * (1 + 1e-14);
dE = checkBalance(modelThird, 'C', 0);
assert(dE(3) == 0);

%% exactly one metabolite without a formula (f, used by R3 only): R3 is NaN, R1 is not

modelOne = model;
modelOne.metFormulas{6} = '';
[dE, E, missingFormulaeBool] = checkBalance(modelOne, 'C', 0);
assert(isequaln(dE, [0; -6; NaN]) && isequaln(E, [6; 6; 0; 0; 1; NaN; 1]));
assert(isequal(missingFormulaeBool, [false; false; false; false; false; true; false]));

%% two metabolites without a formula (d and f): R1 and R3 are NaN

modelTwo = modelOne;
modelTwo.metFormulas{4} = '';
[dE, E] = checkBalance(modelTwo, 'C', 0);
assert(isequaln(dE, [NaN; -6; NaN]) && isequaln(E, [6; 6; 0; NaN; 1; NaN; 1]));

%% a non-standard formula, starting with '(', counts as missing

modelGlycan = model;
modelGlycan.metFormulas{7} = '(Gal)3(Glc)1';
[dE, E, missingFormulaeBool] = checkBalance(modelGlycan, 'C', 0);
assert(isequaln(dE, [0; -6; NaN]) && isnan(E(7)) && isequal(find(missingFormulaeBool), 7));

%% a given missingFormulaeBool: those metabolites count as missing too, and are returned

% (a given missingFormulaeBool must mark every empty formula, as the third output does)
[dE, E, missingFormulaeBool] = checkBalance(model, 'C', 0, '', [true; false; false; false; false; false; false]);
assert(isequaln(dE, [NaN; -6; 0]) && isnan(E(1)) && isequal(E(2:7), [6; 0; 0; 1; 0; 1]));
assert(isequal(find(missingFormulaeBool), 1));
[dE, E, missingFormulaeBool] = checkBalance(modelOne, 'C', 0, '', [true; false; false; false; false; true; false]);
assert(isequaln(dE, [NaN; -6; NaN]) && isnan(E(1)) && isnan(E(6)));
assert(isequal(find(missingFormulaeBool), [1; 6]));

%% printLevel 1 (the default) lists the metabolites without a formula; printLevel 0 is silent

diary(diaryFile);
checkBalance(modelTwo, 'C', 0);
diary('off');
printed = '';
if exist(diaryFile, 'file')
    printed = fileread(diaryFile);
    delete(diaryFile);
end
assert(isempty(strtrim(printed)));
diary(diaryFile);
dE = checkBalance(modelTwo, 'C');
checkBalance(modelTwo, 'C', 1);
diary('off');
printed = fileread(diaryFile);
delete(diaryFile);
assert(isequaln(dE, [NaN; -6; NaN]));
assert(numel(strfind(printed, sprintf('4\td has no formula'))) == 2);
assert(numel(strfind(printed, sprintf('6\tf has no formula'))) == 2);

%% printLevel -1 writes the list to [fileName 'metabolites_without_formulae.txt']

prefix = fullfile(outFolder, 'run1_');
dE = checkBalance(modelTwo, 'C', -1, prefix);
assert(isequaln(dE, [NaN; -6; NaN]));
written = fileread([prefix 'metabolites_without_formulae.txt']);
assert(strcmp(written, sprintf('4\td\n6\tf\n')));
% without a metabolite to list, no file is written
prefix = fullfile(outFolder, 'run2_');
checkBalance(model, 'C', -1, prefix);
assert(~exist([prefix 'metabolites_without_formulae.txt'], 'file'));
% without fileName the file is written in the current folder
cd(outFolder);
checkBalance(modelOne, 'C', -1);
written = fileread(fullfile(outFolder, 'metabolites_without_formulae.txt'));
cd(fileDir);
assert(strcmp(written, sprintf('6\tf\n')));

%% errors: no metFormulas, metFormulas of another length, an element numAtomsOfElementInFormula rejects

assert(verifyCobraFunctionError('checkBalance', 'inputs', {rmfield(model, 'metFormulas'), 'C', 0}));
modelShort = model;
modelShort.metFormulas(end) = [];
assert(verifyCobraFunctionError('checkBalance', 'inputs', {modelShort, 'C', 0}));
% the error of the formula parser is passed on (a single-letter element must be upper case)
assert(verifyCobraFunctionError('checkBalance', 'inputs', {model, 'c', 0}));
try
    checkBalance(model, 'c', 0);
    error('testCheckBalance:noError', 'checkBalance accepted a lower-case element');
catch ME
    assert(strcmp(ME.message, 'Single letter element must not be lower case'));
end

% remove the temporary folder
rmdir(outFolder, 's');

% change the directory
cd(currentDir)
