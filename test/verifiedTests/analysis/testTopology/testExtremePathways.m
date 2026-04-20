% The COBRAToolbox: testExtremePathways.m
%
% Purpose:
%     - testExtremePathways tests the functionality of lsr and extremePathways.
%
% Authors:
%     - Sylvain Arreckx March 2017
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

% change the directory
cd(currentDir)
