function solutions = optStoic(database, normalizationMet, objectiveMets, varargin)
% Identifies the optimal overall stoichiometry of a conversion (first step of
% the optStoic procedure, Chowdhury and Maranas, 2015). The stoichiometric
% coefficients `s_i` of a set of allowed metabolites are the variables
% (negative for reactants, positive for products). The overall conversion
% must satisfy elemental and charge balances and be thermodynamically
% favorable:
%
% .. math::
%
%    max/min  & \sum_{i \in O} w_i s_i \\
%    s.t.     & \sum_i n_{ie} s_i = 0, \quad \forall e \in elements \\
%             & \sum_i q_i s_i = 0 \\
%             & \sum_i \Delta G_{f,i} s_i \leq \Delta G_{max} |s_{norm}| \\
%             & s_{norm} = s_{norm}^{0} \\
%             & lb_i \leq s_i \leq ub_i
%
% where `O` is the set of objective metabolites and `s_norm` is the
% coefficient of the normalization metabolite (e.g. the substrate, fixed to
% -1). Optionally, the number of participating metabolites can be limited
% with binary variables (MILP), coefficients can be required to be integer,
% and alternative stoichiometries can be enumerated with integer cuts.
%
% USAGE:
%
%    solutions = optStoic(database, normalizationMet, objectiveMets, varargin)
%
% INPUTS:
%    database:            (structure) database loaded with
%                         `loadOptStoicDatabase` (fields `mets`, `metNames`,
%                         `elements`, `metComposition`, `metCharges`,
%                         `metDeltaGf` and `metHasFormula`)
%    normalizationMet:    (string) ID of the metabolite whose coefficient is
%                         fixed, e.g. glucose 'C00267'
%    objectiveMets:       (cell array) IDs of the metabolites in the
%                         objective, e.g. {'C00033'}
%
% OPTIONAL INPUTS:
%    normalizationValue:  (double) coefficient of the normalization
%                         metabolite (Default = -1, i.e. one mole consumed)
%    objectiveWeights:    (double) weight of each objective metabolite
%                         (Default = ones). Use -1 to maximize the uptake of
%                         a reactant
%    osenseStr:           (string) 'max' or 'min' (Default = 'max')
%    allowedMets:         (cell array) metabolites allowed to participate.
%                         Others are fixed to zero (Default = all metabolites
%                         with formula and Gibbs free energy of formation)
%    boundMets:           (cell array) metabolites with specific bounds
%                         (Default = {})
%    boundLB:             (double) lower bounds of `boundMets` (Default = [])
%    boundUB:             (double) upper bounds of `boundMets` (Default = [])
%    defaultBounds:       (double) [lb, ub] of the coefficients of allowed
%                         metabolites (Default = [-15 15])
%    dGmax:               (double) maximum Gibbs free energy change of the
%                         overall conversion per mole of the normalization
%                         metabolite, in kcal/mol (Default = -5)
%    elements:            (cell array) elements to balance (Default = all
%                         elements present in the allowed metabolites)
%    balanceCharge:       (logical) impose charge balance (Default = true)
%    maxNumMets:          (double) maximum number of participating
%                         metabolites among `optionalMets` (Default = [], no
%                         limit). Requires a MILP solver
%    optionalMets:        (cell array) metabolites whose participation is
%                         counted by `maxNumMets` (Default = allowed
%                         metabolites except the normalization and objective
%                         metabolites)
%    integerCoefficients: (logical) integer stoichiometric coefficients
%                         (Default = false). Requires a MILP solver
%    nSolutions:          (double) maximum number of alternative
%                         stoichiometries to enumerate. After each solution,
%                         an integer cut requires that at least one of its
%                         participating optional metabolites is excluded
%                         (Default = 1)
%    tol:                 (double) coefficients with absolute value lower
%                         than tol are considered zero (Default = 1e-7)
%    printLevel:          (double) verbosity level (Default = 1)
%
% OUTPUT:
%    solutions:           (structure) structure array (one element per
%                         solution) with fields:
%
%                           * .stat - solver status (1 optimal)
%                           * .objValue - optimal value of the objective
%                           * .mets - IDs of the participating metabolites
%                             (reactants first)
%                           * .metNames - names of the participating metabolites
%                           * .coefs - their stoichiometric coefficients
%                           * .dGr - Gibbs free energy change of the overall
%                             conversion (kcal/mol), as written
%                           * .dGrNormalized - dGr per mole of the
%                             normalization metabolite (kcal/mol)
%                           * .equation - overall conversion with IDs
%                           * .equationNames - overall conversion with names
%                           * .allowedMets, .stoichiometry - full solution
%
% EXAMPLE:
%
%    % maximum yield of acetate from glucose (optStoic.gms, example 1)
%    allowed = {'C00007', 'C00267', 'C00011', 'C00080', 'C00001', 'C00033'};
%    sol = optStoic(database, 'C00267', {'C00033'}, 'allowedMets', allowed, ...
%                   'boundMets', {'C00007'}, 'boundLB', 0, 'boundUB', 0);
%    % sol.equation: 1 C00267 -> 3 C00033 + 3 C00080, sol.dGrNormalized = -75.18
%
% NOTE:
%
%    In `optStoic.gms` the yield `sum(products)/(-s_substrate)` is
%    maximized with `s_substrate <= -1` (an MINLP solved with BARON). Since
%    all constraints are homogeneous, fixing `s_substrate = -1` gives the
%    same optimal yield and turns the problem into an LP.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on optStoic-GAMS (A. Chowdhury, C.Y. Ng, C.D. Maranas)

