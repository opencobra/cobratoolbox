% The COBRAToolbox: testTestFermentationProducts.m
%
% Purpose:
%     - testFermentationProducts(model, microbeID, biomassReaction, database, inputDataFolder)
%       is a DEMETER test-suite function (its name starts with "test"; this file tests it).
%       It reads FermentationTable.txt from inputDataFolder (tab-separated, a header row of
%       fermentation pathways, one row per microbe with 1 where the microbe has the pathway),
%       removes the reference columns (headers starting with "Ref"), takes the end-product
%       exchange of each pathway set to 1 for microbeID, opens every EX_ reaction of the
%       model to -1000..1000, runs flux variability (fastFVA, or fluxVariability when fastFVA
%       stops) at 0% of the biomass optimum and reports, as metabolite names from
%       database.metabolites, the products whose exchange can be secreted (maximum flux
%       > 1e-6: TruePositives) and the others (FalseNegatives, also the exchanges not in the
%       model).
%     - The test writes FermentationTable.txt by hand in a temporary folder, runs the function
%       on a hand-built 6-reaction model and derives the expected lists from the network by
%       hand: methane is made from glucose and can be secreted, formate has an exchange and
%       nothing else (blocked), butanol has no exchange in the model. A reference column
%       holding 1 for the microbe proves the removal of line 50: a column that is not a
%       pathway of the function would otherwise stop line 118 (no matching pathway).
%     - The headers "Formate producer" and "Butanol producer" are not valid MATLAB names:
%       readtable warns (visibly) and readInputTableForPipeline returns them as written.
%     - fastFVA: the reactions to analyse are passed in alphabetical order, which differs
%       from their order in this model, so fastFVA stops with its "not sorted" error before
%       any CPLEX call on every machine, and the fallback to fluxVariability (lines 102-104)
%       is always taken; the warning of line 102 is checked. Both branches give the same
%       lists.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testFermentationProducts.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability (LP) on a hand-built model, every available LP solver among
%     gurobi and glpk.
%
% Coverage exemptions:
%     Line 43: runs initCobraToolbox when the global CBT_LP_SOLVER is empty; that resets the
%     path and solver state of the running session and saves the MATLAB path, so it is not
%     run here (precedent testGetDistributedModelFolder).
%     Lines 85-87, 121-122: branches for MATLAB releases before R2020a (version-specific; the
%     reference MATLAB is R2025a).
%     Lines 99-100: the fastFVA call completes only with IBM CPLEX (its cplexFVA binaries),
%     which is not an available COBRA solver on the reference machine; the test makes
%     fastFVA stop (see the purpose) so the fallback is used on every machine.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTestFermentationProducts'));
cd(fileDir);

% the solver set-up and the solver calls create global variables; they are removed at the end
globalsBefore = who('global');

% the function runs flux variability: an LP solver is needed
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% fastFVA reseeds the random number generator (rng('shuffle')) before it stops; the state of
% the session is restored at the end
rngState = rng;

% hand-built model: glucose uptake feeds the biomass reaction bio1 and the secretion of
% methane (CH4sec); formate has an exchange and nothing else (blocked). The product exchanges
% come in the model in the order for, ch4, not in alphabetical order (see the purpose above)
model = createModel({'EX_glc_D(e)'; 'GLCt'; 'bio1'; 'EX_for(e)'; 'EX_ch4(e)'; 'CH4sec'}, ...
    {'glucose exchange'; 'glucose transport'; 'biomass'; 'formate exchange'; ...
    'methane exchange'; 'methane secretion'}, ...
    {'glc_D[e] <=> '; 'glc_D[e] -> glc_D[c]'; 'glc_D[c] -> '; 'for[e] <=> '; 'ch4[e] <=> '; ...
    'glc_D[c] -> ch4[e]'}, 'printLevel', 0);

% metabolite names of the rBioNet-style database
database.metabolites = {'ch4', 'Methane'; 'for', 'Formate'; 'btoh', 'Butanol'};

% the data table in the folder inputData of a temporary folder: Microbe_A has
% methanogenesis and the formate pathway, Microbe_B the butanol pathway; Ref1 (numeric) and
% Ref2 (text) are reference columns
sandboxDir = tempname;
inputDataFolder = fullfile(sandboxDir, 'inputData');
mkdir(inputDataFolder);
cd(sandboxDir);
tableRows = {'MicrobeID', 'Methanogenesis', 'Formate producer', 'Butanol producer', 'Ref1', 'Ref2'
    'Microbe_A', '1', '1', '0', '1', 'refA'
    'Microbe_B', '0', '0', '1', '0', 'refB'};
fid = fopen(fullfile(inputDataFolder, 'FermentationTable.txt'), 'w');
for i = 1:size(tableRows, 1)
    fprintf(fid, '%s\n', strjoin(tableRows(i, :), sprintf('\t')));
end
fclose(fid);

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing testFermentationProducts using %s ... \n', solvers.LP{k});

        %% products the model can secrete, and those it cannot

        % methane is secreted, formate (blocked) is a false negative; the reference column
        % Ref1, 1 for Microbe_A, is removed and not read as a pathway
        lastwarn('');
        [truePositives, falseNegatives] = testFermentationProducts(model, 'Microbe_A', 'bio1', ...
            database, inputDataFolder);
        assert(isequal(truePositives, {'Methane'}));
        assert(isequal(falseNegatives, {'Formate'}));
        % fastFVA stopped and fluxVariability was used instead
        assert(strncmp(lastwarn, 'fastFVA could not run', 21));
        % the folder is unchanged although fastFVA changes it before it stops
        assert(strcmp(pwd, sandboxDir));

        %% no product of the microbe in the model: no FVA, every product a false negative

        % methanogenesis is 0 for Microbe_B, so methane is not reported although it is secreted
        [truePositives, falseNegatives] = testFermentationProducts(model, 'Microbe_B', 'bio1', ...
            database, inputDataFolder);
        assert(isempty(truePositives));
        assert(isequal(falseNegatives, {'Butanol'}));

        %% a microbe that is not in the table: a warning and two empty lists

        lastwarn('');
        [truePositives, falseNegatives] = testFermentationProducts(model, 'Microbe_C', 'bio1', ...
            database, inputDataFolder);
        assert(iscell(truePositives) && isempty(truePositives));
        assert(iscell(falseNegatives) && isempty(falseNegatives));
        assert(strcmp(lastwarn, 'Microbe "Microbe_C" not found in fermentation product data file.'));

        %% a biomass reaction that is not in the model is an error

        assert(verifyCobraFunctionError('testFermentationProducts', 'outputArgCount', 2, ...
            'inputs', {model, 'Microbe_A', 'bio2', database, inputDataFolder}, ...
            'testMessage', 'Biomass reaction "bio2" not found in model.'));
    end
end

%% clean up

cd(fileDir);
rmdir(sandboxDir, 's');
CobraSolverState.restore(initialSolverState);
rng(rngState);
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clearvars('-global', newGlobals{i});
end

% change the directory
cd(currentDir)
