% The COBRAToolbox: testWriteCbModel.m
%
% Purpose:
%     - test the writeCbModel function
%
% Authors:
%     - Laurent Heirendt
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Function under test:
%     src/base/io/writeCbModel.m
%
% Coverage exemptions:
%     Lines 260-262, 264: dead code, the local function constructGeneStr has no caller.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The JSON format is not detected from the file extension
%       SEVERITY: unusable-option
%       TRIGGER: a .json file name without an explicit format, writeCbModel(model, 'x.json'), or
%         writeCbModel(model, 'format', 'json') with the name picked in the dialog
%       OBSERVED: getFormatFromExtension does not know .json, so the call stops with "Unknown file
%         format"; an explicit format together with a file name works
%       EXPECTED: the same JSON file as with the explicit format
%       LINES: 177-178
%     - DEFECT: The file dialog offers an MPS export that does not exist
%       SEVERITY: unusable-option
%       TRIGGER: a .MPS file name without an explicit format, which the dialog offers as MPS Export
%       OBSERVED: the extension is mapped to the format mps, which has no writer, so the call
%         stops with "Unknown file format"
%       EXPECTED: an MPS file, or no such choice in the dialog
%       LINES: 280-281

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteCbModel'));
cd(fileDir);

% Note: test is only compatible with Matlab R2015b or later
if ~verLessThan('matlab', '8.6')
    % define tolerance
    tol = 1e-6;

    % load the model
    model = getDistributedModel('ecoli_core_model.mat');

    % write the model to an xls file
    writeCbModel(model, 'xlsx', 'testData');

    % read in the xls model file
    modelIn = xls2model('testData.xlsx');

    % convert an old style model
    model = convertOldStyleModel(model);

    % test
    assert(isequal(model.lb, modelIn.lb))
    assert(isequal(model.b, modelIn.b))
    assert(isequal(model.ub, modelIn.ub))
    assert(isequal(sort(model.mets), sort(modelIn.mets)))
    assert(isequal(model.csense, modelIn.csense))
    assert(isequal(model.osenseStr, modelIn.osenseStr))
    assert(isequal(model.rxns, modelIn.rxns))
    assert(isequal(sort(model.genes), sort(modelIn.genes)))
    assert(isequal(model.c, modelIn.c))

    % NOTE: model.rules and model.S are different from modelIn.S and modelIn.rules
    %       as the metabolites are not ordered in the same way.

    solverOK = changeCobraSolver('glpk');

    if solverOK
        % run an LP and compare the solutions
        solModel = optimizeCbModel(model);
        solModelIn = optimizeCbModel(modelIn);

        assert(abs(solModel.f - solModelIn.f) < tol)
        assert(solModel.stat == solModelIn.stat)
    end

    % remove the generated file
    delete('testData.xlsx');
else
    fprintf('\ntestWriteCbModel is not compatible with this version of MATLAB. Please upgrade your version of MATLAB.\n\n');
end

% test varargin

% load the model
model = getDistributedModel('ecoli_core_model.mat');

% write out using varargin
outmodel1 = writeCbModel(model, 'format', 'mat', 'fileName', 'testModel1');
outmodel2 = writeCbModel(model, 'mat', 'testModel2.mat');

% read in the testModel and testModel2
testModel1 = readCbModel('testModel1.mat');
testModel2 = readCbModel('testModel2.mat');
testModel2.description = '';
testModel1.description = '';
assert(isequal(testModel1, testModel2));

% test the legacy signature with more input arguments
[compSymbols, compNames] = getDefaultCompartmentSymbols();
outmodel3 = writeCbModel(model, 'mat', 'testModel3.mat', compNames, compSymbols);
testModel3 = readCbModel('testModel3.mat');
testModel3.description = '';
assert(isequal(testModel1, testModel3));