parser = inputParser();
parser.addRequired('database', @(x) isstruct(x) && all(isfield(x, {'mets', 'elements', 'metComposition', 'metCharges', 'metDeltaGf'})));
parser.addRequired('normalizationMet', @ischar);
parser.addRequired('objectiveMets', @(x) iscellstr(x) || ischar(x));
parser.addParameter('normalizationValue', -1, @(x) isnumeric(x) && isscalar(x) && x ~= 0);
parser.addParameter('objectiveWeights', [], @isnumeric);
parser.addParameter('osenseStr', 'max', @(x) any(strcmpi(x, {'max', 'min'})));
parser.addParameter('allowedMets', {}, @iscellstr);
parser.addParameter('boundMets', {}, @iscellstr);
parser.addParameter('boundLB', [], @isnumeric);
parser.addParameter('boundUB', [], @isnumeric);
parser.addParameter('defaultBounds', [-15 15], @(x) isnumeric(x) && numel(x) == 2 && x(1) <= x(2));
parser.addParameter('dGmax', -5, @(x) isnumeric(x) && isscalar(x));
parser.addParameter('elements', {}, @iscellstr);
parser.addParameter('balanceCharge', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('maxNumMets', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x >= 0));
parser.addParameter('optionalMets', {}, @iscellstr);
parser.addParameter('integerCoefficients', false, @(x) islogical(x) || isnumeric(x));
parser.addParameter('nSolutions', 1, @(x) isnumeric(x) && isscalar(x) && x >= 1);
parser.addParameter('tol', 1e-7, @(x) isnumeric(x) && isscalar(x) && x >= 0);
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(database, normalizationMet, objectiveMets, varargin{:});
database = parser.Results.database;
normalizationMet = parser.Results.normalizationMet;
objectiveMets = cellstr(parser.Results.objectiveMets);
normalizationValue = parser.Results.normalizationValue;
objectiveWeights = parser.Results.objectiveWeights(:);
osenseStr = lower(parser.Results.osenseStr);
allowedMets = parser.Results.allowedMets(:);
boundMets = parser.Results.boundMets(:);
boundLB = parser.Results.boundLB(:);
boundUB = parser.Results.boundUB(:);
defaultBounds = parser.Results.defaultBounds(:)';
dGmax = parser.Results.dGmax;
elements = parser.Results.elements;
balanceCharge = parser.Results.balanceCharge;
maxNumMets = parser.Results.maxNumMets;
optionalMets = parser.Results.optionalMets(:);
integerCoefficients = parser.Results.integerCoefficients;
nSolutions = parser.Results.nSolutions;
tol = parser.Results.tol;
printLevel = parser.Results.printLevel;

