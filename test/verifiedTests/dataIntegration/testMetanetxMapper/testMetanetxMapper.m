% The COBRAToolbox:testMetanetxMapper.m
%
% Purpose:
%     - testing functionality of metanetxMapper function
%
% Authors:
%     - Farid Zare 03/07/2024
%

% require the specified toolboxes and solvers, along with a UNIX OS
solversPkgs = prepareTest();

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

fprintf(' -- Running testMetanetxMapper ... ');

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

% Convert ChEBI to InChi
metData = metanetxMapper('64368', 'chebi');
assert(strcmp(metData.metInChIkey, 'BJBUEDPLEOHJGE-UHFFFAOYSA-N'));

% Convert InChiKey to SMILES
metData = metanetxMapper('HEBKCHPVOIAQTA-SCDXWVJYSA-N');
assert(strcmp(metData.metSmiles, '[CH2:1]([C@@H:3]([C@H:5]([C@@H:4]([CH2:2][OH:7])[OH:9])[OH:10])[OH:8])[OH:6]'));

fprintf('Done.\n');
fprintf('testMetanetxMapper passed successfully.\n');

% change the directory
cd(currentDir);
