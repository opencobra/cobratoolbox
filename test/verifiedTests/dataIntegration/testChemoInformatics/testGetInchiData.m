% The COBRAToolbox: testGetInchiData.m
%
% Purpose:
%     - getInchiData splits an InChI string into its layers and reports the number of layers, whether it is a standard InChI, the formula, the main layer, the net charge and whether stereochemical or isotopic layers exist.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/inchi/getInchiData.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below; the defect below concerns inputs that are skipped.
%
% Known defects documented (NOT tested, NOT fixed here):
%     A negative charge written as a "q-" layer (for example /q-1) gives a net charge of NaN, because only "q+" is removed before the conversion to a number. Such inputs are documented and NOT tested. An InChI with two layers that contain the letter p would also fail inside regexprep; also not tested.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetInchiData'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% glucose: standard InChI with connectivity, hydrogen and stereochemical layers

inchiGlucose = 'InChI=1S/C6H12O6/c7-1-2-3(8)4(9)5(10)6(11)12-2/h2-11H,1H2/t2-,3-,4+,5-,6?/m1/s1';
data = getInchiData(inchiGlucose);
assert(data.layers == 7);
assert(data.standard == true);
assert(strcmp(data.metFormula, 'C6H12O6'));
% the main layer is the identifier up to and including the hydrogen layer
assert(strcmp(data.mainLayer, 'InChI=1S/C6H12O6/c7-1-2-3(8)4(9)5(10)6(11)12-2/h2-11H,1H2'));
assert(data.netCharge == 0);
% the layers /t, /m and /s are counted as stereochemical
assert(data.stereochemicalSubLayers == 3);
assert(data.isotopicLayer == 0);

%% water: only a formula and a hydrogen layer

data = getInchiData('InChI=1S/H2O/h1H2');
assert(data.layers == 3);
assert(strcmp(data.metFormula, 'H2O'));
assert(strcmp(data.mainLayer, 'InChI=1S/H2O'));
assert(data.netCharge == 0 && data.stereochemicalSubLayers == 0 && data.isotopicLayer == 0);

%% proton: no formula layer, the formula is written as H and the charge comes from the /p layer

data = getInchiData('InChI=1S/p+1');
assert(strcmp(data.metFormula, 'H'));
assert(strcmp(data.mainLayer, 'InChI=1S/H'));
assert(data.netCharge == 1);

%% no formula layer: the formula is empty

% the second layer starts with a lower-case letter (a hydrogen layer) and is not /p+1
data = getInchiData('InChI=1S/h1H');
assert(isempty(data.metFormula));
assert(strcmp(data.mainLayer, 'InChI=1S/'));

%% protonation layers (/p) and positive charge (/q) add up to the net charge

% /p-1: one proton removed
data = getInchiData('InChI=1S/C2H3O2/c1-2(3)4/h1H3,(H,3,4)/p-1');
assert(data.netCharge == -1);
assert(strcmp(data.mainLayer, 'InChI=1S/C2H3O2/c1-2(3)4/h1H3,(H,3,4)'));
% /q+1: one positive charge
data = getInchiData('InChI=1S/C2H8N/c1-3-2/h3H,1-2H3/q+1');
assert(data.netCharge == 1);

%% non-standard InChI (no "S")

data = getInchiData('InChI=1/C2H6O/c1-2-3/h3H,2H2,1H3');
assert(data.standard == false);

%% isotopic layer

data = getInchiData('InChI=1S/C3H8/c1-3-2/h3H2,1-2H3/i1+1');
assert(data.isotopicLayer == true);
assert(data.layers == 5);

%% text that is not an InChI -> error

assert(verifyCobraFunctionError('getInchiData', 'inputs', {'abc/def'}, 'testMessage', 'abc/def is not an InChI'));

% change the directory
cd(currentDir)