if isempty(objectiveWeights)
    objectiveWeights = ones(numel(objectiveMets), 1);
end
if numel(objectiveWeights) ~= numel(objectiveMets)
    error('objectiveWeights must have one element per objective metabolite.');
end
if numel(boundLB) ~= numel(boundMets) || numel(boundUB) ~= numel(boundMets)
    error('boundLB and boundUB must have one element per metabolite in boundMets.');
end
hasData = ~isnan(database.metDeltaGf) & ~any(isnan(database.metComposition), 2) & ~isnan(database.metCharges);
if isfield(database, 'metHasFormula')
    hasData = hasData & database.metHasFormula(:);
end
if isempty(allowedMets)
    allowedMets = database.mets(hasData);
end
allowedMets = unique([allowedMets; {normalizationMet}; objectiveMets(:)], 'stable');
[found, metIdx] = ismember(allowedMets, database.mets);
if ~all(found)
    error('Metabolites not found in the database: %s', strjoin(allowedMets(~found), ', '));
end
if ~all(hasData(metIdx))
    error('Metabolites without formula, charge or Gibbs free energy of formation: %s', ...
        strjoin(allowedMets(~hasData(metIdx)), ', '));
end
if ~all(ismember(boundMets, allowedMets))
    error('Metabolites in boundMets must be allowed metabolites.');
end
n = numel(allowedMets);
normIdx = find(strcmp(allowedMets, normalizationMet));
[~, objIdx] = ismember(objectiveMets, allowedMets);

composition = database.metComposition(metIdx, :);
if isempty(elements)
    elements = database.elements(any(composition ~= 0, 1));
end
[foundEl, elIdx] = ismember(elements, database.elements);
if ~all(foundEl)
    error('Elements not found in the database: %s', strjoin(elements(~foundEl), ', '));
end
charges = database.metCharges(metIdx);
deltaGf = database.metDeltaGf(metIdx);

% bounds of the stoichiometric coefficients
lbS = defaultBounds(1) * ones(n, 1);
ubS = defaultBounds(2) * ones(n, 1);
[~, bIdx] = ismember(boundMets, allowedMets);
lbS(bIdx) = boundLB;
ubS(bIdx) = boundUB;
lbS(normIdx) = normalizationValue;
ubS(normIdx) = normalizationValue;
if any(lbS > ubS)
    error('Inconsistent bounds for: %s', strjoin(allowedMets(lbS > ubS), ', '));
end

% binary variables
useBinaries = ~isempty(maxNumMets) || nSolutions > 1;
if useBinaries
    if isempty(optionalMets)
        optionalMets = setdiff(allowedMets, [{normalizationMet}; objectiveMets(:)], 'stable');
    end
    [foundOpt, optIdx] = ismember(optionalMets, allowedMets);
    if ~all(foundOpt)
        error('optionalMets must be allowed metabolites.');
    end
else
    optIdx = [];
end
nBin = numel(optIdx);
nVars = n + nBin;

