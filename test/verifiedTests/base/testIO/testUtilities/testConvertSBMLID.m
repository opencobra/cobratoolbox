% The COBRAToolbox: testConvertSBMLID.m
%
% Purpose:
%     - convertSBMLID converts text to a valid SBML identifier (every character other than letters,
%     digits and _ becomes __code__) and back; the reverse direction also knows the older _DASH_-
%     style names.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/io/utilities/SBML/convertSBMLID.m
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
fileDir = fileparts(which('testConvertSBMLID'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% to SBML (the default): characters that are not allowed become __ASCII code__

assert(strcmp(convertSBMLID('a-b[c]'), 'a__45__b__91__c__93__'));
assert(strcmp(convertSBMLID('abc_1'), 'abc_1'));                   % allowed characters are kept
assert(isequal(convertSBMLID({'a b', 'c'}), {'a__32__b', 'c'}));   % lists of text work too

%% back from SBML

assert(strcmp(convertSBMLID('a__45__b__91__c__93__', false), 'a-b[c]'));
% round trip
original = 'glc-D[e] (x)';
assert(strcmp(convertSBMLID(convertSBMLID(original), false), original));

%% older spellings are also converted back

assert(strcmp(convertSBMLID('a_DASH_b_LPAREN_c_RPAREN_', false), 'a-b(c)'));
assert(strcmp(convertSBMLID('x_FSLASH_y_BSLASH_z_LSQBKT_1_RSQBKT__COMMA__PERIOD__APOS_-DASH-', false), 'x/y\z[1],.''-'));

% change the directory
cd(currentDir)
