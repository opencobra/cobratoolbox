% The COBRAToolbox: testTestPutrefactionPathways.m
%
% Purpose:
%     - testPutrefactionPathways(model, microbeID, biomassReaction, database) is a DEMETER
%       test-suite function (its name starts with "test"; this file tests it). It reads
%       PutrefactionTable.txt (tab-separated, a header row of putrefaction pathways, one row
%       per microbe with 1 where the microbe has the pathway), takes the end reaction of each
%       pathway set to 1 for microbeID (an exchange or an internal reaction such as GLUFORT),
%       opens every EX_ reaction of the model to -1000..1000, runs flux variability (fastFVA,
%       or fluxVariability when fastFVA stops) at 0% of the biomass optimum and reports the
%       end reactions with maximum flux > 1e-6 (TruePositives) and the others (FalseNegatives,
%       also the reactions not in the model). Exchange IDs are replaced by the metabolite
%       name from database.metabolites when the metabolite is there; other IDs are kept.
%     - The test writes PutrefactionTable.txt by hand in a temporary folder, runs the
%       function from there on a hand-built 9-reaction model and derives the expected lists
%       from the network by hand: putrescine and the internal reaction GLUFORT can carry
%       flux (putrescine is in the database, GLUFORT is not a metabolite), hydrogen sulfide
%       has an exchange and nothing else (blocked, in the database), FTCD is not in the model
%       (not in the database). Putrescine_1 and Putrescine_2 end in the same exchange, which
%       is reported once.
%     - The pathway headers with blanks and brackets are not valid MATLAB names: readtable
%       warns (visibly) and readInputTableForPipeline returns them as written.
%     - fastFVA: the reactions to analyse are passed in alphabetical order, which differs
%       from their order in this model, so fastFVA stops with its "not sorted" error before
%       any CPLEX call on every machine, and the fallback to fluxVariability (lines 94-96) is
%       always taken; the warning of line 94 is checked. Both branches give the same lists.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testPutrefactionPathways.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability (LP) on a hand-built model, every available LP solver among
%     gurobi and glpk.
%
% Coverage exemptions:
%     Line 38: runs initCobraToolbox when the global CBT_LP_SOLVER is empty; that resets the
%     path and solver state of the running session and saves the MATLAB path, so it is not
%     run here (precedent testGetDistributedModelFolder).
%     Lines 77-79, 113-114: branches for MATLAB releases before R2020a (version-specific; the
%     reference MATLAB is R2025a).
%     Lines 91-92: the fastFVA call completes only with IBM CPLEX (its cplexFVA binaries),
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
fileDir = fileparts(which('testTestPutrefactionPathways'));
cd(fileDir);

% the solver set-up and the solver calls create global variables; they are removed at the end
globalsBefore = who('global');

% the function runs flux variability: an LP solver is needed
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% fastFVA reseeds the random number generator (rng('shuffle')) before it stops; the state of
% the session is restored at the end
rngState = rng;

% hand-built model: glucose uptake feeds the biomass reaction bio1, the internal reaction
% GLUFORT (its product glu_L is secreted) and the secretion of putrescine (PTRCsec); hydrogen
% sulfide has an exchange and nothing else (blocked). The end reactions come in the model in
% the order GLUFORT, ptrc, h2s, not in alphabetical order (see the purpose above)
model = createModel({'EX_glc_D(e)'; 'GLCt'; 'bio1'; 'GLUFORT'; 'EX_glu_L(e)'; 'EX_ptrc(e)'; ...
    'PTRCsec'; 'EX_h2s(e)'}, ...
    {'glucose exchange'; 'glucose transport'; 'biomass'; 'glutamate formation'; ...
    'glutamate exchange'; 'putrescine exchange'; 'putrescine secretion'; 'sulfide exchange'}, ...
    {'glc_D[e] <=> '; 'glc_D[e] -> glc_D[c]'; 'glc_D[c] -> '; 'glc_D[c] -> glu_L[e]'; ...
    'glu_L[e] <=> '; 'ptrc[e] <=> '; 'glc_D[c] -> ptrc[e]'; 'h2s[e] <=> '}, 'printLevel', 0);

% metabolite names of the rBioNet-style database (no entry for GLUFORT or FTCD)
database.metabolites = {'ptrc', 'Putrescine'; 'h2s', 'Hydrogen sulfide'};

% the data table in a temporary folder that becomes the current folder: Microbe_A has the
% putrescine pathways 1 and 2, H2S_1, histidine degradation (GLUFORT) and THF production
% (FTCD); Microbe_B only THF production
sandboxDir = tempname;
mkdir(sandboxDir);
cd(sandboxDir);
tableRows = {'MicrobeID', 'Putrescine_1', 'Putrescine_2', 'H2S_1', ...
    'Histidine degradation (histidine -> glutamate)', 'THF production (histidine -> tetrahydrofolate)'
    'Microbe_A', '1', '1', '1', '1', '1'
    'Microbe_B', '0', '0', '0', '0', '1'};
fid = fopen('PutrefactionTable.txt', 'w');
for i = 1:size(tableRows, 1)
    fprintf(fid, '%s\n', strjoin(tableRows(i, :), sprintf('\t')));
end
fclose(fid);

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing testPutrefactionPathways using %s ... \n', solvers.LP{k});

        %% end reactions that can carry flux, and those that cannot

        % sorted by reaction ID (EX_ptrc(e) before GLUFORT, EX_h2s(e) before FTCD: lower-case
        % letters sort after upper case, "E" before "F" and "G"); putrescine and hydrogen
        % sulfide are named from the database, GLUFORT and FTCD keep their IDs
        lastwarn('');
        [truePositives, falseNegatives] = testPutrefactionPathways(model, 'Microbe_A', 'bio1', database);
        assert(isequal(truePositives, {'Putrescine', 'GLUFORT'}));
        assert(isequal(falseNegatives, {'Hydrogen sulfide', 'FTCD'}));
        % fastFVA stopped and fluxVariability was used instead
        assert(strncmp(lastwarn, 'fastFVA could not run', 21));
        % the folder is unchanged although fastFVA changes it before it stops
        assert(strcmp(pwd, sandboxDir));

        %% no end reaction of the microbe in the model: no FVA, every pathway a false negative

        % the putrescine pathways are 0 for Microbe_B, so putrescine is not reported
        [truePositives, falseNegatives] = testPutrefactionPathways(model, 'Microbe_B', 'bio1', database);
        assert(isempty(truePositives));
        assert(isequal(falseNegatives, {'FTCD'}));

        %% a microbe that is not in the table: a warning and two empty lists

        lastwarn('');
        [truePositives, falseNegatives] = testPutrefactionPathways(model, 'Microbe_C', 'bio1', database);
        assert(iscell(truePositives) && isempty(truePositives));
        assert(iscell(falseNegatives) && isempty(falseNegatives));
        assert(strcmp(lastwarn, 'Microbe "Microbe_C" not found in putrefaction product data file.'));

        %% a biomass reaction that is not in the model is an error

        assert(verifyCobraFunctionError('testPutrefactionPathways', 'outputArgCount', 2, ...
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