% test new signature
outmodel4 = writeCbModel(model, 'format', 'mat', 'fileName', 'testModel4.mat', 'compNames', compNames, 'compSymbols', compSymbols);
outmodel5 = writeCbModel(model, 'format', 'mat', 'compNames', compNames, 'compSymbols', compSymbols,'fileName', 'testModel5.mat');
testModel4 = readCbModel('testModel4.mat');
testModel5 = readCbModel('testModel5.mat');
testModel4.description = '';
testModel5.description = '';
assert(isequal(testModel4, testModel5));

% remove generate files during testing
for i = 1:5
    delete(['testModel', num2str(i),'.mat']);
end

%% The formats and file name rules below all write into a temporary folder
sandboxDir = tempname;
mkdir(sandboxDir);
sandboxFile = @(name) [sandboxDir filesep name];
origHome = getenv('HOME');

%% A file name as the first argument
writeCbModel(model, sandboxFile('direct.mat'));
savedModel = load(sandboxFile('direct.mat'));
assert(isequal(savedModel.model.rxns, model.rxns));

%% The first optional input has to be text
assert(verifyCobraFunctionError('writeCbModel', 'inputs', {model, 5}, 'testMessage', ...
    'Additional arguments have to be Parameter and Value pairs of the form ''ParameterName'', value '));

%% The legacy signature only accepts SBML level 3, version 1
assert(verifyCobraFunctionError('writeCbModel', 'inputs', ...
    {model, 'mat', sandboxFile('legacy.mat'), compSymbols, compNames, 2}, 'testMessage', 'Only SBML 3 is supported.'));
assert(verifyCobraFunctionError('writeCbModel', 'inputs', ...
    {model, 'mat', sandboxFile('legacy.mat'), compSymbols, compNames, 3, 2}, 'testMessage', 'Only SBML version 1 is supported.'));
writeCbModel(model, 'mat', sandboxFile('legacy.mat'), compSymbols, compNames, 3, 1);
assert(exist(sandboxFile('legacy.mat'), 'file') == 2);

%% A model with missing fields is converted first, and the converted model is returned
incompleteModel = rmfield(model, 'c');
outmodel = writeCbModel(incompleteModel, 'format', 'mat', 'fileName', sandboxFile('incomplete.mat'));
assert(isequal(outmodel.c, zeros(size(model.rxns))));

%% A model with a constraint matrix A: the matrix is written as the stoichiometry
modelWithA = model;
modelWithA.A = model.S;
writeCbModel(modelWithA, 'format', 'mat', 'fileName', sandboxFile('withA.mat'));
savedModel = load(sandboxFile('withA.mat'));
assert(isequal(savedModel.model.S, model.S) && isequal(savedModel.model.A, model.S));

%% The compartments of the model replace the defaults
modelWithComps = model;
modelWithComps.comps = {'c'; 'e'};
writeCbModel(modelWithComps, 'format', 'sbml', 'fileName', sandboxFile('comps.xml'));
assert(contains(fileread(sandboxFile('comps.xml')), 'name="e"'));
modelWithComps.compNames = {'cytosol'; 'outside'};
writeCbModel(modelWithComps, 'format', 'sbml', 'fileName', sandboxFile('compNames.xml'));
assert(contains(fileread(sandboxFile('compNames.xml')), 'name="outside"'));

%% The format follows from the extension of the file name
% text: one header line and one line per reaction, with formula, GPR rule and bounds
writeCbModel(model, 'fileName', sandboxFile('detected.txt'));
textLines = strsplit(strtrim(fileread(sandboxFile('detected.txt'))), newline);
assert(strcmp(strtrim(textLines{1}), sprintf('Rxn name\tFormula\tGene-reaction association\tLB\tUB\tObjective')));
assert(numel(textLines) == numel(model.rxns) + 1);
firstRxnFields = strsplit(textLines{2}, '\t', 'CollapseDelimiters', false);
assert(strcmp(firstRxnFields{1}, model.rxns{1}));
assert(abs(str2double(firstRxnFields{4}) - model.lb(1)) < 0.01);

