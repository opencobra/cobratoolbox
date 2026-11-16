% The COBRAToolbox: testSetDietConstraints.m
%
% Purpose:
%     - setDietConstraints closes every Diet_EX_ uptake of a whole-body model, opens the
%       metabolites essential to the AGORA microbes and a fixed list of compounds missing from
%       the diet database, then sets the lower and upper bounds of the diet exchanges from a
%       diet table (predefined diet scripts or a user table of reaction identifiers and flux
%       strings in mmol/day/person) with special rules for micronutrients, ions and sulfate,
%       scaled by a factor. This test uses a hand-built model with one reaction of every
%       kind and checks the bounds against values worked out by hand from the rules of the
%       function (lb = -1.2 x value x factor, ub = -0.8 x value x factor, micronutrient and
%       ion exceptions), the default factor, the five predefined diets (entry counts and the
%       glucose and sodium values read from the diet scripts) and the recorded SetupInfo.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/setConstraints/setDietConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver on a hand-built model with the fields the
%     function reads (rxns, lb, ub); no whole-body model is loaded.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: diet flux values given as numbers are not accepted
%       SEVERITY: limitation
%       TRIGGER: setDietConstraints(model, {'Diet_EX_glc_D[d]', 10})
%       OBSERVED: MATLAB R2025a: error "Input must be a character vector or string scalar."
%                 from str2num; the documented diet table ("second column holds the
%                 corresponding flux values") must hold the values as character arrays, as
%                 the predefined diet scripts do
%       EXPECTED: numeric flux values accepted, or the documentation naming character arrays
%       LINES: 156, 158, 166, 174
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetDietConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% hand-built model: diet exchanges of a plain nutrient (glucose), two micronutrients
% (adenosylcobalamin, vitamin D2, folate), an ion (sodium), sulfate, choline (in the list of
% compounds missing from the diet database with its own value), cytidine (missing compound),
% acetate (AGORA essential), asparagine (AGORA essential and missing compound), and two
% reactions that are no diet exchange
model = struct();
model.rxns = {'Diet_EX_glc_D[d]'; 'Diet_EX_adocbl[d]'; 'Diet_EX_vitd2[d]'; 'Diet_EX_fol[d]'; ...
    'Diet_EX_na1[d]'; 'Diet_EX_so4[d]'; 'Diet_EX_chol[d]'; 'Diet_EX_cytd[d]'; 'Diet_EX_ac[d]'; ...
    'Diet_EX_asn_L[d]'; 'EX_o2[u]'; 'R1'};
nRxns = numel(model.rxns);
model.lb = -1000 * ones(nRxns, 1);
model.ub = 1000 * ones(nRxns, 1);
isDiet = strncmp(model.rxns, 'Diet_EX_', 8);

% products of decimal constants are compared with a tolerance far below the smallest value
tol = 1e-9;

%% a user diet with factor 0.5: every rule of the bounds, worked out by hand

diet = {'Diet_EX_glc_D[d]', '10'; 'Diet_EX_adocbl[d]', '0.001'; 'Diet_EX_vitd2[d]', '20'; ...
    'Diet_EX_fol[d]', '5'; 'Diet_EX_na1[d]', '3'; 'Diet_EX_so4[d]', '2'; 'Diet_EX_chol[d]', '1'; ...
    'Diet_EX_missing[d]', '7'};
out = setDietConstraints(model, diet, 0.5);
% lower bounds: glucose -1.2 x 10 x 0.5; micronutrients with a value <= 10 get -10 x factor;
% vitamin D2 (20 > 10) gets -1.2 x 20 x 100 x 0.5; the ion gets -1.2 x 3 x 100 x 0.5;
% sulfate -1000 x 0.5; choline -1.2 x 1 x 0.5 (the -41.251 default is overwritten by the
% diet); cytidine and asparagine stay at the -50 of the missing compounds; acetate at the
% -0.1 of the AGORA essentials
expectedLb = [-6; -5; -1200; -5; -180; -500; -0.6; -50; -0.1; -50; -1000; -1000];
% upper bounds: -0.8 x value x factor for every diet entry, 0 for the closed diet exchanges
expectedUb = [-4; -4e-4; -8; -2; -1.2; -0.8; -0.4; 0; 0; 0; 1000; 1000];
assert(all(abs(out.lb - expectedLb) < tol) && all(abs(out.ub - expectedUb) < tol));
% the diet table is recorded; a diet reaction absent from the model is ignored
assert(isequal(out.SetupInfo.DietComposition, diet));
assert(isequal(out.rxns, model.rxns));

%% the default factor is 1

out = setDietConstraints(model, diet);
assert(abs(out.lb(1) + 12) < tol && abs(out.ub(1) + 8) < tol);
assert(abs(out.lb(3) + 2400) < tol && abs(out.ub(3) + 16) < tol);
assert(abs(out.lb(5) + 360) < tol && abs(out.ub(5) + 2.4) < tol);
% without a diet entry the choline exchange keeps its default of -41.251 mmol/day/person
out = setDietConstraints(model, diet(1, :));
assert(abs(out.lb(7) + 41.251) < tol && out.ub(7) == 0);

%% the default diet is the average European diet (95 entries, glucose 135.5803501, sodium
%% 172.4462717 mmol/day/person in the diet script); the same table is used when named

out = setDietConstraints(model);
assert(size(out.SetupInfo.DietComposition, 1) == 95 && size(out.SetupInfo.DietComposition, 2) == 2);
% identifiers are rewritten from EX_...(e) to Diet_EX_...[d]
assert(strcmp(out.SetupInfo.DietComposition{1, 1}, 'Diet_EX_10fthf[d]'));
assert(strcmp(out.SetupInfo.DietComposition{1, 2}, '0.000125752'));
assert(all(strncmp(out.SetupInfo.DietComposition(:, 1), 'Diet_EX_', 8)));
assert(abs(out.lb(1) + 1.2 * 135.5803501) < tol && abs(out.ub(1) + 0.8 * 135.5803501) < tol);
assert(abs(out.lb(5) + 1.2 * 172.4462717 * 100) < tol && abs(out.ub(5) + 0.8 * 172.4462717) < tol);
% folate is in the diet (0.000134614 <= 10): the micronutrient rule gives -10
assert(out.lb(4) == -10 && abs(out.ub(4) + 0.8 * 0.000134614) < tol);
% adenosylcobalamin is not in this diet but essential to the microbes: -0.1 and closed above
assert(abs(out.lb(2) + 0.1) < tol && out.ub(2) == 0);
outNamed = setDietConstraints(model, 'EUAverageDiet');
assert(isequal(outNamed.lb, out.lb) && isequal(outNamed.ub, out.ub));
assert(isequal(outNamed.SetupInfo.DietComposition, out.SetupInfo.DietComposition));

%% the four other predefined diets: 91 entries each; glucose and sodium from the scripts

dietNames = {'HighFiberDiet', 'HighProteinDiet', 'UnhealthyDiet', 'VegetarianDiet'};
glucose = [120.210995, 107.3525763, 119.070988, 102.1380649];
sodium = [147.9118802, 249.2580474, 309.750825, 106.469968];
for i = 1:numel(dietNames)
    out = setDietConstraints(model, dietNames{i}, 1);
    assert(size(out.SetupInfo.DietComposition, 1) == 91);
    assert(abs(out.lb(1) + 1.2 * glucose(i)) < tol && abs(out.ub(1) + 0.8 * glucose(i)) < tol);
    assert(abs(out.lb(5) + 1.2 * sodium(i) * 100) < tol && abs(out.ub(5) + 0.8 * sodium(i)) < tol);
    % reactions that are no diet exchange are never touched
    assert(all(out.lb(~isDiet) == -1000) && all(out.ub(~isDiet) == 1000));
end

% change the directory
cd(currentDir)
