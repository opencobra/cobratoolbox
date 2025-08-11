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

% Run MetanetxMapper
metData = metanetxMapper('MNXM1364063');
% Field presence
assert(isfield(metData, 'metHMDBID'));
assert(isfield(metData, 'metName'));
assert(isfield(metData, 'metKEGGID'));
assert(isfield(metData, 'metBiGGID'));
assert(isfield(metData, 'metInChIkey'));
assert(isfield(metData, 'metSmiles'));

% Run MetanetxMapper with metabolite name
metData = metanetxMapper('L-glutamate', 'name');
% Field presence
assert(isfield(metData, 'metHMDBID'));
assert(isfield(metData, 'metName'));
assert(isfield(metData, 'metKEGGID'));
assert(isfield(metData, 'metBiGGID'));
assert(isfield(metData, 'metInChIkey'));
assert(isfield(metData, 'metSmiles'));

% Run MetanetxMapper with metabolite name
metData = metanetxMapper('glc_D', 'vmh');
% Field presence
assert(isfield(metData, 'metHMDBID'));
assert(isfield(metData, 'metName'));
assert(isfield(metData, 'metKEGGID'));
assert(isfield(metData, 'metBiGGID'));
assert(isfield(metData, 'metInChIkey'));
assert(isfield(metData, 'metSmiles'));

% Run MetanetxMapper with chebi ID
metData = metanetxMapper('4167', 'chebi');
assert(isfield(metData, 'metHMDBID'));
assert(isfield(metData, 'metName'));
assert(isfield(metData, 'metKEGGID'));
assert(isfield(metData, 'metBiGGID'));
assert(isfield(metData, 'metInChIkey'));
assert(isfield(metData, 'metSmiles'));


fprintf('Done.\n');
fprintf('testMetanetxMapper passed successfully.\n');

% change the directory
cd(currentDir);
