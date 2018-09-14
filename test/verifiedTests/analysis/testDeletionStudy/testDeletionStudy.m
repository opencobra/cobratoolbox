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
model = getDistributedModel('ecoli_core_model.mat');

% list of solver packages
solverPkgs = {'tomlab_cplex', 'gurobi', 'glpk'};
%Load reference data.
load('rxnDeletionData.mat');

for k = 1:length(solverPkgs)

    fprintf(' -- Running testfindBlockedReaction using the solver interface: %s ... ', solverPkgs{k});

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverLPOK

        fprintf('\n*** Test basic single gene deletion: ***\n\n');

        %deleting gene for 'ENO')
        [grRatio, grRateKO, grRateWT, hasEffect, delRxns, fluxSolution] = singleGeneDeletion(model, 'FBA', {model.genes{1:4},'b2779'});

        % check if correct hasEffect value
        assert(isequal(hasEffect,hasEffectSD))

        % check if correctly deleted reactions
        assert(isequal(delRxns,delRxnsSD))

        % check if correct grRateKO value
        assert(all(abs(grRateKO-grRateSdKO) < tol))

        % check if correct grRateWT value
        assert(abs(grRateWT-grRateWTRef) < tol)

        %Now, we combine gene 1 and two. 1 has no effect, so 1 and 2 should
        %yield the same as 2.
        modelForUTest = model;
        modelForUTest.genes([1,5]) = strcat(model.genes(1),{'.1','.2'});
        targetValues = [1 2 3 4 ];
        %Check functionality of uniqueGene Flag
        [grRatio, grRateKO, grRateWT, hasEffect, delRxns] = singleGeneDeletion(modelForUTest,'FBA',modelForUTest.genes([1 2 3 4]),true,true);
                % check if correct hasEffect value
        assert(isequal(hasEffect,hasEffectSD(targetValues)))

        % check if correctly deleted reactions
        assert(isequal(delRxns,delRxnsSD(targetValues)))

        % check if correct grRateKO value
        assert(all(abs(grRateKO-grRateSdKO(targetValues)) < tol))

        % check if correct grRateWT value
        assert(abs(grRateWT-grRateWTRef) < tol)

        [grRatioDble, grRateKO, grRateWT] = doubleGeneDeletion(model, 'FBA', model.genes(1:4), {'b2779','b2287'});
        %Check against reference
        assert(all(all(abs(grRatioDble-grRatioDbRef) < tol)));

        % check if correct grRateDble value
        assert(all(all(abs(grRateKO-grRateDbKO) < tol)));

        % check if correct grRateWT value
        assert(abs(grRateWT - grRateWTRef) < tol);

        %% singleRxnDeletion Test
        fprintf('\n\nStarting singleRxnDeletion test:\n');

        [test_grRatio, test_grRateKO, test_grRateWT, test_hasEffect, test_delRxn]= singleRxnDeletion(model, 'FBA');

        grRatio_Rxn_Ref(isnan(grRatio_Rxn_Ref)) = -1;
        test_grRatio(isnan(test_grRatio)) = -1;

        % check if correct grRatio values
        for i = 1:length(grRatio_Rxn_Ref)
            assert(abs(grRatio_Rxn_Ref(i) - test_grRatio(i)) < tol)
        end

        grRateKO_Rxn_Ref(isnan(grRateKO_Rxn_Ref)) = -1;
        test_grRateKO(isnan(test_grRateKO)) = -1;

        % check if correct grRateKO values
        for i = 1:length(grRateKO_Rxn_Ref)
            assert(abs(grRateKO_Rxn_Ref(i) - test_grRateKO(i)) < tol)
        end

        % check if correct grRateWT values
        assert(abs(grRateWTRef - test_grRateWT) < tol)

        % check if correct delRxn values
        assert(isequal(delRxn_Rxn_Ref, test_delRxn))
    end

    % output a success message
    fprintf('Done.\n');
end

% change back to root folder
cd(currentDir)
