% The COBRAToolbox: testDGfzeroGroupContToBiochemical.m
%
% Purpose:
%     - dGfzeroGroupContToBiochemical converts group contribution estimates of the standard Gibbs
%     energy of formation of metabolites into biochemical standard transformed energies at the pH,
%     ionic strength and electrical potential of each compartment, with or without the Legendre
%     transformation.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/thermoDirectionality/dGfzeroGroupContToBiochemical.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 119-123, the branch of the bracket-abbreviation block that is entered when a metabolite
%     is found in the group contribution list: the list of abbreviations it compares with is never
%     filled, so no metabolite is ever found. Lines 191, 231, 241 and 258: the error for a missing
%     hydrogen count (no formula tried gives NaN), the two disabled alternatives of the electrical
%     term (if 1) and the error for an empty transformed energy (an empty energy takes the NaN
%     branch instead).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDGfzeroGroupContToBiochemical'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons (relative)
tol = 1e-10;

% a model with one compartment c (pH 7.2, ionic strength 0.15 M, potential 30 mV), two metabolites
% with group contribution data and one without
model.S = [-1 1; 1 -1; 0 0];
model.mets = {'ac[c]'; 'ethanol[c]'; 'unknown[c]'};
model.metFormulas = {'C2H3O2'; 'C2H6O'; 'CH4'};
model.metCharges = [-1; 0; 0];
model.metCompartments = {'c'; 'c'; 'c'};
model.cellCompartments = 'c';
model.ph = 7.2;
model.is = 0.15;
model.chi = 30;
model.T = 298.15;
model.gasConstant = 8.3144621e-3;
model.faradayConstant = 96.485;
model.metGroupCont = struct('abbreviation', {'ac'; 'ethanol'}, ...
                            'delta_G_formation', {-100; -50}, ...
                            'delta_G_formation_uncertainty', {3; 2});

% quantities of the transformation computed independently of the function
T = model.T;
RT = model.gasConstant * T;
F = model.faradayConstant;
gibbscoeff = (9.20483 * T) / 10^3 - (1.284668 * T^2) / 10^5 + (4.95199 * T^3) / 10^8;
ionicTerm = @(z, nH) gibbscoeff * ((z^2) - nH) * sqrt(0.15) / (1 + 1.6 * sqrt(0.15));

%% transformed Gibbs energies with the Legendre transformation (default)

out = dGfzeroGroupContToBiochemical(model);
% acetate: 3 hydrogens, charge -1
nH = 3; z = -1;
expected = -100 - nH * RT * log(10^-7.2) - ionicTerm(z, nH) + F * (30 / 1000) * z;
assert(abs(out.dfGt0GroupCont(1) - expected) < tol * abs(expected));
% ethanol: 6 hydrogens, uncharged
nH = 6; z = 0;
expected = -50 - nH * RT * log(10^-7.2) - ionicTerm(z, nH) + F * (30 / 1000) * z;
assert(abs(out.dfGt0GroupCont(2) - expected) < tol * abs(expected));
% uncertainties are copied
assert(isequal(out.dfGt0GroupContUncertainty(1:2), [3 2]));
% the Legendre option is stored
assert(out.Legendre == 1);

%% metabolites without group contribution data

out = dGfzeroGroupContToBiochemical(model);
assert(isnan(out.dfGt0GroupCont(3)) && isnan(out.dfGt0GroupContUncertainty(3)));
assert(isnan(out.lambda{3}) && isnan(out.mf{3}));
assert(out.mf{1} == 1 && out.mf{2} == 1);
assert(isequal(out.aveHbound(1:2), [3 6]) && isequal(out.aveZi(1:2), [-1 0]));
% lambda is exp(-isterm / RT)
assert(abs(out.lambda{1} - exp(-ionicTerm(-1, 3) / RT)) < tol);

%% without the Legendre transformation

out = dGfzeroGroupContToBiochemical(model, 0);
z = -1;
isterm = gibbscoeff * (z^2) * sqrt(0.15) / (1 + 1.6 * sqrt(0.15));
expected = -100 - isterm + F * (30 / 1000) * z;
assert(abs(out.dfGt0GroupCont(1) - expected) < tol * abs(expected));
assert(out.Legendre == 0);

%% a compartment with no pH skips the range checks

noPH = model;
noPH.ph = 0;
out = dGfzeroGroupContToBiochemical(noPH);
% the pH term vanishes: log(10^-0) = 0
expected = -100 - 0 - ionicTerm(-1, 3) + F * (30 / 1000) * (-1);
assert(abs(out.dfGt0GroupCont(1) - expected) < tol * abs(expected));

%% pH and ionic strength outside the valid range are errors

bad = model;
bad.ph = 4;
assertFails(@() dGfzeroGroupContToBiochemical(bad));
bad = model;
bad.ph = 10;
assertFails(@() dGfzeroGroupContToBiochemical(bad));
bad = model;
bad.is = 0.5;
assertFails(@() dGfzeroGroupContToBiochemical(bad));
bad = model;
bad.is = -0.1;
assertFails(@() dGfzeroGroupContToBiochemical(bad));

%% group contribution names that end in a bracket

% with this naming the list of abbreviations to compare with is empty, so every metabolite is
% flagged as without group contribution data
bracketed = model;
bracketed.metGroupCont(1).abbreviation = 'ac[c]';
bracketed.metGroupCont(2).abbreviation = 'ethanol[c]';
out = dGfzeroGroupContToBiochemical(bracketed);
assert(all(out.NaNdfG0GCMetBool));
assert(all(isnan(out.dfG0GroupCont)) && all(isnan(out.dfG0GroupContUncertainty)));
assert(all(isnan(out.dfGt0GroupCont)) && all(isnan(out.dfGt0GroupContUncertainty)));
assert(all(cellfun(@isnan, out.mf)));

%% special metabolite names

% the hydrogen ion of the compartment and the metabolite named damval
special = model;
special.mets = {'h[c]'; 'damval[c]'; 'ethanol[c]'};
special.metFormulas = {'H'; 'C2H6O'; 'C2H6O'};
special.metCharges = [1; 0; 0];
out = dGfzeroGroupContToBiochemical(special);
assert(isnan(out.dfGt0GroupCont(1)) && isnan(out.dfGt0GroupCont(2)) && ~isnan(out.dfGt0GroupCont(3)));

%% a missing charge or uncertainty is an error

noCharge = model;
noCharge.metCharges(1) = NaN;
assertFails(@() dGfzeroGroupContToBiochemical(noCharge));
noUncertainty = model;
noUncertainty.metGroupCont(1).delta_G_formation_uncertainty = [];
assertFails(@() dGfzeroGroupContToBiochemical(noUncertainty));

%% a formula without hydrogen atoms gives zero hydrogens

noH = model;
noH.metFormulas{1} = 'CO2';
out = dGfzeroGroupContToBiochemical(noH);
assert(out.aveHbound(1) == 0);


function assertFails(fun)
% Assert that calling fun raises an error.
failed = false;
try
    fun();
catch
    failed = true;
end
assert(failed, 'the call was expected to fail');
end

% change the directory
cd(currentDir)
