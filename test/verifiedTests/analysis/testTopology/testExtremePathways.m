% The COBRAToolbox: testExtremePathways.m
%
% Purpose:
%     - testExtremePathways tests the functionality of lsr and extremePathways.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/extremePathways.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - hand-built toy network, no optimisation solver; needs the external lrs program.
%     All lrs input and output files are written to a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Sylvain Arreckx March 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Test problem from
%     Extreme Pathway Lengths and Reaction Participation in Genome-Scale Metabolic Networks
%     Jason A. Papin, Nathan D. Price and Bernhard Ø. Palsson
%     Farid Zare 2026/04/02 Improved results comparison


[status, result] = system('which lrs');

global CBT_MISSING_REQUIREMENTS_ERROR_ID;

solverPkgs = prepareTest('requiredSoftwares', {'lrs'});

if isempty(strfind(result, '/lrs'))  % Which returns the path with /!
    % This test will be skipped since there are Requirements (LRS) missing.
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, 'lrs was not properly installed on your system');
end

[status, result] = system('locate /usr/local/opt/gmp/lib/libgmp.10.dylib');
if status==0 
    % This test will be skipped since there are Requirements (LRS) missing.
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, 'lrs was not properly installed on your system. Missing /usr/local/opt/gmp/lib/libgmp.10.dylib');
end

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExtremePathways'));
cd(fileDir);
figsBefore = findall(0, 'Type', 'figure');
model = createExtremePathwayModel();

% extremePathways writes its lrs files to the current folder: use a temporary one
workDir = tempname;
mkdir(workDir);
fakeLrsDir = tempname;
mkdir(fakeLrsDir);
systemPath = getenv('PATH');
restoreState = onCleanup(@() restoreSystemState(currentDir, systemPath, {workDir, fakeLrsDir}));
cd(workDir);

minimalModel = struct();
minimalModel.S = model.S;

% calculates the matrix of extreme pathways, P
[P, V] = extremePathways(minimalModel);

refP = [2, 2, 2;
        1, 0, 1;
        0, 1, 0;
        0, 1, 1;
        0, 0, 1;
        1, 0, 0;
        2, 2, 2;
        1, 1, 1;
        1, 1, 1];

expectedP = refP(:, [2, 1, 3]);
expectedPSorted = sortrows(full(expectedP));
actualPSorted = sortrows(full(P));
assert(isequal(expectedPSorted, actualPSorted), ...
    ['ExtremePathways mismatch (case 1).\nExpected:\n%s\nActual:\n%s\n' ...
     'Sorted(Expected):\n%s\nSorted(Actual):\n%s'], ...
    mat2str(expectedP), mat2str(P), mat2str(expectedPSorted), mat2str(actualPSorted))
minimalExpectedSorted = expectedPSorted;

positivity = 0;
inequality = 1;

[P, V] = extremePathways(model, positivity, inequality);

refP = [0,  0, 2;
        1,  1, 0;
        -1, -1, 1;
        0, -1, 1;
        1,  0, 0;
        0,  1, 0;
        0,  0, 2;
        0,  0, 1;
        0,  0, 1];

expectedPSorted = sortrows(full(refP));
actualPSorted = sortrows(full(P));
assert(isequal(expectedPSorted, actualPSorted), ...
    ['ExtremePathways mismatch (case 2).\nExpected:\n%s\nActual:\n%s\n' ...
     'Sorted(Expected):\n%s\nSorted(Actual):\n%s'], ...
    mat2str(refP), mat2str(P), mat2str(expectedPSorted), mat2str(actualPSorted))

% Change the model to have one non integer entry.
model.S(1, 1) = 0.5;
assert(verifyCobraFunctionError('extremePathways','inputs',{model}));

% delete generated files
delete('*.ine');
delete('*.ext');

% close only figures opened during this test
figsAfter = findall(0, 'Type', 'figure');
figsToClose = setdiff(figsAfter, figsBefore);
if ~isempty(figsToClose)
    close(figsToClose);
end

%% model.description names the lrs files, here with the default positivity and an equality
namedModel = struct('S', minimalModel.S, 'description', 'toyNetwork');
namedPathways = extremePathways(namedModel);
assert(isequal(sortrows(full(namedPathways)), minimalExpectedSorted));
assert(isfile('toyNetwork_pos_eq.ine') && isfile('toyNetwork_pos_eq.ext'), ...
    'The lrs files must be named after model.description.');
delete('toyNetwork_pos_eq.*');

% The next three sections replace the lrs program with a script found first on the PATH, or
% hide it. These are the only ways to see a failing, missing or wrong lrs.
if isunix
    %% lrs failing is an error naming the input file
    writeFakeLrs(fakeLrsDir, 'exit 1\n');
    setenv('PATH', [fakeLrsDir pathsep systemPath]);
    failedMessage = '';
    try
        extremePathways(minimalModel);
    catch ME
        failedMessage = ME.message;
    end
    setenv('PATH', systemPath);
    assert(contains(failedMessage, 'lsr failed on file') && contains(failedMessage, 'model_pos_eq.ine'), ...
        'A failing lrs must raise an error naming the input file.');

    %% lrs missing from the PATH is an error that says how to install it
    emptyDir = fullfile(workDir, 'nothingHere');
    mkdir(emptyDir);
    setenv('PATH', emptyDir);
    missingMessage = '';
    try
        extremePathways(minimalModel);
    catch ME
        missingMessage = ME.message;
    end
    setenv('PATH', systemPath);
    assert(contains(missingMessage, 'lrs is not installed'), ...
        'A missing lrs must raise an error that says so.');

    %% A ray outside the nullspace of S is reported, and still returned
    writeFakeLrs(fakeLrsDir, ['cat <<EOF\nV-representation\nbegin\n***** 10 rational\n' ...
        ' 0 1 0 0 0 0 0 0 0 0\nend\nEOF\n']);
    setenv('PATH', [fakeLrsDir pathsep systemPath]);
    lastwarn('');
    wrongRay = extremePathways(minimalModel);
    setenv('PATH', systemPath);
    assert(isequal(full(wrongRay), [1; zeros(8, 1)]));
    assert(contains(lastwarn, 'pathway not in nullspace'), ...
        'A ray outside the nullspace must raise a warning.');
end

function writeFakeLrs(fakeLrsDir, scriptBody)
% Write an executable called lrs that runs scriptBody.
fid = fopen(fullfile(fakeLrsDir, 'lrs'), 'w');
fprintf(fid, ['#!/bin/sh\n' scriptBody]);
fclose(fid);
fileattrib(fullfile(fakeLrsDir, 'lrs'), '+x');
end

% restore the folder and PATH, and remove the temporary folders
clear restoreState

function restoreSystemState(folder, systemPath, temporaryFolders)
% Back to the caller's folder and PATH, on every exit from this test, then remove the folders.
cd(folder);
setenv('PATH', systemPath);
cellfun(@(d) rmdir(d, 's'), temporaryFolders);
end
