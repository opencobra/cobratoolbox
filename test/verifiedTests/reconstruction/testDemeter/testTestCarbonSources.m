% The COBRAToolbox: testTestCarbonSources.m
%
% Purpose:
%     - testCarbonSources(model, microbeID, biomassReaction, database, inputDataFolder) is a
%       DEMETER test-suite function (its name starts with "test"; this file tests it). It
%       reads CarbonSourcesTable.txt from inputDataFolder (tab-separated, a header row of
%       carbon source names, "Ref" columns that it drops, one row per microbe with 1 where
%       the microbe uses the carbon source), maps the carbon sources set to 1 for microbeID
%       to their exchange reactions (a fixed table in the function; several exchanges for
%       some sources, e.g. Chondroitin sulfate), sets biomassReaction as the objective,
%       opens every EX_ reaction of the model to -1000..1000, runs flux variability
%       (fastFVA, or fluxVariability when fastFVA stops) at 0% of the biomass optimum and
%       reports, as metabolite names from database.metabolites, every exchange of these
%       sources that can be taken up (minimum flux below -1e-6: TruePositives) and every
%       other one (FalseNegatives: exchanges that cannot be taken up or are not in the
%       model). Every exchange of a source with several exchanges is judged on its own.
%     - The test writes CarbonSourcesTable.txt by hand in a temporary folder and runs the
%       function on a hand-built 9-reaction model; the expected lists follow from the
%       network by hand: glucose and chondroitin sulfate A can be taken up (both feed the
%       biomass reaction), acetate and chondroitin sulfate B are dead ends, succinate can
%       only be secreted, chondroitin sulfate C and fructose have no exchange in the model.
%       The model is built field by field (no createModel, which is blocked in this feature).
%     - fastFVA: the reactions to analyse are passed in alphabetical order, which differs
%       from their order in this model, so fastFVA stops with its "not sorted" error before
%       any CPLEX solve on every machine, and the fallback to fluxVariability (lines 102-104)
%       is always taken; the warning of line 102 is checked.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testCarbonSources.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability (LP) on a hand-built model, every available LP solver among
%     gurobi and glpk.
%
% Coverage exemptions:
%     Line 43: runs initCobraToolbox when the global CBT_LP_SOLVER is empty; that resets the
%     path and solver state of the running session and saves the MATLAB path, so it is not
%     run here (precedent testGetDistributedModelFolder).
%     Lines 85-87, 122-123: branches for MATLAB releases before R2020a (version-specific; the
%     reference MATLAB is R2025a).
%     Lines 99-100: the fastFVA call is executed on every run below (its fallback warning of
%     line 102 is asserted), but it ends in fastFVA's "not sorted" error, and the coverage
%     plugin records no hit for a statement that ends in an error. Making fastFVA succeed
%     would need IBM CPLEX with compiled cplexFVA binaries (not installed) and a model whose
%     reactions are in alphabetical order.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTestCarbonSources'));
cd(fileDir);

% fastFVA (called first by the function) may create solver globals before it stops; the
% globals that are new at the end are removed
globalsBefore = who('global');

% the function runs flux variability: an LP solver is needed
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% fastFVA reseeds the random number generator (rng('shuffle')) before it stops; the state of
% the session is restored at the end
rngState = rng;

% hand-built model (the reaction order is not alphabetical, see the purpose above):
%   GLCt:        glc_D[e] -> glc_D[c]
%   EX_glc_D(e): glc_D[e] <=>
%   bio1:        glc_D[c] + cspg_a[c] ->
%   EX_ac(e):    ac[e] <=>                (dead end)
%   EX_cspg_b(e): cspg_b[e] <=>           (dead end)
%   EX_cspg_a(e): cspg_a[e] <=>
%   CSPGAt:      cspg_a[e] -> cspg_a[c]
%   SUCCsec:     glc_D[c] -> succ[e]      (succinate can only leave the cell)
%   EX_succ(e):  succ[e] <=>
% Every exchange is closed (bounds 0) in the input: the function opens them itself.
model = struct();
model.rxns = {'GLCt'; 'EX_glc_D(e)'; 'bio1'; 'EX_ac(e)'; 'EX_cspg_b(e)'; 'EX_cspg_a(e)'; ...
    'CSPGAt'; 'SUCCsec'; 'EX_succ(e)'};
model.mets = {'glc_D[e]'; 'glc_D[c]'; 'ac[e]'; 'cspg_b[e]'; 'cspg_a[e]'; 'cspg_a[c]'; 'succ[e]'};
stoichiometry = zeros(7, 9);
stoichiometry([1, 2], 1) = [-1; 1];      % GLCt
stoichiometry(1, 2) = -1;                % EX_glc_D(e)
stoichiometry([2, 6], 3) = [-1; -1];     % bio1
stoichiometry(3, 4) = -1;                % EX_ac(e)
stoichiometry(4, 5) = -1;                % EX_cspg_b(e)
stoichiometry(5, 6) = -1;                % EX_cspg_a(e)
stoichiometry([5, 6], 7) = [-1; 1];      % CSPGAt
stoichiometry([2, 7], 8) = [-1; 1];      % SUCCsec
stoichiometry(7, 9) = -1;                % EX_succ(e)
model.S = sparse(stoichiometry);
isExchange = strncmp('EX_', model.rxns, 3);
model.lb = zeros(9, 1);
model.ub = 1000 * double(~isExchange);
model.c = zeros(9, 1);
model.b = zeros(7, 1);
model.csense = repmat('E', 7, 1);
model.osenseStr = 'max';
model.rxnNames = model.rxns;
model.metNames = model.mets;

