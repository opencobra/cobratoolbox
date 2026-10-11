% The COBRAToolbox: testNumToFormattedString.m
%
% Purpose:
%     - numToFormattedString formats numbers as strings of a limited width, using exponential notation outside a given range of magnitudes.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/surfNetSubfunctions/numToFormattedString.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     For non-scalar input the recursive call passes false as the 4th argument (nChar),
%     so the requested width is ignored for array elements (width 5 is used). The
%     array checks below therefore only use values whose text does not depend on the
%     width.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNumToFormattedString'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% default settings (width 8, exponential outside 1e-6 .. 1e8)

assert(strcmp(numToFormattedString(pi), '3.141593'));     % 8 characters
assert(strcmp(numToFormattedString(123456.789), '123456.8'));
assert(strcmp(numToFormattedString(100.25), '100.25'));    % trailing zeros are removed
assert(strcmp(numToFormattedString(1.50), '1.5'));
assert(strcmp(numToFormattedString(0.5), '0.5'));
assert(strcmp(numToFormattedString(0), '0'));              % zero is never exponential
assert(strcmp(numToFormattedString(12345678), '12345678'));% too wide for decimals: rounded integer

% very large and very small values switch to exponential notation
assert(strcmp(numToFormattedString(1e9), '1.00e+09'));
assert(strcmp(numToFormattedString(1e-7), '1.00e-07'));

% integer classes are converted directly
assert(strcmp(numToFormattedString(int8(7)), '7'));

%% explicit width and magnitude limits

% width 5 and width 3 (raised to the minimum of 5) give the same string
assert(strcmp(numToFormattedString(pi, [], [], 5), '3.142'));
assert(strcmp(numToFormattedString(pi, [], [], 3), '3.142'));
% a larger width gives more decimals
assert(strcmp(numToFormattedString(pi, [], [], 12), '3.1415926536'));
% an upper magnitude limit above the width is lowered to the width: 1e7 >= 10^6 -> exponential
assert(strcmp(numToFormattedString(1e7, -6, 20, 6), '1e+07'));
% a lower magnitude limit too small for the width is raised: 1e-5 < 10^-4 -> exponential
assert(strcmp(numToFormattedString(1e-5, -9, 8, 6), '1e-05'));
% values inside the limits stay in fixed notation
assert(strcmp(numToFormattedString(1e-3, -6, 8, 8), '0.001'));
assert(strcmp(numToFormattedString(1234.5678, [], [], 7), '1234.57'));

%% cell output

% scalar with cellOutput = true is wrapped in a cell
assert(isequal(numToFormattedString(5, [], [], [], true), {'5'}));

% a non-scalar input returns a cell array of strings of the same size (values chosen so
% that the text does not depend on the width, see the header)
formattedArray = numToFormattedString([1.5 1]);
assert(iscell(formattedArray) && isequal(size(formattedArray), [1 2]));
assert(isequal(formattedArray, {'1.5', '1'}));

formattedMatrix = numToFormattedString([1.5 2; 0 3]);
assert(isequal(formattedMatrix, {'1.5', '2'; '0', '3'}));

% change the directory
cd(currentDir)
