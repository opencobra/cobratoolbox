% The COBRAToolbox: testCreateComputedSpeciesData.m
%
% Purpose:
%     - createComputedSpeciesData builds Alberty-style species data (abbreviation, basicData
%       [dGf0 (kJ/mol), dHf0, charge, nH], gcmSpecies, mmspH7Bool) from group-contribution
%       estimates (metGroupCont, kcal/mol) and species pKa (metSpeciespKa). A metabolite without
%       a group-contribution entry is left out. With one species, or when no species has the
%       charge of the group-contribution estimate, the estimate itself is used with the formula
%       and charge of the estimate. Otherwise the estimate is given to the species with that
%       charge (the major microspecies or the most abundant one if several have it) and the
%       energies of the other species follow from the pKa: the more protonated species of a
%       pair is lower by R*T*ln(10)*pKa (R = 1.9858775e-3 kcal/(mol K), T = 298 K), averaging
%       when a species is reached twice. The energies are converted to kJ/mol (factor 4.184)
%       and species of equal charge are merged by -R*T*log(sum(exp(-dGf0/(R*T)))) in kJ/mol
%       (R = 8.3144621e-3, T = 298.15).
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: every expected energy is computed below by hand from the rules above,
%       following the order in which the function visits the pKa matrix (row by row) where it
%       matters; the tolerance 1e-9 kJ/mol covers the different order of the floating-point
%       operations (no first-run value is needed).
%
% Function under test:
%     src/analysis/thermo/groupContribution/createComputedSpeciesData.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs (column structure arrays and a
%     metGroupCont with one entry, see the defects).
%
% Coverage exemptions:
%     Lines 125-126 and 137-138, the averaging branches when the species of the row is computed
%     from the species of the column: these branches are only entered when the row species has
%     no energy yet, so the test of line 121 or 133 is always true and the lines cannot run.
%     Line 190, an empty gcmSpecies: it is set for every included metabolite. Line 193, an
%     empty mmspH7Bool: it needs an empty majorMSpH7, which is not a documented input (an
%     n x 1 boolean vector).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The first group-contribution entry is used for every metabolite
%       SEVERITY: wrong-result
%       TRIGGER: metGroupCont with two or more entries and a metabolite whose entry is not the
%         first one
%       OBSERVED: find(metGcIdx, 1) turns the index of the matching entry into 1, so the charge,
%         formula and energy of metGroupCont(1) are used (for example -41.84 kJ/mol and 4
%         hydrogens of CH4 instead of -83.68 kJ/mol and 6 hydrogens of C2H6)
%       EXPECTED: the data of the matching entry
%       LINES: 47, 51
%     - DEFECT: A row structure array of species fails when two metabolites are included
%       SEVERITY: error
%       TRIGGER: metSpeciespKa as a 1 x n structure array (as assignpKasToSpecies returns it)
%         with two or more metabolites that have a group-contribution entry
%       OBSERVED: error 'Index in position 1 exceeds array bounds. Index must not exceed 1.'
%       EXPECTED: one computedSpeciesData entry per included metabolite
%       LINES: 173-176
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateComputedSpeciesData'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% R*T*ln(10) in kcal/mol for the pKa steps, and R*T in kJ/mol for the merge of equal charges
pKaStep = 1.9858775e-3 * 298 * log(10);
mergeRT = 8.3144621e-3 * 298.15;
tol = 1e-9;

% a species structure in the format of assignpKasToSpecies (one metabolite)
makeSpecies = @(abbreviation, formulas, zs, nHs, majorMSpH7, abundanceAtpH7, pKas) struct( ...
    'abbreviation', abbreviation, 'inchis', {cell(numel(zs), 1)}, 'formulas', {formulas}, ...
    'zs', zs, 'nHs', nHs, 'majorMSpH7', majorMSpH7, 'abundanceAtpH7', abundanceAtpH7, 'pKas', pKas);
% a group-contribution entry in the format of createGroupContributionStruct (kcal/mol)
makeEstimate = @(abbreviation, formula, dGf0, charge) struct('abbreviation', abbreviation, ...
    'formulaMarvin', formula, 'delta_G_formation', dGf0, 'chargeMarvin', charge);

