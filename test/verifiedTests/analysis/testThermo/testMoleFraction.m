% The COBRAToolbox: testMoleFraction.m
%
% Purpose:
%     - moleFraction returns the equilibrium mole fractions of the pseudoisomer species of a
%     metabolite at a given pH, temperature and ionic strength, from Alberty's data.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/protons/moleFraction.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 39 of moleFraction.m (a second, identical default for pHa, never true after the
%     first one) and line 62 (inside the "if 0" block that would adjust the pH with realpH)
%     are never reached: both are dead code in the source.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMoleFraction'));
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

% The expected values come from the Henderson-Hasselbalch relation: [A-]/[HA] = 10^(pH - pKa) with
% pKa = 39.95 / (R T ln 10). calcdGHT uses R = 8.31451e-3 and acidDissociationConstant 8.314472e-3,
% which differ by 5e-6 relative, so mole fractions agree with the relation to about 2e-5.
tol = 1e-4;
pKa = 39.95 / (gasConstant * temperature * log(10));

%% pH equal to the pKa: half protonated

mf = moleFraction('ha[c]', albertyData, metAbbrAlbertyAbbr, temperature, pKa, 0, 0);
assert(abs(sum(mf) - 1) < 1e-12);
assert(norm(mf(:) - [0.5; 0.5]) < tol);

%% one pH unit above and below the pKa

mf = moleFraction('ha[c]', albertyData, metAbbrAlbertyAbbr, temperature, pKa + 1, 0, 0);
assert(norm(mf(:) - [10/11; 1/11]) < tol);        % mostly the deprotonated species A-
mf = moleFraction('ha[c]', albertyData, metAbbrAlbertyAbbr, temperature, pKa - 1, 0, 0);
assert(norm(mf(:) - [1/11; 10/11]) < tol);        % mostly the protonated species HA

%% ionic strength shifts the pKa

ionicStrength = 0.1;
[~, pKaIonic] = acidDissociationConstant('ha[c]', albertyData, metAbbrAlbertyAbbr, temperature, ionicStrength, 0);
mf = moleFraction('ha[c]', albertyData, metAbbrAlbertyAbbr, temperature, 7, ionicStrength, 0);
assert(abs(mf(1) / mf(2) / 10^(7 - pKaIonic(1)) - 1) < 1e-3);

%% three species: fractions add up to 1 and neighbouring ratios follow their pKa

threeSpecies = struct('abbreviation', {'h3'}, 'basicData', {[0 0 -2 0; -40 0 -1 1; -60 0 0 2]});
threeAbbr = {'x', 'h2a[c]', 'h3'};
[~, pKaThree] = acidDissociationConstant('h2a[c]', threeSpecies, threeAbbr);
mf = moleFraction('h2a[c]', threeSpecies, threeAbbr, temperature, 7, 0, 0);
assert(abs(sum(mf) - 1) < 1e-12);
assert(abs(mf(1) / mf(2) / 10^(7 - pKaThree(1)) - 1) < 1e-3);
assert(abs(mf(2) / mf(3) / 10^(7 - pKaThree(2)) - 1) < 1e-3);

%% default temperature, pH, ionic strength and potential: pH 0 is outside the applicable range

lastwarn('');
mf = moleFraction('ha[c]', albertyData, metAbbrAlbertyAbbr);
% the warning from the thermodynamic routine stays visible (Constitution VII-B)
assert(contains(lastwarn, 'pHr out of applicable range'));
% at pH 0 the protonated species HA dominates: [A-]/[HA] = Ka
assert(abs(mf(1) / mf(2) / 10^(-pKa) - 1) < 1e-3);

% change the directory
cd(currentDir)
