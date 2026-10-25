% The COBRAToolbox: testMapAontoBOld.m
%
% Purpose:
%     - mapAontoBOld maps the values of list A onto the keys of list B: the output has one entry per
%     key of B, filled from A for the keys that both lists share.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/mapAontoBOld.m
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
fileDir = fileparts(which('testMapAontoBOld'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% numbers: keys not in A give NaN

mapped = full(mapAontoBOld({'a', 'b', 'c'}, {'b', 'z', 'c'}, [1 2 3]));
assert(isequaln(mapped(:)', [2 NaN 3]));

%% text values: keys not in A give an empty entry

mapped = mapAontoBOld({'a', 'b'}, {'b', 'a', 'q'}, {'X'; 'Y'});
assert(isequal(mapped, {'Y'; 'X'; []}));

%% logical values: keys not in A give false

mapped = mapAontoBOld({'a', 'b'}, {'b', 'a', 'q'}, [true; false]);
assert(isequal(mapped(:)', [false true false]));

%% int64 values behave like numbers

mapped = full(mapAontoBOld({'a', 'b'}, {'b', 'a'}, int64([5; 6])));
assert(isequal(mapped(:)', [6 5]));

%% an existing output Bin is kept for the keys that are not in A

assert(isequal(mapAontoBOld({'a', 'b'}, {'b', 'a', 'q'}, [5; 6], [9; 9; 9]), [6; 5; 9]));

%% other classes are rejected

errorCaught = false;
try
    mapAontoBOld({'a', 'b'}, {'b', 'a'}, single([5; 6]));
catch exception
    errorCaught = strcmp(exception.message, 'unrecognised class');
end
assert(errorCaught);

% change the directory
cd(currentDir)
