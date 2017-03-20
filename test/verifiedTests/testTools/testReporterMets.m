% The COBRAToolbox: testReporterMets.m
%
% Purpose:
%     - tests the basic functionality of reporterMets
%       Tests five metrics ('default','mean','median','std','count')
%
% Authors:
%     - CI integration: Lemmer El Assal, March 2017
%


% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testReporterMets']);


load e_coli_core.mat % model
load ref_testReporterMets.mat % load reference data - too large to include inline.
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
cd(CBTDIR)
