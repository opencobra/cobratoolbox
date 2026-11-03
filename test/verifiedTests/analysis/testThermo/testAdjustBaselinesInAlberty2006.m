% The COBRAToolbox: testAdjustBaselinesInAlberty2006.m
%
% Purpose:
%     - adjustBaselinesInAlberty2006 moves the metabolites of Alberty's tables whose standard
%       Gibbs energies of formation are given relative to a group baseline (CoA, FAD, FMN,
%       glutathione, NAD, retinal and ubiquinone groups) onto the elements: the
%       group-contribution energy of the basic species of the group (the computed species of
%       the same charge, charge -5 for coenzyme A) is added to every species of every member,
%       the enthalpies are set to NaN, and the hydrogen numbers (and, for the CoA group, the
%       charges) are shifted to those of the computed basic species. Every other entry is
%       returned unchanged.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the input energies, charges and hydrogen numbers of the group members
%       are those of the shipped table Alberty2006.mat; the group-contribution values are
%       hand-made. Every
%       expected value is computed below with the rule of the function (the same additions), so
%       the comparisons are exact. The last section reads the shipped table Alberty2006.mat (data
%       file of the toolbox) and checks which entries change; its counts (198 entries without
%       glutathionered, 25 group members) were recorded from the first run on 2026-11-03 (no
%       model, no solver) and guard consistency with the shipped table (Tier 5).
%
% Function under test:
%     src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; hand-built inputs, plus the shipped data file
%     Alberty2006.mat in the last section.
%
% Coverage exemptions:
%     Lines 172-175, the update of glutathionered: that input is skipped (see the defect below).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The reduced glutathione energies are halved together with the baseline
%       SEVERITY: wrong-result
%       TRIGGER: an Alberty2006 entry glutathionered (with glutathioneox and the computed entry
%         gthox)
%       OBSERVED: every species energy of glutathionered becomes (dfG0 + gc)/2, where gc is the
%         group-contribution energy of the oxidized basic species, and its hydrogen numbers are
%         shifted by the full hydrogen adjustment of the oxidized dimer; the tabulated energy of
%         the reduced form relative to the oxidized form is halved
%       EXPECTED: dfG0 + gc/2 (and half the hydrogen adjustment): one reduced glutathione carries
%         half the baseline of the dimer (GSSG + 2 e- = 2 GSH), while its tabulated energy keeps
%         its value
%       LINES: 173, 175
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAdjustBaselinesInAlberty2006'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% Alberty entries (row structure array like Alberty2006.mat); basicData columns are dfG0
% (kJ/mol), dfH0, charge and number of hydrogens, one row per species. Members are listed
% before and after their group base on purpose; atp belongs to no group. glutathionered is left
% out (see the defect).
abbreviations = {'acetylcoA', 'coA', 'fadred', 'fadox', 'fmnox', 'fmnred', 'glutathioneox', ...
    'nadox', 'nadred', 'retinal', 'retinol', 'ubiquinoneox', 'ubiquinonered', 'atp'};
basicData = {[-180.36, NaN, 0, 3], [0, NaN, -1, 0; -47.83, NaN, 0, 1], [-38.88, NaN, -2, 33], ...
    [0, NaN, -2, 31], [0, NaN, -2, 19], [-38.88, NaN, -2, 21], [0, NaN, -2, 30], ...
    [0, 0, -1, 26], [22.65, -31.94, -2, 27], [0, NaN, 0, 28], [-27.91, NaN, 0, 30], ...
    [0, NaN, 0, 90], [-89.92, NaN, 0, 92], [-2768.1, -3619.21, -4, 12; -2811.48, -3612.91, -3, 13]};
alberty = struct('abbreviation', abbreviations, 'basicData', basicData);

% group-contribution species (row structure array like createComputedSpeciesData returns); the
% basic species of each group is the one with the charge of Alberty's species of energy 0
% (charge -5 for coenzyme A)
computedAbbreviations = {'atp', 'coa', 'fad', 'fmn', 'gthox', 'nad', 'retinal', 'q10'};
computedBasicData = {[-2700, NaN, -4, 12], [-2950, NaN, -4, 32; -2900, NaN, -5, 31], ...
    [-1500, NaN, -3, 30; -1450, NaN, -2, 32], [-1100, NaN, -2, 19], [-1818.91, NaN, -2, 32], ...
    [-2215.8, NaN, -1, 26], [120, NaN, 0, 28], [-700, NaN, 0, 90]};
computedSpeciesData = struct('abbreviation', computedAbbreviations, 'basicData', computedBasicData);

