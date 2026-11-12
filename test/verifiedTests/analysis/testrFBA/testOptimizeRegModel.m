% The COBRAToolbox: testOptimizeRegModel.m
%
% Purpose:
%     - testrFBA tests the optimizeRegModel function and its different outputs
%
% Function under test:
%     src/analysis/rFBA/optimizeRegModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on the regulatory E. coli core model modelReg.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimizeRegModel'));
cd(fileDir);

% require LP and QP solvers; skip gracefully if none are available
solvers = prepareTest('needsLP', true, 'needsQP', true);

% load model and test data
load('modelReg.mat');
load('refData_optimizeRegModel.mat');

%set tolerance
tol = 1e-4;

% solver packages
solverPkgs = solvers.LP;

% QP solvers
QPsolverPkgs = solvers.QP;

for k =1:length(solverPkgs)

    for j=1:length(QPsolverPkgs)%QP solvers

        solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
        solverQPOK = changeCobraSolver(QPsolverPkgs{j}, 'QP', 0);

        if solverLPOK && solverQPOK
             %Without initial state
            [FBAsolstest,DRgenestest,constrainedRxnstest,cycleStarttest,statestest] = optimizeRegModel(modelReg);
            assert(isequal(cycleStart,cycleStarttest))
            assert(isequal(DRgenestest,DRgenes))
            assert(isequal(constrainedRxnstest,constrainedRxns))
            assert(isequal(statestest,states))
            %only compare objective because solution may vary
            assert( FBAsolstest{1}.f - FBAsols{1}.f < tol)

            %With initial state
            initialStates = false.*ones(length(modelReg.regulatoryGenes)+length(modelReg.regulatoryInputs1)+length(modelReg.regulatoryInputs2),1);
            [FBAsolstest,DRgenestest,constrainedRxnstest,cycleStarttest,statestest] = optimizeRegModel(modelReg,initialStates);
            assert(isequal(cycleStart,cycleStarttest))
            assert(isequal(DRgenestest,DRgenes))
            assert(isequal(constrainedRxnstest,constrainedRxns))
            assert(isequal(statestest,states))
            %only compare objective because solution may vary
            assert( FBAsolstest{1}.f - FBAsols{1}.f < tol)

            % the growth rate of the regulated model is the reference from both sides
            assert(abs(FBAsolstest{1}.f - FBAsols{1}.f) < tol)

            % a first state of the wrong length is refused
            assert(verifyCobraFunctionError('optimizeRegModel', 'inputs', {modelReg, [true; false]}, ...
                                            'testMessage', 'initialRegState is invalid length'));
        end
    end

    fprintf('Done.\n');
end

 % change the directory
 cd(currentDir)