% constraints
nEl = numel(elIdx);
A = [composition(:, elIdx)'; charges'; deltaGf'];
b = [zeros(nEl, 1); 0; dGmax * abs(normalizationValue)];
csense = [repmat('E', nEl, 1); 'E'; 'L'];
if ~balanceCharge
    A(nEl + 1, :) = [];
    b(nEl + 1) = [];
    csense(nEl + 1) = [];
end
A = [A, zeros(size(A, 1), nBin)];
if nBin > 0
    % lb_i y_i <= s_i <= ub_i y_i
    link = sparse(1:nBin, optIdx, 1, nBin, n);
    A = [A; link, -diag(ubS(optIdx)); link, -diag(lbS(optIdx))];
    b = [b; zeros(2 * nBin, 1)];
    csense = [csense; repmat('L', nBin, 1); repmat('G', nBin, 1)];
    if ~isempty(maxNumMets)
        A = [A; zeros(1, n), ones(1, nBin)];
        b = [b; maxNumMets];
        csense = [csense; 'L'];
    end
end
c = zeros(nVars, 1);
c(objIdx) = objectiveWeights;
problem = struct();
problem.A = sparse(A);
problem.b = b;
problem.c = c;
problem.lb = [lbS; zeros(nBin, 1)];
problem.ub = [ubS; ones(nBin, 1)];
problem.csense = csense;
problem.osense = 1;
if strcmp(osenseStr, 'max')
    problem.osense = -1;
end
isMILP = nBin > 0 || integerCoefficients;
if isMILP
    vartype = repmat('C', nVars, 1);
    if integerCoefficients
        vartype(1:n) = 'I';
    end
    vartype(n + 1:end) = 'B';
    problem.vartype = vartype;
    problem.x0 = [];
end

solutions = struct('stat', {}, 'objValue', {}, 'mets', {}, 'metNames', {}, 'coefs', {}, ...
    'dGr', {}, 'dGrNormalized', {}, 'equation', {}, 'equationNames', {}, 'allowedMets', {}, 'stoichiometry', {});
for k = 1:nSolutions
    if isMILP
        sol = solveCobraMILP(problem, 'printLevel', 0);
    else
        sol = solveCobraLP(problem, 'printLevel', 0);
    end
    if sol.stat ~= 1
        if k == 1
            solutions(1).stat = sol.stat;
            if printLevel > 0
                fprintf('optStoic: no optimal solution found (stat = %d).\n', sol.stat);
            end
        end
        break
    end
    s = sol.full(1:n);
    s(abs(s) < tol) = 0;
    participating = find(s ~= 0);
    [~, order] = sort(s(participating) > 0);
    participating = participating(order);
    names = allowedMets(participating);
    if isfield(database, 'metNames')
        metNames = database.metNames(metIdx(participating));
    else
        metNames = names;
    end
    coefs = s(participating);
    reactants = coefs < 0;
    fmt = @(cf, ids) strjoin(strcat(arrayfun(@(a) num2str(abs(a), 6), cf, 'UniformOutput', false), {' '}, ids), ' + ');
    sol.equation = [fmt(coefs(reactants), names(reactants)) ' -> ' fmt(coefs(~reactants), names(~reactants))];
    sol.equationNames = [fmt(coefs(reactants), metNames(reactants)) ' -> ' fmt(coefs(~reactants), metNames(~reactants))];
    solutions(k).stat = sol.stat;
    solutions(k).objValue = c(1:n)' * s;
    solutions(k).mets = names;
    solutions(k).metNames = metNames;
    solutions(k).coefs = coefs;
    solutions(k).dGr = deltaGf' * s;
    solutions(k).dGrNormalized = deltaGf' * s / abs(normalizationValue);
    solutions(k).equation = sol.equation;
    solutions(k).equationNames = sol.equationNames;
    solutions(k).allowedMets = allowedMets;
    solutions(k).stoichiometry = s;
    if printLevel > 0
        fprintf('optStoic solution %d: objective = %.4g, dGr = %.2f kcal/mol\n   %s\n   %s\n', k, ...
            solutions(k).objValue, solutions(k).dGrNormalized, sol.equation, sol.equationNames);
    end
    if k < nSolutions
        % integer cut: at least one of the participating optional metabolites
        % must be excluded, sum_{i in P} (1 - y_i) >= 1
        y = zeros(nBin, 1);
        y(ismember(optIdx, participating)) = 1;
        if sum(y) == 0
            break
        end
        cut = zeros(1, nVars);
        cut(n + 1:end) = -y';
        problem.A = [problem.A; sparse(cut)];
        problem.b = [problem.b; 1 - sum(y)];
        problem.csense = [problem.csense; 'G'];
    end
end
end
