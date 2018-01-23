% The COBRAToolbox: testWriteCbModel.m
%
% Purpose:
%     - test the writeCbModel function
%
% Authors:
%     - Laurent Heirendt

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

% change to old directory
cd(currentDir);