% metabolite names of the rBioNet-style database
database.metabolites = {'glc_D', 'D-Glucose'; 'ac', 'Acetate'; 'cspg_a', 'Chondroitin sulfate A'; ...
    'cspg_b', 'Chondroitin sulfate B'; 'cspg_c', 'Chondroitin sulfate C'; 'succ', 'Succinate'; ...
    'fru', 'D-Fructose'};

% the data table in a temporary folder (inputDataFolder). Microbe_A uses D-glucose, acetate,
% chondroitin sulfate, succinate, fructose and a source without exchange mapping
% ("Unknown sugar"), not L-lactate; Microbe_B uses only "Unknown sugar"; Microbe_C only
% fructose. The Ref column is dropped by the function
inputDataFolder = tempname;
mkdir(inputDataFolder);
tableRows = {'MicrobeID', 'D-glucose', 'Ref', 'Acetate', 'Chondroitin sulfate', 'Succinate', ...
    'Fructose', 'L-lactate', 'Unknown sugar'
    'Microbe_A', '1', 'PMID1', '1', '1', '1', '1', '0', '1'
    'Microbe_B', '0', 'PMID2', '0', '0', '0', '0', '0', '1'
    'Microbe_C', '0', 'PMID3', '0', '0', '0', '1', '0', '0'};
fid = fopen(fullfile(inputDataFolder, 'CarbonSourcesTable.txt'), 'w');
for i = 1:size(tableRows, 1)
    fprintf(fid, '%s\n', strjoin(tableRows(i, :), sprintf('\t')));
end
fclose(fid);

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing testCarbonSources using %s ... \n', solvers.LP{k});

        %% carbon sources the model can take up, and those it cannot

        % glucose and chondroitin sulfate A can be taken up (minimum flux -1000, far below
        % the -1e-6 threshold of the function, so no tolerance question arises); chondroitin
        % sulfate B and C are false negatives although A is taken up (each exchange counts);
        % acetate is a dead end; succinate can only be secreted (uptake is what counts);
        % fructose has no exchange in the model. The lists are sorted by reaction ID and
        % given as names; their orientation is not documented, so they are compared as
        % columns
        lastwarn('');
        [truePositives, falseNegatives] = testCarbonSources(model, 'Microbe_A', 'bio1', ...
            database, inputDataFolder);
        assert(iscell(truePositives) && iscell(falseNegatives));
        assert(isequal(truePositives(:), {'Chondroitin sulfate A'; 'D-Glucose'}));
        assert(isequal(falseNegatives(:), {'Acetate'; 'Chondroitin sulfate B'; ...
            'Chondroitin sulfate C'; 'D-Fructose'; 'Succinate'}));
        % fastFVA stopped and fluxVariability was used instead
        assert(strncmp(lastwarn, 'fastFVA could not run', 21));
        % the current folder is unchanged although fastFVA changes it before it stops
        assert(strcmp(pwd, fileDir));

        %% a source marked 1 without an exchange mapping: no FVA, both lists empty

        % "Unknown sugar" is not in the mapping table of the function, so no reaction is
        % analysed and nothing is reported
        [truePositives, falseNegatives] = testCarbonSources(model, 'Microbe_B', 'bio1', ...
            database, inputDataFolder);
        assert(iscell(truePositives) && isempty(truePositives));
        assert(iscell(falseNegatives) && isempty(falseNegatives));

        %% no exchange of the microbe's sources in the model: no FVA, a false negative

        [truePositives, falseNegatives] = testCarbonSources(model, 'Microbe_C', 'bio1', ...
            database, inputDataFolder);
        assert(isempty(truePositives));
        assert(isequal(falseNegatives(:), {'D-Fructose'}));

        %% a microbe that is not in the table: a warning and two empty lists

        lastwarn('');
        [truePositives, falseNegatives] = testCarbonSources(model, 'Microbe_D', 'bio1', ...
            database, inputDataFolder);
        assert(iscell(truePositives) && isempty(truePositives));
        assert(iscell(falseNegatives) && isempty(falseNegatives));
        assert(strcmp(lastwarn, 'Microbe "Microbe_D" not found in carbon source data file.'));

        %% a biomass reaction that is not in the model is an error

        assert(verifyCobraFunctionError('testCarbonSources', 'outputArgCount', 2, ...
            'inputs', {model, 'Microbe_A', 'bio2', database, inputDataFolder}, ...
            'testMessage', 'Biomass reaction "bio2" not found in model.'));
    end
end

%% clean up

rmdir(inputDataFolder, 's');
CobraSolverState.restore(initialSolverState);
rng(rngState);
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clear('global', newGlobals{i});
end

% change the directory
cd(currentDir)
