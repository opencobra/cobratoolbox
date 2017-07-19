function [POAtable, fluxRange, Stat, pairList] = SteadyComPOAgr(modelCom, options, LP, varargin)
% Analyze pairwise relationship between reaction fluxes/biomass variables for a community model
% at community steady-state at a given growth rate. Called by `SteadyComPOA`. See `tutorial_SteadyCom` for more details.
%
% USAGE:
%
%    [POAtable, fluxRange, Stat, pairList] = SteadyComPOAgr(modelCom, options, LP)
%
% INPUT:
%    modelCom:     A community COBRA model structure with the following fields (created using createMultipleSpeciesModel)
%                  (the first 5 fields are required, at least one of the last two is needed. Can be obtained using `getMultiSpecisModelId`):
%
%                    * S - Stoichiometric matrix
%                    * b - Right hand side
%                    * c - Objective coefficients
%                    * lb - Lower bounds
%                    * ub - Upper bounds
%                    * infoCom - structure containing community reaction info
%                    * indCom - the index structure corresponding to `infoCom`
%
% OPTIONAL INPUTS:
%    options:    option structure with the following fields:
%
%                  * GR - The growth rate at which POA is performed. If not
%                    given, find the maximum growth rate by `SteadyCom.m`
%                  * optBMpercent - Only consider solutions that yield at least a certain percentage of the optimal biomass (Default = 99.99)
%                  * rxnNameList - list of reactions (IDs or .rxns) to be analyzed. Use a :math:`(N_{rxns} + N_{organism}) * K` matrix for POA of `K`
%                    linear combinations of fluxes and/or abundances (Default = biomass reaction of each organism,
%                    or reactions listed in `pairList` [see below] if `pairList` is given)
%                  * pairList - pairs in `rxnNameList` to be analyzed. `N_pair` by 2 array of:
%
%                    * - indices referring to the rxns in `rxnNameList`, e.g., `[1 2]` to analyze `rxnNameList{1}` vs `rxnNameList{2}`
%                    * - rxn names which are members of `rxnNameList`, e.g., `{'EX_glc-D(e)', 'EX_ac(e)'}`
%                    If not supplied, analyze all `K(K-1)` pairs from the K targets in `rxnNameList`.
%                  * symmetric - true to avoid running symmetric pairs (e.g. analyze pair `(j,k)` only if :math:`j > k`, total :math:` K(K-1)/2 pairs)`.
%                    Used only when `pairList` is not supplied.
%                  * Nstep - number of steps for fixing one flux at a value between the min. and the max. possible fluxes. Default 10.
%                    Can also be a vector indicating the fraction of intermediate value to be analyzed,
%                    e.g. `[0 0.5 1]` means computing at `minFlux`, `0.5(minFlux + maxFlux)` and `maxFlux`
%                  * NstepScale - used only when Nstep is a single number.
%
%                    * -'lin' for a linear (uniform) scale of step size
%                    * -'log' for a log scaling of the step sizes
%                  * fluxRange - flux range for each entry in `rxnNameList`. `K x 2` matrix. Defaulted to be found by `SteadyComFVA.m`
%                    (other parameters)
%                  * savePOA - filename to save the POA results (default 'POAtmp/POA'). Must be non-empty. New folder is recommended
%                  * threads - for parallelization: > 1 for explicitly stating the no. of threads used,
%                    0 or -1 for using all available threads. Default 1.
%                  * verbFlag - verbose output. 0 or 1.
%                  * loadModel - (`ibm_cplex` only) string of filename to be loaded. If non-empty, load the
%                    cplex model ('loadModel.mps'), basis ('loadModel.bas') and parameters ('loadModel.prm').
%                    (May add also other parameters in `SteadyCom` for calculating the maximum growth rate.)
%
%    parameter:  structure for solver-specific parameters.
%                  'param1', value1, ...:  name-value pairs for `solveCobraLP` parameters. See solveCobraLP for details
%
% OUTPUTS:
%    POAtable:   `K x K` cells. `(i, i)` -cell contains the flux range of `rxnNameList{i}`.
%                `(i,j)`-cell contains a `Nstep x 2` matrix, with `(k, 1)` -entry being the min of `rxnNameList{j}`
%                when `rxnNameList{i}` is fixed at the `k`-th value, `(k, 2)` -entry being the max.
%    fluxRange:  `K x 2` matrix of flux range for each entry in `rxnNameList`
%    Stat :      `K x K` structure array with fields:
%
%                  * -'cor': the slope from linear regression between the fluxes of a pair
%                  * -'r2':  the corresponding coefficient of determination (R-square)
%    pairList:   `pairList` after transformation from various input formats

global CBT_LP_SOLVER

[modelCom, ibm_cplex, feasTol, solverParams, parameters, varNameDisp, ...
    xName, m, n, nSp, nRxnSp] = SteadyComSubroutines('initialize', modelCom, varargin{:});
% Initialization above
if nargin < 2 || isempty(options)
    options = struct();
end
% handle solveCobraLP name-value arguments that are specially treated in SteadyCom functions
[options, varargin] = SteadyComSubroutines('solveCobraLP_arg', options, parameters, varargin);

[GRfx, GR, BMmaxLB, BMmaxUB, optBMpercent, ...  % parameters for finding maximum growth rate
    symmetric, rxnNameList, pairList, fluxRange, Nstep, NstepScale, ...  % parameters for POA
    verbFlag, threads, savePOA, loadModel] = SteadyComSubroutines('getParams',  ...
    {'GRfx', 'GR', 'BMmaxLB', 'BMmaxUB', 'optBMpercent',...
    'symmetric', 'rxnNameList', 'pairList', 'fluxRange', 'Nstep', 'NstepScale',...
    'verbFlag', 'threads', 'savePOA', 'loadModel'}, options, modelCom);

if isempty(savePOA)
    % always use save option to reduce memory need
    savePOA = 'POAtmp/POA';
end
directory = strsplit(savePOA, filesep);
if numel(directory) > 1
    % not saving in the current directory. Create the directory.
    directory = strjoin([{pwd}, directory(1:end - 1)], filesep);
    if ~exist(directory, 'dir')
        mkdir(directory);
    end
end

% check if the whole computation been finished before
if ~isempty(savePOA)
    if exist(sprintf('%s.mat', savePOA), 'file')
        data0 = load(sprintf('%s.mat', savePOA));
        if isfield(data0, 'finished')
            if verbFlag
                fprintf('Already finished. Results loaded from %s.mat\n', savePOA);
            end
            load(sprintf('%s.mat', savePOA), 'POAtable', 'fluxRange', 'Stat')
            return
        else
            clear data0
        end
    end
end

% parallel computation
if threads ~= 1 && isempty(gcp('nocreate'))
    try
        if threads > 1
            %given explicit no. of threads
            parpool(ceil(threads));
        else
            %default max no. of threads (input 0 or -1 etc)
            parpool;
        end
    catch
        threads = 1;
    end
end
if threads ~= 1 && ~isfield(parameters, 'solver')
    % add explicitly the solver name to avoid error in parallel computation
    varargin = [varargin(:); {'solver'; CBT_LP_SOLVER}];
end

%% handle LP structure
checkBMrow = false;
if isempty(GR)
    % if max growth rate not given, find it and get the LP problem
    options2 = options;
    options2.minNorm = false;
    [~, result,LP] = SteadyCom(modelCom, options2, varargin{:});
    GR = result.GRmax;
    if ibm_cplex
        idRow = size(LP.Model.A, 1);  % row that constrains the total biomass
    else
        idRow = size(LP.A, 1);  % row that constrains the total biomass
    end
    addRow = false;
elseif nargin < 3 || isempty(LP) || (~isstruct(LP) && ~isobject(LP)) || isempty(fieldnames(LP))
    % only the growth rate given but not the LP structure
    if ibm_cplex && ~isempty(loadModel)
        % load Cplex model if loadModel is given
        LP = Cplex('poa');
        LP.readModel([loadModel '.mps']);
        LP.readBasis([loadModel '.bas']);
        LP.readParam([loadModel '.prm']);
        LP.DisplayFunc = [];
        fprintf('Load model ''%s'' successfully.\n', loadModel);
        checkBMrow = true;
    else
        % get the LP structure using SteadyCom
        options2 = options;
        options2.LPonly = true;
        [~, ~, LP] = SteadyCom(modelCom, options2, varargin{:});
        addRow = true;  % no constraint on total biomass using LPonly option
    end
else
    % GR given as input and LP is supplied, expected when called by SteadyComPOA
    checkBMrow = true;
end
% check if a row constraining the sum of biomass exists
if checkBMrow
    addRow = true;
    % take the row with the largest index if there are multiple rows
    if ibm_cplex && size(LP.Model.A, 1) > m + 2 * nRxnSp + nSp
        idRow = find(ismember(LP.Model.A((m + 2 * nRxnSp + nSp + 1) : end, 1 : (n + nSp)), ...
            sparse(ones(nSp, 1), (n + 1) : (n + nSp), ones(nSp, 1), 1, n + nSp), 'rows'));
        addRow = isempty(idRow);
    elseif ~ibm_cplex && size(LP.A, 1) > m + 2 * nRxnSp + nSp
        idRow = find(ismember(LP.A((m + 2 * nRxnSp + nSp + 1) : end, 1 : (n + nSp)), ...
            sparse(ones(nSp, 1), (n + 1) : (n + nSp), ones(nSp, 1), 1, n + nSp), 'rows'));
        idRow = idRow(LP.csense(m + 2 * nRxnSp + nSp + idRow) == 'G');
        addRow = isempty(idRow);
    end
    if ~addRow
        idRow = idRow(end);
        idRow = m + 2 * nRxnSp + nSp + idRow;
    end
end
% add a row for constraining the sum of biomass if not exist
if addRow
    % using default BMmaxLB and BMmaxUB if not given in options
    if ibm_cplex
        LP.addRows(BMmaxLB * optBMpercent / 100, sparse(ones(1, nSp), ...
            (n + 1):(n + nSp), 1, 1, size(LP.Model.A, 2)), BMmaxUB, 'UnityBiomass');
        idRow = size(LP.Model.A, 1);
    else
        LP.A = [LP.A; sparse([ones(nSp, 1); 2 * ones(nSp, 1)], repmat((n + 1):(n + nSp), 1, 2),...
            1, 2, size(LP.A, 2))];
        LP.b = [LP.b; BMmaxUB; BMmaxLB * optBMpercent / 100];
        LP.csense = [LP.csense, 'LG'];
        idRow = size(LP.A, 1);
    end
else
    % using BMmaxLB and BMmaxUB stored in the LP if not given in options
    if ~isfield(options, 'BMmaxLB') %take from LP if not supplied
        if ibm_cplex
            BMmaxLB = LP.Model.lhs(idRow);
        else
            BMmaxLB = LP.b(idRow);
        end
    end
    if ~isfield(options, 'BMmaxUB') %take from LP if not supplied
        if ibm_cplex
            BMmaxUB = LP.Model.rhs(idRow);
        else
            BMmaxUB = LP.b(idRow - 1);
        end
    end
    % not allow the max. biomass to exceed the one at max growth rate,
    % can happen if optBMpercent < 100. May dismiss this constraint or
    % manually supply BMmaxUB in the options if sum of biomass should be variable
    if ibm_cplex
        LP.Model.lhs(idRow) = BMmaxLB * optBMpercent / 100;
        LP.Model.rhs(idRow) = BMmaxUB;
    else
        LP.b(idRow) = BMmaxLB * optBMpercent / 100;
        LP.b(idRow - 1) = BMmaxUB;
    end
end
if ibm_cplex
    LP = setCplexParam(LP, solverParams);  % set Cplex parameters
    nVar = size(LP.Model.A, 2);  % number of variables
    BMmax0 = LP.Model.lhs(idRow);  % required biomass
    % update the LP to ensure the current growth rate is constrained
    LP.Model.A = SteadyComSubroutines('updateLPcom', modelCom, GR, GRfx, [], LP.Model.A, []);
    LP.Model.sense = 'minimize';
    LP.Model.obj(:) = 0;
    LP.solve();
    dev = checkSolFeas(LP);
else
    nVar = size(LP.A, 2);  % number of variables
    BMmax0 = LP.b(idRow);  % required biomass
    % update the LP to ensure the current growth rate is constrained
    LP.A = SteadyComSubroutines('updateLPcom', modelCom, GR, GRfx, [], LP.A, []);
    LP.c(:) = 0;
    LP.osense = 1;
    sol = solveCobraLP(LP, varargin{:});
    dev = checkSolFeas(LP, sol);
    if isfield(sol, 'basis')
        LP.basis = sol.basis;  % reuse basis
    end
end
% check and adjust for feasibility
kBMadjust = 0;
while ~(dev <= feasTol) && kBMadjust < 10
    kBMadjust = kBMadjust + 1;
    if ibm_cplex
        LP.Model.lhs(end) = BMmax0 * (1 - feasTol/(11 - kBMadjust));
        LP.solve();
        dev = checkSolFeas(LP);
    else
        LP.b(idRow) = BMmax0 * (1 - feasTol/(11 - kBMadjust));
        sol = solveCobraLP(LP, varargin{:});
        dev = checkSolFeas(LP, sol);
        if isfield(sol, 'basis')
            LP.basis = sol.basis;  % reuse basis
        end
    end
    if verbFlag
        fprintf('BMmax adjustment: %d\n',kBMadjust);
    end
end
% number of target reactions/linear combinations of reactions to be analyzed
if iscell(rxnNameList) || (min(size(rxnNameList)) == 1 && size(rxnNameList, 1) < n)
    nRxnPOA = numel(rxnNameList);
else
    nRxnPOA = size(rxnNameList, 2);
end
if ~(dev <= feasTol)
    warning('Model not feasible.')
    POAtable = cell(nRxnPOA);
    fluxRange = NaN(nRxnPOA, 2);
    Stat = repmat(struct('cor', [], 'r2', []), nRxnPOA, nRxnPOA);
    pairList = [];
    return
end
% use all rxns in pairList if rxnNameList not given
if (~isfield(options, 'rxnNameList') || isempty(options.rxnNameList)) && isfield(options.pairList) ...
        && iscell(options.pairList)
    % get rxnNameList from pairList if only pairList given
    rxnNameList = options.pairList(:);
end
% objective matrix
rxnNameList = SteadyComSubroutines('rxnList2objMatrix', rxnNameList, varNameDisp, xName, n, nVar, 'rxnNameList');
options.rxnNameList = rxnNameList;
% handle pairList
if isempty(pairList)
    % if pairList not given, run for all pairs
    pairList = [reshape(repmat(1:nRxnPOA, nRxnPOA, 1), nRxnPOA ^ 2, 1), repmat((1:nRxnPOA)', nRxnPOA, 1)];
    if symmetric
        % the option 'symmetric' is only used here when pairList is not supplied to avoid running symmetric pairs (e.g. j vs k and k vs j)
        pairList(pairList(:, 1) >= pairList(:, 2), :) = [];
    end
elseif size(pairList, 2) ~= 2
    error('pairList must be an N-by-2 array denoting the pairs (rxn names or indices in rxnNameList) to analyze!')
elseif iscell(pairList)
    pairList = SteadyComSubroutines('rxnList2objMatrix', pairList(:), varNameDisp, xName, n, nVar, 'pairList');
    [yn, id] = ismember(pairList', rxnNameList', 'rows');
    if ~all(yn)
        error('Some entries in options.pairList are not in options.rxnNameList');
    end
    pairList = reshape(id, numel(id) / 2, 2);
end
% exclude all (i,i) indices.
pairList = pairList(pairList(:, 1) ~= pairList(:, 2), :);
Npair = size(pairList, 1);  % number of pairs to be analyzed

%% find pairs in the pairList not analyzed yet
undone = true(Npair,1);
[NstepEach, fluxStepEach] = deal([]);
if exist(sprintf('%s.mat',savePOA), 'file')
    % all are done
    fprintf('Already finished. Results were already saved to %s.mat\n',savePOA);
    load(sprintf('%s.mat',savePOA), 'POAtable', 'fluxRange', 'Stat');
    return
elseif exist(sprintf('%s_POApre.mat',savePOA), 'file')
    % load previously saved prep file
    fluxRange = load(sprintf('%s_POApre.mat',savePOA), 'fluxRange', 'NstepEach', 'fluxStepEach');
    [NstepEach, fluxStepEach, fluxRange] = deal(fluxRange.NstepEach, fluxRange.fluxStepEach, fluxRange.fluxRange);
    for jP = 1:Npair
        undone(jP) = ~exist(sprintf('%s_j%d_k%d.mat',savePOA,pairList(jP,1),pairList(jP,2)), 'file');
    end
    fprintf('Unfinished pairs: %d\n', sum(undone));
end

if any(undone)
    %% Find flux range by FVA
    printFluxRange = true;
    if isempty(fluxRange)
        options.GR = GR;
        fluxRange = zeros(size(rxnNameList,2), 2);
        [fluxRange(:,1), fluxRange(:,2)] = SteadyComFVAgr(modelCom, options, LP, varargin{:});
        printFluxRange = false;
    end
    % print flux range
    if verbFlag && printFluxRange
        fprintf('Flux range:\nrxn\tmin\tmax\n');
        for jRxn = 1:size(rxnNameList, 2)
            strPrint = strjoin(varNameDisp(rxnNameList(:, jRxn) ~= 0), ',');
            fprintf('%s\t%.6f\t%.6f\n', strPrint, fluxRange(jRxn,1), fluxRange(jRxn,2));
        end
    end
    if isempty(NstepEach) && isempty(fluxStepEach)
        % range of values for each target acting as the independent flux variable
        NstepEach = zeros(nRxnPOA, 1);
        fluxStepEach = cell(nRxnPOA, 1);
        for j = 1:nRxnPOA
            if abs(fluxRange(j, 2) - fluxRange(j, 1)) < 1e-8
                fluxStepEach{j} = fluxRange(j, 1);
                NstepEach(j) = 1;
            else
                if numel(Nstep) > 1
                    % manually supply Nstep vector (% from min to max)
                    NstepEach(j) = numel(Nstep);
                    fluxStepEach{j} = fluxRange(j, 1) + (fluxRange(j, 2) - fluxRange(j, 1)) * Nstep;
                else
                    % uniform step or log-scaled step
                    NstepEach(j) = Nstep;
                    if strcmp(NstepScale, 'log')
                        if sign(fluxRange(j, 2)) == sign(fluxRange(j, 1))
                            if fluxRange(j, 1) > 0
                                [a, b] = deal(fluxRange(j, 1), fluxRange(j, 2));
                                fluxStepEach{j} = exp(log(a) + ((log(b) - log(a)) / (Nstep - 1)) * (0:(Nstep - 1)));
                            else
                                [b, a] = deal(-fluxRange(j, 1), -fluxRange(j, 2));
                                fluxStepEach{j} = exp(log(a) + ((log(b) - log(a)) / (Nstep - 1)) * (0:(Nstep - 1)));
                                fluxStepEach{j} = -fluxStepEach{j}(end:-1:1);
                            end
                        else
                            % not an ideal situation. Flux ranges containing zero
                            % should not use step size at log scale
                            a = [-inf, (1:(Nstep - 1)) / (Nstep - 1)];
                            fluxStepEach{j} = fluxRange(j, 1) + (fluxRange(j, 2) - fluxRange(j, 1)) * 0.01 * (100 .^ a);
                        end
                    else
                        % uniform step size
                        fluxStepEach{j} = (fluxRange(j, 1) : (fluxRange(j, 2) - fluxRange(j, 1)) / (Nstep - 1) : fluxRange(j, 2))';
                    end
                end
                fluxStepEach{j} = fluxStepEach{j}(:);
            end
        end
        save(sprintf('%s_POApre.mat',savePOA), 'fluxRange', 'GR', 'fluxStepEach', 'NstepEach', ...
            'rxnNameList', 'pairList', 'options', 'solverParams', 'parameters');
    end
    if (~isfield(modelCom, 'b'))
        modelCom.b = zeros(size(modelCom.S,1),1);
    end

    Npair =sum(undone);  % update number of pairs to be analyzed
    undoneId = find(undone);  % and their IDs

    if verbFlag  % print starting pair
        fprintf('\nPOA for %d pairs of reactions at growth rate %.6f\n', ...
            Npair - sum(pairList(undoneId, 1) == pairList(undoneId, 2)), GR);
        strPrintj = strjoin(varNameDisp(rxnNameList(:, pairList(undoneId(1), 1)) ~= 0), ',');
        strPrintk = strjoin(varNameDisp(rxnNameList(:, pairList(undoneId(1), 2)) ~= 0), ',');
        fprintf('Start from #%d %s vs #%d %s.\n', pairList(undoneId(1), 1), strPrintj, pairList(undoneId(1), 2), strPrintk);
        fprintf('%15s%15s%10s%10s%10s%10s   %s\n', 'Rxn1', 'Rxn2', 'corMin', 'r2', 'corMax', 'r2', 'Time')
    end
    if ibm_cplex
        [lb0, ub0] = deal(LP.Model.lb, LP.Model.ub);
    else
        [lb0, ub0] = deal(LP.lb, LP.ub);
    end
    addConstraint = false;

    if threads == 1
        %% single thread computation
        for jP = 1:Npair
            [j,k] = deal(pairList(undoneId(jP), 1),pairList(undoneId(jP), 2));
            if ~exist(sprintf('%s_j%d_k%d.mat', savePOA, j, k), 'file')
                NstepJ = NstepEach(j);
                fluxStepJ = fluxStepEach{j};
                % delete constraint added in the previous round if any
                if addConstraint
                    if ibm_cplex
                        LP.delRows(size(LP.Model.A, 1));
                    else
                        LP.A(end - 1:end, :) = [];
                        LP.b(end - 1:end) = [];
                        LP.csense(end - 1:end) = [];
                        if isfield(LP, 'basis') && isstruct(LP.basis) && isfield(LP.basis, 'cbasis')
                            LP.basis.cbasis(end - 1:end) = [];
                        end
                    end
                    addConstraint = false;
                end
                % if not a single flux, but a linear combination, add explicit constraint.
                if nnz(rxnNameList(:,j)) > 1
                    if ibm_cplex
                        LP.addRows(-inf, rxnNameList(:,j)',inf, 'POArow');
                    else
                        LP.A = [LP.A; repmat(rxnNameList(:,j)', 2, 1)];
                        LP.b = [LP.b; inf; -inf];
                        LP.csense = [LP.csense, 'LG'];
                        if isfield(LP, 'basis') && isstruct(LP.basis) && isfield(LP.basis, 'cbasis')
                            LP.basis.cbasis = [LP.basis.cbasis; 0; 0];
                        end
                    end
                    addConstraint = true;
                    rxnNameId = [];
                else
                    rxnNameId = rxnNameList(:,j) ~= 0;
                end
                fluxPOAvalue = zeros(NstepJ, 2);
                % reset LP bounds
                if ibm_cplex
                    [LP.Model.lb, LP.Model.ub] = deal(lb0, ub0);
                else
                    [LP.lb, LP.ub] = deal(lb0, ub0);
                end
                for p = 1:NstepJ
                    % minimize flux of the k-th reaction
                    if ibm_cplex
                        LP.Model.obj = rxnNameList(:, k);
                        LP.Model.sense = 'minimize';
                    else
                        LP.c = full(rxnNameList(:, k));
                        LP.osense = 1;
                    end
                    % fix flux v_j and solve
                    [LP, dev, sol] = fixFluxAndSolve(LP, fluxStepJ, p, 1e-12, ibm_cplex, addConstraint, rxnNameId, varargin{:});
                    eps0 = 1e-9;
                    while ~(dev <= feasTol) && eps0 < 1e-3  % largest acceptable tolerance set to be 0.001
                        eps0 = eps0 * 10;
                        [LP, dev, sol] = fixFluxAndSolve(LP, fluxStepJ, p, eps0, ibm_cplex, addConstraint, rxnNameId, varargin{:});
                    end
                    if dev <= feasTol
                        if ibm_cplex
                            fluxPOAvalue(p, 1) = LP.Model.obj' * LP.Solution.x;
                        else
                            fluxPOAvalue(p, 1) = sol.obj;
                        end
                    else
                        fluxPOAvalue(p, 1) = NaN; % shoud not happen
                    end
                    % maximize flux of the k-th reaction
                    if ibm_cplex
                        LP.Model.sense = 'maximize';
                        LP.solve();
                        dev = checkSolFeas(LP);
                    else
                        LP.osense = -1;
                        sol = solveCobraLP(LP, varargin{:});
                        if isfield(sol, 'basis') && ~isempty(sol.basis)
                            LP.basis = sol.basis;
                        end
                        dev = checkSolFeas(LP, sol);
                    end
                    eps0 = 1e-9;
                    while ~(dev <= feasTol) && eps0 < 1e-3
                        eps0 = eps0 * 10;
                        [LP, dev, sol] = fixFluxAndSolve(LP, fluxStepJ, p, eps0, ibm_cplex, addConstraint, rxnNameId, varargin{:});
                    end
                    if dev <= feasTol
                        if ibm_cplex
                            fluxPOAvalue(p, 2) = LP.Model.obj' * LP.Solution.x;
                        else
                            fluxPOAvalue(p, 2) = sol.obj;
                        end
                    else
                        fluxPOAvalue(p, 2) = NaN; % shoud not happen
                    end

                end
                POAtableJK = fluxPOAvalue;
                % simple linear regression to check correlations
                notNan = ~isnan(fluxPOAvalue(:, 1));
                [bMin, ~, ~, ~, statMin] = regress(fluxPOAvalue(notNan, 1),...
                    [fluxStepJ(notNan) ones(sum(notNan), 1)]);
                notNan = ~isnan(fluxPOAvalue(:, 2));
                [bMax, ~, ~, ~, statMax] = regress(fluxPOAvalue(notNan, 2),...
                    [fluxStepJ(notNan) ones(sum(notNan), 1)]);
                StatJK.cor = [bMin(1) bMax(1)];
                StatJK.r2 = [statMin(1) statMax(1)];
                if verbFlag  % print results
                    strPrintj = strjoin(varNameDisp(rxnNameList(:, j) ~= 0), ',');
                    strPrintk = strjoin(varNameDisp(rxnNameList(:, k) ~= 0), ',');
                    fprintf('%15s%15s%10.4f%10.4f%10.4f%10.4f   %04d-%02d-%02d %02d:%02d:%02.0f\n',...
                        strPrintj, strPrintk, StatJK.cor(1), StatJK.r2(1), StatJK.cor(2), StatJK.r2(2), clock);
                end
                iSave(savePOA, POAtableJK, StatJK, GR, j, k);  % save results for the current pair
            end
        end
    else
        %% parallel
        fprintf('POA in parallel...\n');
        if ibm_cplex
            LPmodel = LP.Model;
            LPstart = LP.Start;
        end
        % parallelization using spmd to allow redistribution of jobs upon
        % completion of any of the workers to avoid being idle
        numPool = gcp;
        numPool = numPool.NumWorkers;
        while Npair > 0
            % mannually distribute jobs
            remainder = mod(Npair, numPool);
            nJ = floor(Npair / numPool);
            kJ = 0;
            nRange = cell(numPool, 1);
            undoneCur = Composite();
            % Composite object is assigned as one cell/worker outside spmd blocks but called as the cell content inside spmd blocks
            for kP = 1:numPool
                if kP <= remainder
                    nRange{kP} = (kJ + 1) : (kJ + nJ + 1);
                    kJ = kJ + nJ + 1;
                else
                    nRange{kP} = (kJ + 1) : (kJ + nJ);
                    kJ = kJ + nJ;
                end
                nRange{kP} = undoneId(nRange{kP});
                undoneCur{kP} = undone(nRange{kP});
            end
            spmd
                % setup local LP
                if ibm_cplex
                    LPp = Cplex('subproblem');
                    LPp.Model = LPmodel;
                    LPp.DisplayFunc = [];
                    LPp = setCplexParam(LPp, solverParams);
                    LPp.Start = LPstart;
                else
                    LPp = LP;
                end
                addConstraint = false;
                % denote wether the current flag is the first to finish
                first = true;
                for jP = 1:numel(nRange{labindex})  % labindex = #thread
                    [j,k] = deal(pairList(nRange{labindex}(jP), 1), pairList(nRange{labindex}(jP), 2));
                    if ~exist(sprintf('%s_j%d_k%d.mat', savePOA, j, k), 'file')
                        NstepJ = NstepEach(j);
                        fluxStepJ = fluxStepEach{j};
                        StatJK = struct();
                        % reset LP bounds
                        if ibm_cplex
                            [LPp.Model.lb, LPp.Model.ub] = deal(lb0, ub0);
                        else
                            [LPp.lb, LPp.ub] = deal(lb0, ub0);
                        end
                        % delete constraint added in the previous round if any
                        if addConstraint
                            if ibm_cplex
                                LPp.delRows(size(LPp.Model.A,1));
                            else
                                LPp.A(end - 1:end, :) = [];
                                LPp.b(end - 1:end) = [];
                                LPp.csense(end - 1:end) = [];
                                if isfield(LPp, 'basis') && isstruct(LPp.basis) && isfield(LPp.basis, 'cbasis')
                                    LPp.basis.cbasis(end - 1:end) = [];
                                end
                            end
                            addConstraint = false;
                        end
                        % if not a single flux, but a linear combination, add explicit constraint.
                        if nnz(rxnNameList(:,j)) > 1
                            if ibm_cplex
                                LPp.addRows(-inf, rxnNameList(:, j)', inf, 'POArow');
                            else
                                LPp.A = [LPp.A; repmat(rxnNameList(:,j)', 2, 1)];
                                LPp.b = [LPp.b; inf; -inf];
                                LPp.csense = [LPp.csense, 'LG'];
                                if isfield(LPp, 'basis') && isstruct(LPp.basis) && isfield(LPp.basis, 'cbasis')
                                    LPp.basis.cbasis = [LPp.basis.cbasis; 0; 0];
                                end
                            end
                            addConstraint = true;
                            rxnNameId = [];
                        else
                            rxnNameId = rxnNameList(:,j) ~= 0;
                        end

                        fluxPOAvalue = zeros(NstepJ, 2);
                        for p = 1:NstepJ
                            % minimize flux of the k-th reaction
                            if ibm_cplex
                                LPp.Model.obj = rxnNameList(:, k);
                                LPp.Model.sense = 'minimize';
                            else
                                LPp.c = full(rxnNameList(:, k));
                                LPp.osense = 1;
                            end
                            %fix flux of the j-th reaction
                            [LPp, dev, solp] = fixFluxAndSolve(LPp, fluxStepJ, p, 1e-12, ibm_cplex, addConstraint, rxnNameId, varargin{:});
                            eps0 = 1e-9;
                            while dev > feasTol && eps0 < 1e-3  % largest acceptable tolerance set to be 0.001
                                eps0 = eps0 * 10;
                                [LPp, dev, solp] = fixFluxAndSolve(LPp, fluxStepJ, p, eps0, ibm_cplex, addConstraint, rxnNameId, varargin{:});
                            end
                            if dev <= feasTol
                                if ibm_cplex
                                    minf = LPp.Model.obj' * LPp.Solution.x;
                                else
                                    minf = solp.obj;
                                end
                            else
                                minf = NaN; % shoud not happen
                            end
                            % maximize flux of the k-th reaction
                            if ibm_cplex
                                LPp.Model.sense = 'maximize';
                                LPp.solve();
                                dev = checkSolFeas(LPp);
                            else
                                LPp.osense = -1;
                                solp = solveCobraLP(LPp, varargin{:});
                                if isfield(solp, 'basis') && ~isempty(solp.basis)
                                    LPp.basis = solp.basis;
                                end
                                dev = checkSolFeas(LPp, solp);
                            end
                            eps0 = 1e-9;
                            while dev > feasTol && eps0 < 1e-3
                                eps0 = eps0 * 10;
                                [LPp, dev, solp] = fixFluxAndSolve(LPp, fluxStepJ, p, eps0, ibm_cplex, addConstraint, rxnNameId, varargin{:});
                            end
                            if dev <= feasTol
                                if ibm_cplex
                                    maxf = LPp.Model.obj' * LPp.Solution.x;
                                else
                                    maxf = solp.obj;
                                end
                            else
                                maxf = NaN; %shoud not happen
                            end
                            fluxPOAvalue(p,:) = [minf maxf];
                        end

                        POAtableJK = fluxPOAvalue;
                        %simple linear regression to check correlations
                        notNan = ~isnan(fluxPOAvalue(:, 1));
                        [bMin, ~, ~, ~, statMin] = regress(fluxPOAvalue(notNan, 1), [fluxStepJ(notNan) ones(sum(notNan), 1)]);
                        notNan = ~isnan(fluxPOAvalue(:, 2));
                        [bMax, ~, ~, ~, statMax] = regress(fluxPOAvalue(notNan, 2), [fluxStepJ(notNan) ones(sum(notNan), 1)]);
                        StatJK.cor = [bMin(1) bMax(1)];
                        StatJK.r2 = [statMin(1) statMax(1)];
                        if verbFlag  % print results
                            strPrintj = strjoin(varNameDisp(rxnNameList(:, j) ~= 0,:), ',');
                            strPrintk = strjoin(varNameDisp(rxnNameList(:, k) ~= 0,:), ',');
                            fprintf('%15s%15s%10.4f%10.4f%10.4f%10.4f   %04d-%02d-%02d %02d:%02d:%02.0f\n',...
                                strPrintj, strPrintk, StatJK.cor(1), StatJK.r2(1), StatJK.cor(2), StatJK.r2(2), clock);
                        end
                        iSave(savePOA, POAtableJK, StatJK, GR, j, k);  % save results for the current pair
                    end
                    undoneCur(jP) = false;
                    % check if any of workers has finished its loop, break the loop and redistribute if finished
                    if labProbe('any',0);
                        first = false;
                        break
                    end
                end
                if first
                    % finish of one worker, call off other workers
                    if verbFlag
                        fprintf('Current loop finished. Stop other workers...\n');
                    end
                    labSend(true,setdiff(1:numlabs, labindex), 0);
                    if verbFlag
                        fprintf('All workers have ceased. Redistributing...\n');
                    end
                end
                % avoid warning from missed message
                pause(1e-8);
                while labProbe('any',0);
                    pause(1e-8);
                    labReceive('any',0);
                end
            end
            % update undone
            for kP = 1:numPool
                undone(nRange{kP}) = undoneCur{kP};
            end
            undoneId = find(undone);
            Npair = numel(undoneId);
        end
    end
end
if verbFlag
    fprintf('Finished. Save final results to %s.mat\n', savePOA);
end
POAtable = cell(nRxnPOA, nRxnPOA);
Stat = repmat(struct('cor', 0, 'r2', 0), nRxnPOA, nRxnPOA);
for jP = 1:nRxnPOA
    POAtable{jP, jP} = fluxStepEach{jP};
    Stat(jP, jP) = struct('cor', [1 1], 'r2', [1 1]);
end
for jP = 1:size(pairList,1)
    data = load(sprintf('%s_j%d_k%d.mat', savePOA, pairList(jP, 1), pairList(jP, 2)), 'POAtableJK', 'StatJK');
    POAtable{pairList(jP, 1), pairList(jP, 2)} = data.POAtableJK;
    Stat(pairList(jP, 1), pairList(jP, 2)) = data.StatJK;
end
save(sprintf('%s.mat', savePOA), 'POAtable', 'Stat', 'GR', 'fluxRange');
end

function [LP, dev, sol] = fixFluxAndSolve(LP, fluxRangeJ, p, eps0, ibm_cplex, addConstraint, rxnNameId, varargin)
if ibm_cplex
    if addConstraint
        [LP.Model.lhs(end), LP.Model.rhs(end)] = deal(fluxRangeJ(p) - eps0, fluxRangeJ(p) + eps0);
    else
        [LP.Model.lb(rxnNameId), LP.Model.ub(rxnNameId)] = deal(fluxRangeJ(p) - eps0, fluxRangeJ(p) + eps0);
    end
    sol = [];
    LP.solve();
    dev = checkSolFeas(LP);
else
    if addConstraint
        [LP.b(end), LP.b(end-1)] = deal(fluxRangeJ(p) - 1e-12, fluxRangeJ(p) + 1e-12);
    else
        [LP.lb(rxnNameId), LP.ub(rxnNameId)] = deal(fluxRangeJ(p) - 1e-12, fluxRangeJ(p) + 1e-12);
    end
    sol = solveCobraLP(LP, varargin{:});
    if isfield(sol, 'basis') && ~isempty(sol.basis)
        LP.basis = sol.basis;
    end
    dev = checkSolFeas(LP, sol);
end
end

function iSave(savePOA, POAtableJK, StatJK, GR, j0, k0)
save(sprintf('%s_j%d_k%d.mat', savePOA, j0, k0), 'POAtableJK', 'StatJK', 'GR', 'j0', 'k0');
end
