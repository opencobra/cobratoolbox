function pathways = findOptStoicPathways(database, overallMets, overallCoefs, varargin)
% Identifies metabolic networks (pathways) that carry out a given overall
% stoichiometric conversion using the reactions of a database (second step
% of the optStoic procedure, Chowdhury and Maranas, 2015). Two formulations
% are available:
%
%   * minFlux: minimizes the sum of absolute fluxes of the database reactions
%   * minRxn: minimizes the number of database reactions
%
% An exchange reaction is added for each metabolite of the overall
% conversion, with its flux fixed to the corresponding coefficient. All
% metabolites (including cofactors) must be balanced. Alternative pathways
% are enumerated with integer cuts: the reactions of each pathway found
% cannot be all active in the next ones. Optionally, the loopless
% constraints of Ng et al. (2019) prevent internal cycles (including cycles
% that only interconvert cofactors), and the total flux of minFlux can be
% fixed to enumerate the pathways with a given total flux.
%
% .. math::
%
%    min      & \sum_{j \in J} |v_j| \; (minFlux) \; or \; \sum_{j \in J} y_j \; (minRxn) \\
%    s.t.     & \sum_j S_{ij} v_j = 0, \quad \forall i \\
%             & LB_j y_j \leq v_j \leq UB_j y_j \\
%             & \sum_{j \in P_k} (1 - y_j) \geq 1, \quad \forall k \; (integer \; cuts) \\
%             & y_j \in \{0, 1\}, \; v_j \in Z \; (optional) \\
%             & \sum_j N_{lj} G_j = 0, \; G_j \leq -1 \; if \; v_j > 0, \;
%               G_j \geq 1 \; if \; v_j < 0, \; |G_j| \geq 1 \; (loopless, optional)
%
% USAGE:
%
%    pathways = findOptStoicPathways(database, overallMets, overallCoefs, varargin)
%
% INPUTS:
%    database:          (structure) database loaded with `loadOptStoicDatabase`
%                       (COBRA model with fields `S`, `mets`, `rxns`, `lb`, `ub`)
%    overallMets:       (cell array) metabolites of the overall conversion
%    overallCoefs:      (double) their stoichiometric coefficients (negative
%                       for consumed metabolites, positive for produced ones)
%
% OPTIONAL INPUTS:
%    method:            (string) 'minFlux' or 'minRxn' (Default = 'minFlux')
%    nSolutions:        (double) maximum number of pathways to enumerate
%                       (Default = 1)
%    flexibleMets:      (cell array) metabolites whose exchange flux is not
%                       fixed but bounded, e.g. protons {'C00080'} because of
%                       proton imbalances in the database (Default = {})
%    flexibleBounds:    (double) n x 2 matrix with the bounds of the
%                       exchange of `flexibleMets` (Default = [-10 10] for each)
%    excludedRxns:      (cell array) reactions that cannot be used (Default = {})
%    excludedMets:      (cell array) metabolites that cannot participate:
%                       all reactions involving them are excluded (Default = {})
%    maxRxns:           (double) maximum number of database reactions in
%                       a pathway (Default = [], no limit)
%    exchangeConstraints: (structure) structure array of linear constraints
%                       on the exchange fluxes, with fields `mets` (cell
%                       array of metabolites of `overallMets` or
%                       `flexibleMets`), `coefs` (double), `lb` and `ub`:
%                       lb <= sum(coefs .* v_EX(mets)) <= ub (Default = [])
%    loopless:          (logical) add the loopless constraints of Ng et al.
%                       (2019). Requires the fields `loopMatrix` (nLoops x
%                       nRxns, e.g. a basis of the null space of the internal
%                       stoichiometric matrix) and `loopRxns` (logical,
%                       reactions that can form internal cycles) of the
%                       database (Default = false)
%    totalFlux:         (double) fixes the total flux (sum of absolute
%                       fluxes of the database reactions) of minFlux, so
%                       that all the pathways with this total flux are
%                       enumerated (Default = [], not fixed)
%    previousPathways:  (structure) pathways found previously (output of
%                       this function), excluded with integer cuts. Allows
%                       to continue an enumeration in several calls
%                       (Default = [])
%    integerFlux:       (logical) fluxes must be integers, as in
%                       `minFlux.gms` and `minRxn.gms` (Default = true)
%    timeLimit:         (double) time limit of each MILP in seconds
%                       (Default = 1200)
%    relMipGapTol:      (double) relative MIP gap tolerance (Default = 1e-6)
%    tol:               (double) fluxes with absolute value lower than tol
%                       are considered zero (Default = 1e-6)
%    printLevel:        (double) 0 silent, 1 summary of each pathway,
%                       2 solver output (Default = 1)
%
% OUTPUT:
%    pathways:          (structure) structure array (one element per pathway)
%                       with fields:
%
%                         * .stat - solver status (1 optimal, 3 time limit
%                           with a feasible solution)
%                         * .objValue - optimal value (sum of fluxes or
%                           number of reactions)
%                         * .rxns - IDs of the database reactions in the pathway
%                         * .fluxes - their fluxes
%                         * .nRxns - number of database reactions
%                         * .totalFlux - sum of absolute fluxes
%                         * .exchangeMets, .exchangeFluxes - fluxes of the
%                           exchange reactions (negative = consumption)
%                         * .table - table with the reactions, abbreviations,
%                           fluxes, formulas (metabolite names) and names
%                         * .time - solution time in seconds
%
% EXAMPLE:
%
%    % glucose -> 3 acetate + 3 H+ (minFlux.gms)
%    pathways = findOptStoicPathways(database, {'C00267', 'C00033'}, [-1 3], ...
%        'method', 'minFlux', 'flexibleMets', {'C00080'}, 'flexibleBounds', [-10 10], 'nSolutions', 5);
%    % glucose + ADP + Pi -> 2 pyruvate + ATP + H2O with 2 NAD(P)H, loopless,
%    % total flux 10 (llminflux, Ng et al. 2019; the database must include the
%    % fields loopMatrix and loopRxns)
%    redox = struct('mets', {{'C00004', 'C00005'}, {'C00003', 'C00004'}, {'C00006', 'C00005'}}, ...
%        'coefs', {[1 1], [1 1], [1 1]}, 'lb', {2, 0, 0}, 'ub', {2, 0, 0});
%    pathways = findOptStoicPathways(database, {'C00031', 'C00022', 'C00002', 'C00008', 'C00009', 'C00001'}, ...
%        [-1 2 1 -1 -1 1], 'flexibleMets', {'C00080', 'C00003', 'C00004', 'C00006', 'C00005'}, ...
%        'flexibleBounds', [-10 10; -2 0; 0 2; -2 0; 0 2], 'exchangeConstraints', redox, ...
%        'loopless', true, 'totalFlux', 10, 'nSolutions', 100);
%
% NOTE:
%
%    As in the GAMS implementation, the set of reactions stored for the
%    integer cuts is the set of reactions with y_j = 1 (minRxn) or with
%    non-zero flux (minFlux), including the exchange reactions. Reactions
%    with both bounds equal to zero are removed from the problem, and the
%    auxiliary variables `x_j >= |v_j|` of minFlux are only defined for
%    reversible reactions (|v_j| is v_j or -v_j for irreversible ones), which
%    gives the same optimal solutions with a smaller problem. When the total
%    flux is fixed, a direction binary is added for each reversible reaction
%    to enforce `x_j = |v_j|` (otherwise `x_j` could exceed `|v_j|` and
%    pathways with a lower total flux would satisfy the constraint). Requires a
%    MILP solver (see `changeCobraSolver`). The loopless constraints follow
%    `llminflux_1_0ATP_z10.gms` of optstoic-python: a pseudo free energy
%    `G_j` in [-M, M] and a binary `a_j` are defined for every reaction of
%    `loopRxns` (including those that cannot carry flux), with
%    sum_j Nint(l,j) G_j = 0, G_j >= -M a_j + (1 - a_j),
%    G_j <= -a_j + M (1 - a_j), v_j >= -M (1 - a_j) and v_j <= M a_j, where
%    M is the maximum absolute flux bound.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on minFlux.gms and minRxn.gms (A. Chowdhury, C.Y. Ng, C.D. Maranas)
%            - Sebastián N. Mendoza, 15/10/2026, loopless constraints, fixed total flux and exchange constraints (Ng et al., 2019)

