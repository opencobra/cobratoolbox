% The COBRAToolbox: testMetsToKeep.m
%
% Purpose:
%     - metsToKeep removes metabolomics measurements of low quality: a compound is kept when its
%     replicate relative standard deviations (RSDqc_*) and the mean plus standard deviation of its
%     calibration relative error are below thresholds (default 25).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/metabolomics/metsToKeep.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMetsToKeep'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% The function prints a short summary; it is captured with evalc (Constitution VII-A) and the
% captured text uses the unique variable name printedText.

% long-format measurements (first column is an id that is dropped in the result)
dataOrg = table((1:4)', ["m1"; "m1"; "m2"; "m3"], [10; 11; 12; 13], 'VariableNames', {'id', 'compound', 'area'});
% quality of the replicate samples per compound (the first variable is the placeholder that becomes 'keep')
metRep = table(zeros(3, 1), ["m1"; "m2"; "m3"], [5; 30; 10], [6; 10; 50], 'VariableNames', {'Var1', 'compound', 'RSDqc_A', 'RSDqc_B'});
% relative errors of the calibration samples
calRelErr = table(["m1"; "m1"; "m2"; "m3"], [10; -5; 3; 40], 'VariableNames', {'compound', 'RE'});

%% default thresholds (25)

% m1: replicate RSD 5 and 6 are below 25 and the calibration error 2.5 + 10.6 is below 25 -> keep
% m2: replicate RSD 30 is above 25 -> drop
% m3: replicate RSD 50 is above 25 and the calibration error 40 is above 25 -> drop
printedText = evalc('[cleanedData, summary] = metsToKeep(dataOrg, metRep, calRelErr);');
assert(isequal(summary.keep', [1 0 0]));
assert(isequal(summary.REcheck', [1 1 0]));
assert(isequal(summary.RSDqcCheck', [1 0 0]));
assert(abs(summary.sumRE(1) - 2.5) < 1e-12 && summary.sumRE(2) == 3 && summary.sumRE(3) == 40);
% only the rows of the kept compound remain and the id column is dropped
assert(isequal(cleanedData.Properties.VariableNames, {'compound', 'area'}));
assert(isequal(cleanedData.compound, ["m1"; "m1"]) && isequal(cleanedData.area, [10; 11]));
assert(contains(printedText, 'Number of metabolites in the dataset: 3'));
assert(contains(printedText, 'Number of metabolites left after quality check: 1'));

%% thresholds can be given

printedText = evalc('[~, summary] = metsToKeep(dataOrg, metRep, calRelErr, struct(''tresholdRSDqc'', 60, ''tresholdCalRE'', 50));');
assert(isequal(summary.keep', [1 1 1]));
% a threshold of 1 keeps nothing
printedText = evalc('[cleanedData, summary] = metsToKeep(dataOrg, metRep, calRelErr, struct(''tresholdRSDqc'', 1));');
assert(isequal(summary.keep', [0 0 0]) && height(cleanedData) == 0);
% a structure without the two fields leaves the defaults
printedText = evalc('[~, summary] = metsToKeep(dataOrg, metRep, calRelErr, struct(''other'', 1));');
assert(isequal(summary.keep', [1 0 0]));

%% compounds without calibration data are dropped; an infinite error counts as missing, a NaN as 0

onlyFirstCompound = table("m1", Inf, 'VariableNames', {'compound', 'RE'});
printedText = evalc('[~, summary] = metsToKeep(dataOrg, metRep, onlyFirstCompound);');
assert(isequal(summary.keep', [1 0 0]));          % m1 is kept (its error is ignored); m2, m3 have no calibration
withNaN = table(["m1"; "m2"], [NaN; 1], 'VariableNames', {'compound', 'RE'});
printedText = evalc('[~, summary] = metsToKeep(dataOrg, metRep, withNaN);');
assert(isequal(summary.keep', [1 0 0]) && summary.sumRE(1) == 0);

% change the directory
cd(currentDir)
