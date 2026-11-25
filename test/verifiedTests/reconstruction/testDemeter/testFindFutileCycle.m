% The COBRAToolbox: testFindFutileCycle.m
%
% Purpose:
%     - findFutileCycle(model, cut, closedModel) maximises DM_atp_c_ (with the minimal one-norm
%       flux, optimizeCbModel 'zero') after closing the uptake of the model (lower bound 0 for
%       reactions whose names start with Ex_, EX_, DM_ or sink_, and for every reaction with a
%       single stoichiometric coefficient of +-1) unless closedModel is 0, and returns a table of
%       the reactions whose absolute flux exceeds cut (default 250): identifier, lower bound,
%       upper bound, flux (the last three as text) and formula; {} when there is none.
%     - Input: hand-built models. A futile cycle R1 (a + adp -> b + atp) / R2 (b -> a) makes ATP
%       from nothing, so DM_atp_c_ reaches its bound 1000 with every exchange closed. A linear
%       model makes ATP only from an uptake of 300, so DM_atp_c_ is 0 when the uptake is closed
%       and 300 when it is open. Every expected flux follows from these mass balances (each
%       optimum is unique).
%
% Function under test:
%     src/reconstruction/demeter/src/debugging/findFutileCycle.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves LPs (optimizeCbModel) on hand-built models; every available LP solver
%     among gurobi and glpk.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The FBA solution is printed to the console
%       SEVERITY: cosmetic
%       TRIGGER: every call
%       OBSERVED: the statement fba = optimizeCbModel(...) has no semicolon, so the whole
%         solution structure is displayed ("fba = struct with fields: ... f: 1000")
%       EXPECTED: no console output apart from the formulas printed by printRxnFormula
%       LINES: 43
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindFutileCycle'));
cd(fileDir);

% the solver functions create global variables; the ones that did not exist before are removed
% at the end
globalsBefore = who('global');

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% LP fluxes of these small models are exact up to the solver's feasibility tolerance (1e-9 or
% better); the bounds in the table are copied, so they are compared exactly
tol = 1e-6;

% futile cycle: R1 and R2 regenerate a while making ATP. The other reactions are uptakes that
% are closed: EX_a, Ex_b and sink_adp by their names, Uptake_a (one coefficient -1) as a
% single-metabolite reaction
cycleModel = createModel({'R1', 'R2', 'DM_atp_c_', 'EX_a', 'Ex_b', 'sink_adp', 'Uptake_a'}, ...
    {'', '', '', '', '', '', ''}, ...
    {'a[c] + adp[c] -> b[c] + atp[c]', 'b[c] -> a[c]', 'atp[c] -> adp[c]', 'a[c] <=> ', ...
    'b[c] <=> ', 'adp[c] <=> ', 'a[c] <=> '}, ...
    'lowerBoundList', [0 0 0 -1000 -10 -5 -20], 'upperBoundList', [1000 1000 1000 1000 1000 1000 1000], ...
    'printLevel', 0);

% linear ATP production from an uptake of c of at most 300 through UPT_c (one coefficient -1)
linearModel = createModel({'UPT_c', 'R3', 'DM_atp_c_'}, {'', '', ''}, ...
    {'c[c] <=> ', 'c[c] + adp[c] -> atp[c]', 'atp[c] -> adp[c]'}, ...
    'lowerBoundList', [-300 0 0], 'upperBoundList', [0 1000 1000], 'printLevel', 0);

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing findFutileCycle using %s ... \n', solvers.LP{k});

    %% futile cycle in the closed model (defaults: cut 250, closedModel 1)
    % the cycle carries 1000 (bound of DM_atp_c_ and R1) in R1, R2 and DM_atp_c_; nothing else
    % carries flux, because all uptakes are closed
    futileTable = findFutileCycle(cycleModel);
    assert(istable(futileTable) && size(futileTable, 1) == 3);
    assert(isequal(futileTable{:, 1}, {'R1'; 'R2'; 'DM_atp_c_'}));
    assert(isequal(str2double(cellstr(futileTable{:, 2})), [0; 0; 0]));
    assert(isequal(str2double(cellstr(futileTable{:, 3})), [1000; 1000; 1000]));
    assert(all(abs(str2double(cellstr(futileTable{:, 4})) - 1000) < tol));
    % the formulas are those of printRxnFormula
    expectedFormulas = printRxnFormula(cycleModel, 'rxnAbbrList', {'R1'; 'R2'; 'DM_atp_c_'}, 'printFlag', false);
    assert(isequal(futileTable{:, 5}, expectedFormulas));

    %% cut above every flux: no reaction is reported
    assert(isequal(findFutileCycle(cycleModel, 2000), {}));

    %% no futile cycle: the closed model makes no ATP
    % UPT_c is closed (one coefficient), so DM_atp_c_ is 0 and no flux exceeds the cut
    assert(isequal(findFutileCycle(linearModel), {}));

    %% the open model (closedModel = 0) keeps the uptake
    % 300 of c are taken up (flux -300) and turned into 300 ATP, above the cut 250
    openTable = findFutileCycle(linearModel, 250, 0);
    assert(isequal(openTable{:, 1}, {'UPT_c'; 'R3'; 'DM_atp_c_'}));
    assert(isequal(str2double(cellstr(openTable{:, 2})), [-300; 0; 0]));
    assert(isequal(str2double(cellstr(openTable{:, 3})), [0; 1000; 1000]));
    assert(all(abs(str2double(cellstr(openTable{:, 4})) - [-300; 300; 300]) < tol));
    % a cut above 300 leaves no reaction
    assert(isequal(findFutileCycle(linearModel, 300.5, 0), {}));

    %% each name prefix closes a reaction with two metabolites
    % the uptake 'c + d <=>' has two coefficients, so only its name can close it: with the
    % prefixes EX_, Ex_, DM_ and sink_ the closed model makes no ATP; with another name the
    % uptake stays open and 300 ATP are made
    for prefixedName = {'EX_cd', 'Ex_cd', 'DM_cd', 'sink_cd', 'UPT_cd'}
        pairModel = createModel({prefixedName{1}, 'R4', 'DM_atp_c_'}, {'', '', ''}, ...
            {'c[c] + d[c] <=> ', 'c[c] + d[c] + adp[c] -> atp[c]', 'atp[c] -> adp[c]'}, ...
            'lowerBoundList', [-300 0 0], 'upperBoundList', [0 1000 1000], 'printLevel', 0);
        pairTable = findFutileCycle(pairModel);
        if strcmp(prefixedName{1}, 'UPT_cd')
            assert(isequal(pairTable{:, 1}, {'UPT_cd'; 'R4'; 'DM_atp_c_'}));
            assert(all(abs(str2double(cellstr(pairTable{:, 4})) - [-300; 300; 300]) < tol));
        else
            assert(isequal(pairTable, {}), prefixedName{1});
        end
    end
end

% leave the solver selection and the globals as they were found
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
