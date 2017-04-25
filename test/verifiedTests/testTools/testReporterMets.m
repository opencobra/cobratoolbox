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
fileDir = fileparts(which('testReporterMets'));
cd(fileDir);

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

% update with pValFlag=1
try
  for i=1:length(metric)
      [normScore(:, i), nRxnsMet(:, i), nRxnsMetUni(:, i), rawScore(:, i)] = reporterMets(model, data, nRand, 1, nLayers, metric{i}, dataRxns);
  end
catch ME
    assert(length(ME.message) > 0)
end

% update with dataRxns={} cell
for i=1:length(metric)
    [normScore(:, i), nRxnsMet(:, i), nRxnsMetUni(:, i), rawScore(:, i)] = reporterMets(model, data, nRand, pValFlag, nLayers, metric{i}, {});
end
assert(isequal(nRxnsMet, ref_nRxnsMet));
assert(isequal(nRxnsMetUni, ref_nRxnsMetUni));
assert(isequal(rawScore, ref_rawScore));

% update with nRand=empty
for i=1:length(metric)
    [normScore(:, i), nRxnsMet(:, i), nRxnsMetUni(:, i), rawScore(:, i)] = reporterMets(model, data, [], pValFlag, nLayers, metric{i}, dataRxns);
end
assert(isequal(nRxnsMet, ref_nRxnsMet));
assert(isequal(nRxnsMetUni, ref_nRxnsMetUni));
assert(isequal(rawScore, ref_rawScore));

% update with dataRxns={{'a'}}
for i=1:length(metric)
    [normScore(:, i), nRxnsMet(:, i), nRxnsMetUni(:, i), rawScore(:, i)] = reporterMets(model, data, nRand, pValFlag, nLayers, metric{i}, {{'a'}});
end
assert(isequal(nRxnsMet, zeros(72,5)));
assert(isequal(nRxnsMetUni, zeros(72,5)));
assert(isequal(rawScore, zeros(72,5)));

% update checking with less inputs and checking if sum(data(RxnInd)==1 and length(randInd)==1
load('ref_testReporterMets2.mat');
nRxnsMet=[];
nRxnsMetUni=[];
rawScore=[];
[normScore(:, 1), nRxnsMet(:, 1), nRxnsMetUni(:, 1), rawScore(:, 1)] = reporterMets(model, data);
[normScore(:, 2), nRxnsMet(:, 2), nRxnsMetUni(:, 2), rawScore(:, 2)] = reporterMets(model, data, 1000, false, 1, 'std');
[normScore(:, 3), nRxnsMet(:, 3), nRxnsMetUni(:, 3), rawScore(:, 3)] = reporterMets(model, data, 1000, false, 1, 'count');
assert(isequal(nRxnsMet, nRxnsMet_ref2));
assert(isequal(nRxnsMetUni, nRxnsMetUni_ref2));
assert(isequal(rawScore, rawScore_ref2));

% change the directory
cd(currentDir)
