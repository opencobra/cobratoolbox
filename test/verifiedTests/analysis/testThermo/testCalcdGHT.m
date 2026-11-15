% The COBRAToolbox: testCalcdGHT.m
%
% Purpose:
%     - calcdGHT returns the standard transformed Gibbs energy of formation of a reactant (a
%       group of pseudoisomer species) at a given real pH, ionic strength and temperature, with
%       the mole fraction, average bound protons, average charge and activity coefficient of each
%       species (Alberty 2003). This test checks one and two species, the Legendre transformation
%       for pH switched on and off, the (no-op) electrical potential option, the van't Hoff
%       adjustment when standard enthalpies are given, numerically large energies (log-sum-exp),
%       the pH-range warning and the temperature and ionic-strength errors.
%     - Expected values come from Alberty's equations written out independently here (Eq. 3.6-3,
%       3.7-4, 4.4-9/10 of Alberty 2003): RTalpha = 9.20483e-3 T - 1.284668e-5 T^2
%       + 4.95199e-8 T^3, the extended Debye-Hueckel term RTalpha (z^2 - nH) sqrt(I) / (1 + 1.6
%       sqrt(I)), the pH term nH R T ln(10^-pH) and the partition function of the pseudoisomers.
%       Two literature anchors are checked as well: RTalpha = 2.91482 kJ/mol at 298.15 K (the
%       value Alberty 2003 uses at 298.15 K) and the pKa of acetic acid (4.76) obtained from
%       Alberty's species values (dGf0 acetic acid -396.46, acetate -369.31 kJ/mol).
%
% Function under test:
%     src/analysis/thermo/reactantContribution/calcdGHT.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 69: inside "if 0" (the error for a pH outside 5 - 9 is switched off), dead code.
%     Line 151: inside "if 0" (electrical potential term), dead code.
%     Lines 197-408: the enthalpy branch "if ~isempty(dHzero)" directly follows "dHzero=[]" on
%     line 195, so it is unreachable by any input (see the limitation below).
%     Lines 414-636: the multiple precision toolbox branch; the condition on line 89 ends in
%     "|| 1", so the else branch is unreachable by any input.
%     Lines 687, 697-700, 711-747: the local helper maxstar is called only as maxstar(x) (line
%     173), so its argument-count error, its two- and three-argument forms and its weighted sum
%     are unreachable through calcdGHT.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The standard transformed enthalpy dHf0 is always NaN
%       SEVERITY: limitation
%       TRIGGER: any call, e.g. calcdGHT(-100, -50, -1, 3, 7, 0.25, 298.15)
%       OBSERVED: dHf0 = NaN; line 195 sets dHzero = [] before the enthalpy branch ("makes
%       script faster to leave this out for now")
%       EXPECTED: the documented output "reactant standard transformed enthalpy of formation"
%       LINES: 195-196, 411
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalcdGHT'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% constants of calcdGHT (kJ/mol/K, K)
R = 8.31451e-3;
Tstd = 298.15;
% Alberty 2003, Eq. 3.7-4: RT times the Debye-Hueckel coefficient alpha
rtAlpha = @(temp) 9.20483e-3 * temp - 1.284668e-5 * temp^2 + 4.95199e-8 * temp^3;
% extended Debye-Hueckel factor sqrt(I) / (1 + 1.6 sqrt(I))
dhFactor = @(is) sqrt(is) / (1 + 1.6 * sqrt(is));
% the inputs are energies of order 1e2 - 1e3 kJ/mol; double arithmetic in a different order
% agrees to about 1e-12 relative, so 1e-9 kJ/mol (absolute) is a safe tolerance
tol = 1e-9;

%% one species, default options: transformed Gibbs energy at pH 7, I = 0.25 M, 298.15 K

dGzero = -100; zi = -1; nH = 3; pHr = 7; is = 0.25; temp = 298.15;
[dGf0, dHf0, mf, aveHbound, aveZi, lambda, gpfnsp] = calcdGHT(dGzero, [], zi, nH, pHr, is, temp);
expected = dGzero - nH * R * temp * log(10^-pHr) - rtAlpha(temp) * (zi^2 - nH) * dhFactor(is);
assert(abs(dGf0 - expected) < tol);
% a single species is the whole reactant: mole fraction 1, averages equal the species values
assert(abs(gpfnsp - dGf0) < tol);
assert(abs(mf - 1) < 1e-12);
assert(abs(aveHbound - nH) < 1e-12 && abs(aveZi - zi) < 1e-12);
% activity coefficient ln(gamma) = -alpha z^2 sqrt(I) / (1 + 1.6 sqrt(I))
assert(abs(lambda - exp(-rtAlpha(temp) * zi^2 * dhFactor(is) / (R * temp))) < 1e-12);
% literature anchor: RTalpha = 2.91482 kJ/mol at 298.15 K (Alberty 2003), recovered from lambda
% of a monovalent ion; the temperature polynomial of Eq. 3.7-4 gives 2.91489 at 298.15 K, so the
% tolerance is 1e-4 kJ/mol
rtAlphaFromLambda = -log(lambda) * R * temp / dhFactor(is);
assert(abs(rtAlphaFromLambda - 2.91482) < 1e-4);
% the enthalpy is never computed (limitation in the header)
assert(isnan(dHf0));

%% all optional inputs given, printLevel 1 (prints that no multiple precision toolbox is used)

[dGf0Full, dHf0Full] = calcdGHT(dGzero, [], zi, nH, pHr, is, temp, 0, 1, 1, 1);
assert(abs(dGf0Full - dGf0) < tol && isnan(dHf0Full));

%% two species (acetic acid / acetate, Alberty's dGf0 at 298.15 K) at pH 7, I = 0

% species ordered acid (z = 0, nH = 4) then acetate (z = -1, nH = 3)
dGzero = [-396.46; -369.31]; zi = [0; -1]; nH = [4; 3];
[dGf0, ~, mf, aveHbound, aveZi, lambda, gpfnsp] = calcdGHT(dGzero, [], zi, nH, 7, 0, Tstd);
speciesG = dGzero - nH * R * Tstd * log(10^-7);
assert(norm(gpfnsp - speciesG) < tol);
% reactant energy from the partition function (no overflow at these magnitudes)
assert(abs(dGf0 - (-R * Tstd * log(sum(exp(-speciesG / (R * Tstd)))))) < 1e-8);
% mole fractions sum to one; their ratio follows Henderson-Hasselbalch with
% pKa = (dGf0(acetate) - dGf0(acid)) / (R T ln 10)
pKa = (dGzero(2) - dGzero(1)) / (R * Tstd * log(10));
assert(abs(pKa - 4.76) < 0.01);            % literature pKa of acetic acid, to 2 decimals
assert(abs(sum(mf) - 1) < 1e-12);
assert(abs(mf(2) / mf(1) - 10^(7 - pKa)) / 10^(7 - pKa) < 1e-9);
assert(abs(aveHbound - mf' * nH) < 1e-12 && abs(aveZi - mf' * zi) < 1e-12);
% at zero ionic strength every activity coefficient is one
assert(all(abs(lambda - 1) < 1e-15));

%% no Legendre transformation for pH: no pH term, ionic-strength term without -nH

dGzero = [-396.46; -369.31]; zi = [0; -1]; nH = [4; 3]; is = 0.1;
[~, ~, ~, ~, ~, ~, gpfnsp] = calcdGHT(dGzero, [], zi, nH, 7, is, Tstd, 0, 0);
assert(norm(gpfnsp - (dGzero - rtAlpha(Tstd) * zi.^2 * dhFactor(is))) < tol);

%% electrical potential: with or without its Legendre transformation the result is unchanged

% the electrical term is always 0 (the term itself is inside "if 0", line 151)
dGf0Chi0 = calcdGHT(dGzero, [], zi, nH, 7, is, Tstd, 0, 1, 1);
dGf0Chi = calcdGHT(dGzero, [], zi, nH, 7, is, Tstd, 50, 1, 1);
dGf0NoChi = calcdGHT(dGzero, [], zi, nH, 7, is, Tstd, 50, 1, 0);
assert(abs(dGf0Chi - dGf0Chi0) < tol && abs(dGf0NoChi - dGf0Chi0) < tol);

%% standard enthalpies given: van't Hoff adjustment of the species energies to 310.15 K

dGzero = -100; dHzero = -50; zi = -1; nH = 3; is = 0.25; temp = 310.15;
[~, dHf0, ~, ~, ~, ~, gpfnsp] = calcdGHT(dGzero, dHzero, zi, nH, 7, is, temp);
dGzeroT = dGzero * temp / Tstd + dHzero * (1 - temp / Tstd);
expected = dGzeroT - nH * R * temp * log(10^-7) - rtAlpha(temp) * (zi^2 - nH) * dhFactor(is);
assert(abs(gpfnsp - expected) < tol);
assert(isnan(dHf0));

%% large energies: the log-sum-exp (local maxstar) stays finite where exp would overflow

% -gpfnsp/(RT) is about 1.2e3, beyond exp's range (about 709)
dGzero = [-3000; -2990]; zi = [0; 0]; nH = [0; 0];
[dGf0, ~, mf] = calcdGHT(dGzero, [], zi, nH, 7, 0, Tstd);
x = -dGzero / (R * Tstd);
assert(isinf(exp(x(1))));
% closed form for two terms: log(e^x1 + e^x2) = x1 + log(1 + e^(x2 - x1))
assert(abs(dGf0 - (-R * Tstd * (x(1) + log1p(exp(x(2) - x(1)))))) < 1e-9);
assert(all(isfinite(mf)) && abs(sum(mf) - 1) < 1e-12);

%% pH outside 5 - 9: a warning, the result is still computed

lastwarn('');
dGf0 = calcdGHT(-100, [], -1, 3, 4, 0, Tstd);
assert(strcmp(lastwarn, 'pHr out of applicable range, 5 - 9.'));
assert(abs(dGf0 - (-100 - 3 * R * Tstd * log(10^-4))) < tol);

%% temperature or ionic strength outside the tabulated range: errors

assert(verifyCobraFunctionError('calcdGHT', 'inputs', {-100, [], -1, 3, 7, 0, 260}, ...
    'testMessage', 'temperature out of applicable range, 273.15 - 313.15'));
assert(verifyCobraFunctionError('calcdGHT', 'inputs', {-100, [], -1, 3, 7, 0, 320}, ...
    'testMessage', 'temperature out of applicable range, 273.15 - 313.15'));
assert(verifyCobraFunctionError('calcdGHT', 'inputs', {-100, [], -1, 3, 7, 0.5, Tstd}, ...
    'testMessage', 'ionic strength out of applicable range, 0 - 0.35'));
assert(verifyCobraFunctionError('calcdGHT', 'inputs', {-100, [], -1, 3, 7, -0.1, Tstd}, ...
    'testMessage', 'ionic strength out of applicable range, 0 - 0.35'));

% restore the directory
cd(currentDir)
