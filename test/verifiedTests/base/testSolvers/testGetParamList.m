% The COBRAToolbox: testGetParamList.m
%
% Purpose:
%     - getParamList lists the parameters of a nested CPLEX parameter structure and their dotted
%     paths: a parameter is a structure that holds Cur (or Min, Max, Def, ...) below the top level.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/cplex/getParamList.m
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
fileDir = fileparts(which('testGetParamList'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% parameters shared by the first two sections
parameters.simplex.display.Cur = 1;
parameters.simplex.tolerances.Cur = 2;
parameters.mip.Cur = 3;
parameters.timelimit = 4;                      % a top-level value is not a parameter group

%% parameters in nested structures (leaves of the top level are not parameters)

[paramList, paramPath, addCur] = getParamList(parameters, false);
assert(isequal(paramList, {'display'; 'tolerances'; 'mip'}));
assert(isequal(paramPath, {'simplex.display'; 'simplex.tolerances'; 'mip'}));
assert(isequal(addCur, [false; false; false]));

%% going to the bottom level: user-supplied parameters with a Cur field

[paramList, paramPath, addCur] = getParamList(parameters, true);
assert(isequal(paramList, {'display'; 'tolerances'; 'mip'; 'timelimit'}));
assert(isequal(paramPath, {'simplex.display'; 'simplex.tolerances'; 'mip'; 'timelimit'}));
% '.Cur' was the bottom level of the first three; timelimit was a plain value
assert(isequal(addCur, [true; true; true; false]));

%% several fields under one parameter give that parameter once

nested.a.b.Cur = 1;
nested.a.b.Min = 0;
nested.c = 5;
[paramList, paramPath] = getParamList(nested, false);
assert(isequal(paramList, {'b'}) && isequal(paramPath, {'a.b'}));

%% a top-level value before the parameters is skipped

[paramList, paramPath] = getParamList(struct('t', 3, 'x', struct('y', struct('Cur', 1))), false);
assert(isequal(paramList, {'y'}) && isequal(paramPath, {'x.y'}));

%% empty structures are skipped

% an empty structure first, in the middle and last
[paramList, paramPath] = getParamList(struct('s', struct(), 'x', struct('y', struct('Cur', 1))), false);
assert(isequal(paramList, {'y'}) && isequal(paramPath, {'x.y'}));
[paramList, paramPath] = getParamList(struct('x', struct('y', struct('Cur', 1)), 's', struct()), false);
assert(isequal(paramList, {'y'}) && isequal(paramPath, {'x.y'}));
[paramList, paramPath] = getParamList(struct('x', struct('e', struct(), 'y', struct('Cur', 1))), false);
assert(isequal(paramList, {'y'}) && isequal(paramPath, {'x.y'}));
[paramList, paramPath] = getParamList(struct('x', struct('y', struct('Cur', 1), 'e', struct())), false);
assert(isequal(paramList, {'y'}) && isequal(paramPath, {'x.y'}));

% change the directory
cd(currentDir)
