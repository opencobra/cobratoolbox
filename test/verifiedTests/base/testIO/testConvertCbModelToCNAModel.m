% The COBRAToolbox: testConvertCbModelToCNAModel.m
%
% Purpose:
%     - convertCbModelToCNAModel checks the CellNetAnalyzer installation and, when it is found,
%       converts a COBRA model to a CellNetAnalyzer mass-flow project with CNAcobra2cna. This
%       test checks the call without CellNetAnalyzer (message only, nothing converted) and the
%       conversion with the two CellNetAnalyzer pieces the interface needs (startcna and
%       CNAgenerateMFNetwork) replaced by test doubles in a temporary folder. The expected
%       project fields are worked out from the model: species and reaction identifiers as char
%       matrices, the full stoichiometric matrix, the bounds, and the objective with the sign
%       of a minimisation (-c for a maximisation).
%
% Function under test:
%     src/base/io/convertCbModelToCNAModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model conversion on a two-reaction hand-built model, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: without CellNetAnalyzer a call with an output stops with an unassigned-output error
%       SEVERITY: cosmetic
%       TRIGGER: cnaModel = convertCbModelToCNAModel(model) when startcna is not on the path
%       OBSERVED: MATLAB R2025a: 'Output argument "cnaModel" (and possibly others) not assigned
%       a value in the execution with "convertCbModelToCNAModel" function.' after the message
%       of checkCNAinstallation; the call cannot succeed without CellNetAnalyzer, only the
%       message is unhelpful
%       EXPECTED: an error that says CellNetAnalyzer is needed
%       LINES: 31-33
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertCbModelToCNAModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% checkCNAinstallation may add the interface folder to the path: save the path to restore it
pathBefore = path;

% two reactions, two metabolites; the metabolite names are one character long because
% CNAcobra2cna (external interface) loops over the columns of the name matrix
model = createModel({'R1'; 'R2'}, {'first'; 'second'}, {'a -> b'; 'b <=> '}, 'printLevel', 0);
model.metNames = {'A'; 'B'};
model.c = [1; 0];

%% without CellNetAnalyzer the call only reports it (no output requested), at both print levels
% only meaningful where CellNetAnalyzer is not installed; where it is, the conversion below
% covers the same lines
if isempty(which('startcna'))
    convertCbModelToCNAModel(model);
    convertCbModelToCNAModel(model, 0);
    % nothing was converted and the path holds no CellNetAnalyzer start function
    assert(isempty(which('startcna')));
end

%% the conversion, with the CellNetAnalyzer functions replaced by test doubles
doubleFolder = tempname;
mkdir(doubleFolder);
fid = fopen([doubleFolder filesep 'startcna.m'], 'w');
fprintf(fid, 'function startcna()\nend\n');
fclose(fid);
fid = fopen([doubleFolder filesep 'CNAgenerateMFNetwork.m'], 'w');
fprintf(fid, 'function cnap = CNAgenerateMFNetwork(cnap)\nend\n');
fclose(fid);
addpath(doubleFolder);

cnaModel = convertCbModelToCNAModel(model);
cnaModelQuiet = convertCbModelToCNAModel(model, 0);

rmpath(doubleFolder);
rmdir(doubleFolder, 's');

% exact: identifiers, matrix and bounds are copied; the objective of a maximisation is -c
assert(isequal(cnaModel.specID, char(model.mets)));
assert(isequal(cnaModel.specLongName, char(model.metNames)));
assert(isequal(cnaModel.reacID, char(model.rxns)));
assert(isequal(cnaModel.stoichMat, [-1 0; 1 -1]));
assert(isequal(cnaModel.reacMin, [0; -1000]));
assert(isequal(cnaModel.reacMax, [1000; 1000]));
assert(isequal(cnaModel.objFunc, [-1; 0]));
% the print level changes only the messages, not the project
assert(isequal(cnaModelQuiet, cnaModel));

% restore the path and change the directory
path(pathBefore);
cd(currentDir)
