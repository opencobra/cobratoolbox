% The COBRAToolbox: testOptStoicPathways.m
%
% Purpose:
%     - tests findOptStoicPathways, optStoicMinFlux and optStoicMinRxn on
%       small networks: enumeration of alternative pathways with integer
%       cuts, flexible metabolites, excluded reactions and metabolites,
%       maximum number of reactions, linear constraints on the exchanges,
%       non-integer fluxes, fixed total flux with reversible reactions,
%       loopless constraints, previous pathways and wrong inputs
%     - tests plotOptStoicPathway
%
% Authors:
%     - Sebastián N. Mendoza, 24/11/2026
%

global CBTDIR

% require a MILP solver (no MATLAB toolbox is needed)
solvers = prepareTest('needsLP', true, 'needsMILP', true, 'useSolversIfAvailable', {'glpk', 'gurobi', 'ibm_cplex'});

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-6;

% network 1: two alternative pathways from A to 2 D (A -> C -> 2 D and
% A -> B -> C -> 2 D), a reaction from a metabolite that cannot be produced
% (E -> D), a dead end (B <=> F) and a reaction that produces protons (H)
db = createModel();
db = addReaction(db, 'R1', 'reactionFormula', 'A -> B', 'printLevel', 0);
db = addReaction(db, 'R2', 'reactionFormula', 'B -> C', 'printLevel', 0);
db = addReaction(db, 'R3', 'reactionFormula', 'A -> C', 'printLevel', 0);
db = addReaction(db, 'R4', 'reactionFormula', 'C -> 2 D', 'printLevel', 0);
db = addReaction(db, 'R5', 'reactionFormula', 'E -> D', 'printLevel', 0);
db = addReaction(db, 'R6', 'reactionFormula', 'B <=> F', 'printLevel', 0);
db = addReaction(db, 'H1', 'reactionFormula', 'A -> G + H', 'printLevel', 0);
db.metNames = strcat(db.mets, '_name');
db.rxnNames = strcat('name_', db.rxns);
db.rxnAbbreviations = strcat('ab_', db.rxns);

% network 2: a pathway from A to D with a reversible reaction and an
% internal cycle B -> C -> E -> B (minimal fields of the database)
model2 = createModel();
model2 = addReaction(model2, 'T1', 'reactionFormula', 'A -> B', 'printLevel', 0);
model2 = addReaction(model2, 'T2', 'reactionFormula', 'B <=> D', 'printLevel', 0);
model2 = addReaction(model2, 'L1', 'reactionFormula', 'B <=> C', 'printLevel', 0);
model2 = addReaction(model2, 'L2', 'reactionFormula', 'C <=> E', 'printLevel', 0);
model2 = addReaction(model2, 'L3', 'reactionFormula', 'E <=> B', 'printLevel', 0);
db2 = struct('S', model2.S, 'mets', {model2.mets}, 'rxns', {model2.rxns}, 'lb', model2.lb, 'ub', model2.ub);
% basis of the null space of the internal cycle (loopless constraints)
db2Loop = db2;
db2Loop.loopMatrix = double(ismember(db2.rxns, {'L1', 'L2', 'L3'}))';
db2Loop.loopRxns = ismember(db2.rxns, {'L1', 'L2', 'L3'});

