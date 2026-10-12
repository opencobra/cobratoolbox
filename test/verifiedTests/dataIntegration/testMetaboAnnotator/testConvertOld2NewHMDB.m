% The COBRAToolbox: testConvertOld2NewHMDB.m
%
% Purpose:
%     - convertOld2NewHMDB converts old-style HMDB metabolite IDs (HMDB plus 5 digits) to the new
%     style with 7 digits.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Identifiers of 12 or more characters give an empty result
%       SEVERITY: limitation
%       TRIGGER: an identifier with 12 or more characters, for example HMDB00012345
%       OBSERVED: the result is an empty text instead of the identifier
%       EXPECTED: the identifier returned unchanged or an error
%       LINES: 19-28
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertOld2NewHMDB'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% old-style identifiers are padded with zeros to 7 digits

assert(strcmp(convertOld2NewHMDB('HMDB1234'), 'HMDB0001234'));
assert(strcmp(convertOld2NewHMDB('HMDB00001'), 'HMDB0000001'));

%% identifiers that already have 7 digits are returned unchanged

assert(strcmp(convertOld2NewHMDB('HMDB0001234'), 'HMDB0001234'));

%% an identifier without the prefix gets it (the digits are padded)

assert(strcmp(convertOld2NewHMDB('12'), 'HMDB0000012'));

% change the directory
cd(currentDir)