parser = inputParser();
parser.addRequired('database', @(x) isstruct(x) && all(isfield(x, {'S', 'mets', 'rxns', 'lb', 'ub'})));
parser.addRequired('overallMets', @iscellstr);
parser.addRequired('overallCoefs', @isnumeric);
parser.addParameter('method', 'minFlux', @(x) any(strcmpi(x, {'minFlux', 'minRxn'})));
parser.addParameter('nSolutions', 1, @(x) isnumeric(x) && isscalar(x) && x >= 1);
parser.addParameter('flexibleMets', {}, @iscellstr);
parser.addParameter('flexibleBounds', [], @isnumeric);
parser.addParameter('excludedRxns', {}, @iscellstr);
parser.addParameter('excludedMets', {}, @iscellstr);
parser.addParameter('maxRxns', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x >= 1));
parser.addParameter('exchangeConstraints', [], @(x) isempty(x) || (isstruct(x) && all(isfield(x, {'mets', 'coefs', 'lb', 'ub'}))));
parser.addParameter('loopless', false, @(x) islogical(x) || isnumeric(x));
parser.addParameter('totalFlux', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x >= 0));
parser.addParameter('previousPathways', [], @(x) isempty(x) || (isstruct(x) && all(isfield(x, {'rxns', 'exchangeMets', 'exchangeFluxes'}))));
parser.addParameter('integerFlux', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('timeLimit', 1200, @(x) isnumeric(x) && isscalar(x) && x > 0);
parser.addParameter('relMipGapTol', 1e-6, @(x) isnumeric(x) && isscalar(x) && x >= 0);
parser.addParameter('tol', 1e-6, @(x) isnumeric(x) && isscalar(x) && x >= 0);
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(database, overallMets, overallCoefs, varargin{:});
database = parser.Results.database;
overallMets = parser.Results.overallMets(:);
overallCoefs = parser.Results.overallCoefs(:);
method = parser.Results.method;
nSolutions = parser.Results.nSolutions;
flexibleMets = parser.Results.flexibleMets(:);
flexibleBounds = parser.Results.flexibleBounds;
excludedRxns = parser.Results.excludedRxns(:);
excludedMets = parser.Results.excludedMets(:);
maxRxns = parser.Results.maxRxns;
exchangeConstraints = parser.Results.exchangeConstraints;
loopless = parser.Results.loopless;
totalFlux = parser.Results.totalFlux;
previousPathways = parser.Results.previousPathways;
integerFlux = parser.Results.integerFlux;
timeLimit = parser.Results.timeLimit;
relMipGapTol = parser.Results.relMipGapTol;
tol = parser.Results.tol;
printLevel = parser.Results.printLevel;

isMinFlux = strcmpi(method, 'minFlux');
if numel(overallCoefs) ~= numel(overallMets)
    error('overallCoefs must have one element per metabolite in overallMets.');
end
if isempty(flexibleBounds)
    flexibleBounds = repmat([-10 10], numel(flexibleMets), 1);
end
if size(flexibleBounds, 1) ~= numel(flexibleMets) || size(flexibleBounds, 2) ~= 2
    error('flexibleBounds must be a n x 2 matrix with one row per metabolite in flexibleMets.');
end
allExMets = unique([overallMets; flexibleMets], 'stable');
[found, exMetIdx] = ismember(allExMets, database.mets);
if ~all(found)
    error('Metabolites not found in the database: %s', strjoin(allExMets(~found), ', '));
end
if integerFlux && any(abs(overallCoefs - round(overallCoefs)) > 1e-9)
    error('integerFlux requires integer overall coefficients. Scale the overall stoichiometry.');
end
missingRxns = setdiff(excludedRxns, database.rxns);
if ~isempty(missingRxns) && printLevel > 0
    fprintf('Warning: excluded reactions not found in the database: %s\n', strjoin(missingRxns, ', '));
end
if loopless && ~all(isfield(database, {'loopMatrix', 'loopRxns'}))
    error('The loopless constraints require the fields loopMatrix and loopRxns of the database.');
end
if ~isempty(totalFlux) && ~isMinFlux
    error('totalFlux can only be fixed with the minFlux method.');
end
for k = 1:numel(exchangeConstraints)
    if ~iscellstr(exchangeConstraints(k).mets) || numel(exchangeConstraints(k).mets) ~= numel(exchangeConstraints(k).coefs)
        error('exchangeConstraints(%d): mets must be a cell array with one coefficient per metabolite.', k);
    end
    if ~all(ismember(exchangeConstraints(k).mets, allExMets))
        error('exchangeConstraints(%d): metabolites must be in overallMets or flexibleMets.', k);
    end
end

% database reactions available
available = ~(database.lb == 0 & database.ub == 0);
available(ismember(database.rxns, excludedRxns)) = false;
if ~isempty(excludedMets)
    metRows = ismember(database.mets, excludedMets);
    available(any(database.S(metRows, :) ~= 0, 1)') = false;
end
rxnIdx = find(available);
nInt = numel(rxnIdx);

% exchange reactions
nEx = numel(allExMets);
exLB = zeros(nEx, 1);
exUB = zeros(nEx, 1);
[isOverall, posOverall] = ismember(allExMets, overallMets);
exLB(isOverall) = overallCoefs(posOverall(isOverall));
exUB(isOverall) = overallCoefs(posOverall(isOverall));
[isFlex, posFlex] = ismember(allExMets, flexibleMets);
exLB(isFlex) = flexibleBounds(posFlex(isFlex), 1);
exUB(isFlex) = flexibleBounds(posFlex(isFlex), 2);
exRxns = strcat('EX_', allExMets);

S = [database.S(:, rxnIdx), sparse(exMetIdx, 1:nEx, -1, numel(database.mets), nEx)];
usedMets = any(S ~= 0, 2);
S = S(usedMets, :);
nMets = size(S, 1);
LB = [database.lb(rxnIdx); exLB];
UB = [database.ub(rxnIdx); exUB];
nR = nInt + nEx;
isInternal = [true(nInt, 1); false(nEx, 1)];

% variables: v (nR), y (nR) and, for minFlux, x = |v| (reversible database
% reactions only; |v| = v or -v for irreversible reactions)
revIdx = find(isInternal & LB < 0 & UB > 0);
nX = numel(revIdx) * isMinFlux;
nVars = 2 * nR + nX;
iv = 1:nR;
iy = nR + (1:nR);
ix = 2 * nR + (1:nX);
I = speye(nR);
A = [S, sparse(nMets, nR + nX); ...                   % mass balance
    I, -spdiags(LB, 0, nR, nR), sparse(nR, nX); ...   % v - LB y >= 0
    I, -spdiags(UB, 0, nR, nR), sparse(nR, nX)];      % v - UB y <= 0
b = zeros(nMets + 2 * nR, 1);
csense = [repmat('E', nMets, 1); repmat('G', nR, 1); repmat('L', nR, 1)];
if isMinFlux && nX > 0
    P = sparse(1:nX, revIdx, 1, nX, nR);
    A = [A; -P, sparse(nX, nR), speye(nX); P, sparse(nX, nR), speye(nX)];  % x >= v, x >= -v
    b = [b; zeros(2 * nX, 1)];
    csense = [csense; repmat('G', 2 * nX, 1)];
end
if ~isempty(maxRxns)
    row = sparse(1, iy(isInternal), 1, 1, nVars);
    A = [A; row];
    b = [b; maxRxns];
    csense = [csense; 'L'];
end
c = zeros(nVars, 1);
if isMinFlux
    c(iv(isInternal & LB >= 0)) = 1;
    c(iv(isInternal & UB <= 0 & LB < 0)) = -1;
    c(ix) = 1;
else
    c(iy(isInternal)) = 1;
end
vmax = max(abs([LB; UB]));
lb = [LB; zeros(nR, 1); zeros(nX, 1)];
ub = [UB; ones(nR, 1); vmax * ones(nX, 1)];
vartype = [repmat('C', nR, 1); repmat('B', nR, 1); repmat('C', nX, 1)];
if integerFlux
    vartype(iv) = 'I';
end
% fixed total flux (minFlux objective)
if ~isempty(totalFlux)
    % x_j = |v_j| for the reversible reactions (direction binaries d_j), so
    % that the fixed value is the actual sum of absolute fluxes:
    % v_j <= M d_j, v_j >= -M (1 - d_j), x_j <= v_j + 2M (1 - d_j), x_j <= -v_j + 2M d_j
    if nX > 0
        id = nVars + (1:nX);
        nVarsDir = nVars + nX;
        A = [A, sparse(size(A, 1), nX)];
        Pv = sparse(1:nX, iv(revIdx), 1, nX, nVarsDir);
        Px = sparse(1:nX, ix, 1, nX, nVarsDir);
        Pd = sparse(1:nX, id, 1, nX, nVarsDir);
        A = [A; Pv - vmax * Pd; Pv - vmax * Pd; Px - Pv + 2 * vmax * Pd; Px + Pv - 2 * vmax * Pd];
        b = [b; zeros(nX, 1); -vmax * ones(nX, 1); 2 * vmax * ones(nX, 1); zeros(nX, 1)];
        csense = [csense; repmat('L', nX, 1); repmat('G', nX, 1); repmat('L', nX, 1); repmat('L', nX, 1)];
        c = [c; zeros(nX, 1)];
        lb = [lb; zeros(nX, 1)];
        ub = [ub; ones(nX, 1)];
        vartype = [vartype; repmat('B', nX, 1)];
        nVars = nVarsDir;
    end
    A = [A; c'];
    b = [b; totalFlux];
    csense = [csense; 'E'];
end
% linear constraints on the exchange fluxes
for k = 1:numel(exchangeConstraints)
    [~, pos] = ismember(exchangeConstraints(k).mets, allExMets);
    row = sparse(1, iv(nInt + pos), exchangeConstraints(k).coefs, 1, nVars);
    A = [A; row; row];
    b = [b; exchangeConstraints(k).lb; exchangeConstraints(k).ub];
    csense = [csense; 'G'; 'L'];
end
% loopless constraints: G (pseudo free energies) and a (binaries) for all
% the loop reactions, linked to v for those that can carry flux
if loopless
    loopIdx = find(database.loopRxns(:));
    nL = numel(loopIdx);
    N = database.loopMatrix(:, loopIdx);
    N = N(any(N, 2), :);
    nLoops = size(N, 1);
    [hasFlux, posFlux] = ismember(loopIdx, rxnIdx);
    nF = sum(hasFlux);
    ia = nVars + nL + (1:nL);
    nVarsLoop = nVars + 2 * nL;
    IL = speye(nL);
    A = [A, sparse(size(A, 1), 2 * nL); ...
        sparse(nLoops, nVars), N, sparse(nLoops, nL); ...      % sum_j N(l,j) G_j = 0
        sparse(nL, nVars), IL, (vmax + 1) * IL; ...            % G_j >= -M a_j + (1 - a_j)
        sparse(nL, nVars), IL, (vmax + 1) * IL];               % G_j <= -a_j + M (1 - a_j)
    b = [b; zeros(nLoops, 1); ones(nL, 1); vmax * ones(nL, 1)];
    csense = [csense; repmat('E', nLoops, 1); repmat('G', nL, 1); repmat('L', nL, 1)];
    link = sparse(1:nF, iv(posFlux(hasFlux)), 1, nF, nVarsLoop) + sparse(1:nF, ia(hasFlux), -vmax, nF, nVarsLoop);
    A = [A; link; link];                                       % v_j >= -M (1 - a_j), v_j <= M a_j
    b = [b; -vmax * ones(nF, 1); zeros(nF, 1)];
    csense = [csense; repmat('G', nF, 1); repmat('L', nF, 1)];
    c = [c; zeros(2 * nL, 1)];
    lb = [lb; -vmax * ones(nL, 1); zeros(nL, 1)];
    ub = [ub; vmax * ones(nL, 1); ones(nL, 1)];
    vartype = [vartype; repmat('C', nL, 1); repmat('B', nL, 1)];
    nVars = nVarsLoop;
end
problem = struct('A', A, 'b', b, 'c', c, 'lb', lb, 'ub', ub, 'csense', csense, ...
    'osense', 1, 'vartype', vartype, 'x0', []);

allRxns = [database.rxns(rxnIdx); exRxns];
% integer cuts of the pathways found previously (same reaction sets as the
% cuts added after each iteration: reactions and exchanges with flux)
nPrevious = 0;
for p = 1:numel(previousPathways)
    activeEx = previousPathways(p).exchangeMets(previousPathways(p).exchangeFluxes(:) ~= 0);
    [isRxn, rxnPos] = ismember(previousPathways(p).rxns(:), allRxns(1:nInt));
    [isEx, exPos] = ismember(activeEx(:), allExMets);
    if ~all(isRxn) || ~all(isEx)
        continue  % uses reactions not available in this problem
    end
    cols = [rxnPos; nInt + exPos];
    problem.A = [problem.A; sparse(1, iy(cols), 1, 1, nVars)];
    problem.b = [problem.b; numel(cols) - 1];
    problem.csense = [problem.csense; 'L'];
    nPrevious = nPrevious + 1;
end
pathways = struct('stat', {}, 'objValue', {}, 'rxns', {}, 'fluxes', {}, 'nRxns', {}, 'totalFlux', {}, ...
    'exchangeMets', {}, 'exchangeFluxes', {}, 'table', {}, 'time', {});
if printLevel > 0
    fprintf('%s: %d database reactions, %d exchange reactions, %d metabolites\n', method, nInt, nEx, nMets);
    if loopless
        fprintf('loopless constraints: %d loops, %d loop reactions\n', nLoops, nL);
    end
    if nPrevious > 0
        fprintf('integer cuts of %d previous pathways\n', nPrevious);
    end
end
for k = 1:nSolutions
    t0 = tic;
    sol = solveCobraMILP(problem, 'timeLimit', timeLimit, 'relMipGapTol', relMipGapTol, ...
        'printLevel', max(0, printLevel - 1));
    elapsed = toc(t0);
    if ~(sol.stat == 1 || (sol.stat == 3 && ~isempty(sol.full)))
        if printLevel > 0
            fprintf('Iteration %d: no feasible solution (stat = %d). Stopping.\n', k, sol.stat);
        end
        break
    end
    v = sol.full(iv);
    y = round(sol.full(iy));
    v(abs(v) < tol) = 0;
    if isMinFlux
        inPathway = v ~= 0;
    else
        inPathway = y == 1;
    end
    sel = inPathway & isInternal;
    pathway = struct();
    pathway.stat = sol.stat;
    pathway.objValue = sol.obj;
    pathway.rxns = allRxns(sel);
    pathway.fluxes = v(sel);
    pathway.nRxns = sum(sel);
    pathway.totalFlux = sum(abs(v(sel)));
    if ~isempty(totalFlux) && abs(pathway.totalFlux - totalFlux) > max(tol, 1e-6 * totalFlux) && printLevel > 0
        fprintf('Warning: pathway %d has a total flux of %g instead of %g\n', k, pathway.totalFlux, totalFlux);
    end
    pathway.exchangeMets = allExMets;
    pathway.exchangeFluxes = v(~isInternal);
    dbIdx = rxnIdx(sel(isInternal));
    abbreviations = repmat({''}, numel(dbIdx), 1);
    if isfield(database, 'rxnAbbreviations')
        abbreviations = database.rxnAbbreviations(dbIdx);
    end
    names = database.rxns(dbIdx);
    if isfield(database, 'rxnNames')
        names = database.rxnNames(dbIdx);
    end
    formulas = printRxnFormula(database, 'rxnAbbrList', pathway.rxns, 'printFlag', false, ...
        'metNameFlag', isfield(database, 'metNames'));
    pathway.table = table(pathway.rxns, abbreviations, pathway.fluxes, formulas(:), names(:), ...
        'VariableNames', {'rxn', 'abbreviation', 'flux', 'formula', 'name'});
    pathway.time = elapsed;
    pathways(k) = pathway;
    if printLevel > 0
        fprintf('Iteration %d: objective = %g, reactions = %d, sum of fluxes = %g, time = %.1f s\n', ...
            k, sol.obj, pathway.nRxns, pathway.totalFlux, elapsed);
    end
    if k < nSolutions
        % integer cut: sum_{j in P} y_j <= |P| - 1
        cut = sparse(1, iy(inPathway), 1, 1, nVars);
        problem.A = [problem.A; cut];
        problem.b = [problem.b; sum(inPathway) - 1];
        problem.csense = [problem.csense; 'L'];
    end
end
end
