% The COBRAToolbox: testRenameDREAMOutputFiles.m
%
% Purpose:
%     - renameDREAMOutputFiles copies the RXN files returned by the DREAM atom-mapping server,
%       which are named by job ID, to files named after the original reactions. The mapping
%       is read from messages.txt in the input folder, lines of the form
%       'The reaction mapping has been completed for "<zipfile>/<name>" (ID <id>) with 2D
%       input data.'. The test builds such a folder by hand (two mapped reactions, a line of
%       another zip file and an unrelated line) and checks that exactly the two mapped files
%       are written under their original names with the content of the DREAM files; the zip
%       file name with and without '.zip', folder names with and without a trailing file
%       separator, and a messages.txt without any mapping (nothing written).
%
% Function under test:
%     src/dataIntegration/fluxomics/atomTransition/renameDREAMOutputFiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, no server; hand-written files in a temporary folder.
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
fileDir = fileparts(which('testRenameDREAMOutputFiles'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% all files of this test live in a temporary folder removed at the end
workFolder = tempname;
inFolder = [workFolder filesep 'dreamOutput'];
outFolder = [workFolder filesep 'renamed'];
mkdir(inFolder);
mkdir(outFolder);

% the DREAM output: messages.txt and one RXN file per job ID (a third file is not mapped)
messages = sprintf(['Job started.\n', ...
    'The reaction mapping has been completed for "rxnFiles/PGI" (ID 1001) with 2D input data.\n', ...
    'The reaction mapping has been completed for "otherZip/TPI" (ID 1003) with 2D input data.\n', ...
    'The reaction mapping has been completed for "rxnFiles/FBA" (ID 1002) with 2D input data.\n']);
fid = fopen([inFolder filesep 'messages.txt'], 'w');
fprintf(fid, '%s', messages);
fclose(fid);
rxnContents = {sprintf('$RXN\nPGI mapped\n  1  1\n'), sprintf('$RXN\nFBA mapped\n  1  2\n'), ...
    sprintf('$RXN\nTPI mapped\n  1  1\n')};
jobIds = {'1001', '1002', '1003'};
for k = 1:3
    fid = fopen([inFolder filesep jobIds{k} '.rxn'], 'w');
    fprintf(fid, '%s', rxnContents{k});
    fclose(fid);
end

%% the mapped files are copied under their original names, with the same content

% zip file name with its extension, folders without a trailing separator
renameDREAMOutputFiles('rxnFiles.zip', inFolder, outFolder);
writtenFiles = dir([outFolder filesep '*.rxn']);
assert(isequal(sort({writtenFiles.name}), {'FBA.rxn', 'PGI.rxn'}));
% the content is copied exactly
assert(strcmp(fileread([outFolder filesep 'PGI.rxn']), rxnContents{1}));
assert(strcmp(fileread([outFolder filesep 'FBA.rxn']), rxnContents{2}));
% the input files are left in place
assert(all(isfile(strcat(inFolder, filesep, jobIds, '.rxn'))));

%% zip file name without extension and folders with a trailing separator give the same files

delete([outFolder filesep '*.rxn']);
renameDREAMOutputFiles('rxnFiles', [inFolder filesep], [outFolder filesep]);
writtenFiles = dir([outFolder filesep '*.rxn']);
assert(isequal(sort({writtenFiles.name}), {'FBA.rxn', 'PGI.rxn'}));
assert(strcmp(fileread([outFolder filesep 'FBA.rxn']), rxnContents{2}));

%% a zip file name that does not occur in messages.txt: nothing is written

delete([outFolder filesep '*.rxn']);
renameDREAMOutputFiles('unknownZip.zip', inFolder, outFolder);
assert(isempty(dir([outFolder filesep '*.rxn'])));

% remove the temporary folder
rmdir(workFolder, 's');

% change the directory
cd(currentDir)
