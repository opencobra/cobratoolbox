function [model, metCompute, ele, metEle, rxnBal, S_fill, solInfo, N, varargout] ...
    = computeMetFormulae(model, varargin)
% Compute the chemical formulas of all metabolites without formulas using 
% a set of metabolites with known formulae and a set of reactions by
% solving an optimization problem minimizing the overall inconsistency in
% elemental balance. Metabolites that may have variable stoichiometries
% (e.g., H+, H2O) can be supplied to automatically fill up inconsistency
%
% USAGE:
%    [model, metCompute, ele, metEle, rxnBal, S_fill, solInfo, N, LP] ...
%        = computeMetFormulae(model, knownMets, balancedRxns, fillMets, calcCMs, nameCMs, deadCMs, metMwRange, LPparams, ...)
%    [model, metCompute, ele, metEle, rxnBal, S_fill, solInfo, N, LP] ...
%        = computeMetFormulae(model, 'parameter', value, ...)
%
% INPUT:
%    model:          COBRA model
%
% OPTIONAL INPUTS (support name-value argument input):
%    kownMets:       Known metabolites (cell array of strings or vector of met IDs) 
%                    [default all mets with nonempty .metFormulas]
%    balancedRxns:   The set of reactions for inferring formulae (cell array of strings or vector of rxn IDs)
%                    [default all non-exchange reactions]
%    fillMets:       The chemical formulas for compounds for freely filling the
%                    imbalance, e.g. {'HCharge1', 'H2O'} [default 'HCharge1' if charge info exists else 'H']
%    calcCMs:        Calculate conserved moieties from the left null space of S. Options:
%                      * 'efmtool': Use EFMtool (most comprehensive, recommanded, but computational 
%                                   cost may be high if there are many deadend mets)
%                      * 'null':    Use the rational basis computed by Matlab 
%                      * N:         Directly supply the matrix :math:`N` for conserved moieties 
%                                   (rational basis or the set of extreme rays)
%                      * false:     Not to find conserved moieties and return minimal formulae
%                      [default 'efmtool' if 'CalculateFluxModes.m' is in path, else switch to 'null']
%    nameCMs:        Name the identified conserved moieties or not [default 0]
%                      * 0:  The program assigns default names for conserved moieties (Conserve_a, Conserve_b, ...)
%                      * 1:  Name true conserved moieties interactively (exclude dead end mets). 
%                      * 2:  Name all interactively (including dead end)
%    deadCMs:        true to include dead end metabolites when finding conserved moieties (default true)
%    LPparams:       Additional parameters for `solveCobraLP`. See `solveCobraLP` for details
%
% OUTPUTS:
%    model:          COBRA model with updated formulas
%    metCompute:     #unknown mets x 2 cel array [mets | computed formulas]
%    ele:            Elements corresponding to the row of rxnBal, the coloumn of metEle
%    metEle:         Chemical formulas in matrix (#metKnown x #elements)
%    rxnBal:         Elemental balance of rxns (#elements x #rxns)
%    S_fill:         Adjustment of the S-matrix by 'metFill' (#metFill x #rxns in the input)
%    solInfo:        Info for the Minimum Inconsistency under Parsimony optimization:
%                      * metUnknown:    mets whose formulae are being solved for (#met_unknown x 1 cell)
%                      * ele:           the original elements present in the model's formulae. 
%                                       May have less elements than the output 'ele' above. (#elements x 1 cell)
%                      * eleConnect:    connected components partitioning solInf.ele (#elements x #components logical matrix).
%                                       Elements in the same component mean that they are connected
%                                       by some 'metFill' and are optimized in the same round.
%                      * metEleUnknown: the formulae found for unknown metabolites (#met_unknown x #elements)
%                      * sol:           solutions returned by solveCobraLP, #components x 1 struct array, 
%                                       each with the following three solutions:
%                                         * .minIncon: minimum inconsistency (Step 1), 
%                                         * .minFill: minimum adjustment by filling metabolites (Step 2),
%                                         * .minForm: minimal formulae (Step 3)
%                      * var:           indices of variables corresponding to the vector solInfo.sol.full
%                                       (including .m.ele, .xp.ele, .xn.ele, .Ap.metFill, .An.metFill)
%                      * infeasibility: infeasibility of each solve (#components x 1 struct array,
%                                       each with .minIncon, .minFill and .minForm)
%                                       The problem is not solved successfully if infeasibility > solInfo.feasTol
%                      * bound:         * .minFill, bounds on total inconsistency for each element.
%                                       * .minForm, tolerance f used for relaxing the bounds on inconsistency
%                                                   and adjustment (ub = value x (1 + f), lb = value x (1 - f)) (#components x 1)
%                      * feasTol:       tolerance used to determine solution feasibility
%                      * stat:          cell array of minIncon/minFill/minForm/infeasible stating which 
%                                       solution is feasible for the optimization for each componenet in .eleConnect. 
%                      * final:         minIncon/minFill/minForm/mixed/infeasible stating where 
%                                       the final solution metEleUnknwon is obtained from. 
%                                       Ideally minForm if no numerical issue on feasibility.
%    N:              the set of extreme rays or the rational null space
%                    matrix representing the minimal conserved moiety vectors
%    LP:             LP problem structure for solveCobraLP (#components x 1)

if ~isfield(model,'metFormulas')
    error('model does not have the field ''metFormulas.''')
end
optArgin = {'knownMets', 'balancedRxns', 'fillMets', 'calcCMs', 'nameCMs', 'deadCMs', 'metMwRange'}; 
defaultValues = {[], [], 'HCharge1', true, false, true, []};
validator = {@(x) ischar(x) | iscellstr(x) | isvector(x), ...  % knownMets
    @(x) ischar(x) | iscellstr(x) | isvector(x), ...  % balancedRxns
    @(x) ischar(x) | iscellstr(x), ...  % fillMets
    @(x) ischar(x) | isnumeric(x) | isscalar(x), ...  % calcCMs
    @isscalar, @isscalar, ...    % nameCMs and deadCMs
    @(x) ischar(x) | isscalar(x)};  % metMwRange
[tempArgin, jArg] = deal({}, 1);
if isempty(varargin)
    varargin = {[]};
end
while jArg <= min(numel(varargin), numel(optArgin))
    if ischar(varargin{jArg}) && any(strncmp(optArgin, varargin{jArg}, numel(varargin{jArg})))
        % name-value pair arguments begin
        % get the name-vale pair arguments
        while jArg <= numel(varargin) - 1
            if any(strncmp(optArgin, varargin{jArg}, numel(varargin{jArg})))
                tempArgin = [tempArgin; varargin(jArg:(jArg + 1))];
                jArg = jArg + 2;
            else
                break
            end
        end
        break
    elseif ~isempty(varargin{jArg}) || (jArg == 3 && isequal(varargin{jArg}, {}))
        % true input if it is nonempty
        tempArgin = [tempArgin; optArgin(jArg); varargin(jArg)];
    end
    jArg = jArg + 1;
end

% the rest are parameters for solveCobraLP
varargin = varargin(jArg:end);
% get printLevel from the cobra solver parameters if exists
printLevel = 1;
for j = 1:(numel(varargin) - 1)
    if ischar(varargin{j}) && strcmpi(varargin{j}, 'printLevel')
        printLevel = varargin{j + 1};
        break
    end
end

% parse the name-value arguments
parser = inputParser();
for jArg = 1:numel(optArgin)
    parser.addParameter(optArgin{jArg}, defaultValues{jArg}, validator{jArg});
end
parser.CaseSensitive = false;
parser.parse(tempArgin{:});

metKnown = parser.Results.knownMets;
rxns = parser.Results.balancedRxns;
metFill  = parser.Results.fillMets;
findCM = parser.Results.calcCMs;
nameCM = parser.Results.nameCMs;
deadCM = parser.Results.deadCMs;
metInterest0 = parser.Result.metMwRange;

if isempty(metKnown)  % use all mets with chemical formulae
    metKnown = model.mets(~cellfun(@isempty,model.metFormulas));
elseif ischar(metKnown)
    metKnown = {metKnown};
end
if isempty(rxns)  % use all non-exchange reactions
    rxns = find(sum(model.S~=0,1) > 1 & (model.lb ~= 0 | model.ub ~= 0)');
elseif ischar(rxns)
    rxns = {rxns};
end
if ischar(metFill)
    if strcmpi(metFill, 'none')
        metFill = {};
    else
        metFill = {metFill};
    end
end
if isempty(findCM) || (numel(findCM) == 1 && findCM)
    findCM = 'efmtool';
end
calcMetMwRange = false;
if ~isempty(metInterest0)
    % calculate the range for MW of metInterest, no metabolite for filling inconsistency
    metFill = {};
    if ischar(metInterest0)
        metInterest = findMetIDs(model, metInterest0);
    else
        metInterest = metInterest0;
    end
    if metInterest <= 0 || round(metInterest) ~= metInterest
        error('''%s'' is neither a metabolite nor a valid met index in the model.', metInterest0)
    end
    calcMetMwRange = true;
end
% get reaction indices
if iscell(rxns)
    rxnC = findRxnIDs(model,rxns);
else
    rxnC = rxns;
end
if any(rxnC == 0)
    if iscell(rxns)
        error('%s in rxns is/are not in the model.', strjoing(rxns(rxnC == 0), ' ,'));
    else
        error('rxn indices must be positive integer.')
    end
end
% get metabolite indices
if iscell(metKnown)
    metK = findMetIDs(model,metKnown);
else
    metK = metKnown;
end
if any(metK == 0) 
    if iscell(metKnown)
        error('%s in knownMets is/are not in the model.', strjoin(metKnown(metK == 0), ' ,'));
    else
        error('metKnown indices must be positive integer.')
    end
end
metKform = cellfun(@isempty, model.metFormulas(metK));
if any(metKform)
    warning('Some mets in metKnown do not have formulas in the model. Ignore them.');
end
[metK,metKform] = deal(metK(~metKform), model.metFormulas(metK(~metKform)));

% get feasibility tolerance
if ~isempty(varargin) && isstruct(varargin{1}) && isfield(varargin{1}, 'feasTol')
    feasTol = varargin{1}.feasTol;
else
    feasTolInInput = find(strcmp(varargin,'feasTol'),1);
    if ~isempty(feasTolInInput)
        if feasTolInInput == numel(varargin) || ~isnumeric(varargin{feasTolInInput+1})
            error('Invalid input for the parameter feasTol.');
        end
        feasTol = varargin{find(feasTolInInput) + 1};
    else
        feasTol = getCobraSolverParams('LP',{'feasTol'});
    end
end

digitRounded = 12;
%% Preprocess
% formulas for known metabolites
% [All formulas must be in the form of e.g. Abc2Bcd1. Elements are represented by one capital letter 
% followed by lower case letter or underscore, followed by a number for the stoichiometry. 
% Brackets/parentheses and repeated elements are also supported, e.g. CuSO4(H2O)5.]
[~,eleK,metEleK] = checkEleBalance(metKform);
% check if information on charges exists
if ~any(strcmp(eleK, 'Charge'))
    fieldCharge = '';
    if isfield(model, 'metCharges')
        fieldCharge = 'metCharges';
    elseif isfield(model, 'metCharge')
        fieldCharge = 'metCharge';
    end
    if ~isempty(fieldCharge) && ~all(isnan(model.(fieldCharge))) && ~all(model.(fieldCharge) == 0)
        % add charge as one of the elements
        eleK{end + 1} = 'Charge';
        metEleK(:, end + 1) = double(model.(fieldCharge)(metK));
    elseif numel(metFill) == 1 && strcmp(metFill{1}, 'HCharge1')
        metFill = {'H'};  % no charge information, simply use H as filling metabolites
    end
end
% formulas for filling metabolites
[~,eleK,metEleF] = checkEleBalance(metFill, eleK);
if numel(eleK) > size(metEleK,2)
    metEleK = [metEleK, zeros(size(metEleK,1), numel(eleK) - size(metEleK,2))];
end
eleCh = strcmp(eleK,'Charge');  % index for charge coloumn
m = size(model.S,1);  % number of mets
nE = numel(eleK);  % number of elements
mK = numel(metK);  % number of known mets
mU = m - mK;  % number of unknown mets
mF = numel(metFill);  % number of filling mets
metU = setdiff((1:m)',metK);  % index for unknown mets
nR = numel(rxnC);  % number of reactions that should be mass balanced

% elements connected because of metFill. They need to be optimized in the same problem.
eleConnect = false(nE);
eleUnchecked = true(nE,1);
nEC = 0;
while any(eleUnchecked)
    nEC = nEC + 1;
    jE = find(eleUnchecked, 1);
    eleConnect(jE, nEC) = true;
    metFillCon = any(metEleF(:, eleConnect(:,nEC)), 2);
    while true
        eleConnect(any(metEleF(metFillCon,:), 1), nEC) = true; 
        metFillConNext = any(metEleF(:, eleConnect(:,nEC)), 2);
        if ~any(metFillConNext & ~metFillCon)
            break
        end
        metFillCon = metFillConNext;
    end
    eleUnchecked(eleConnect(:,nEC)) = false;
end
eleConnect = eleConnect(:, 1:nEC);

%% main loop
% constraint matrix for m_ie, x^pos_je, x^neg_je: [S_unknown I_nR -I_nR]
[row,col,entry] = find([model.S(:, rxnC)', speye(nR), -speye(nR)]);
nCol = m + nR * 2;
% chemical formulae
[metEleU.minIncon, metEleU.minFill, metEleU.minForm] = deal(NaN(mU, nE));
% infeasibility of each solve
[infeasibility, sol] = deal(repmat(struct('minIncon', [], 'minFill', [], 'minForm', []), nEC, 1));
[S_fill.minIncon, S_fill.minFill, S_fill.minForm] = deal(sparse(mF, nR));
% bound on the total inconsistency allowed
bound = repmat(struct('minIncon', [], 'minFill', [], 'minForm', []), nEC, 1);
index = repmat(struct('m', [], 'xp', [], 'xn', [], 'Ap', [], 'An', []), nEC, 1);
if nargout == 9
    % only assign output LP when requested
    varargout = {repmat(struct('A', [], 'b', [], 'lb', [], 'ub', [], 'c', [], 'csense', [], 'osense', []), nEC, 1)};
end
for jEC = 1:nEC
    LPj = struct();
    %% minimum inconsistency
    kE = sum(eleConnect(:, jEC));  % number of connected elements in the current component
    metFillCon = any(metEleF(:, eleConnect(:, jEC)), 2);  % connected mets for filling 
    mFC = sum(metFillCon);  % number of connected mets for filling
    % Matrix containing m_ie for all conected elements:
    % [S I_nR -I_nR | 0 ...                               0 ;
    %  0 ...      0 | S I_nR -I_nR | 0 ...   |            0 ;
    %  0 ...                         0 ... 0 | S I_nR -I_nR ]
    rowJ = repmat(row(:), kE, 1) + reshape(repmat(0:nR:(nR * (kE - 1)), numel(row), 1), numel(row) * kE, 1);
    colJ = repmat(col(:), kE, 1) + reshape(repmat(0:nCol:(nCol * (kE - 1)), numel(col), 1), numel(col) * kE, 1);
    entryJ = repmat(entry(:), kE, 1);
    LPj.A = sparse(rowJ, colJ, entryJ, nR * kE, nCol * kE);
    % Matrix for mets for filling (m_i,e for met i, element e, I_nR identity matrix):
    % [m_1,1 * I_nR  | m_2,1 * I_nR  | ... | m_mFC,1 * I_nR ;
    %  m_1,2 * I_nR  | m_2,2 * I_nR  | ... | m_mFC,2 * I_nR ;
    %  ...
    %  m_1,kE * I_nR | m_2,kE * I_nR | ... | m_mFC,kE * I_nR] 
    rowJ = repmat((1:(nR * kE))', mFC, 1); 
    colJ = repmat((1:nR)', kE * mFC, 1) + reshape(repmat(0:nR:(nR * (mFC - 1)), nR * kE, 1), nR * kE * mFC, 1);
    entryJ = full(metEleF(metFillCon, eleConnect(:, jEC))');
    entryJ = reshape(repmat(entryJ(:)', nR, 1), nR * kE * mFC, 1);
    LPj.A = [LPj.A, sparse(rowJ, colJ, entryJ, nR * kE, nR * mFC), -sparse(rowJ, colJ, entryJ, nR * kE, nR * mFC)];
    LPj.lb = zeros(size(LPj.A, 2), 1);
    LPj.ub = inf(size(LPj.A, 2),1);
    [~, idCharge] = ismember(find(eleCh), find(eleConnect(:, jEC)));
    if idCharge > 0
        % charges can be negative
        LPj.lb((nCol * (idCharge - 1) + 1) : (nCol * (idCharge - 1) + m)) = -inf;
    end
    % store the index
    eleInd = find(eleConnect(:, jEC));
    eleJ = eleK(eleInd);
    for jkE = 1:kE
        index0 = (jkE - 1) * nCol;
        index(jEC).m.(eleJ{jkE}) = (index0 + 1) : (index0 + m);
        index(jEC).xp.(eleJ{jkE}) = (index0 + m + 1) : (index0 + m + nR);
        index(jEC).xn.(eleJ{jkE}) = (index0 + m + nR + 1) : (index0 + m + nR * 2);
        if jkE == idCharge
            % allow known formulas but unknown charges
            chargeKnown = ~isnan(metEleK(:, eleInd(jkE)));
            LPj.lb(index(jEC).m.(eleJ{jkE})(metK(chargeKnown))) = metEleK(chargeKnown, eleInd(jkE));
            LPj.ub(index(jEC).m.(eleJ{jkE})(metK(chargeKnown))) = metEleK(chargeKnown, eleInd(jkE));
        else
            LPj.lb(index(jEC).m.(eleJ{jkE})(metK)) = metEleK(:, eleInd(jkE));
            LPj.ub(index(jEC).m.(eleJ{jkE})(metK)) = metEleK(:, eleInd(jkE));
        end
    end
    if mFC > 0
        metFillConName = metFill(metFillCon);
        for jFC = 1:mFC
            index0 = kE * nCol + (jFC - 1) * nR;
            index(jEC).Ap.(metFillConName{jFC}) = (index0 + 1) : (index0 + nR);
            index(jEC).An.(metFillConName{jFC}) = (index0 + nR + 1) : (index0 + nR * 2);
        end
    end
    
    
    % Objective: sum(x^pos_ie + x^neg_ie)
    LPj.c = zeros(size(LPj.A, 2), 1);
    for jkE = 1:kE
        LPj.c((nCol * (jkE - 1) + m + 1) : (nCol * jkE)) = 1;
    end
    % RHS: 0
    LPj.b = zeros(nR * kE, 1);
    LPj.csense = char('E' * ones(1, nR * kE));
    LPj.osense = 1;  % minimize
    % solve for minimum inconsistency
    if nargin < 6
        sol(jEC).minIncon = solveCobraLP(LPj);
    else
        sol(jEC).minIncon = solveCobraLP(LPj, varargin{:});
    end
    if isfield(sol(jEC).minIncon, 'full') && numel(sol(jEC).minIncon.full) == size(LPj.A, 2)
        % store the chemical formulae
        jkE = 0;
        for jE = 1:nE
            if eleConnect(jE, jEC)
                jkE = jkE + 1;
                metEleU.minIncon(:, jE) = sol(jEC).minIncon.full(nCol * (jkE - 1) + metU);
            end
        end
        S_fill.minIncon(metFillCon, :) = reshape(...
            sol(jEC).minIncon.full((nCol * kE + 1) : (nCol * kE + nR * mFC)) ...
            - sol(jEC).minIncon.full((nCol * kE + nR * mFC + 1) : (nCol * kE + nR * mFC *2)), nR, mFC)';
    else
        metEleU.minIncon(:,eleConnect(:, jEC)) = NaN;
    end
    % manually check feasibility
    infeas = checkSolFeas(LPj, sol(jEC).minIncon);
    infeasibility(jEC).minIncon = infeas;
    if infeas <= feasTol  % should always be feasible
       %% minimize the stoichiometric coefficients of mets for filling
        %  or calculate the range for the MW of the metabolite of interest
        for jkE = 1:kE
            % add constraint on total inconsistency: sum(x^pos_i,e + x^neg_i,e) <= inconsistency
            LPj.A(end + 1,:) = 0;
            LPj.A(end, (nCol * (jkE - 1) + m + 1):(nCol * jkE)) = 1;
            % rounding to avoid numerical issues on feasibility
            LPj.b(end + 1) = round(sum(sol(jEC).minIncon.full((nCol * (jkE - 1) + m + 1):(nCol * jkE))), digitRounded);
        end
        LPj.csense((end + 1):(end + kE)) = 'L';
        
        % reuse basis
        if isfield(sol(jEC).minIncon, 'basis')
            LPj.basis = sol(jEC).minIncon.basis;
            if isstruct(LPj.basis) && isfield(LPj.basis, 'cbasis')
                LPj.basis.cbasis((end + 1) : (end + kE)) = 0;
            end
        end
        % inconsistency for each element
        bound(jEC).minIncon = LPj.b((end - kE + 1) : end);
        % change objective to min adjustment
        LPj.c(:) = 0;
        LPj.c((nCol * kE + 1) : (nCol * kE + nR * mFC * 2)) = 1;
        % solve, adjust tolerance if infeasible
        f = 1e-6;
        while true
            if nargin < 6
                sol(jEC).minFill = solveCobraLP(LPj);
            else
                sol(jEC).minFill = solveCobraLP(LPj, varargin{:});
            end
            infeas = checkSolFeas(LPj, sol(jEC).minFill);
            if infeas <= feasTol || f > 1e-4 + 1e-8
                break
            end
            f = f * 10;
            LPj.b((end - kE + 1) : end) = bound(jEC).minIncon * (1 + f);
            % rounding to avoid numerical issues on feasibility
            LPj.b = round(LPj.b, digitRounded);
        end
        if isfield(sol(jEC).minFill,'full') && numel(sol(jEC).minFill.full) == size(LPj.A,2)
            % store the chemical formulae
            jkE = 0;
            for jE = 1:nE
                if eleConnect(jE, jEC)
                    jkE = jkE + 1;
                    metEleU.minFill(:,jE) = sol(jEC).minFill.full(nCol * (jkE - 1) + metU);
                end
            end
            S_fill.minFill(metFillCon,:) = reshape(...
                sol(jEC).minFill.full((nCol * kE + 1) : (nCol * kE + nR * mFC)) ...
                - sol(jEC).minFill.full((nCol * kE + nR * mFC + 1) : (nCol * kE + nR * mFC *2)), nR, mFC)';
        else
            metEleU.minFill(:,eleConnect(:,jEC)) = NaN;
        end
        infeasibility(jEC).minFill = infeas;
        bound(jEC).minFill = LPj.b((end - kE + 1) : end);
        %% minimal formulas
        if infeas <= feasTol
            % feasible solution found. Use sol.minFill to constrain
            solChoice = 'minFill';
        else
            % infeasible when minimizing stoichiometric coefficients of
            % filling mets. Use sol.minIncon to constrain
            solChoice = 'minIncon'; 
        end
        % remove constraint on total inconsistency
        LPj.A((end - kE + 1) : end, :) = [];
        LPj.b((end - kE + 1) : end) = [];
        LPj.csense((end - kE + 1) : end) = '';
        if isfield(LPj, 'basis') && isfield(LPj.basis, 'cbasis')
            LPj.basis.cbasis((end - kE + 1) : end) = [];
        end
        LPj.c(:) = 0;  % reset objective
        % if charge is involved, split it into m^pos, m^neg
        if idCharge > 0
            mUch = sum(~chargeKnown);
            LPj.A = [LPj.A,  sparse(size(LPj.A, 1), (mU + mUch) * 2); ...
                sparse(1:(mU + mUch), nCol * (idCharge - 1) + [metU; metK(~chargeKnown)], ...
                1, mU + mUch, size(LPj.A,2)), -speye(mU + mUch), speye(mU + mUch)];
            LPj.b = [LPj.b; zeros(mU + mUch, 1)];
            LPj.csense = [LPj.csense char('E' * ones(1, mU + mUch))];
            LPj.lb = [LPj.lb; zeros((mU + mUch) * 2, 1)];
            LPj.ub = [LPj.ub; inf((mU + mUch) * 2, 1)];
            LPj.c = [LPj.c; ones((mU + mUch) * 2, 1)];
            if isfield(LPj, 'basis') 
                if isstruct(LPj.basis)
                    % for gurobi
                    if isfield(LPj.basis, 'vbasis')
                        LPj.basis.vbasis((end + 1) : (end + (mU + mUch) * 2)) = 0;
                    end
                    if isfield(LPj.basis, 'cbasis')
                        LPj.basis.cbasis((end + 1) : (end + mU + mUch)) = 0;
                    end
                else
                    % for other solvers
                    if numel(LPj.basis) == size(LPj.A, 2) - (mU + mUch) * 2
                        LPj.basis((end + 1) : (end + (mU + mUch) * 2)) = 0;
                    end
                end
            end
        end
        for jkE = 1:kE
            % fix inconsistency variables
            ind = (nCol * (jkE - 1) + m + 1) : (nCol * jkE);
            LPj.ub(ind) = sol(jEC).(solChoice).full(ind) * (1 + 1e-10);
            LPj.lb(ind) = sol(jEC).(solChoice).full(ind) * (1 - 1e-10);
            % minimize chemical formulae
            if jkE ~= idCharge
                LPj.c((nCol * (jkE - 1) + 1) : (nCol * (jkE - 1) + m)) = 1;
            end
        end
        % fix stoichiometric coefficients for filling mets
        LPj.ub((nCol * kE + 1) : (nCol * kE + nR * 2 * mFC)) ...
            = sol(jEC).(solChoice).full((nCol * kE + 1) : (nCol * kE + nR* 2 * mFC)) * (1 + 1e-10);
        LPj.lb((nCol * kE + 1) : (nCol * kE + nR * 2 * mFC)) ...
            = sol(jEC).(solChoice).full((nCol * kE + 1) : (nCol * kE + nR * 2 * mFC)) * (1 - 1e-10);
        % rounding to avoid numerical issues on feasibility
        LPj.ub = round(LPj.ub, digitRounded);
        LPj.lb = round(LPj.lb, digitRounded);
        % solve, adjust tolerance if infeasible
        f = 1e-10;
        while true
            if nargin < 6
                sol(jEC).minForm = solveCobraLP(LPj);
            else
                sol(jEC).minForm = solveCobraLP(LPj, varargin{:});
            end
            infeas = checkSolFeas(LPj, sol(jEC).minForm);
            if infeas <= feasTol || f > 1e-5
                break
            end
            f = f * 10;
            for jkE = 1:kE
                % relax tolerance
                ind = (nCol * (jkE - 1) + m + 1) : (nCol * jkE);
                LPj.ub(ind) = sol(jEC).(solChoice).full(ind) * (1 + f);
                LPj.lb(ind) = sol(jEC).(solChoice).full(ind) * (1 - f);
            end
            LPj.ub((nCol * kE + 1) : (nCol * kE + nR * 2 * mFC)) ...
                = sol(jEC).(solChoice).full((nCol * kE + 1) : (nCol * kE + nR * 2 * mFC)) * (1 + f);
            LPj.lb((nCol * kE + 1) : (nCol * kE + nR * 2 * mFC)) ...
                = sol(jEC).(solChoice).full((nCol * kE + 1) : (nCol * kE + nR * 2 * mFC)) * (1 - f);
            % rounding to avoid numerical issues on feasibility
            LPj.ub = round(LPj.ub, digitRounded);
            LPj.lb = round(LPj.lb, digitRounded);
        end
        if isfield(sol(jEC).minForm, 'full') && numel(sol(jEC).minForm.full) == size(LPj.A, 2)
            % store the chemical formulae
            jkE = 0;
            for jE = 1:nE
                if eleConnect(jE, jEC)
                    jkE = jkE + 1;
                    metEleU.minForm(:, jE) = sol(jEC).minForm.full(nCol * (jkE - 1) + metU);
                end
            end
            S_fill.minForm(metFillCon,:) = reshape(...
                sol(jEC).minForm.full((nCol * kE + 1) : (nCol * kE + nR * mFC)) ...
                - sol(jEC).minForm.full((nCol * kE + nR * mFC + 1) : (nCol * kE + nR * mFC *2)), nR, mFC)';
        else
            metEleU.minForm(:, eleConnect(:,jEC)) = NaN;
        end
        infeasibility(jEC).minForm = infeas;
        bound(jEC).minForm = f;
    else
        [infeasibility(jEC).minFill, infeasibility(jEC).minForm] = deal(inf);
    end
    if nargout == 9
        if isfield(LPj, 'basis')
            LPj = rmfield(LPj, 'basis');
        end
        varargout{1}(jEC) = LPj;
    end
end
%% store the solution and relevant info
solInfo.metUnknown = model.mets(metU);
solInfo.ele = eleK;
solInfo.eleConnect = eleConnect;
solInfo.rxns = model.rxns(rxnC);
solInfo.metEleUnknwon = metEleU;
solInfo.metFill = metFill;
solInfo.S_fill = S_fill;
solInfo.sol = sol;
solInfo.var = index;
solInfo.infeasibility = infeasibility;
solInfo.bound = bound;
solInfo.feasTol = feasTol;
solInfo.stat = repmat({'infeasible'}, nEC, 1);
solInfo.stat([infeasibility.minIncon] <= feasTol) = {'minIncon'};
solInfo.stat([infeasibility.minFill] <= feasTol) = {'minFill'};
solInfo.stat([infeasibility.minForm] <= feasTol) = {'minForm'};
if any(strcmp(solInfo.stat, 'infeasible'))
    fprintf('Critical failure: no feasible solution is found.\n')
    metCompute = {};
    solInfo.final = 'infeasible';
    return
elseif all(strcmp(solInfo.stat, 'minForm'))
    solInfo.final = 'minForm';
elseif all(strcmp(solInfo.stat, 'minFill'))
    solInfo.final = 'minFill';
elseif all(strcmp(solInfo.stat, 'minIncon'))
    solInfo.final = 'minIncon';
else
    solInfo.final = 'mixed';
end
% Get the best metEle and S_fill as the solution for incorporating results from conserved moiety calculations. 
% For each set of elements in eleConnect, choose the latest solution (minForm > minFill > minIncon), recorded in solInfo.stat.
metEle = zeros(m, nE);
metEle(metK,:) = metEleK;
S_fill = sparse(mF, numel(model.rxns));
for jEC = 1:nEC
    metEle(metU,eleConnect(:,jEC)) = metEleU.(solInfo.stat{jEC})(:, eleConnect(:,jEC));
    metFillCon = any(metEleF(:, eleConnect(:,jEC)), 2);
    if any(metFillCon)
        S_fill(metFillCon, rxnC) = solInfo.S_fill.(solInfo.stat{jEC})(metFillCon, :);
    end
end
%% find conserved moieties

CMfound = false;
N = [];
if size(findCM, 1) == numel(model.mets)
    % input is the null space matrix / set of extreme rays
    N = findCM;
    CMfound = true;
elseif ~ischar(findCM) && numel(findCM) > 1
    warning('Input extreme ray matrix has #rows (%d) different from #mets (%d). Ignore.', size(findCM,1), numel(model.mets));
    findCM = 'efmtool';
end
if ischar(findCM) && ~CMfound
    N = findElementaryMoietyVectors(model, 'method', findCM, 'deadCMs', deadCM, varargin{:});
    CMfound = true;
end
if CMfound
    if printLevel
        fprintf('Elementary conserved moiety vectors found.\n');
    end
    % clear close-to-zero values
    N(abs(N) < 1e-8) = 0;
    N = sparse(N);
    % true generic conserved moieties, positive and not involving known mets
    Ncm = N(:,~any(N < 0, 1) & ~any(N(metK,:),1));
    % add them into formulas
    metEle = [metEle, Ncm];
    ele = [eleK(:); cell(size(Ncm,2),1)];
    j2 = 1;
    for j = 1:size(Ncm,2)
        while any(strcmp(ele(1:nE),['Conserve_' num2alpha(j2)]))
            j2 = j2 + 1;
        end
        ele{nE+j} = ['Conserve_' num2alpha(j2)];
        j2 = j2 + 1;
    end
else
    ele = eleK(:);
end

% get formulae in string
model.metFormulas = convertMatrixFormulas(ele,metEle,10);
if nameCM > 0 && CMfound
    % manually name conserved moieties
    ele0 = ele;
    nDefault = 0;
    nCM = size(Ncm,2);
    eleDel = false(nE + nCM, 1);
    if nameCM == 1
        % get dead end metatbolites
        [~,removedMets] = removeDeadEnds(model);
        metDead = findMetIDs(model,removedMets);
    end
    for j = 1:nCM
        fprintf('\n');
        writeCell2Text([model.mets(Ncm(:,j)~=0),model.metFormulas(Ncm(:,j)~=0),...
            model.metNames(Ncm(:,j)~=0)]);
        fprintf('\n');
        if nameCM == 1 && any(Ncm(metDead,j),1)
            % use the defaulted for dead end mets
            nDefault = nDefault + 1;
            ele{nE+j} = ele0{nE + nDefault};
        else
            cont = false;
            while true
                s = input(['Enter the formula for the conserved moiety (e.g. OHRab_cd):\n',...
                    '(hit return to use default name ''Conserve_xxx'')\n'],'s');
                if isempty(s)
                    % use the defaulted
                    nDefault = nDefault + 1;
                    ele{nE+j} = ele0{nE + nDefault};
                    break
                end
                re = regexp(s,'[A-Z][a-z_]*(\-?\d+\.?\d*)?','match');
                if strcmp(strjoin(re,''),s)
                    % manual input formula, continue to checking
                    cont = true;
                    break
                end
            end
            if cont
                % get the matrix for the input formula
                nEnew = numel(ele) - nE - nCM;
                [~, eleJ, metEleJ] = checkEleBalance(s,ele([1:nE, (nE+nCM+1):end]));
                metEle(:,[1:nE, (nE+nCM+1):end]) ...
                    = metEle(:,[1:nE, (nE+nCM+1):end])...
                        + metEle(:,nE+j) * metEleJ(1,1:(nE+nEnew));
                if numel(eleJ) > nE + nEnew
                    % there are new elements
                    ele = [ele(:); eleJ((numel(ele)-nCM+1):end)];
                    metEle = [metEle, ...
                        metEle(:,nE+j) * metEleJ(1,(nE+nEnew+1):end)];
                end
                eleDel(nE + j) = true;
            end
        end
    end
    % del defaulted but replaced columns
    if any(eleDel)
        eleDel = find(eleDel);
        ele(eleDel) = [];
        metEle(:,eleDel) = [];
    end
    % 1:nE                    :    real elements
    % nE + 1 : nE + nDefault  :    default generic elements (Conserve_xxx)
    % nE + nDeafult + 1 : end :    generic element by user's input
    % Change if names of default generic elements are mixed up with user input
    j0 = 0;
    for j = 1:nDefault
        j0 = j0 + 1;
        nameJ = ['Conserve_' num2alpha(j0)];
        while any(strcmp(ele([1:nE, (nE + nDefault + 1):end]), nameJ))
            j0 = j0 + 1;
            nameJ = ['Conserve_' num2alpha(j0)];
        end
        ele{nE + j} = nameJ;
    end
end
% reaction balance
rxnBal = metEle' * model.S;
model.metFormulas = convertMatrixFormulas(ele, metEle, 10);
metCompute = [model.mets(metU) model.metFormulas(metU)];
end

function s = num2alpha(index,charSet)
% s = num2alpha(j, charSet)
% Given a nonzero integer j and a character set charSet, convert j into
% a string formed from the characters in charSet having order j.
% 'charSet' defaulted to be '_abcdefghijklmnopqrstuvwxyz' in which '_' acts
% like 0 and 'z' acts like the largest digit 9 in decimal expression
% e.g. num2slpha(0) is '_' , num2slpha(1) is 'a', num2slpha(27^2) is 'a__'

if nargin < 2
    charSet = ['_' char(97:122)];
end
if numel(index) > 1
    s = cell(numel(index), 1);
    for j = 1:numel(index)
        s{j} = num2alpha(index(j), charSet);
    end
    return
end
N = length(charSet);
s = '';
k = floor(index/N);
while k > 0
    s = [charSet(index - k * N + 1) s];
    index = k;
    k = floor(index / N);
end
s = [charSet(index + 1) s];
end