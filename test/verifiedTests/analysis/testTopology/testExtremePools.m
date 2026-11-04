% The COBRAToolbox: testExtremePools.m
%
% Purpose:
%     - testExtremePools tests the functionality of lsr and extremePools.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/extremePools.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - hand-built toy network, no optimisation solver; needs the external lrs program.
%     Every lrs input and output file is written to a temporary folder, because extremePools
%     writes to, and deletes *.ine, *.ext, *.sh and *.time from, the current folder.
%
% Coverage exemptions:
%     Line 68: unreachable, every branch above it leaves model.SIntRxnBool defined, so the else of the isfield test never runs.
%     Lines 80-87, 92-153: the bodies of two `if 0` blocks (disabled row reduction and old lrs interface).
%     Line 162: unreachable, param is created at the top of the function, so the ~exist test is always false.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model with mets but no usable SIntRxnBool stops on an undefined variable
%       SEVERITY: error
%       TRIGGER: extremePools(model) with model.mets and without model.SIntRxnBool or model.SIntMetBool, or with either of them of the wrong length
%       OBSERVED: error "Unrecognized function or variable 'printLevel'": findSExRxnInd is called with printLevel-1, and printLevel is never defined
%       EXPECTED: the exchange reactions are found heuristically, as the comments say, and the extreme pools are returned
%       LINES: 55, 62
%     - DEFECT: The third output is the transpose of what the help text states
%       SEVERITY: cosmetic
%       TRIGGER: any call, for example [P, vertexBool, N] = extremePools(model) with model.SConsistentRxnBool
%       OBSERVED: N is the n x m matrix S', and P*N' = 0 holds
%       EXPECTED: the help text states an m x n matrix N such that P*N = 0
%       LINES: 44
%
% Authors:
%     - Modified for CI integration - Thomas Pfau
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Test problem from
%     Extreme Pathway Lengths and Reaction Participation in Genome-Scale Metabolic Networks
%     Jason A. Papin, Nathan D. Price and Bernhard Ø. Palsson

solverPkgs = prepareTest('requiredSoftwares', {'lrs'});

[status, result] = system('which lrs');

global CBT_MISSING_REQUIREMENTS_ERROR_ID;

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

%Generate the test model an set up the fields.
cd(fileparts(which('testExtremePools.m')));
model = createExtremePathwayModel();
model = findSExRxnInd(model);

% extremePools writes and deletes lrs files in the current folder: use a temporary one
workDir = tempname;
mkdir(workDir);
fakeLrsDir = tempname;
mkdir(fakeLrsDir);
systemPath = getenv('PATH');
figuresBefore = findall(0, 'Type', 'figure');
restoreState = onCleanup(@() restoreSystemState(currentDir, systemPath, {workDir, fakeLrsDir}));
cd(workDir);

% Extreme pools:
Pools = [0     0     0     1     0     0     1;...
         1     1     0     0     0     2     0;...
         1     1     2     2     2     0     0];      

fprintf('%s\n','Testing Extreme pools')

% %calculates the matrix of extreme pools
% [status, result] = system('which lrs');
% assert( ~isempty(strfind(result, '/lrs')),'lrs was not properly installed on your system'); %Which returns the path with / !

[CalculatedPools]=extremePools(model);    
assert(isequal(full(CalculatedPools),Pools));

%% A model that states its consistent reactions: those columns are used, and N is their transpose
consistentModel = model;
consistentModel.SConsistentRxnBool = model.SIntRxnBool;
[poolsConsistent, vertexBool, N] = extremePools(consistentModel);
assert(isequal(sortrows(full(poolsConsistent)), sortrows(Pools)));
assert(isequal(N, model.S(:, model.SIntRxnBool)'));
assert(~any(vertexBool), 'The cone of a homogeneous system has rays only, no vertex.');
assert(all(all(poolsConsistent * N' == 0)), 'Each extreme pool must lie in the left nullspace.');

%% A model with S only: every row and column counts as internal, so exchange reactions leave one pool
sOnlyPools = extremePools(struct('S', model.S));
assert(isequal(full(sOnlyPools), [0 0 0 1 0 0 1]), ...
    'With the exchange reactions kept, only the F and G pool has no boundary flux.');

%% model.description names the lrs files, and param.debug keeps them
namedModel = model;
namedModel.description = 'toyNetwork';
namedPools = extremePools(namedModel, struct('debug', 1));
assert(isequal(full(namedPools), Pools));
assert(isfile('toyNetwork.ine') && isfile('toyNetwork.ext'), 'param.debug = 1 must keep the lrs files.');
delete('toyNetwork*');

%% Without param.debug the generated files are deleted
extremePools(namedModel);
assert(isempty(dir('toyNetwork*')), 'The lrs files must be deleted by default.');

%% Non-integer stoichiometric coefficients are refused
fractionalModel = model;
fractionalModel.S(1, 1) = 0.5;
assert(verifyCobraFunctionError('extremePools', 'inputs', {fractionalModel}, ...
    'testMessage', 'Stoichiometric coefficients must be all integers'));
close(setdiff(findall(0, 'Type', 'figure'), figuresBefore));

%% A ray outside the left nullspace is reported: lrs is replaced by a script that returns one
% lrs is exact, so this guard can only be seen with a program that returns a wrong ray
if isunix
    fid = fopen(fullfile(fakeLrsDir, 'lrs'), 'w');
    fprintf(fid, '#!/bin/sh\ncat <<EOF\nV-representation\nbegin\n***** 8 rational\n');
    fprintf(fid, ' 0 1 0 0 0 0 0 0\nend\nEOF\n');
    fclose(fid);
    fileattrib(fullfile(fakeLrsDir, 'lrs'), '+x');
    setenv('PATH', [fakeLrsDir pathsep systemPath]);
    lastwarn('');
    wrongPool = extremePools(model);
    setenv('PATH', systemPath);
    assert(isequal(full(wrongPool), [1 0 0 0 0 0 0]));
    assert(contains(lastwarn, 'extreme pool not in left nullspace'), ...
        'A ray outside the left nullspace must raise a warning.');
end

% restore the folder and PATH, and remove the temporary folders
clear restoreState

function restoreSystemState(folder, systemPath, temporaryFolders)
% Back to the caller's folder and PATH, on every exit from this test, then remove the folders.
cd(folder);
setenv('PATH', systemPath);
cellfun(@(d) rmdir(d, 's'), temporaryFolders);
end
