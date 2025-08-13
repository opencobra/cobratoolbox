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

fprintf(' -- Running testMetanetxMapper ... \n');
prepareTest('needsWebAddress','https://beta.metanetx.org');

% Convert Swiss lipids to HMDB
metData = metanetxMapper('MNXM1364063');
assert(strcmp(metData.metHMDBID, 'HMDB0304632'));

% CommonName
assert(strcmp(metData.metName, 'D-glucose'));

% KEGG
assert(strcmp(metData.metKEGGID, 'C00031'));

% BiGG
assert(strcmp(metData.metBiGGID, 'glc__D'));

% InChi
assert(strcmp(metData.metInChIkey, 'WQZGKKKJIJFFOK-GASJEMHNSA-N'));

% SMILES
assert(strcmp(metData.metSmiles, 'OC[C@H]1OC(O)[C@H](O)[C@@H](O)[C@@H]1O'));

fprintf('Done.\n');
fprintf('testMetanetxMapper passed successfully.\n');

% change the directory
cd(currentDir);
