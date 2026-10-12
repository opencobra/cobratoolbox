% The COBRAToolbox: testAcidDissociationConstant.m
%
% Purpose:
%     - acidDissociationConstant returns the acid dissociation constants Ka and pKa between the
%     successive pseudoisomer species of a metabolite from the Gibbs energies of formation in
%     Alberty's data.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/reactantContribution/acidDissociationConstant.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 85-86 of acidDissociationConstant.m (the else branch of the constant "if 1") are
%     never reached: the branch is switched off in the source.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Ka and pKa are returned as square matrices with only the first entries filled
%       SEVERITY: cosmetic
%       TRIGGER: a metabolite with p species
%       OBSERVED: Ka and pKa are (p-1)-by-(p-1) matrices of which only the first p-1 entries (linear
%         index) are set, the rest are 0
%       EXPECTED: vectors of length p-1
%       LINES: 62-63
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAcidDissociationConstant'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% metabolite 'ha[c]' with one pseudoisomer group 'hf' of two species. Rows of basicData are
% [dGf0 (kJ/mol), dHf0 (kJ/mol), charge, number of H], listed from the least to the most protonated:
% A- (charge -1, 0 H) and HA (charge 0, 1 H) with dGf0(HA) - dGf0(A-) = -39.95
albertyData = struct('abbreviation', {'hf'}, 'basicData', {[0 0 -1 0; -39.95 0 0 1]});
metAbbrAlbertyAbbr = {'x', 'ha[c]', 'hf'};      % [id, metabolite abbreviation, Alberty abbreviation]
gasConstant = 8.314472e-3;                      % kJ/(K mol), the value used by acidDissociationConstant
temperature = 298.15;

% tolerance for pKa: the same closed formula is evaluated here and in the function, so the
% difference is only rounding
tol = 1e-8;
logTen = log(10);
temperature = 298.15;
expectedPKa = 39.95 / (gasConstant * temperature * logTen);   % two species, no ionic strength

%% two species: pKa = -(dG(HA) - dG(A-)) / (R T ln 10) with no ionic strength

[Ka, pKa] = acidDissociationConstant('ha[c]', albertyData, metAbbrAlbertyAbbr);
assert(abs(pKa(1) - expectedPKa) < tol);
% Ka = 10^-pKa
assert(abs(Ka(1) / 10^(-expectedPKa) - 1) < 1e-8);

%% the temperature cancels when dHf0 is zero (dG scales with T)

[~, pKaOtherTemperature] = acidDissociationConstant('ha[c]', albertyData, metAbbrAlbertyAbbr, 300);
assert(abs(pKaOtherTemperature(1) - expectedPKa) < tol);

%% ionic strength 0.1 lowers the pKa of a species pair where the charge changes by one

ionicStrength = 0.1;
gibbsCoefficient = (9.20483 * temperature) / 10^3 - (1.284668 * temperature^2) / 10^5 + (4.95199 * temperature^3) / 10^8;
debyeHueckelTerm = gibbsCoefficient * sqrt(ionicStrength) / (1 + 1.6 * sqrt(ionicStrength));
[~, pKaIonic] = acidDissociationConstant('ha[c]', albertyData, metAbbrAlbertyAbbr, temperature, ionicStrength, 0);
assert(abs(pKaIonic(1) - (expectedPKa - 2 * debyeHueckelTerm / (gasConstant * temperature * logTen))) < tol);

%% three species: one pKa per step (only the first p-1 entries are set, see the header)

threeSpecies = struct('abbreviation', {'h3'}, 'basicData', {[0 0 -2 0; -40 0 -1 1; -60 0 0 2]});
[~, pKaThree] = acidDissociationConstant('h2a[c]', threeSpecies, {'x', 'h2a[c]', 'h3'});
assert(abs(pKaThree(1) - 40 / (gasConstant * temperature * logTen)) < tol);
assert(abs(pKaThree(2) - 20 / (gasConstant * temperature * logTen)) < tol);

% change the directory
cd(currentDir)
