% The COBRAToolbox: testWaterGibbsEnergyOfFormation.m
%
% Purpose:
%     - waterGibbsEnergyOfFormation returns the standard Gibbs energy of formation of liquid water
%     (kJ/mol) at a temperature T in kelvin from tabulated Shomate coefficients.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: The Gibbs energy of
%       formation uses the absolute entropy of water instead of the entropy of formation.
%
% Function under test:
%     src/analysis/thermo/reactantContribution/waterGibbsEnergyOfFormation.m
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
%     - Generated for feature tier1-test-batch4, 2026-10-13.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWaterGibbsEnergyOfFormation'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a finite scalar is returned for temperatures in the usual range

for T = [273.15 298.15 310.15 350]
    dGf0 = waterGibbsEnergyOfFormation(T);
    assert(isscalar(dGf0) && isfinite(dGf0) && isreal(dGf0));
end

%% the result depends on the temperature

assert(waterGibbsEnergyOfFormation(298.15) ~= waterGibbsEnergyOfFormation(310.15));

%% the standard Gibbs energy of formation of liquid water

% Reference values: dfG = dfH - T*dfS for H2(g) + 1/2 O2(g) -> H2O(l), computed outside this
% function from the NIST Shomate equations of liquid water, H2 and O2 (research note R3 of feature
% 20261102-140321-tier1-safe-defect-fixes). At 298.15 K the tabulated standard value is
% -237.13 kJ/mol (NIST, CODATA); the Shomate coefficients give -237.14. The tolerance of
% 0.05 kJ/mol covers the rounding of the tabulated coefficients.
assert(abs(waterGibbsEnergyOfFormation(298.15) - (-237.14)) < 0.05);
assert(abs(waterGibbsEnergyOfFormation(310.15) - (-235.19)) < 0.05);

% change the directory
cd(currentDir)
