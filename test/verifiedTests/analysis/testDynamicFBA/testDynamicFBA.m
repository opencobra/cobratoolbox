% The COBRAToolbox: testDynamicFBA.m
%
% Purpose:
%     - testDynamicFBA tests the DynamicFBA function and its different outputs
%
% Function under test:
%     src/analysis/dynamicFBA/dynamicFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The number of tracked exchange reactions is printed on every call
%       SEVERITY: cosmetic
%       TRIGGER: any call of dynamicFBA
%       OBSERVED: the statement length(excRxnNames) has no semicolon, so ans = 16 is displayed
%       EXPECTED: no output
%       LINES: 66
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDynamicFBA'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true);

model = getDistributedModel('ecoli_core_model.mat');

load('testData_dynamicFBA.mat');

smi = {'EX_glc(e)', 'EX_ac(e)'}; % exchange reaction for substrate in environment

smc = [10.8; 0.4]; % Glucose, Acetate concentration (all in mM)

Xec = 0.001; % initial biomass
dt = 1.0/100.0; % time steps
time = 1.0/dt; % simulation time

%define solver packages
solverPkgs = solvers.LP;

% set tolerance
tol = 1e-8;

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverLPOK == 1
        fprintf('   Testing dynamicFBA using %s ... ', solverPkgs{k});
        [concentrationMatrixtest, excRxnNamestest, timeVectest, biomassVectest] = dynamicFBA(model, smi, smc, Xec, dt, time);

        assert(any(any(abs(concentrationMatrixtest - concentrationMatrix) < tol)))
        assert(isequal(excRxnNamestest, excRxnNames))
        assert(isequal(timeVectest, timeVec))
        assert(any(abs(biomassVectest - biomassVec) < tol))

        % the biomass follows from the unique optimal growth rate, so all of it must agree
        assert(norm(biomassVectest - biomassVec, inf) < 1e-6)

        % concentrations are never negative, and the substrate column starts at the given values
        assert(all(concentrationMatrixtest(:) >= 0))
        assert(abs(concentrationMatrixtest(strcmp(excRxnNamestest, 'EX_glc(e)'), 1) - smc(1)) < tol)
        assert(abs(concentrationMatrixtest(strcmp(excRxnNamestest, 'EX_ac(e)'), 1) - smc(2)) < tol)

        %% the nutrients run out: the simulation stops before the last step

        printed = evalc('[concentrationShort, ~, timeShort, biomassShort] = dynamicFBA(model, smi, [0.002; 0], Xec, dt, time);');
        assert(contains(printed, 'No feasible solution - nutrients exhausted'))
        assert(numel(timeShort) < time + 1)
        assert(numel(biomassShort) == numel(timeShort))
        assert(size(concentrationShort, 2) == numel(timeShort))
        assert(all(diff(biomassShort) > 0))

        %% explicit reactions to plot and excluded uptake reactions

        % oxygen is not excluded here, so its uptake is followed; its concentration falls from the
        % assumed 1000 mM because no initial concentration is given
        [concentrationO2, excRxnNamesO2] = dynamicFBA(model, smi, smc, Xec, dt, 2, {'EX_glc(e)'}, ...
                                                      {'EX_co2(e)', 'EX_h2o(e)', 'EX_h(e)'});
        rowO2 = strcmp(excRxnNamesO2, 'EX_o2(e)');
        assert(nnz(rowO2) == 1);
        assert(concentrationO2(rowO2, 1) == 1000 && concentrationO2(rowO2, end) < 1000);

        % only the requested reaction is drawn in the right panel
        assert(numel(findobj(gca, 'Type', 'line')) == 1);

        %% progress lines are printed when no text waitbar is used

        global WAITBAR_TYPE
        savedWaitbar = WAITBAR_TYPE;
        WAITBAR_TYPE = 0;
        printed = evalc('dynamicFBA(model, smi, smc, Xec, dt, 2);');
        WAITBAR_TYPE = savedWaitbar;
        assert(contains(printed, sprintf('2\t')));

        %% a substrate that is not an exchange reaction is refused

        assert(verifyCobraFunctionError('dynamicFBA', 'inputs', {model, {'PGI'}, 1, Xec, dt, 2}, ...
                                        'testMessage', 'Invalid substrate uptake reaction!'));
    end
end

% close open figure
close all

% change the directory
cd(currentDir)
