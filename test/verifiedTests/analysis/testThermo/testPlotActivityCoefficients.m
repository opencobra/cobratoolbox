% The COBRAToolbox: testPlotActivityCoefficients.m
%
% Purpose:
%     - plotActivityCoefficients(modelT) collects the activity coefficients of all metabolite
%       species (modelT.met(i).lambda), prints those below 0.01, draws their histogram over the
%       bins 0:0.01:1, and draws in a new figure the extended Debye-Hueckel activity coefficient
%       for charges 1 to 4 over ionic strengths 0 to 0.25 M at modelT.temp. It returns the
%       histogram counts n, the bin edges and lambda. Quarantined: no behaviour of
%       plotActivityCoefficients is asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/thermo/protons/plotActivityCoefficients.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - reporting for a model, no solver; a test would use a hand-built model with S,
%     mets, metNames, temp, gasConstant and met(i).lambda / met(i).aveZi, with invisible
%     figures closed at the end.
%
% Coverage exemptions:
%     every line - plotActivityCoefficients is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The output lambda holds the ionic-strength curves, not the activity coefficients of the species
%       SEVERITY: wrong-result
%       TRIGGER: any call, for example modelT.S = zeros(2, 1), modelT.mets = {'a'; 'b'},
%         modelT.metNames = {'A'; 'B'}, modelT.temp = 298.15, modelT.gasConstant = 8.314472e-3,
%         modelT.met(1).lambda = [0.5 0.005], modelT.met(1).aveZi = -1, modelT.met(2).lambda = [],
%         modelT.met(2).aveZi = 0, [n, edges, lambda] = plotActivityCoefficients(modelT)
%       OBSERVED: MATLAB R2025a, 2026-11-16: size(n) = size(edges) = [1 101] as expected, but
%         size(lambda) = [4 1000] and lambda(1:4, 1) = [1; 1; 1; 1], lambda(1:4, 2) = [0.9820;
%         0.9300; 0.8494; 0.7482]: lines 62-66 reuse the variable lambda of lines 34-43 for the
%         curves of charges 1 to 4, overwriting the species values
%       EXPECTED: lambda = [0.5 0.005], the activity coefficients of the metabolite species, as
%         the OUTPUTS section says
%       LINES: 65
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotActivityCoefficients'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
