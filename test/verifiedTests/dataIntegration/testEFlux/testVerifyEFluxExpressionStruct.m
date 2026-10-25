% The COBRAToolbox: testVerifyEFluxExpressionStruct.m
%
% Purpose:
%     - verifyEFluxExpressionStruct checks that an expression structure fits a model for eFlux: all
%     genes are assigned unless the data are preprocessed, and the number of values equals the
%     number of targets.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/transcriptomics/eFlux/verifyEFluxExpressionStruct.m
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
fileDir = fileparts(which('testVerifyEFluxExpressionStruct'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.genes = {'g1'; 'g2'};

%% a valid expression structure

expression = struct('target', {{'g1'; 'g2'}}, 'value', [1; 2]);
assert(verifyCobraFunctionTrue(model, expression));

%% preprocessed data need not cover all genes

expression = struct('target', {{'g1'}}, 'value', 1, 'preprocessed', true);
assert(verifyEFluxExpressionStruct(model, expression));

%% data that are not preprocessed must assign every gene

expression = struct('target', {{'g1'}}, 'value', 1, 'preprocessed', false);
verifyCobraFunctionError('verifyEFluxExpressionStruct', 'inputs', {model, expression}, ...
    'testMessage', 'The following genes are lacking assignments');

%% the number of values must fit the number of targets

expression = struct('target', {{'g1'; 'g2'}}, 'value', [1; 2; 3]);
verifyCobraFunctionError('verifyEFluxExpressionStruct', 'inputs', {model, expression}, ...
    'testMessage', 'The number of values in the expression struct does not fit');


function tf = verifyCobraFunctionTrue(model, expression)
% Call the function under test and return its result.
tf = verifyEFluxExpressionStruct(model, expression);
end

% change the directory
cd(currentDir)