% glucose: one species and its estimate (-218.7 kcal/mol, charge 0)
glucose = makeSpecies('glc', {'C6H12O6'}, 0, 12, true, 100, 0);
glucoseEstimate = makeEstimate('glc', 'C6H12O6', -218.7, 0);

%% one species: the group-contribution estimate is used

computedSpeciesData = createComputedSpeciesData(glucose, glucoseEstimate);

assert(isequal(size(computedSpeciesData), [1, 1]));
assert(isequal(fieldnames(computedSpeciesData), {'abbreviation'; 'mmspH7Bool'; 'gcmSpecies'; 'basicData'}));
assert(strcmp(computedSpeciesData.abbreviation, 'glc'));
assert(isequal(computedSpeciesData.gcmSpecies, true) && isequal(computedSpeciesData.mmspH7Bool, true));
% [dGf0 in kJ/mol, no enthalpy, charge, hydrogens of the formula C6H12O6]
assert(abs(computedSpeciesData.basicData(1) - (-218.7 * 4.184)) < tol);
assert(isnan(computedSpeciesData.basicData(2)) && isequal(computedSpeciesData.basicData(3:4), [0, 12]));

%% a metabolite without a group-contribution entry is left out

unknown = makeSpecies('xyz', {'CH4'}, 0, 4, true, 100, 0);

computedSpeciesData = createComputedSpeciesData([glucose; unknown], glucoseEstimate);
assert(isscalar(computedSpeciesData) && strcmp(computedSpeciesData.abbreviation, 'glc'));
computedSpeciesData = createComputedSpeciesData([unknown; glucose], glucoseEstimate);
assert(isscalar(computedSpeciesData) && strcmp(computedSpeciesData.abbreviation, 'glc'));
assert(abs(computedSpeciesData.basicData(1) - (-218.7 * 4.184)) < tol);

%% four species linked by pKa: energies propagated from the estimated species

% species 1 has the fewest hydrogens; the estimate (-100 kcal/mol, charge 0) belongs to
% species 4. The symmetric pKa matrix links the pairs 1-2, 1-3, 1-4, 2-3 and 2-4.
pKas = zeros(4);
pKas(1, 2) = 9.5;
pKas(1, 3) = 8;
pKas(1, 4) = 7;
pKas(2, 3) = 4;
pKas(2, 4) = 3;
pKas = pKas + pKas';
species = makeSpecies('h4x', {'CHO4'; 'CH2O4'; 'CH3O4'; 'CH4O4'}, [-3; -2; -1; 0], [1; 2; 3; 4], ...
    [false; false; false; true], [0; 0; 10; 90], pKas);
estimate = makeEstimate('h4x', 'CH4O4', -100, 0);

computedSpeciesData = createComputedSpeciesData(species, estimate);

% the matrix is visited row by row: pair 1-4 gives species 1, pair 2-1 gives species 2, pair
% 2-3 gives species 3, pair 2-4 is averaged into species 4 and pair 3-1 is averaged into
% species 1 (pairs 1-2 and 1-3 are skipped in row 1 because neither species is known yet)
dG = NaN(4, 1);
dG(4) = -100;
dG(1) = dG(4) + pKaStep * 7;
dG(2) = dG(1) - pKaStep * 9.5;
dG(3) = dG(2) - pKaStep * 4;
dG(4) = (dG(4) + (dG(2) - pKaStep * 3)) / 2;
dG(1) = (dG(1) + (dG(3) + pKaStep * 8)) / 2;

assert(strcmp(computedSpeciesData.abbreviation, 'h4x'));
assert(max(abs(computedSpeciesData.basicData(:, 1) - dG * 4.184)) < tol);
assert(all(isnan(computedSpeciesData.basicData(:, 2))));
assert(isequal(computedSpeciesData.basicData(:, 3:4), [[-3; -2; -1; 0], [1; 2; 3; 4]]));
% the estimated species and the major microspecies are flagged
assert(isequal(computedSpeciesData.gcmSpecies, [false; false; false; true]));
assert(isequal(computedSpeciesData.mmspH7Bool, [false; false; false; true]));

%% three species: a pair reached from its more protonated species

