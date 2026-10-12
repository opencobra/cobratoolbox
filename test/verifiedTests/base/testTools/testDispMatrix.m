% The COBRAToolbox: testDispMatrix.m
%
% Purpose:
%     - dispMatrix prints a matrix of integers in one of several layouts (MATLAB display, plain,
%     aligned, with or without all-zero rows and columns).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/utilities/dispMatrix.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDispMatrix'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the printed text is captured with evalc, which is the only way to read it (Constitution VII-A);
% the captured text uses the unique variable name printedText
exampleMatrix = [1 -20; 0 300];

%% plain layout 'N': values separated by a space

printedText = evalc('dispMatrix(exampleMatrix, ''N'')');
assert(strcmp(printedText, sprintf('1 -20 \n0 300 \n')));

%% aligned layout 'Z' (the default): every column as wide as the largest value (and the sign)

printedText = evalc('dispMatrix(exampleMatrix, ''Z'')');
assert(strcmp(printedText, sprintf('    1  -20\n    0  300\n')));
printedText = evalc('dispMatrix(exampleMatrix)');
assert(strcmp(printedText, sprintf('    1  -20\n    0  300\n')));

%% MATLAB's own display

printedText = evalc('dispMatrix(exampleMatrix, ''disp'')');
assert(contains(printedText, '300') && contains(printedText, '-20'));

%% layouts without all-zero rows and columns

sparseLooking = [1 0 0; 0 0 0; 0 5 0];
printedText = evalc('dispMatrix(sparseLooking, ''nonzeroN'')');
assert(strcmp(printedText, sprintf('1 0 \n0 5 \n')));
printedText = evalc('dispMatrix(sparseLooking, ''nonzeroZ'')');
assert(strcmp(printedText, sprintf(' 1 0\n 0 5\n')));

%% an unknown layout prints nothing

printedText = evalc('dispMatrix(exampleMatrix, ''unknown'')');
assert(isempty(printedText));

% change the directory
cd(currentDir)
