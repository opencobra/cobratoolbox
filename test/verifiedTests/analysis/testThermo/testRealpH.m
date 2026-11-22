% The COBRAToolbox: testRealpH.m
%
% Purpose:
%     - realpH converts a glass-electrode (apparent) pH into the pH used in thermodynamic
%       calculations by subtracting the extended Debye-Hueckel term
%       alpha(T) * sqrt(I) / (ln(10) * (1 + 1.6 * sqrt(I))) (Alberty 2003, p. 48), with
%       alpha(T) = 1.10708 - 1.54508e-3 T + 5.95584e-6 T^2 (T in K). The test checks the
%       value at 298.15 K against Alberty's tabulated alpha = 1.17582 kg^(1/2) mol^(-1/2),
%       the zero adjustment at zero ionic strength, element-wise use of a pH vector, and
%       the temperature and ionic-strength dependence of the adjustment.
%
% Function under test:
%     src/analysis/thermo/protons/realpH.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built scalar inputs.
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
fileDir = fileparts(which('testRealpH'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% 298.15 K, ionic strength 0.25 M: Alberty's tabulated alpha

% hand calculation with alpha = 1.17582 (Alberty 2003, Table 3.1, 298.15 K) and
% sqrt(I) = 0.5: adjustment = 1.17582 * 0.5 / (ln(10) * 1.8) = 0.141848...
alphaAlberty = 1.17582;
expectedAdjustment = alphaAlberty * 0.5 / (log(10) * (1 + 1.6 * 0.5));
[pHr, pHAdjustment] = realpH(7, 298.15, 0.25);
% the polynomial alpha at 298.15 K (1.175849) differs from the 6-figure tabulated value by
% 3e-5, i.e. about 4e-6 in the adjustment; 1e-5 covers that rounding and nothing more
tol = 1e-5;
assert(abs(pHAdjustment - expectedAdjustment) < tol);
assert(abs(pHr - (7 - expectedAdjustment)) < tol);
% the real pH is the apparent pH minus the adjustment (same floating-point operation)
assert(abs(pHr - (7 - pHAdjustment)) < 1e-12);
% a single output is the real pH
assert(abs(realpH(7, 298.15, 0.25) - pHr) < 1e-12);

%% zero ionic strength: no adjustment

% sqrt(0) = 0, so the adjustment is exactly zero and the pH is unchanged
[pHr, pHAdjustment] = realpH(7.4, 310.15, 0);
assert(pHAdjustment == 0);
assert(pHr == 7.4);

%% a vector of apparent pH values is adjusted element-wise

% temperature and ionic strength are scalars, so one adjustment applies to every pH
apparentpH = [6.5; 7; 7.5];
[pHr, pHAdjustment] = realpH(apparentpH, 298.15, 0.1);
assert(isscalar(pHAdjustment) && pHAdjustment > 0);
assert(isequal(size(pHr), size(apparentpH)));
assert(max(abs(pHr - (apparentpH - pHAdjustment))) < 1e-12);

%% dependence on temperature and ionic strength

% alpha(T) increases with T above 130 K (derivative -1.54508e-3 + 2 * 5.95584e-6 T),
% so the adjustment at 310.15 K exceeds the one at 298.15 K
[~, adjustment298] = realpH(7, 298.15, 0.25);
[~, adjustment310] = realpH(7, 310.15, 0.25);
assert(adjustment310 > adjustment298);
% the ratio of the adjustments at two ionic strengths does not depend on T (alpha cancels):
% sqrt(I) / (1 + 1.6 sqrt(I)) is 0.5 / 1.8 for I = 0.25 and 0.1 / 1.16 for I = 0.01
[~, adjustmentLow298] = realpH(7, 298.15, 0.01);
[~, adjustmentLow310] = realpH(7, 310.15, 0.01);
expectedRatio = (0.5 / 1.8) / (0.1 / 1.16);
% ratios of floating-point quotients agree to rounding error
assert(abs(adjustment298 / adjustmentLow298 - expectedRatio) < 1e-12);
assert(abs(adjustment310 / adjustmentLow310 - expectedRatio) < 1e-12);

% change the directory
cd(currentDir)