% the estimate (-60 kcal/mol, charge -1) belongs to species 2; the pairs are 1-3 and 2-3. Row 1
% skips pair 1-3 (neither species known), row 2 gives species 3 from species 2, and row 3 gives
% species 1 from species 3 (the more protonated species of the pair is the known one)
pKas = zeros(3);
pKas(1, 3) = 6;
pKas(2, 3) = 4;
pKas = pKas + pKas';
species = makeSpecies('h3y', {'CHO3'; 'CH2O3'; 'CH3O3'}, [-2; -1; 0], [1; 2; 3], ...
    [false; true; false], [5; 90; 5], pKas);

computedSpeciesData = createComputedSpeciesData(species, makeEstimate('h3y', 'CH2O3', -60, -1));

dG = NaN(3, 1);
dG(2) = -60;
dG(3) = dG(2) - pKaStep * 4;
dG(1) = dG(3) + pKaStep * 6;
assert(max(abs(computedSpeciesData.basicData(:, 1) - dG * 4.184)) < tol);
assert(isequal(computedSpeciesData.basicData(:, 3:4), [[-2; -1; 0], [1; 2; 3]]));
assert(isequal(computedSpeciesData.gcmSpecies, [false; true; false]));

%% two species of the estimated charge: major microspecies, abundance, or none

% species 2 and 3 have the charge 0 of the estimate (-50 kcal/mol); species 1 is linked to both
pKas = [0 5 5; 5 0 0; 5 0 0];
estimate = makeEstimate('t', 'CH2', -50, 0);

% after the pKa steps species 2 and 3 both have the estimate, and they are merged into one
% species of charge 0 by -R*T*log(exp(0) + exp(0)); species 1 is the estimate + 5 pKa units
dGSpecies1 = (-50 + pKaStep * 5) * 4.184;
dGMerged = -50 * 4.184 - mergeRT * log(2);

% the major microspecies (species 3) has the charge: it gets the estimate
species = makeSpecies('t', {'C'; 'CH2'; 'CH2'}, [-1; 0; 0], [1; 2; 2], [false; false; true], [10; 20; 70], pKas);
computedSpeciesData = createComputedSpeciesData(species, estimate);
assert(size(computedSpeciesData.basicData, 1) == 2);
assert(abs(computedSpeciesData.basicData(1, 1) - dGSpecies1) < tol);
assert(abs(computedSpeciesData.basicData(2, 1) - dGMerged) < tol);
assert(isequal(computedSpeciesData.basicData(:, 3:4), [-1, 1; 0, 2]));
assert(isequal(computedSpeciesData.gcmSpecies, [false; true]) && isequal(computedSpeciesData.mmspH7Bool, [false; true]));

% the major microspecies (species 1) does not have the charge: the most abundant species of the
% charge (species 3) gets the estimate; the energies are the same
species.majorMSpH7 = [true; false; false];
computedSpeciesData = createComputedSpeciesData(species, estimate);
assert(abs(computedSpeciesData.basicData(1, 1) - dGSpecies1) < tol);
assert(abs(computedSpeciesData.basicData(2, 1) - dGMerged) < tol);
assert(isequal(computedSpeciesData.gcmSpecies, [false; true]) && isequal(computedSpeciesData.mmspH7Bool, [true; false]));

% no species of the charge is abundant: the message 'GCM major microspecies for t not found.' is
% printed and the estimate is used as a single species with the formula of the estimate (CH2)
species.abundanceAtpH7 = [100; 0; 0];
computedSpeciesData = createComputedSpeciesData(species, estimate);
assert(abs(computedSpeciesData.basicData(1) - (-50 * 4.184)) < tol);
assert(isnan(computedSpeciesData.basicData(2)) && isequal(computedSpeciesData.basicData(3:4), [0, 2]));
assert(isequal(computedSpeciesData.gcmSpecies, true) && isequal(computedSpeciesData.mmspH7Bool, true));

%% no species has the charge of the estimate: the estimate is used as a single species

species = makeSpecies('u', {'C'; 'CH2'}, [-1; 0], [1; 2], [false; true], [10; 90], [0 5; 5 0]);
computedSpeciesData = createComputedSpeciesData(species, makeEstimate('u', 'CH3', -20, 1));
assert(abs(computedSpeciesData.basicData(1) - (-20 * 4.184)) < tol);
assert(isequal(computedSpeciesData.basicData(3:4), [1, 3]));

% change the directory
cd(currentDir)
