% The COBRAToolbox: testCompile.m
%
% Purpose:
%     - compile builds a C++ MEX file with the selected C++ MEX compiler (MSVC, Clang or g++)
%       from one or more sources, adding the include folders and the BarrierRound utils
%       folder, with the options std (C++ standard, default c++17), debug (-g) and fmath
%       (fast-math). The test compiles a small MEX source, written to a tempname folder, into
%       that folder (never into src/) and calls the result: the MEX returns the value of
%       __cplusplus, whether __FAST_MATH__ is defined, and a constant from a header in the
%       include folder, so the effect of each option is checked by the compiler itself
%       (__cplusplus is 201703 for C++17, 202002 for C++20, 201402 for C++14). Without a C++
%       MEX compiler, the test checks the documented error instead.
%
% Function under test:
%     src/analysis/sampling/BarrierRound/utils/compile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written C++ source in a tempname folder. A C++ MEX
%     compiler is used when one is selected (mex -setup C++).
%
% Coverage exemptions:
%     Line 35: needs a machine without a selected C++ MEX compiler (reached by the test
%     there); lines 49-50: MSVC compiler (Windows); lines 52-53: Clang compiler (macOS);
%     line 58: needs a selected compiler other than MSVC, Clang or g++. The reference machine
%     uses g++; mex.getCompilerConfigurations is a built-in method and cannot be replaced by
%     a stub on the path.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompile'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the MEX source and a header in a separate include folder, both in a tempname folder; the
% compiled files go to the same folder, which is the current folder while compiling
sandboxDir = tempname;
includeDir = fullfile(sandboxDir, 'include');
mkdir(includeDir);
sourceFile = fullfile(sandboxDir, 'probeOptions.cpp');
writeTextFile(fullfile(includeDir, 'probeConstant.h'), {'#define PROBE_CONSTANT 42.0'});
writeTextFile(sourceFile, {'#include "mex.h"'; '#include "probeConstant.h"'; ...
    'void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])'; '{'; ...
    '    double fastMath = 0;'; '#ifdef __FAST_MATH__'; '    fastMath = 1;'; '#endif'; ...
    '    plhs[0] = mxCreateDoubleScalar((double) __cplusplus);'; ...
    '    plhs[1] = mxCreateDoubleScalar(fastMath);'; ...
    '    plhs[2] = mxCreateDoubleScalar(PROBE_CONSTANT);'; '}'});
% a source without the header, for the call without include folders
plainSourceFile = fullfile(sandboxDir, 'probePlain.cpp');
writeTextFile(plainSourceFile, {'#include "mex.h"'; ...
    'void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])'; '{'; ...
    '    plhs[0] = mxCreateDoubleScalar((double) __cplusplus);'; '}'});
cd(sandboxDir);
pathBefore = path;
addpath(sandboxDir);

selectedCompiler = mex.getCompilerConfigurations('C++', 'Selected');

if isempty(selectedCompiler)
    %% no C++ MEX compiler: the documented error

    assert(verifyCobraFunctionError('compile', 'inputs', {fullfile(sandboxDir, 'probePlain'), plainSourceFile}, ...
        'testMessage', 'No C++ mex compiler is available.'));
elseif ~any(contains(selectedCompiler.ShortName, {'MSVCPP', 'Clang++', 'g++'}))
    %% an unsupported compiler: the documented error

    assert(verifyCobraFunctionError('compile', 'inputs', {fullfile(sandboxDir, 'probePlain'), plainSourceFile}, ...
        'testMessage', 'Currently, we only support MSVCPP, Clang++ or g++ as the compiler.'));
else
    %% defaults: one source as a character vector, no include folder, C++17, no fast-math

    compile(fullfile(sandboxDir, 'probePlain'), plainSourceFile);
    assert(exist('probePlain', 'file') == 3);
    % __cplusplus is an integer constant, so the comparison is exact
    assert(probePlain() == 201703);

    %% include folder as a character vector, std c++20, fast-math and debug symbols

    compile(fullfile(sandboxDir, 'probeFast'), {sourceFile}, includeDir, ...
        struct('std', 'c++20', 'fmath', true, 'debug', true));
    [cplusplus, fastMath, probeConstant] = probeFast();
    assert(cplusplus == 202002 && fastMath == 1 && probeConstant == 42);

    %% include folders as a cell array, std c++14, fast-math off

    compile(fullfile(sandboxDir, 'probeStd'), sourceFile, {includeDir}, struct('std', 'c++14'));
    [cplusplus, fastMath, probeConstant] = probeStd();
    assert(cplusplus == 201402 && fastMath == 0 && probeConstant == 42);
end

%% clean up: MEX files released, path, temporary folder and directory restored

clear mex
path(pathBefore);
cd(fileDir);
rmdir(sandboxDir, 's');

% change the directory
cd(currentDir)

function writeTextFile(fileName, textLines)
% write each line followed by a newline
fid = fopen(fileName, 'w');
fprintf(fid, '%s\n', textLines{:});
fclose(fid);
end
