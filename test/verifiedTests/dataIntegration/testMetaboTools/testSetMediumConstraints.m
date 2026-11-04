% The COBRA Toolbox: testSetMediumConstraints.m
%
% Purpose:
%     - test the setMediumConstraints function
%
% Function under test:
%     src/dataIntegration/metabotools/setMediumConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on Recon 2.05, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below. The coverage plugin reports the conc2Rate call
%     in the loop as not run although it is (the section on uptake rates asserts its result, and the
%     profiler counts it), so this was measured with the profiler.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Author:
%     - Loic Marx, December 2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which(mfilename));
cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

% load reference data 
load('refData_setMediumConstraints.mat');

% define input
model = getDistributedModel('Recon2.v05.mat'); 
set_inf = 1000;
current_inf = 500; 
medium_composition = {'EX_ala_L(e)';'EX_arg_L(e)'}; % related to the RPMI composition
met_Conc_mM = [1;2]; %Change in metabolite concentration (mM)
cellConc = 1; 
t = 1; % Time in hours
cellWeight = 500 * 1e-12; 
mediumCompounds = {'EX_co2(e)';'EX_h(e)'}; %metabolites that are uptake from the medium but not captured by the measured data
mediumCompounds_lb = -10;
customizedConstraints = {'EX_o2(e)'}; %limit the model behaviour to the secretion of oxygen
customizedConstraints_lb = 1;
customizedConstraints_ub = 2;
close_exchanges = 1; % 1 : close exchange , 0: open exchange 

% set up the tolerance
tol = 1e-4;

% generate data
[modelMedium, basisMedium] = setMediumConstraints(model, set_inf, current_inf, medium_composition, met_Conc_mM, cellConc, t, cellWeight, mediumCompounds, mediumCompounds_lb, customizedConstraints, customizedConstraints_ub, customizedConstraints_lb, close_exchanges);

% if customizedConstraints, customizedConstraints_ub, customizedConstraints_lb close_exchanges are not defined 
[modelMedium_noCustomizedConstraints, basisMedium_noCustomizedConstraints] = setMediumConstraints(model, set_inf, current_inf, medium_composition, met_Conc_mM, cellConc, t, cellWeight, mediumCompounds, mediumCompounds_lb);

% comparison between refData and generated data 
assert(norm(modelMedium_ref.lb - modelMedium.lb) < tol) %lowerband
assert(norm(modelMedium_ref.ub - modelMedium.ub) < tol) %upperband
assert(isequal(basisMedium_ref, basisMedium))

% comparison between refData without constraint and generated data without constraints inputs
assert(norm(modelMedium_Ref_noCustomizedConstraints.lb - modelMedium_noCustomizedConstraints.lb) < tol) %lowerband
assert(norm(modelMedium_Ref_noCustomizedConstraints.ub - modelMedium_noCustomizedConstraints.ub) < tol) %upperband
assert(isequal(basisMedium_Ref_noCustomizedConstraints, basisMedium_noCustomizedConstraints))

%% the uptake rate of each medium metabolite comes from its concentration
for iMet = 1:numel(medium_composition)
    expectedUptake = conc2Rate(met_Conc_mM(iMet), cellConc, t, cellWeight);
    assert(abs(modelMedium.lb(findRxnIDs(model, medium_composition{iMet})) + expectedUptake) < tol);
end

%% without a medium composition only the basic medium and the custom constraints apply
[modelNoMedium, basisNoMedium] = setMediumConstraints(model, set_inf, current_inf, {}, [], cellConc, t, cellWeight, mediumCompounds, mediumCompounds_lb, customizedConstraints, customizedConstraints_ub, customizedConstraints_lb, close_exchanges);

% the output vector then lists the custom constraints only
assert(isequal(basisNoMedium, customizedConstraints));
% the basic medium and the custom constraint are set
assert(all(modelNoMedium.lb(findRxnIDs(model, mediumCompounds)) == mediumCompounds_lb));
assert(modelNoMedium.lb(findRxnIDs(model, 'EX_o2(e)')) == customizedConstraints_lb);
assert(modelNoMedium.ub(findRxnIDs(model, 'EX_o2(e)')) == customizedConstraints_ub);
% an exchange that belonged to the medium before is now closed for uptake like any other
assert(modelNoMedium.lb(findRxnIDs(model, 'EX_ala_L(e)')) == 0);

%% close_exchanges = 0 leaves the other exchange reactions as they were
[modelOpen, basisOpen] = setMediumConstraints(model, set_inf, current_inf, medium_composition, met_Conc_mM, cellConc, t, cellWeight, mediumCompounds, mediumCompounds_lb, {}, [], [], 0);

assert(isequal(basisOpen, mediumCompounds));
exchangeBool = strncmp(model.rxns, 'EX_', 3);
exchangeBool(ismember(model.rxns, [medium_composition; mediumCompounds])) = false;
% the infinite bounds are rescaled from current_inf to set_inf, all others are unchanged
expectedLb = model.lb;
expectedLb(expectedLb == -current_inf) = -set_inf;
assert(any(exchangeBool & expectedLb < 0));
assert(isequal(modelOpen.lb(exchangeBool), expectedLb(exchangeBool)));

% change the directory
cd(currentDir)
