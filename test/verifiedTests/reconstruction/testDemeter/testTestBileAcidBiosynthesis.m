% The COBRAToolbox: testTestBileAcidBiosynthesis.m
%
% Purpose:
%     - testBileAcidBiosynthesis(model, microbeID, biomassReaction, database) is a DEMETER
%       test-suite function (its name starts with "test"; this file tests it). It reads
%       BileAcidTable.txt (tab-separated, a header row of bile acid products, one row per
%       microbe with 1 where the microbe produces it), takes the
%       exchange reaction of each product set to 1 for microbeID, opens every EX_ reaction
%       of the model to -1000..1000, runs flux variability (fastFVA, or fluxVariability when
%       fastFVA stops) at 0% of the biomass optimum and reports, as metabolite names from
%       database.metabolites, the products whose exchange can be secreted (maximum flux
%       > 1e-6: TruePositives) and the others (FalseNegatives, also the exchanges not in the
%       model).
%     - The test writes BileAcidTable.txt by hand in a temporary folder, runs the function
%       from there on a hand-built 6-reaction model and derives the expected lists from the
%       network by hand: cholate is made from glucose and can be secreted, deoxycholate has
%       an exchange and nothing else (blocked), lithocholate has no exchange in the model.
%     - Unlike the other DEMETER product tests, the name replacement of the true positives
%       (lines 130-135) runs without a check for an empty list; the empty case is tested.
%     - fastFVA: the reactions to analyse are passed in alphabetical order, which differs
%       from their order in this model, so fastFVA stops with its "not sorted" error before
%       any CPLEX call on every machine, and the fallback to fluxVariability (lines 95-97) is
%       always taken; the warning of line 95 is checked. Both branches give the same lists.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testBileAcidBiosynthesis.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability (LP) on a hand-built model, every available LP solver among
%     gurobi and glpk.
%
% Coverage exemptions:
%     Line 39: runs initCobraToolbox when the global CBT_LP_SOLVER is empty; that resets the
%     path and solver state of the running session and saves the MATLAB path, so it is not
%     run here (precedent testGetDistributedModelFolder).
%     Lines 78-80, 114-115: branches for MATLAB releases before R2020a (version-specific; the
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
fileDir = fileparts(which('testTestBileAcidBiosynthesis'));
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
% cholate (CHOLsec); deoxycholate has an exchange and nothing else (blocked). The product
% exchanges come in the model in the order dchac, cholate, not in alphabetical order (see the
% purpose above)
model = createModel({'EX_glc_D(e)'; 'GLCt'; 'bio1'; 'EX_dchac(e)'; 'EX_cholate(e)'; 'CHOLsec'}, ...
    {'glucose exchange'; 'glucose transport'; 'biomass'; 'deoxycholate exchange'; ...
    'cholate exchange'; 'cholate secretion'}, ...
    {'glc_D[e] <=> '; 'glc_D[e] -> glc_D[c]'; 'glc_D[c] -> '; 'dchac[e] <=> '; 'cholate[e] <=> '; ...
    'glc_D[c] -> cholate[e]'}, 'printLevel', 0);

% metabolite names of the rBioNet-style database
database.metabolites = {'cholate', 'Cholate'; 'dchac', 'Deoxycholate'; 'HC02191', 'Lithocholate'};

% the data table in a temporary folder that becomes the current folder: Microbe_A produces
% the three bile acids; Microbe_B only lithocholate
sandboxDir = tempname;
mkdir(sandboxDir);
cd(sandboxDir);
tableRows = {'MicrobeID', 'Cholate', 'Deoxycholate', 'Lithocholate'
    'Microbe_A', '1', '1', '1'
    'Microbe_B', '0', '0', '1'};
fid = fopen('BileAcidTable.txt', 'w');
for i = 1:size(tableRows, 1)
    fprintf(fid, '%s\n', strjoin(tableRows(i, :), sprintf('\t')));
end
fclose(fid);

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing testBileAcidBiosynthesis using %s ... \n', solvers.LP{k});

        %% bile acids the model can secrete, and those it cannot

        % cholate is secreted; deoxycholate (blocked) and lithocholate (no exchange) are false
        % negatives, sorted by reaction ID (EX_HC02191(e) before EX_dchac(e): upper case sorts
        % first) and given as names
        lastwarn('');
        [truePositives, falseNegatives] = testBileAcidBiosynthesis(model, 'Microbe_A', 'bio1', database);
        assert(isequal(truePositives, {'Cholate'}));
        assert(isequal(falseNegatives, {'Lithocholate', 'Deoxycholate'}));
        % fastFVA stopped and fluxVariability was used instead
        assert(strncmp(lastwarn, 'fastFVA could not run', 21));
        % the folder is unchanged although fastFVA changes it before it stops
        assert(strcmp(pwd, sandboxDir));

        %% no bile acid of the microbe in the model: no FVA, every bile acid a false negative

        % cholate is 0 for Microbe_B, so it is not reported although it is secreted; the
        % empty list of true positives goes through the name replacement unchanged
        [truePositives, falseNegatives] = testBileAcidBiosynthesis(model, 'Microbe_B', 'bio1', database);
        assert(iscell(truePositives) && isempty(truePositives));
        assert(isequal(falseNegatives, {'Lithocholate'}));

        %% a microbe that is not in the table: a warning and two empty lists

        lastwarn('');
        [truePositives, falseNegatives] = testBileAcidBiosynthesis(model, 'Microbe_C', 'bio1', database);
        assert(iscell(truePositives) && isempty(truePositives));
        assert(iscell(falseNegatives) && isempty(falseNegatives));
        assert(strcmp(lastwarn, 'Microbe "Microbe_C" not found in bile acid metabolism data file.'));

        %% a biomass reaction that is not in the model is an error

        assert(verifyCobraFunctionError('testBileAcidBiosynthesis', 'outputArgCount', 2, ...
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
