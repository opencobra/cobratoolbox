% The COBRAToolbox: testTwoSidedBarrier.m
%
% Purpose:
%     - TwoSidedBarrier is the handle class of the logarithmic barrier
%       phi(x) = - sum log(x - lb) - sum log(ub - x) of the box lb <= x <= ub. The constructor
%       stores the bounds, the indices of the one-sided and free coordinates and a feasible
%       centre; the methods return feasibility, the largest step along a direction, the
%       boundary normals, the gradient, Hessian and third derivative of phi, and quantities
%       derived from them. set_vdim changes the orientation of the stored vectors.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: every expected value below is computed by hand from the formulas of
%       the class for a box with one bounded, one upper-bounded, one lower-bounded and one free
%       coordinate (no first-run value is needed).
%
% Function under test:
%     src/analysis/sampling/BarrierRound/PolytopeSimplifier/TwoSidedBarrier.m
%     (other classes of the same name under external/ and papers/ come later on the path; the
%     test checks that this one is used)
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: step_size fails for more than one point
%       SEVERITY: error
%       TRIGGER: step_size(x, v) with x and v holding two or more points (rows when vdim is 2,
%         columns when vdim is 1) and a nonzero direction entry outside the first point
%       OBSERVED: error 'The logical indices contain a true value outside of the array bounds.'
%         (the bound vector is indexed with the mask of the whole point matrix)
%       EXPECTED: one step size per point; for vdim 2 the largest step is already sized per
%         point
%       LINES: 89, 94
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTwoSidedBarrier'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the class of the COBRA Toolbox source tree is the one used
classFile = which('TwoSidedBarrier');
assert(contains(classFile, fullfile('src', 'analysis', 'sampling', 'BarrierRound', 'PolytopeSimplifier')));

% the box: coordinate 1 in (0, 2), coordinate 2 below 5, coordinate 3 above 1, coordinate 4 free
lb = [0; -Inf; 1; -Inf];
ub = [2; 5; Inf; Inf];

% an interior point, and the tolerance for the floating-point values that are not exactly
% representable (each is one or two operations on numbers of order 1, so a few ulp)
x = [1; 0; 2; 3];
tol = 1e-15;

%% constructor: bounds, one-sided and free coordinates, centre

barrier = TwoSidedBarrier(lb, ub);

assert(isequal(barrier.lb, lb) && isequal(barrier.ub, ub));
assert(barrier.n == 4 && barrier.vdim == 1 && barrier.extraHessian == 0);
% upperIdx lists lb = -Inf, lowerIdx lists ub = Inf, freeIdx lists both
assert(isequal(barrier.upperIdx, [2; 4]));
assert(isequal(barrier.lowerIdx, [3; 4]));
assert(isequal(barrier.freeIdx, 4));
% the centre is the midpoint, 1e6 inside a single infinite side, and 0 for a free coordinate
assert(isequal(barrier.center, [1; 5 - 1e6; 1 + 1e6; 0]));

%% set_bound replaces the bounds and the derived indices

barrier = TwoSidedBarrier(lb, ub);
barrier.set_bound([-1; -1], [1; 3]);
assert(barrier.n == 2 && isequal(barrier.lb, [-1; -1]) && isequal(barrier.ub, [1; 3]));
assert(isempty(barrier.upperIdx) && isempty(barrier.lowerIdx) && isempty(barrier.freeIdx));
assert(isequal(barrier.center, [0; 1]));

% an empty box (lb not below ub) and bounds of different sizes are rejected by assertions
assert(verifyCobraFunctionError('TwoSidedBarrier', 'inputs', {[0; 1], [1; 1]}));
assert(verifyCobraFunctionError('TwoSidedBarrier', 'inputs', {[0; 0], [1; 1; 1]}));

%% feasible: strictly inside the box

barrier = TwoSidedBarrier(lb, ub);
assert(isequal(barrier.feasible(x), true));
% a point on a finite bound is not feasible
assert(isequal(barrier.feasible([0; 0; 2; 3]), false));
assert(isequal(barrier.feasible([1; 5; 2; 3]), false));
% several points stored as columns: one answer per point
assert(isequal(barrier.feasible([x, [1; 0; 0.5; 3]]), [true, false]));

%% step_size: the largest step from x along v that stays in the box (one point)

