% The COBRAToolbox: testDeletionStudy.m
%
% Purpose:
%     - tests the basic functionality of singleGeneDeletion/doubleGeneDeletion/singleRxnDeletion
%       Makes sure that these resultant values are correct:
%       singleGeneDeletion - hasEffect, delRxns, grRateKO, grRateWT
%       doubleGeneDeletion - grRatioDble, grRateKO, grRateWT
%       singleRXDeletion - hasEffect, delRxn, grRateKO, grRateWT
%       returns 1 if all are correct, else 0
%
% Author:
%     - Original file: Joseph Kang 11/16/09
%     - CI integration: Laurent Heirendt

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDeletionStudy'));
cd(fileDir);

tol = 1e-6;

%load model
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% list of solver packages
solverPkgs = {'tomlab_cplex', 'gurobi6', 'glpk'};

for k = 1:length(solverPkgs)

    fprintf(' -- Running testfindBlockedReaction using the solver interface: %s ... ', solverPkgs{k});

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverLPOK

        fprintf('\n*** Test basic single gene deletion: ***\n\n');
        fprintf('\n*** Deleting gene for ENO: ***\n\n');

        %deleting gene for 'ENO')
        [grRatio, grRateKO, grRateWT, hasEffect, delRxns, fluxSolution] = singleGeneDeletion(model, 'FBA', {'b2779'});

        % check if correct hasEffect value
        assert(hasEffect == 1)

        % check if correctly deleted reactions
        assert(strcmp(delRxns{1}, 'ENO'))

        % check if correct grRateKO value
        assert(abs(grRateKO) < tol)

        % check if correct grRateWT value
        assert(abs(grRateWT) > tol)

        [grRatioDble, grRateKO, grRateWT] = doubleGeneDeletion(model, 'FBA', {'b2779'}, {'b2287'});

        % check if correct grRateDble value
        assert(abs(grRatioDble) < tol)

        % check if correct grRateKO value
        assert(abs(grRateKO) < tol)

        % check if correct grRateWT value
        assert(abs(grRateWT) > tol)

        %% singleRxnDeletion Test
        fprintf('\n\nStarting singleRxnDeletion test:\n');

        [test_grRatio, test_grRateKO, test_grRateWT, test_hasEffect, test_delRxn]= singleRxnDeletion(model, 'FBA');
        load('rxnDeletionData.mat');

        grRatio(isnan(grRatio)) = -1;
        test_grRatio(isnan(test_grRatio)) = -1;

        % check if correct grRatio values
        for i = 1:length(grRatio)
            assert(abs(grRatio(i) - test_grRatio(i)) < tol)
        end

        grRateKO(isnan(grRateKO)) = -1;
        test_grRateKO(isnan(test_grRateKO)) = -1;

        % check if correct grRateKO values
        for i = 1:length(grRateKO)
            assert(abs(grRateKO(i) - test_grRateKO(i)) < tol)
        end

        % check if correct grRateWT values
        assert(abs(grRateWT - test_grRateWT) < tol)

        % check if correct delRxn values
        assert(isequal(delRxn, test_delRxn))
    end

    % output a success message
    fprintf('Done.\n');
end

% change back to root folder
cd(currentDir)
