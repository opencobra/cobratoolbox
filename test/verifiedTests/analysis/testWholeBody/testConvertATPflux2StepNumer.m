% The COBRAToolbox: testConvertATPflux2StepNumer.m
%
% Purpose:
%     - convertATPflux2StepNumer converts an ATP hydrolysis flux into the corresponding energy (kJ
%     and kcal), walking distance in metres and number of steps, using sex-dependent stride length.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/convertATPflux2StepNumer.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The function name inside the file differs from the file name
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: the file is named convertATPflux2StepNumer.m but declares
%         convertATPflux2StepNumber, so MATLAB resolves calls through the file name and the declared
%         name is ignored
%       EXPECTED: the declared name equal to the file name
%       LINES: 1
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertATPflux2StepNumer'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons (relative)
tol = 1e-12;

%% male stride (0.415 of the height)

[energyKJ, energyKcal, meter, stepNumber] = convertATPflux2StepNumer(1000, 'male', 70, 175);
% 1000 flux units = 1 mol ATP, 64 kJ
assert(abs(energyKJ - 64) < tol);
assert(abs(energyKcal - 64 * 0.239006) < tol * 64);
assert(abs(meter - 64 * 1000 / (3 * 70)) < tol * 305);
% stride 0.415 * 175 cm = 72.625 cm
assert(abs(stepNumber - meter / 0.72625) < tol * 420);

%% any other value of sex uses the female stride (0.413 of the height)

[~, ~, meter, stepNumber] = convertATPflux2StepNumer(1000, 'female', 70, 175);
assert(abs(stepNumber - meter / (0.413 * 175 / 100)) < tol * 422);
[~, ~, ~, stepNumberOther] = convertATPflux2StepNumer(1000, 'unknown', 70, 175);
assert(stepNumberOther == stepNumber);

%% no flux, no energy

[energyKJ, ~, meter, stepNumber] = convertATPflux2StepNumer(0, 'male', 70, 175);
assert(energyKJ == 0 && meter == 0 && stepNumber == 0);

% change the directory
cd(currentDir)