% sbml, expa, xls and xlsx
writeCbModel(model, 'fileName', sandboxFile('detected.xml'));
assert(numel(readCbModel(sandboxFile('detected.xml')).rxns) == numel(model.rxns));
writeCbModel(model, 'fileName', sandboxFile('detected.expa'));
assert(contains(fileread(sandboxFile('detected.expa')), model.rxns{1}));
writeCbModel(model, 'fileName', sandboxFile('detected.xlsx'));
assert(exist(sandboxFile('detected.xlsx'), 'file') == 2);
writeCbModel(model, 'fileName', sandboxFile('detected.xls'));
assert(exist(sandboxFile('detected.xls'), 'file') == 2);

% json needs the explicit format
writeCbModel(model, 'format', 'json', 'fileName', sandboxFile('explicit.json'));
assert(isValidJSON(sandboxFile('explicit.json')));

% an unknown extension or format is an error
assert(verifyCobraFunctionError('writeCbModel', 'inputs', {model, 'fileName', sandboxFile('detected.foo')}, ...
    'testMessage', 'Unknown file format'));
assert(verifyCobraFunctionError('writeCbModel', 'inputs', {model, 'format', 'foo', 'fileName', sandboxFile('explicit.foo')}, ...
    'testMessage', 'Unknown file format'));

%% A file name starting with ~/ is expanded, with HOME pointing into the sandbox
setenv('HOME', sandboxDir);
try
    writeCbModel(model, 'format', 'xlsx', 'fileName', '~/tilde.xlsx');
    writeCbModel(model, 'format', 'sbml', 'fileName', '~/tilde.xml');
catch ME
    setenv('HOME', origHome);
    rethrow(ME);
end
setenv('HOME', origHome);
assert(exist(sandboxFile('tilde.xlsx'), 'file') == 2);
assert(exist(sandboxFile('tilde.xml'), 'file') == 2);

%% Without a file name it is asked for: uiputfile is replaced by a test double
global WRITECBMODEL_DIALOG_ANSWER
doubleFolder = [sandboxDir filesep 'doubles'];
mkdir(doubleFolder);
fid = fopen([doubleFolder filesep 'uiputfile.m'], 'w');
fprintf(fid, 'function [fileName, filePath] = uiputfile(varargin)\n');
fprintf(fid, 'global WRITECBMODEL_DIALOG_ANSWER\n');
fprintf(fid, '[fileName, filePath] = deal(WRITECBMODEL_DIALOG_ANSWER{:});\nend\n');
fclose(fid);
addpath(doubleFolder);
clear writeCbModel
try
    % the requested format and the file picked for it; the extension decides what is written
    dialogCases = {'xls', 'dialog.xlsx'; 'text', 'dialog1.txt'; 'txt', 'dialog2.txt'; 'sbml', 'dialog.xml'; ...
        'mat', 'dialog1.mat'; 'expa', 'dialog.expa'; 'toselect', 'dialog2.mat'; 'otherFormat', 'dialog3.mat'};
    for i = 1:size(dialogCases, 1)
        WRITECBMODEL_DIALOG_ANSWER = {dialogCases{i, 2}, sandboxDir};
        writeCbModel(model, 'format', dialogCases{i, 1});
        assert(exist(sandboxFile(dialogCases{i, 2}), 'file') == 2);
    end

    % no format at all
    WRITECBMODEL_DIALOG_ANSWER = {'dialog4.mat', sandboxDir};
    writeCbModel(model);
    assert(exist(sandboxFile('dialog4.mat'), 'file') == 2);

    % a cancelled dialog writes nothing and still returns the model
    WRITECBMODEL_DIALOG_ANSWER = {0, 0};
    nFiles = numel(dir(sandboxDir));
    outmodel = writeCbModel(model, 'format', 'mat');
    assert(numel(dir(sandboxDir)) == nFiles);
    assert(isequal(outmodel.rxns, model.rxns));
catch ME
    rmpath(doubleFolder);
    clear uiputfile WRITECBMODEL_DIALOG_ANSWER
    rmdir(sandboxDir, 's');
    rethrow(ME);
end
rmpath(doubleFolder);
clear uiputfile
clear global WRITECBMODEL_DIALOG_ANSWER
rmdir(sandboxDir, 's');

% change to old directory
cd(currentDir);
