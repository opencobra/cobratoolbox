% The COBRAToolbox: testTransform.m
%
% Purpose:
%     - Transform computes the Legendre-transformed standard Gibbs energy of formation of a
%     metabolite at a given pH, ionic strength and temperature from its pseudoisomer species (dG0,
%     number of H, charge) with the extended Debye-Hueckel equation.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/trainingModel/Transform.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 39-41 of Transform.m (the catch block) are not reached: the statement in the try block
%     does not fail for numeric input.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTransform'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: the expected values below were computed
% independently with the same formula (dG0' = -RT ln sum exp(-(dG0 + nH*(RT ln10 pH + DH) - z^2 DH)/RT),
% R = 8.3144621e-3 kJ/(K mol)); rounding is far below 1e-9
tol = 1e-9;
R = 8.3144621e-3;     % gas constant in kJ/(K mol), the value used by Transform
T = 298.15;           % temperature in K

%% one species with ionic strength (reference computed independently, see above)

assert(abs(Transform([-100 2 1], 7, 0.1, 298.15) - (-19.47579317690459)) < 1e-8);

%% one species without ionic strength: only the pH term

expected = -100 + 2 * R * T * log(10) * 7;
assert(abs(Transform([-100 2 1], 7, 0, T) - expected) < tol);

%% two species of the same metabolite combine like a Boltzmann sum

% the more stable species dominates, but both contribute: the result is below the lower value
single = Transform([-100 2 1], 7, 0, T);
both = Transform([-100 2 1; -90 1 0], 7, 0, T);
assert(both < single);
assert(abs(both - (-R * T * log(exp(-single / (R * T)) + exp(-(-90 + 1 * R * T * log(10) * 7) / (R * T))))) < tol);

%% the ionic-strength term depends on the charge

withCharge = Transform([-100 0 2], 7, 0.1, T);
withoutCharge = Transform([-100 0 0], 7, 0.1, T);
assert(withCharge < withoutCharge);
assert(abs(withoutCharge - (-100)) < tol);

% change the directory
cd(currentDir)