for k = 1:numel(solvers.MILP)
    fprintf(' -- Running testOptStoicPathways using the solver interface: %s ... ', solvers.MILP{k});
    solverOK = changeCobraSolver(solvers.MILP{k}, 'MILP', 0);
    if solverOK
        % minFlux: enumeration stops when no more pathways exist
        output = evalc('pathways = optStoicMinFlux(db, {''A'', ''D''}, [-1, 2], ''nSolutions'', 3);');
        assert(numel(pathways) == 2 && contains(output, 'no feasible solution'));
        assert(pathways(1).stat == 1 && abs(pathways(1).objValue - 2) < tol);
        assert(isequal(pathways(1).rxns, {'R3'; 'R4'}) && isequal(pathways(1).fluxes, [1; 1]));
        assert(pathways(1).nRxns == 2 && pathways(1).totalFlux == 2);
        assert(isequal(pathways(1).exchangeMets, {'A'; 'D'}) && isequal(pathways(1).exchangeFluxes, [-1; 2]));
        assert(isequal(pathways(1).table.abbreviation, {'ab_R3'; 'ab_R4'}));
        assert(isequal(pathways(1).table.name, {'name_R3'; 'name_R4'}));
        assert(contains(pathways(1).table.formula{1}, 'A_name') && pathways(1).time >= 0);
        assert(isequal(pathways(2).rxns, {'R1'; 'R2'; 'R4'}) && pathways(2).totalFlux == 3);

        % minRxn
        pathways = optStoicMinRxn(db, {'A', 'D'}, [-1, 2], 'nSolutions', 2, 'printLevel', 0, ...
            'timeLimit', 60, 'relMipGapTol', 1e-4);
        assert(numel(pathways) == 2 && pathways(1).nRxns == 2 && pathways(2).nRxns == 3);
        assert(abs(pathways(1).objValue - 2) < tol);

        % excluded reactions (a missing reaction is reported) and metabolites
        output = evalc('pathways = optStoicMinFlux(db, {''A'', ''D''}, [-1, 2], ''excludedRxns'', {''R3'', ''R99''});');
        assert(contains(output, 'R99') && isequal(pathways(1).rxns, {'R1'; 'R2'; 'R4'}));
        pathways = optStoicMinFlux(db, {'A', 'D'}, [-1, 2], 'excludedMets', {'B'}, 'nSolutions', 2, 'printLevel', 0);
        assert(numel(pathways) == 1 && isequal(pathways(1).rxns, {'R3'; 'R4'}));
        pathways = optStoicMinFlux(db, {'A', 'D'}, [-1, 2], 'excludedMets', {'C'}, 'printLevel', 0);
        assert(isempty(pathways));

        % maximum number of reactions
        pathways = optStoicMinRxn(db, {'A', 'D'}, [-1, 2], 'maxRxns', 2, 'nSolutions', 2, 'printLevel', 0);
        assert(numel(pathways) == 1 && isequal(pathways(1).rxns, {'R3'; 'R4'}));

        % flexible metabolites and linear constraints on the exchanges
        pathways = optStoicMinFlux(db, {'A', 'G'}, [-1, 1], 'printLevel', 0);
        assert(isempty(pathways));
        pathways = optStoicMinFlux(db, {'A', 'G'}, [-1, 1], 'flexibleMets', {'H'}, 'printLevel', 0);
        assert(isequal(pathways(1).rxns, {'H1'}) && isequal(pathways(1).exchangeMets, {'A'; 'G'; 'H'}));
        assert(isequal(pathways(1).exchangeFluxes, [-1; 1; 1]));
        constraint = struct('mets', {{'H'}}, 'coefs', 1, 'lb', 2, 'ub', 2);
        pathways = optStoicMinFlux(db, {'A', 'G'}, [-1, 1], 'flexibleMets', {'H'}, 'flexibleBounds', [-5, 5], ...
            'exchangeConstraints', constraint, 'printLevel', 0);
        assert(isempty(pathways));
        constraint = struct('mets', {{'H', 'G'}, {'H'}}, 'coefs', {[1, 1], 1}, 'lb', {2, 0}, 'ub', {2, 1});
        pathways = optStoicMinFlux(db, {'A', 'G'}, [-1, 1], 'flexibleMets', {'H'}, 'exchangeConstraints', constraint, ...
            'printLevel', 0);
        assert(isequal(pathways(1).rxns, {'H1'}));

        % non-integer fluxes
        pathways = optStoicMinFlux(db, {'A', 'D'}, [-0.5, 1], 'integerFlux', false, 'printLevel', 0);
        assert(isequal(pathways(1).rxns, {'R3'; 'R4'}) && max(abs(pathways(1).fluxes - 0.5)) < tol);

        % previous pathways: the enumeration continues in a second call; a
        % previous pathway that uses unavailable reactions is ignored
        pathways = optStoicMinFlux(db, {'A', 'D'}, [-1, 2], 'printLevel', 0);
        output = evalc('pathways2 = optStoicMinFlux(db, {''A'', ''D''}, [-1, 2], ''previousPathways'', pathways);');
        assert(contains(output, 'integer cuts of 1 previous pathways'));
        assert(isequal(pathways2(1).rxns, {'R1'; 'R2'; 'R4'}));
        output = evalc(['pathways2 = optStoicMinFlux(db, {''A'', ''D''}, [-1, 2], ''previousPathways'', pathways, ', ...
            '''excludedRxns'', {''R3''});']);
        assert(~contains(output, 'previous pathways') && isequal(pathways2(1).rxns, {'R1'; 'R2'; 'R4'}));

        % network 2: without database annotations, the table uses the reaction IDs
        pathways = optStoicMinFlux(db2, {'A', 'D'}, [-1, 1], 'printLevel', 2);
        assert(isequal(pathways(1).rxns, {'T1'; 'T2'}) && pathways(1).totalFlux == 2);
        assert(isequal(pathways(1).table.name, {'T1'; 'T2'}) && all(cellfun(@isempty, pathways(1).table.abbreviation)));
        % fixed total flux: the internal cycle is used, and the total flux is
        % the sum of absolute fluxes (also for the reversible reaction T2)
        pathways = optStoicMinFlux(db2, {'A', 'D'}, [-1, 1], 'totalFlux', 5, 'nSolutions', 2, 'printLevel', 0);
        assert(numel(pathways) == 1 && pathways(1).totalFlux == 5 && pathways(1).nRxns == 5);
        assert(abs(pathways(1).objValue - 5) < tol && all(abs(pathways(1).fluxes) == 1));
        % fluxes of the cycle lower than tol are not reported in the pathway
        output = evalc(['pathways = optStoicMinFlux(db2, {''A'', ''D''}, [-1, 1], ''totalFlux'', 2.5, ', ...
            '''integerFlux'', false, ''tol'', 0.2);']);
        assert(contains(output, 'Warning: pathway 1 has a total flux of 2 instead of 2.5'));
        assert(isequal(pathways(1).rxns, {'T1'; 'T2'}));
        % loopless constraints: the cycle cannot be used
        output = evalc('pathways = optStoicMinFlux(db2Loop, {''A'', ''D''}, [-1, 1], ''loopless'', true);');
        assert(contains(output, 'loopless constraints: 1 loops, 3 loop reactions'));
        assert(isequal(pathways(1).rxns, {'T1'; 'T2'}));
        pathways = optStoicMinFlux(db2Loop, {'A', 'D'}, [-1, 1], 'loopless', true, 'totalFlux', 5, 'printLevel', 0);
        assert(isempty(pathways));
        % loop reactions that are not available keep their loopless variables
        pathways = optStoicMinFlux(db2Loop, {'A', 'D'}, [-1, 1], 'loopless', true, 'excludedRxns', {'L3'}, ...
            'printLevel', 0);
        assert(isequal(pathways(1).rxns, {'T1'; 'T2'}));
        pathways = optStoicMinRxn(db2Loop, {'A', 'D'}, [-1, 1], 'loopless', true, 'printLevel', 0);
        assert(pathways(1).nRxns == 2);
    end
    fprintf('Done.\n');
end

% wrong inputs (checked before solving)
assert(verifyCobraFunctionError('findOptStoicPathways', 'inputs', {db, {'A', 'D'}, -1}));
assert(verifyCobraFunctionError('findOptStoicPathways', 'inputs', {db, {'A', 'D'}, [-1, 2], 'method', 'other'}));
assert(verifyCobraFunctionError('findOptStoicPathways', 'inputs', {db, {'A', 'X'}, [-1, 2]}));
assert(verifyCobraFunctionError('findOptStoicPathways', 'inputs', {db, {'A', 'D'}, [-1, 2], ...
    'flexibleMets', {'H'}, 'flexibleBounds', [-1, 1, 2]}));
assert(verifyCobraFunctionError('findOptStoicPathways', 'inputs', {db, {'A', 'D'}, [-0.5, 1]}));
assert(verifyCobraFunctionError('findOptStoicPathways', 'inputs', {db2, {'A', 'D'}, [-1, 1], 'loopless', true}));
assert(verifyCobraFunctionError('findOptStoicPathways', 'inputs', {db, {'A', 'D'}, [-1, 2], ...
    'method', 'minRxn', 'totalFlux', 3}));
assert(verifyCobraFunctionError('findOptStoicPathways', 'inputs', {db, {'A', 'D'}, [-1, 2], ...
    'exchangeConstraints', struct('mets', {{'A', 'D'}}, 'coefs', 1, 'lb', 0, 'ub', 1)}));
assert(verifyCobraFunctionError('findOptStoicPathways', 'inputs', {db, {'A', 'D'}, [-1, 2], ...
    'exchangeConstraints', struct('mets', {{'B'}}, 'coefs', 1, 'lb', 0, 'ub', 1)}));
assert(verifyCobraFunctionError('optStoicMinFlux', 'inputs', {db, {'A', 'D'}}));
assert(verifyCobraFunctionError('optStoicMinFlux', 'inputs', {db, {'A', 'D'}, [-1, 2], 'method', 'minRxn'}));
assert(verifyCobraFunctionError('optStoicMinRxn', 'inputs', {db, {'A', 'D'}}));
assert(verifyCobraFunctionError('optStoicMinRxn', 'inputs', {db, {'A', 'D'}, [-1, 2], 'method', 'minFlux'}));

% plotOptStoicPathway (figures are not displayed)
defaultVisible = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');
pathway = struct('rxns', {{'R1'; 'R2'; 'R4'}}, 'fluxes', [1; 1; 1], 'exchangeMets', {{'A'; 'D'}}, ...
    'exchangeFluxes', [-1; 2]);
[G, h] = plotOptStoicPathway(db, pathway);
assert(numnodes(G) == 7 && numedges(G) == 6);
assert(findedge(G, 'm:A', 'r:R1') > 0 && findedge(G, 'r:R1', 'm:B') > 0 && findedge(G, 'r:R4', 'm:D') > 0);
assert(any(strcmp(h.NodeLabel, 'ab_R1 (1)')) && any(strcmp(h.NodeLabel, 'A_name')));
% currency metabolites, labels without abbreviations and fluxes, given axes and title
figure;
ax = axes();
pathway = rmfield(pathway, {'exchangeMets', 'exchangeFluxes'});
[G, h] = plotOptStoicPathway(db, pathway, 'currencyMets', {'B'}, 'useAbbreviations', false, ...
    'showFlux', false, 'axes', ax, 'title', 'pathway');
assert(numnodes(G) == 6 && numedges(G) == 4);
assert(any(strcmp(h.NodeLabel, 'R1')) && strcmp(ax.Title.String, 'pathway'));
% database without metabolite names nor abbreviations
[~, h] = plotOptStoicPathway(db2, struct('rxns', {{'T1'; 'T2'}}, 'fluxes', [1; -1]));
assert(any(strcmp(h.NodeLabel, 'T1 (1)')) && any(strcmp(h.NodeLabel, 'D')));
assert(verifyCobraFunctionError('plotOptStoicPathway', 'inputs', {db, struct('rxns', {{'X'}}, 'fluxes', 1)}));
close all
set(0, 'DefaultFigureVisible', defaultVisible);

% change the directory
cd(currentDir)
