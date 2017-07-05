% The COBRAToolbox: testMinSpan.m
%
% Purpose:
%     - test the ability to determine the MinSpan vectors of the
%       E.coli core model
%
% Authors:
%     - Original test file: Aarash Bordbar
%     - CI integration: Sylvain Arreckx, June 2017

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMinSpan'));
cd(fileDir);

% create a parallel pool
poolobj = gcp('nocreate');  % if no pool, do not create new one.
if isempty(poolobj)
    parpool(2);  % launch 2 workers
end

changeCobraSolver('glpk', 'all');

% load the model
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% Remove biomass equation for MinSpan calculation
bmName = {'Biomass_Ecoli_core_w_GAM'};
model = removeRxns(model, bmName);

[m, n] = size(model.S);
assert(m == 72 & n == 94, 'Unable to setup input for MinSpan determination');

% Setup parameters and run detMinSpan
params.saveIntV = 0; % Do not save intermediate output
minSpanVectors = detMinSpan(model, params);

% Check size of vectors and number of entries
[r, c] = size(minSpanVectors);
numEntries = nnz(minSpanVectors);

assert(r == 94 & c == 23, 'MinSpan vector matrix wrong size');
assert(numEntries == 479, 'MinSpan vector matrix is not minimal');
