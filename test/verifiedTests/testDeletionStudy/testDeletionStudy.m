%testDeletionStudy tests the basic functionality of
%singleGeneDeletion/doubleGeneDeletion/singleRxnDeletion
%   Makes sure that these resultant values are correct:
%       singleGeneDeletion - hasEffect, delRxns, grRateKO, grRateWT
%       doubleGeneDeletion - grRatioDble, grRateKO, grRateWT
%       singleRXDeletion - hasEffect, delRxn, grRateKO, grRateWT
%   returns 1 if all are correct, else 0
%
%   Joseph Kang 11/16/09

% define global paths
global path_TOMLAB
global path_GUROBI

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testDeletionStudy']);

tol = 1e-6;

%load model
load('ecoli_core_model', 'model');

% list of solver packages
solverPkgs = {'tomlab_cplex', 'gurobi6', 'glpk'};

for k = 1:length(solverPkgs)

    fprintf(' -- Running testfindBlockedReaction using the solver interface: %s ... ', solverPkgs{k});

    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        addpath(genpath(path_GUROBI));
    end

    solverLPOK = changeCobraSolver(solverPkgs{k});

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

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        rmpath(genpath(path_GUROBI));
    end

    % output a success message
    fprintf('Done.\n');
end

% change back to root folder
cd(CBTDIR);
