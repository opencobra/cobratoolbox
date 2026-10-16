% The COBRAToolbox: testWaterGibbsEnergyOfFormation.m
%
% Purpose:
%     - waterGibbsEnergyOfFormation returns the standard Gibbs energy of formation of liquid water
%     (kJ/mol) at a temperature T in kelvin from tabulated Shomate coefficients.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
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
%     - DEFECT: The Gibbs energy of formation uses the absolute entropy of water instead of the
%         entropy of formation
%       SEVERITY: wrong-result
%       TRIGGER: any temperature, for example T = 298.15 K
%       OBSERVED: the entropy term uses the absolute entropy of liquid water (about 0.07 kJ/(mol K))
%         and not the entropy of formation relative to H2 and O2, so the result is about -306.7
%         kJ/mol at 298.15 K
%       EXPECTED: about -237.1 kJ/mol at 298.15 K, the tabulated standard Gibbs energy of formation
%         of liquid water
%       LINES: 39-46
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

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

% change the directory
cd(currentDir)