barrier = TwoSidedBarrier(lb, ub);
% positive entries meet ub: (2 - 1)/1 = 1 for coordinate 1 and Inf for coordinate 4; the
% negative entry of coordinate 2 never meets lb = -Inf
assert(barrier.step_size(x, [1; -1; 0; 2]) == 1);
% a negative entry meets lb: (0 - 1)/(-0.5) = 2
assert(barrier.step_size(x, [-0.5; 0; 0; 0]) == 2);
% a zero direction gives the largest step 1e16
assert(barrier.step_size(x, zeros(4, 1)) == 1e16);
% a step that would be larger than 1e16 is cut to 1e16
assert(barrier.step_size(x, [0; 0; 1; 0]) == 1e16);

%% boundary: the normal and the offset of the nearer side of each coordinate

barrier = TwoSidedBarrier(lb, ub);
xBoundary = [0.5; 0; 2; 3];
[A, b] = barrier.boundary(xBoundary);
% below the centre (coordinates 1 and 3) the lower side -x <= -lb is used, otherwise x <= ub
assert(issparse(A) && isequal(full(A), diag([-1; 1; -1; 1])));
assert(isequal(b, [0; 5; -1; Inf]));

% the assumption that a single point is given is checked
assert(verifyCobraFunctionError('boundary', 'inputs', {barrier, [x, x]}));

%% gradient, Hessian, third derivative and the derived quantities

barrier = TwoSidedBarrier(lb, ub);
% gradient 1/(ub - x) - 1/(x - lb)
assert(isequal(barrier.gradient(x), [1 - 1; 1/5 - 0; 0 - 1; 0 - 0]));
% Hessian 1/(x - lb)^2 + 1/(ub - x)^2; the free coordinate has Hessian 0
hessianValue = barrier.hessian(x);
assert(max(abs(hessianValue - [2; 1/25; 1; 0])) < tol);
% third derivative -2*(1/(x - lb)^3 - 1/(ub - x)^3)
tensorValue = barrier.tensor(x);
assert(max(abs(tensorValue - [0; 2/125; -2; 0])) < tol);

% quadratic_form_gradient u.^2 .* tensor, hessian_norm d.^2 .* Hessian
u = [1; 2; 3; 4];
assert(max(abs(barrier.quadratic_form_gradient(x, u) - u.^2 .* [0; 2/125; -2; 0])) < tol);
assert(max(abs(barrier.hessian_norm(x, u) - u.^2 .* [2; 1/25; 1; 0])) < tol);

% boundary_distance: the distance to the nearer side of each coordinate
assert(isequal(barrier.boundary_distance(x), [1; 5; 1; Inf]));

%% extraHessian is added to the Hessian and used by logdet_gradient

barrier = TwoSidedBarrier(lb, ub);
barrier.extraHessian = 1;
assert(max(abs(barrier.hessian(x) - [3; 1/25 + 1; 2; 1])) < tol);
% logdet_gradient is tensor ./ Hessian; with extraHessian = 1 the free coordinate gives 0
logdetGradient = barrier.logdet_gradient(x);
assert(max(abs(logdetGradient - [0; (2/125)/(1/25 + 1); -1; 0])) < tol);

%% vdim 2: vectors stored as rows

% set_vdim reshapes the bounds and the centre
barrier = TwoSidedBarrier(lb, ub);
barrier.set_vdim(2);
assert(barrier.vdim == 2);
assert(isequal(barrier.lb, lb') && isequal(barrier.ub, ub') && isequal(barrier.center, [1, 5 - 1e6, 1 + 1e6, 0]));

% feasibility per row and the step size of a single row point
assert(isequal(barrier.feasible([x'; 1, 0, 0.5, 3]), [true; false]));
assert(barrier.step_size(x', [1, -1, 0, 2]) == 1);
assert(barrier.step_size(x', zeros(1, 4)) == 1e16);
[A, b] = barrier.boundary([0.5, 0, 2, 3]);
assert(isequal(full(A), diag([-1, 1, -1, 1])) && isequal(b, [0, 5, -1, Inf]));

% back to columns
barrier.set_vdim(1);
assert(barrier.vdim == 1 && isequal(barrier.lb, lb) && isequal(barrier.center, [1; 5 - 1e6; 1 + 1e6; 0]));

% only 1 and 2 are accepted
assert(verifyCobraFunctionError('set_vdim', 'inputs', {barrier, 3}));

% the constructor stores a given vdim (row bounds for vdim 2)
barrier = TwoSidedBarrier(lb', ub', 2);
assert(barrier.vdim == 2 && isequal(barrier.feasible(x'), true));

% change the directory
cd(currentDir)
