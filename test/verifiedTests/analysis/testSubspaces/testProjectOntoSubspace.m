% The COBRAToolbox: testProjectOntoSubspace.m
%
% Purpose:
%     - projectOntoSubspace splits fluxes (vf, vr, net flux) into their null-space and row-space
%     parts and potentials (u, u0, log concentration) into their column-space and left-null-space
%     parts of a matrix A, using the Moore-Penrose pseudoinverse.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: The forward flux is
%       not projected onto the row space; Omitting the row or column selection makes the call fail;
%       The two consistency checks only catch one direction.
%
% Function under test:
%     src/analysis/subspaces/subspaceProjection/projectOntoSubspace.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 95-96, 102-103, 109-110, 116-117, 123-124 and 130-131 of projectOntoSubspace.m (the defaults of
%     u, u0, lnx, vf, vr and vnet) are never reached: those arguments are used earlier in the function,
%     so a call that omits them errors first. All other lines are reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testProjectOntoSubspace'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for the projections: a pseudoinverse of a 2 x 3 matrix, so rounding is far below 1e-10
tol = 1e-10;

A = [1 1 0; 0 1 1];                       % 2 x 3, rank 2
vnet = [1; 2; 3];
vf = [2; 3; 4];
vr = vf - vnet;                           % forward - reverse = net
u = [1; 2];
u0 = [0.5; 1];
lnx = u - u0;                             % chemical potential = standard potential + log concentration
allRows = true(2, 1);
allColumns = true(3, 1);

% projectors computed here from the pseudoinverse (independent of the function)
rowSpace = pinv(A) * A;                   % onto the row space
nullSpace = eye(3) - rowSpace;            % onto the null space
columnSpace = A * pinv(A);                % onto the column space
leftNullSpace = eye(2) - columnSpace;     % onto the left null space

%% fluxes: net flux and reverse flux are split into null-space and row-space parts

[vfN, vfR, vrN, vrR, vnetN, vnetR] = projectOntoSubspace(A, vf, vr, vnet, u, u0, lnx, 0, allRows, allColumns);
assert(norm(vnetN - nullSpace * vnet) < tol);
assert(norm(vnetR - rowSpace * vnet) < tol);
assert(norm(vnetN + vnetR - vnet) < tol);
assert(norm(A * vnetN) < tol);              % the null-space part is in the null space
assert(norm(vrN - nullSpace * vr) < tol);
assert(norm(vrR - rowSpace * vr) < tol);
% the forward flux is split in the same way: vfR = PR*vf and vfN + vfR = vf
assert(norm(vfN - nullSpace * vf) < tol);
assert(norm(vfR - rowSpace * vf) < tol);
assert(norm(vfN + vfR - vf) < tol);

%% potentials and log concentrations: column-space and left-null-space parts

[~, ~, ~, ~, ~, ~, uL, uC, u0L, u0C, lnxL, lnxC] = projectOntoSubspace(A, vf, vr, vnet, u, u0, lnx, 0, allRows, allColumns);
assert(norm(uC - columnSpace * u) < tol && norm(uL - leftNullSpace * u) < tol);
assert(norm(u0C - columnSpace * u0) < tol && norm(u0L - leftNullSpace * u0) < tol);
assert(norm(lnxC - columnSpace * lnx) < tol && norm(lnxL - leftNullSpace * lnx) < tol);
% A has full row rank, so the left null space is {0}
assert(norm(uL) < tol);

%% empty optional inputs are skipped

[vfN, ~, vrN, ~, vnetN, vnetR] = projectOntoSubspace(A, [], [], vnet, [], [], [], 0, allRows, allColumns);
assert(norm(vnetN - nullSpace * vnet) < tol && norm(vnetR - rowSpace * vnet) < tol);
assert(all(isnan(vfN)) && all(isnan(vrN)));

%% the defaults of the print level and of the row and column selection (reachable when vf and lnx are empty)

[~, ~, ~, ~, vnetN, vnetR] = projectOntoSubspace(A, [], [], vnet, u, u0, []);
assert(norm(vnetN - nullSpace * vnet) < tol && norm(vnetR - rowSpace * vnet) < tol);

%% the defaults of the row and column selection are used with a non-empty forward flux

% without rowBool and colBool: every row and column is projected
[vfN, vfR, ~, ~, vnetN, vnetR, uL, uC] = projectOntoSubspace(A, vf, vr, vnet, u, u0, lnx);
assert(norm(vfN - nullSpace * vf) < tol && norm(vfR - rowSpace * vf) < tol);
assert(norm(vnetN - nullSpace * vnet) < tol && norm(vnetR - rowSpace * vnet) < tol);
assert(norm(uC - columnSpace * u) < tol && norm(uL - leftNullSpace * u) < tol);
% with rowBool but without colBool
[vfN, vfR] = projectOntoSubspace(A, vf, vr, vnet, u, u0, lnx, 0, allRows);
assert(norm(vfN - nullSpace * vf) < tol && norm(vfR - rowSpace * vf) < tol);

%% inconsistent inputs are rejected

% net flux different from forward minus reverse flux
errorCaught = false;
try
    projectOntoSubspace(A, [0; 0; 0], [0; 0; 0], vnet, u, u0, lnx, 0, allRows, allColumns);
catch exception
    errorCaught = contains(exception.message, 'Net flux does not equal the difference between forward and reverse flux');
end
assert(errorCaught);
% potential different from standard potential plus log concentration
errorCaught = false;
try
    projectOntoSubspace(A, vf, vr, vnet, u, u0, [0; 0], 0, allRows, allColumns);
catch exception
    errorCaught = contains(exception.message, 'Chemical potential does not equal');
end
assert(errorCaught);
% a negative difference is rejected as well: the net flux is smaller than forward minus reverse
assert(verifyCobraFunctionError('projectOntoSubspace', 'inputs', {A, vf, vr, vnet - 1, u, u0, lnx, 0, allRows, allColumns}, ...
    'testMessage', 'Net flux does not equal the difference between forward and reverse flux'));
% and so is u - u0 - lnx below zero
assert(verifyCobraFunctionError('projectOntoSubspace', 'inputs', {A, vf, vr, vnet, u, u0, lnx + 1, 0, allRows, allColumns}, ...
    'testMessage', 'Chemical potential does not equal standard chemical potential plus logarithmic conc.'));

% change the directory
cd(currentDir)
