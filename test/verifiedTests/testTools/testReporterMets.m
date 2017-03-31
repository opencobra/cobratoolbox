% The COBRAToolbox: testReporterMets.m
%
% Purpose:
%     - tests the basic functionality of reporterMets
%       Tests five metrics ('default','mean','median','std','count')
%
% Authors:
%     - CI integration: Lemmer El Assal, March 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

% load reference data and model
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

load('ref_testReporterMets.mat');
nRand = 10;
pValFlag = 0;
nLayers = 2;
metric = {'default', 'mean', 'median', 'std', 'count'};
dataRxns = [];

for i=1:length(metric)
    [normScore(:, i), nRxnsMet(:, i), nRxnsMetUni(:, i), rawScore(:, i)] = reporterMets(model, data, nRand, pValFlag, nLayers, metric{i}, dataRxns);
end

% normScore is random
assert(isequal(nRxnsMet, ref_nRxnsMet));
assert(isequal(nRxnsMetUni, ref_nRxnsMetUni));
assert(isequal(rawScore, ref_rawScore));

% change the directory
cd(currentDir)
