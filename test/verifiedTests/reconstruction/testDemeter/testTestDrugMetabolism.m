% The COBRAToolbox: testTestDrugMetabolism.m
%
% Purpose:
%     - testDrugMetabolism(model, microbeID, biomassReaction, database) is a DEMETER
%       test-suite function (its name starts with "test"; this file tests it). It reads
%       drugTable.txt (tab-separated, a header row of drug-enzyme names, one row per microbe
%       with 1 where the microbe has the enzyme), collects the drug exchange reactions of the
%       enzymes set to 1 for microbeID, opens every EX_ reaction of the model to -1000..1000,
%       runs flux variability (fastFVA, or fluxVariability when fastFVA stops) at 0% of the
%       biomass optimum and reports, as metabolite names from database.metabolites, the
%       exchanges that can carry flux in either direction (TruePositives) and the others
%       (FalseNegatives, also the exchanges not in the model).
%     - The test writes drugTable.txt by hand in a temporary folder, runs the function from
%       there on a hand-built 7-reaction model and derives the expected lists from the
%       network by hand: r788 can only be taken up (it is converted into r406), r406 can
%       only be secreted, lactulose is a dead end, 4-hydroxyphenylacetate and p-cresol have
%       no exchange in the model.
%     - fastFVA: the reactions to analyse are passed in alphabetical order, which differs
%       from their order in this model, so fastFVA stops with its "not sorted" error before
%       any CPLEX call on every machine, and the fallback to fluxVariability (lines 95-97) is
%       always taken; the warning of line 95 is checked. Both branches give the same lists.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testDrugMetabolism.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability (LP) on a hand-built model, every available LP solver among
%     gurobi and glpk.
%
% Coverage exemptions:
%     Line 40: runs initCobraToolbox when the global CBT_LP_SOLVER is empty; that resets the
%     path and solver state of the running session and saves the MATLAB path, so it is not
%     run here (precedent testGetDistributedModelFolder).
%     Lines 78-80, 115-116: branches for MATLAB releases before R2020a (version-specific; the
%     reference MATLAB is R2025a).
%     Lines 92-93: the fastFVA call completes only with IBM CPLEX (its cplexFVA binaries),
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
fileDir = fileparts(which('testTestDrugMetabolism'));
cd(fileDir);

% the solver set-up and the solver calls create global variables; they are removed at the end
globalsBefore = who('global');

% the function runs flux variability: an LP solver is needed
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% fastFVA reseeds the random number generator (rng('shuffle')) before it stops; the state of
% the session is restored at the end
rngState = rng;

% hand-built model: glucose uptake feeds the biomass reaction bio1; r788 is converted into
% r406 outside the cell (r788 can only be taken up, r406 only secreted); lactulose has an
% exchange and nothing else (blocked). The drug exchanges come in the model in the order
% r788, r406, lactl, not in alphabetical order (see the purpose above)
model = createModel({'EX_glc_D(e)'; 'GLCt'; 'bio1'; 'EX_r788(e)'; 'EX_r406(e)'; 'R788conv'; 'EX_lactl(e)'}, ...
    {'glucose exchange'; 'glucose transport'; 'biomass'; 'r788 exchange'; 'r406 exchange'; ...
    'r788 conversion'; 'lactulose exchange'}, ...
    {'glc_D[e] <=> '; 'glc_D[e] -> glc_D[c]'; 'glc_D[c] -> '; 'r788[e] <=> '; 'r406[e] <=> '; ...
    'r788[e] -> r406[e]'; 'lactl[e] <=> '}, 'printLevel', 0);

% metabolite names of the rBioNet-style database
database.metabolites = {'r788', 'Fostamatinib'; 'r406', 'Tamatinib'; 'lactl', 'Lactulose'; ...
    '4hphac', '4-Hydroxyphenylacetate'; 'pcresol', 'p-Cresol'};

% the data table in a temporary folder that becomes the current folder: Microbe_A has the
% enzymes eALP (r788, r406) and cBGal (lactulose); Microbe_B has only cHpd (4hphac, p-cresol)
sandboxDir = tempname;
mkdir(sandboxDir);
cd(sandboxDir);
tableRows = {'MicrobeID', 'eALP', 'cBGal', 'cHpd'
    'Microbe_A', '1', '1', '0'
    'Microbe_B', '0', '0', '1'};
fid = fopen('drugTable.txt', 'w');
for i = 1:size(tableRows, 1)
    fprintf(fid, '%s\n', strjoin(tableRows(i, :), sprintf('\t')));
end
fclose(fid);

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing testDrugMetabolism using %s ... \n', solvers.LP{k});

        %% drugs of the microbe that the model can take up or secrete, and those it cannot

        % r788 counts although it can only be taken up and r406 although it can only be
        % secreted: activity in either direction is enough. Lactulose (blocked) is a false
        % negative. The lists are sorted by reaction ID (r406 before r788) and given as names
        lastwarn('');
        [truePositives, falseNegatives] = testDrugMetabolism(model, 'Microbe_A', 'bio1', database);
        assert(isequal(truePositives, {'Tamatinib'; 'Fostamatinib'}));
        assert(isequal(falseNegatives, {'Lactulose'}));
        % fastFVA stopped and fluxVariability was used instead
        assert(strncmp(lastwarn, 'fastFVA could not run', 21));
        % the folder is unchanged although fastFVA changes it before it stops
        assert(strcmp(pwd, sandboxDir));

        %% no drug exchange of the microbe in the model: no FVA, every drug a false negative

        % eALP is 0 for Microbe_B, so r788 and r406 are not reported although they carry flux
        [truePositives, falseNegatives] = testDrugMetabolism(model, 'Microbe_B', 'bio1', database);
        assert(isempty(truePositives));
        assert(isequal(falseNegatives, {'4-Hydroxyphenylacetate'; 'p-Cresol'}));

        %% a microbe that is not in the table: a warning and two empty lists

        lastwarn('');
        [truePositives, falseNegatives] = testDrugMetabolism(model, 'Microbe_C', 'bio1', database);
        assert(iscell(truePositives) && isempty(truePositives));
        assert(iscell(falseNegatives) && isempty(falseNegatives));
        assert(strcmp(lastwarn, 'Microbe "Microbe_C" not found in drug data file.'));

        %% a biomass reaction that is not in the model is an error

        assert(verifyCobraFunctionError('testDrugMetabolism', 'outputArgCount', 2, ...
            'inputs', {model, 'Microbe_A', 'bio2', database}, ...
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
