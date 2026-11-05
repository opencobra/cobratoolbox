% The COBRAToolbox: testRobustnessAnalysis.m
%
% Purpose:
%     - %testRobustnessAnalysis tests the basic functionality of robustnessAnalysis
%       and doubleRobustnessAnalysis
%       robustnessAnalysis Performs robustness analysis for a reaction of
%       interest and an objective of interest
%
%       [controlFlux, objFlux] = robustnessAnalysis(model, controlRxn, nPoints,
%       plotResFlag, objRxn, objType)
%       This function is used to compute and plot the value of the model objective
%       function as a function of flux values for a reaction of interest (controlRxn)
%       as a means to analyze the network robustness with respect to that reaction.
%
%       doubleRobustnessAnalysis Performs robustness analysis for a pair of reactions of
%       interest and an objective of interest
%
%       [controlFlux1, controlFlux2, objFlux] = doubleRobustnessAnalysis(model,
%       controlRxn1, controlRxn2, nPoints, plotResFlag, objRxn, objType)
%
% Function under test:
%     src/analysis/robustnessAnalysis/robustnessAnalysis.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRobustnessAnalysis'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
prepareTest('needsLP', true);

% set the tolerance
tol = 1e-3;

% Testing robustnessAnalysis

% 1. Set input parameters.
model = getDistributedModel('ecoli_core_model.mat');
controlRxn = 'PFK';

% 2. Run robustnessAnalysis.
figure(1);
[controlFlux, objFlux] = robustnessAnalysis(model, controlRxn);

% 3. These are the expected values.
controlExpected = [0; 9.295; 18.591;
                   27.8857; 37.1810; 46.4763;
                   55.7715; 65.066; 74.3621;
                   83.6573; 92.9526; 102.2478;
                   111.5431; 120.8384; 130.1336;
                   139.4289; 148.7242; 158.0194;
                   167.3147; 176.6100;];
objExpected = [0.7040; 0.8650; 0.8194;
               0.7737; 0.72815; 0.6825;
               0.6369; 0.5893; 0.5402;
               0.4910; 0.4419; 0.3928;
               0.3437; 0.2946; 0.2455;
               0.1964; 0.1473; 0.0982;
               0.0491; 0;];

% 4. Check if obtained values match with expected ones within tolerance.
assert(all(abs(controlFlux - controlExpected) < tol))
assert(all(abs(objFlux - objExpected) < tol))

% Testing doubleRobustnessAnalysis

% 1. Set input parameters.
controlRxn1 = 'PGI';
controlRxn2 = 'PFK';

% 2. Run doubleRobustnessAnalysis.
figure(2);
[controlFlux1, controlFlux2, objFlux] = doubleRobustnessAnalysis(model, controlRxn1, controlRxn2, 5);

% 3. These are the expected values.
controlExpected1 = [-50.0000000000000; -35.0000000000000; -20.0000000000000; -5; 10;];
controlExpected2 = [0; 44.1525000000000; 88.3050000000000; 132.457500000000; 176.610000000000;];
% objExpected = [0, 0, 0, 0, 0;
%                0.330465626067129, 0.330465626067130, 0.255797293399143, 0.0278870926766020, 0;
%                0.660931252134257, 0.566576530713856, 0.339677951611958, 0.111767750889414, 0;
%                0.188965536094505, 0.640893960027506, 0.407434227171747, 0.173974494315987, 0;
%                0, 0, 0, 0, 0; ];
%solvers return NaN objective rather than zero if there is not solution
objExpected = [0, 0, 0, NaN, NaN;
               0.330465626067129, 0.330465626067130, 0.255797293399143, 0.0278870926766020, NaN;
               0.660931252134257, 0.566576530713856, 0.339677951611958, 0.111767750889414, NaN;
               0.188965536094505, 0.640893960027506, 0.407434227171747, 0.173974494315987, NaN;
               NaN, 0, 0, 0, 0; ];
% 4. Check if obtained values match with expected ones within tolerance.
assert(all(abs(controlFlux1 - controlExpected1) < tol))
assert(all(abs(controlFlux2 - controlExpected2) < tol))
objFlux(isnan(objFlux))=0;
objExpected(isnan(objExpected))=0;
assert(all(all(abs(objFlux - objExpected) < tol)))

%% an explicit objective reaction and objective sense, without a plot

objRxn = 'ATPM';
for objType = {'max', 'min'}
    [controlFlux, objFlux] = robustnessAnalysis(model, controlRxn, 4, false, objRxn, objType{1});

    % the control values span the range of the control reaction, and every objective value is the
    % optimum of objRxn with the control reaction fixed at that value (NaN where infeasible)
    assert(isequal(size(controlFlux), [4, 1]) && isequal(size(objFlux), [4, 1]));
    assert(abs(controlFlux(1)) < tol && abs(controlFlux(end) - 176.61) < tol);
    modelObj = changeObjective(model, objRxn);
    for i = 1:numel(controlFlux)
        solFixed = optimizeCbModel(changeRxnBounds(modelObj, controlRxn, controlFlux(i), 'b'), objType{1});
        assert((isnan(objFlux(i)) && isnan(solFixed.f)) || abs(objFlux(i) - solFixed.f) < tol);
    end
end

%% a control reaction that is not in the model is refused

assert(verifyCobraFunctionError('robustnessAnalysis', 'inputs', {model, 'notAReaction'}, ...
                                'testMessage', 'Control reaction does not exist!'));

% close figures
close all;

% change the directory
cd(currentDir)
