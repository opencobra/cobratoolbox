% The COBRAToolbox: testCreateFitL.m
%
% Purpose:
%     - createFitL fits the one-term Gaussian a1*exp(-((x-b1)/c1)^2) to the residual (left)
%       density curve of discretizeFPKM, starting from the fixed point
%       [0.0442 -0.5154 2.7799] with the bound c1 >= 0 (cobraFitGauss1, display off). The test
%       fits noise-free curves made from known coefficients, so the expected coefficients are
%       the ones used to build the data (hand derivation): an exact Gaussian is recovered up to
%       the fit tolerance and leaves no residual. It also checks the goodness-of-fit fields
%       documented by cobraFitGauss1, the evaluating handle f and row and column inputs.
%
% Function under test:
%     src/dataIntegration/transcriptomics/rFASTCORMICS/createFitL.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built curves.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateFitL'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a log2(FPKM) grid as produced by cobraKsdensity (a row of 100 points) and an exact
% Gaussian residual curve near the start point of createFitL
xi = linspace(-8, 8, 100);
a1 = 0.05; b1 = -0.8; c1 = 2.2;
rest = a1 * exp(-((xi - b1) / c1) .^ 2);

%% an exact Gaussian is recovered (row x, row y)

[fitresult, gof] = createFitL(xi, rest);
% the fit stops on a relative change of 1e-6 (TolFun, TolX of cobraFitGauss1); on exact data
% the coefficients agree to far better than 1e-4 relative, which is the tolerance used
coefTol = 1e-4;
assert(abs(fitresult.a1 - a1) < coefTol * a1);
assert(abs(fitresult.b1 - b1) < coefTol * abs(b1));
assert(abs(fitresult.c1 - c1) < coefTol * c1);
% exact data leave (almost) no residual: sse is a sum of squares of values below 1e-6
assert(gof.sse < 1e-10);
assert(abs(gof.rsquare - 1) < 1e-8);
% 100 points, 3 coefficients: dfe = 97 (integer, exact)
assert(isequal(gof.dfe, 97));
assert(all(isfield(gof, {'sse', 'rsquare', 'dfe', 'adjrsquare', 'rmse'})));
% the handle evaluates the fitted curve on the grid (same tolerance argument as above)
assert(max(abs(fitresult.f(xi(:)) - rest(:))) < coefTol * a1);

%% column inputs give the same fit

[fitColumn, gofColumn] = createFitL(xi', rest');
% same data, same start point: the same iterations, hence the same coefficients
assert(abs(fitColumn.a1 - fitresult.a1) < 1e-12);
assert(abs(fitColumn.b1 - fitresult.b1) < 1e-12);
assert(abs(fitColumn.c1 - fitresult.c1) < 1e-12);
assert(abs(gofColumn.sse - gof.sse) < 1e-15);

% change the directory
cd(currentDir)
