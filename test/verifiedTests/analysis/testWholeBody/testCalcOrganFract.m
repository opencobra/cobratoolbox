% The COBRAToolbox: testCalcOrganFract.m
%
% Purpose:
%     - calcOrganFract computes the organ weights and weight fractions of an individual from
%       body-weight polynomials (Table 3 of PMID 19267313: 14 organs for a man, 15 for a
%       woman), derives six blood cell populations from the blood weight, takes the organs of
%       the model that have no polynomial from the reference man/woman table of
%       getOrganWeightFraction and rewrites IndividualParameters.OrgansWeights. This test
%       checks a 70 kg man and a 60 kg woman on a hand-built model. The expected weights were
%       derived independently of MATLAB by evaluating the polynomial coefficients listed in
%       the function (and the blood cell proportions of its comments) for Wt = 70000 g and
%       60000 g; the reference weights of the organs without polynomial (Colon 300/290 g,
%       Lung 536 g, sIEC 640/600 g for man/woman) are read from the reference table.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/calcOrganFract.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups without a solver on a hand-built model with the reaction
%     identifiers the function reads (no whole-body model is loaded).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalcOrganFract'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the organs of a whole-body model are read from the reactions named <Organ>_biomass_maintenance;
% sIEC is always added by the function. Liver and Brain have polynomials, Colon, Lung and
% sIEC come from the reference table
model = struct('rxns', {{'Liver_biomass_maintenance'; 'Colon_biomass_maintenance'; ...
    'Lung_biomass_maintenance'; 'Liver_EX_glc_D(e)_[bc]'; 'Brain_biomass_maintenance'}});
individualParameters = struct('sex', 'male', 'bodyWeight', 70, 'CardiacOutput', 5360, ...
    'OrgansWeights', {{'Liver', 1800, 2.57; 'Brain', 1400, 2}});

% relative tolerance for the polynomial values: they are evaluated in double precision from
% coefficients with three significant digits, so only rounding noise separates them from
% the independently derived constants
relTol = 1e-6;

%% a 70 kg man: 14 polynomial organs, 6 blood cell populations, 3 organs from the reference table

[organs, organWeight, organWeightFract, outParameters] = calcOrganFract(model, individualParameters);
expectedOrgans = {'Brain'; 'Heart'; 'Kidney'; 'Liver'; 'Lungs'; 'Spleen'; 'Agland'; 'Pancreas'; ...
    'Thymus'; 'Thyroidgland'; 'Adipocytes'; 'Muscle'; 'Skin'; 'Blood'; ...
    'Bcells'; 'CD4Tcells'; 'Nkcells'; 'Monocyte'; 'Platelet'; 'RBC'; 'Colon'; 'Lung'; 'sIEC'};
% weights in g for Wt = 70000 g: polynomials, then the blood cells (blood weight 4788.322 g,
% blood volume 4788.322 / 1.0506 ml, WBC 1 %, lymphocytes 30 % of WBC, B cells 9 % of
% lymphocytes, CD4 T cells 15 % of WBC, NK cells 15 % of lymphocytes, monocytes 5 % of WBC,
% platelets 4 g/l, red blood cells 495 g/l), then the reference man
expectedWeight = [1249.43; 360.57; 294.609; 1677.8181; 1079.05; 191.107; 13.53289; 103.6; ...
    16.842; 16.94; 14302.8011; 23504.6; 2413.1695; 4788.322; ...
    1.29284694; 7.182483; 2.1547449; 2.394161; 18.23080906; 2256.062621; 300; 536; 640];
assert(isequal(organs, expectedOrgans));
assert(isequal(size(organWeight), [23 1]) && isequal(size(organWeightFract), [23 1]));
assert(all(abs(organWeight - expectedWeight) <= relTol * expectedWeight));
% the fractions are the weights divided by the body weight in g (both are computed from each
% other, so only rounding separates them)
assert(all(abs(organWeightFract - organWeight / 70000) < 1e-12));
% the updated parameters: blood volume from the blood weight and the plasma density 1.0506,
% the old OrgansWeights kept as OrgansWeightsRefMan, and a new 23 x 3 table of strings
assert(abs(outParameters.BloodVolume - 4788.322 / 1.0506) <= relTol * 4557.7);
assert(isequal(outParameters.OrgansWeightsRefMan, individualParameters.OrgansWeights));
assert(isequal(size(outParameters.OrgansWeights), [23 3]));
assert(isequal(outParameters.OrgansWeights(:, 1), organs));
for i = 1:numel(organs)
    assert(strcmp(outParameters.OrgansWeights{i, 2}, num2str(organWeight(i))));
    assert(strcmp(outParameters.OrgansWeights{i, 3}, num2str(organWeightFract(i) * 100)));
end
% the other parameters are passed through
assert(strcmp(outParameters.sex, 'male') && outParameters.bodyWeight == 70);

%% a 60 kg woman: the female polynomials add the breast; only sIEC is missing from this model

individualParameters.sex = 'female';
individualParameters.bodyWeight = 60;
[organs, organWeight, organWeightFract, outParameters] = calcOrganFract( ...
    struct('rxns', {{'Brain_biomass_maintenance'}}), individualParameters);
expectedOrgans = {'Brain'; 'Heart'; 'Kidney'; 'Liver'; 'Lungs'; 'Spleen'; 'Agland'; 'Pancreas'; ...
    'Thymus'; 'Thyroidgland'; 'Adipocytes'; 'Muscle'; 'Skin'; 'Blood'; 'Breast'; ...
    'Bcells'; 'CD4Tcells'; 'Nkcells'; 'Monocyte'; 'Platelet'; 'RBC'; 'sIEC'};
% weights in g for Wt = 60000 g (blood weight 4263.264 g), then the reference woman's sIEC
expectedWeight = [1235.9328; 285.48; 285.984; 1438.944; 920.16; 149.808; 12.45744; 88.8; ...
    15.504; 14.52; 17564.84736; 18267.6; 1862.419392; 4263.264; 600; ...
    1.15108128; 6.394896; 1.9184688; 2.131632; 16.23173044; 2008.676642; 600];
assert(isequal(organs, expectedOrgans));
assert(all(abs(organWeight - expectedWeight) <= relTol * expectedWeight));
assert(all(abs(organWeightFract - organWeight / 60000) < 1e-12));
assert(abs(outParameters.BloodVolume - 4263.264 / 1.0506) <= relTol * 4057.9);
assert(isequal(size(outParameters.OrgansWeights), [22 3]) && isequal(outParameters.OrgansWeights(:, 1), organs));
assert(strcmp(outParameters.OrgansWeights{15, 1}, 'Breast') && strcmp(outParameters.OrgansWeights{15, 2}, '600'));

% change the directory
cd(currentDir)
