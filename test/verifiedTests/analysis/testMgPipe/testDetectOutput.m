% The COBRAToolbox: testDetectOutput.m
%
% Purpose:
%     - detectOutput changes the current folder to resPath and returns the position of the
%       file objNam in the list of the .mat files of that folder (as returned by dir), or an
%       empty array when there is no .mat file of exactly that name. The callers (mgPipe,
%       microbiotaModelSimulator, createPersonalizedModel) rely on the change of folder:
%       createPersonalizedModel saves its models with relative file names afterwards. The
%       test builds a temporary folder with three .mat files and one .txt file and checks the
%       position returned, the exact (whole name, extension included) matching, the empty
%       result and the new current folder. Expected positions follow from the alphabetical
%       order of the file names.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/detectOutput.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; small files written to a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDetectOutput'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% results folder with the .mat files a.mat, b.mat, c.mat and the text file b.txt
resFolder = tempname;
mkdir(resFolder);
placeholder = 1;
save(fullfile(resFolder, 'a.mat'), 'placeholder');
save(fullfile(resFolder, 'b.mat'), 'placeholder');
save(fullfile(resFolder, 'c.mat'), 'placeholder');
fid = fopen(fullfile(resFolder, 'b.txt'), 'w');
fprintf(fid, 'not a MAT-file\n');
fclose(fid);
emptyFolder = tempname;
mkdir(emptyFolder);

%% a file that exists: its position in the list of .mat files, and the folder is changed

cd(fileDir);
mapP = detectOutput(resFolder, 'b.mat');
% b.mat is the second of a.mat, b.mat, c.mat (positions are integers, compared exactly)
assert(isequal(mapP, 2));
% the current folder is now the results folder (the documented callers rely on it)
assert(strcmp(pwd, resFolder));
assert(isequal(detectOutput(resFolder, 'c.mat'), 3));

%% exact matching: a prefix, a name without extension or a non-.mat file is not found

assert(isempty(detectOutput(resFolder, 'b')));
assert(isempty(detectOutput(resFolder, 'b.txt')));
assert(isempty(detectOutput(resFolder, 'd.mat')));

%% a folder without any .mat file gives an empty result

assert(isempty(detectOutput(emptyFolder, 'a.mat')));
assert(strcmp(pwd, emptyFolder));

%% clean up

cd(fileDir);
rmdir(resFolder, 's');
rmdir(emptyFolder, 's');

% change the directory
cd(currentDir)