% the expected entry after adding the energy gc, shifting the hydrogens by dH and the charges
% by dZ, with the enthalpies set to NaN
shiftEntry = @(data, gc, dH, dZ) [data(:, 1) + gc, NaN(size(data, 1), 1), data(:, 3) + dZ, data(:, 4) + dH];

%% the members of every group are moved onto the group-contribution baseline

adjusted = adjustBaselinesInAlberty2006(alberty, computedSpeciesData);

% same entries in the same order
assert(isequal(size(adjusted), size(alberty)));
assert(isequal({adjusted.abbreviation}, abbreviations));
getData = @(name) adjusted(strcmp(abbreviations, name)).basicData;
getInput = @(name) alberty(strcmp(abbreviations, name)).basicData;

% CoA group: the computed species of charge -5 (energy -2900, 31 hydrogens) is the baseline; the
% hydrogens are shifted by 31 - 0 and the charges by -5 - (-1) for every member
assert(isequaln(getData('coA'), shiftEntry(getInput('coA'), -2900, 31, -4)));
assert(isequaln(getData('acetylcoA'), shiftEntry(getInput('acetylcoA'), -2900, 31, -4)));

% FAD group: the computed species of charge -2 (energy -1450, 32 hydrogens versus 31)
assert(isequaln(getData('fadox'), shiftEntry(getInput('fadox'), -1450, 1, 0)));
assert(isequaln(getData('fadred'), shiftEntry(getInput('fadred'), -1450, 1, 0)));

% FMN group: energy -1100, same hydrogen number
assert(isequaln(getData('fmnox'), shiftEntry(getInput('fmnox'), -1100, 0, 0)));
assert(isequaln(getData('fmnred'), shiftEntry(getInput('fmnred'), -1100, 0, 0)));

% glutathione: the oxidized form (energy -1818.91, 32 hydrogens versus 30)
assert(isequaln(getData('glutathioneox'), shiftEntry(getInput('glutathioneox'), -1818.91, 2, 0)));

% NAD group: energy -2215.8; the enthalpy of nadox (0) and of nadred are set to NaN
assert(isequaln(getData('nadox'), shiftEntry(getInput('nadox'), -2215.8, 0, 0)));
assert(isequaln(getData('nadred'), shiftEntry(getInput('nadred'), -2215.8, 0, 0)));

% retinal group (energy 120) and ubiquinone group (energy -700)
assert(isequaln(getData('retinal'), shiftEntry(getInput('retinal'), 120, 0, 0)));
assert(isequaln(getData('retinol'), shiftEntry(getInput('retinol'), 120, 0, 0)));
assert(isequaln(getData('ubiquinoneox'), shiftEntry(getInput('ubiquinoneox'), -700, 0, 0)));
assert(isequaln(getData('ubiquinonered'), shiftEntry(getInput('ubiquinonered'), -700, 0, 0)));

% an entry outside the groups is unchanged, although a computed entry exists for it
assert(isequaln(getData('atp'), getInput('atp')));

%% the shipped table: only the members of the groups change

% the shipped table Alberty2006.mat (199 entries); glutathionered is removed (see the defect)
shipped = load('Alberty2006.mat');
shippedAlberty = shipped.Alberty2006;
shippedAlberty(strcmp({shippedAlberty.abbreviation}, 'glutathionered')) = [];

adjusted = adjustBaselinesInAlberty2006(shippedAlberty, computedSpeciesData);

groupMembers = {'coA', 'acetoacetylcoA', 'acetylcoA', 'coAglutathione', 'malylcoA', ...
    'methylmalonylcoA', 'oxalylcoA', 'propanoylcoA', 'succinylcoA', 'fadox', 'fadred', ...
    'fadenzox', 'fadenzred', 'fmnox', 'fmnred', 'glutathioneox', 'nadox', 'nadred', ...
    'nicotinamideribonucleotide', 'nadpox', 'nadpred', 'retinal', 'retinol', 'ubiquinoneox', ...
    'ubiquinonered'};
isMember = ismember({shippedAlberty.abbreviation}, groupMembers);
isChanged = arrayfun(@(k) ~isequaln(adjusted(k).basicData, shippedAlberty(k).basicData), 1:numel(shippedAlberty));

% every group member changes (the 25 names above are all in Alberty2006.mat), and the other 173
% entries do not
assert(isequal(isChanged, isMember));
assert(nnz(isMember) == 25 && numel(shippedAlberty) == 198);
assert(isequal({adjusted.abbreviation}, {shippedAlberty.abbreviation}));

% for example succinylcoA follows the CoA rule
succinylcoA = strcmp({shippedAlberty.abbreviation}, 'succinylcoA');
assert(isequaln(adjusted(succinylcoA).basicData, shiftEntry(shippedAlberty(succinylcoA).basicData, -2900, 31, -4)));

% change the directory
cd(currentDir)
