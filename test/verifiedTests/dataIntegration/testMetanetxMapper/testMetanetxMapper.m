% The COBRAToolbox:testMetanetxMapper.m
%
% Purpose:
%     - testing functionality of metanetxMapper function
%
% Authors:
%     - Farid Zare 03/07/2024
%

global CBTDIR

% define the features required to run the test
requiredToolboxes = { 'bioinformatics_toolbox', 'optimization_toolbox' };

requiredSolvers = { 'dqqMinos', 'matlab' };

% require the specified toolboxes and solvers, along with a UNIX OS
solversPkgs = prepareTest();

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

fprintf(' -- Running testmetanetxMapper ... ');

% Convert Swiss lipids to HMDB
metData = metanetxMapper('SLM:000390086');
assert(strcmp(metData.metHMDBID, 'HMDB0000688'));

% Convert HMDB to CommonName
metData = metanetxMapper('HMDB0000148');
assert(strcmp(metData.metName, 'L-glutamate'));

% Convert VMH to KEGG
metData = metanetxMapper('succ', 'vmh');
assert(strcmp(metData.metKEGGID, 'C00042'));

% Convert SwissLipids to BiGG
metData = metanetxMapper('SLM:000000287');
assert(strcmp(metData.metBiGGID, 'chsterol'));

fprintf('Done.\n');
fprintf('testmetanetxMapper passed successfully.\n');

% change the directory
cd(currentDir)
