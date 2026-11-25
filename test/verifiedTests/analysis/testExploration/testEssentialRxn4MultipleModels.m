% The COBRAToolbox: testEssentialRxn4MultipleModels.m
%
% Purpose:
%     - essentialRxn4MultipleModels sets the objective of each model of a structure (or of
%       each .mat file of a folder) to a given reaction, deletes every reaction in turn
%       (singleRxnDeletion) and returns a table with one row per reaction of the union of
%       the models (sorted) and one column per model holding the objective flux after the
%       deletion, or 'NotIncluded' when the model lacks the reaction; dataStruct holds the
%       reactions, growth rates and flux solutions of each model.
%     - Expected values are derived by hand from the two four- and five-reaction models below
%       (the maximal objective flux after each deletion is a short calculation written next to
%       the assertions).
%
% Function under test:
%     src/analysis/exploration/essentialRxn4MultipleModels.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - FBA (LP) through singleRxnDeletion with every available LP solver among
%     gurobi and glpk, on two hand-built toy models.
%
% Coverage exemptions:
%     Lines 63-64: unreachable; the function calls singleRxnDeletion(model) without a
%     reaction list, so the deleted reactions delRxn are always model.rxns and the set
%     difference of line 61 is always empty.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testEssentialRxn4MultipleModels'));
cd(fileDir);

% note the globals that exist now: the solver interface (parameter globals) and showprogress
% create globals, which are removed at the end
globalsBefore = who('global');

% the single reaction deletions solve LPs
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% model one: EX_A supplies at most 10 A; two parallel reactions R1 (at most 4) and R2 make B,
% and OBJ removes B. Deleting EX_A or OBJ gives 0, R1 gives 10 (R2 takes over), R2 gives 4
oneIds = {'EX_A'; 'R1'; 'R2'; 'OBJ'};
modelOne = createModel(oneIds, oneIds, {' -> A'; 'A -> B'; 'A -> B'; 'B -> '}, ...
    'upperBoundList', [10; 4; 1000; 1000], 'printLevel', 0);
% model two: R1 (at most 4) or the detour R3, R4 (R4 at most 3) make B; the optimum is 7.
% Deleting EX_A or OBJ gives 0, R1 gives 3, R3 or R4 gives 4
twoIds = {'EX_A'; 'R1'; 'R3'; 'R4'; 'OBJ'};
modelTwo = createModel(twoIds, twoIds, {' -> A'; 'A -> B'; 'A -> C'; 'C -> B'; 'B -> '}, ...
    'upperBoundList', [10; 4; 1000; 3; 1000], 'printLevel', 0);

% rows of the table: the union of the reactions, sorted (ASCII: uppercase O before R)
expectedRxns = {'EX_A'; 'OBJ'; 'R1'; 'R2'; 'R3'; 'R4'};
expectedOne = {0; 0; 10; 4; 'NotIncluded'; 'NotIncluded'};
expectedTwo = {0; 0; 3; 'NotIncluded'; 4; 4};

% LP optima are exact to the solver tolerance (about 1e-9); 1e-6 separates rounding from a
% wrong value, and the same tolerance bounds the residual of S*v = 0 and of the bounds
tol = 1e-6;

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing essentialRxn4MultipleModels using %s ... \n', solvers.LP{k});

        %% a structure of models

        allModels = struct('modelOne', modelOne, 'modelTwo', modelTwo);
        [essentialTable, dataStruct] = essentialRxn4MultipleModels(allModels, 'OBJ');
        assert(isequal(essentialTable.Properties.VariableNames, {'rxn', 'modelOne', 'modelTwo'}));
        assert(isequal(essentialTable.rxn, expectedRxns));
        % numbers and 'NotIncluded' in the right places, numbers within the tolerance
        for i = 1:numel(expectedRxns)
            for column = {'modelOne', 'modelTwo'; expectedOne, expectedTwo}
                value = essentialTable.(column{1}){i};
                expectedValue = column{2}{i};
                if ischar(expectedValue)
                    assert(ischar(value) && strcmp(value, expectedValue));
                else
                    assert(isnumeric(value) && abs(value - expectedValue) < tol);
                end
            end
        end

        % dataStruct: the reactions of each model (as a column, in model order), the growth
        % rate after each deletion, and a flux vector per deletion that is a steady state
        % within the bounds, carries no flux through the deleted reaction and whose OBJ flux
        % is the growth rate
        assert(isequal(fieldnames(dataStruct), {'modelOne'; 'modelTwo'}));
        modelPairs = {modelOne, dataStruct.modelOne, [0; 10; 4; 0]; modelTwo, dataStruct.modelTwo, [0; 3; 4; 4; 0]};
        for m = 1:2
            [testModel, modelData, expectedRates] = modelPairs{m, :};
            assert(isequal(modelData.rxnSubsystems, testModel.rxns));
            assert(max(abs(modelData.grRateKO - expectedRates)) < tol);
            nRxns = numel(testModel.rxns);
            assert(isequal(size(modelData.fluxSolution), [nRxns, nRxns]));
            for i = 1:nRxns
                flux = modelData.fluxSolution(:, i);
                assert(max(abs(testModel.S * flux)) < tol);
                assert(all(flux >= testModel.lb - tol) && all(flux <= testModel.ub + tol));
                assert(abs(flux(i)) < tol);
                assert(abs(flux(strcmp(testModel.rxns, 'OBJ')) - modelData.grRateKO(i)) < tol);
            end
        end

        %% a folder of .mat files

        % each file holds one model (any variable name); the column name is the file name
        % without '.mat' and without dots, followed by '_model'
        modelsDir = tempname;
        mkdir(modelsDir);
        model = modelOne;
        save(fullfile(modelsDir, 'model.one.mat'), 'model');
        anotherName = modelTwo;
        save(fullfile(modelsDir, 'two.mat'), 'anotherName');
        [folderTable, folderData] = essentialRxn4MultipleModels(modelsDir, 'OBJ');
        assert(isequal(folderTable.Properties.VariableNames, {'rxn', 'modelone_model', 'two_model'}));
        assert(isequal(folderTable.rxn, expectedRxns));
        % same values as for the structure: model one lacks R3 and R4, model two lacks R2
        assert(isequal(folderTable.modelone_model(5:6), {'NotIncluded'; 'NotIncluded'}));
        assert(strcmp(folderTable.two_model{4}, 'NotIncluded'));
        assert(abs(folderTable.modelone_model{3} - 10) < tol && abs(folderTable.modelone_model{4} - 4) < tol);
        assert(abs(folderTable.two_model{3} - 3) < tol && abs(folderTable.two_model{5} - 4) < tol);
        assert(max(abs(folderData.two_model.grRateKO - [0; 3; 4; 4; 0])) < tol);
        rmdir(modelsDir, 's');
        clear model anotherName
    end
end

% restore the solver state
CobraSolverState.restore(initialSolverState);

% remove the globals created during the test
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
