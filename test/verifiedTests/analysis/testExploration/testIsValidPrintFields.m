% The COBRAToolbox: testIsValidPrintFields.m
%
% Purpose:
%     - isValidPrintFields checks the format of the "fields to print" argument of the surfNet
%     functions: a text, a list of texts, or two such lists (metabolite fields and reaction fields).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/surfNetSubfunctions/isValidPrintFields.m
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
fileDir = fileparts(which('testIsValidPrintFields'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

errorMessageStart = 'Must be (1) a cell array of two cells';

%% valid formats return true

assert(isValidPrintFields('mets') == true);                      % a text
assert(isValidPrintFields({'a', 'b'}) == true);                  % a list of texts
assert(isValidPrintFields("rxns") == true);                      % a string
assert(isValidPrintFields({{'a'}, {'b', 'c'}}) == true);         % two lists: metabolite and reaction fields

%% invalid formats raise an explanatory error

errorCaught = false;
try
    isValidPrintFields(5);
catch exception
    errorCaught = startsWith(exception.message, errorMessageStart);
end
assert(errorCaught);

% two cells, one of which is not a list of texts
errorCaught = false;
try
    isValidPrintFields({{'a'}, 5});
catch exception
    errorCaught = startsWith(exception.message, errorMessageStart);
end
assert(errorCaught);

% change the directory
cd(currentDir)
