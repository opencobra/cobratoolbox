% The COBRAToolbox: testParsave.m
%
% Purpose:
%     - parsave saves a variable to a MAT-file so that it can be called from a parfor loop. A
%       structure with a 'rxns' field (a model) is saved under the name 'model', as a
%       version 7 MAT-file when it has fewer than 300000 reactions and as a version 7.3
%       (HDF5) MAT-file otherwise; any other (non-structure) value is saved under the name
%       'data'. The test checks the variable name, the round-trip of the saved value and the
%       MAT-file version written in the file header (the text 'MATLAB 5.0 MAT-file' or
%       'MATLAB 7.3 MAT-file' at the start of the file, documented by MathWorks).
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/parsave.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built structures and arrays saved in a temporary
%     folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A structure without a rxns field is silently not saved
%       SEVERITY: limitation
%       TRIGGER: parsave(fullfile(tempname, 'x.mat'), struct('a', 1))
%       OBSERVED: no file is written and no warning or error is raised (the isfield test on
%         line 15 has no else branch)
%       EXPECTED: per the header ('Saves a data variable (e.g., model)'), the structure is
%         saved; the callers in the toolbox pass only models or cell arrays
%       LINES: 15
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParsave'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% all files are written to a temporary folder that is removed at the end
tmpFolder = tempname;
mkdir(tmpFolder);

%% a model with fewer than 300000 reactions is saved as 'model' in a version 7 MAT-file

smallModel = struct('rxns', {{'R1'; 'R2'}}, 'mets', {{'A'; 'B'}}, 'S', sparse([1 0; -1 1]));
smallFile = fullfile(tmpFolder, 'smallModel.mat');
parsave(smallFile, smallModel);
% exactly one variable, named 'model', holding the input unchanged (exact round trip)
fileVars = whos('-file', smallFile);
assert(isequal({fileVars.name}, {'model'}));
loaded = load(smallFile);
assert(isequal(loaded.model, smallModel));
% the header text gives the MAT-file version (version 7 files start with 'MATLAB 5.0')
fid = fopen(smallFile, 'r');
headerText = fread(fid, [1 19], '*char');
fclose(fid);
assert(strcmp(headerText, 'MATLAB 5.0 MAT-file'));

%% a model with 300000 reactions or more is saved as 'model' in a version 7.3 MAT-file

% only length(model.rxns) is read, so a sparse column of 300000 entries reaches the
% branch with a file of a few kilobytes
largeModel = struct('rxns', sparse(300000, 1));
largeFile = fullfile(tmpFolder, 'largeModel.mat');
parsave(largeFile, largeModel);
fileVars = whos('-file', largeFile);
assert(isequal({fileVars.name}, {'model'}));
loaded = load(largeFile);
assert(isequal(loaded.model, largeModel));
fid = fopen(largeFile, 'r');
headerText = fread(fid, [1 19], '*char');
fclose(fid);
assert(strcmp(headerText, 'MATLAB 7.3 MAT-file'));

%% any value that is not a structure is saved under the name 'data'

% a cell array of solutions, as analyseObjectiveShadowPrices passes it
cellValue = {struct('f', 1.5); {}};
cellFile = fullfile(tmpFolder, 'cellValue.mat');
parsave(cellFile, cellValue);
fileVars = whos('-file', cellFile);
assert(isequal({fileVars.name}, {'data'}));
loaded = load(cellFile);
assert(isequal(loaded.data, cellValue));

% a numeric matrix
numericValue = magic(4);
numericFile = fullfile(tmpFolder, 'numericValue.mat');
parsave(numericFile, numericValue);
loaded = load(numericFile);
assert(isequal(fieldnames(loaded), {'data'}) && isequal(loaded.data, numericValue));

%% clean up

rmdir(tmpFolder, 's');

% change the directory
cd(currentDir)
