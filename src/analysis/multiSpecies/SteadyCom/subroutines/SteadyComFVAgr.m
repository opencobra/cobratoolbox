function [minFlux, maxFlux, minFD, maxFD, LP, GR] = SteadyComFVAgr(modelCom, options, LP, varargin)
% Flux variability analysis for community model at community steady-state at a given growth rate. Called by `SteadyComFVA`
% The function is capable of saving intermediate results and continuing from previous results
% if the file path is given in `options.saveFVA`. It also allows switch from single thread to parallel
% computation from intermediate results (but not the other way round).
%
% USAGE:
%
%    [minFlux, maxFlux, minFD, maxFD, LP, GR] = SteadyComFVAgr(modelCom, options, LP, parameter, 'param1', value1, 'param2', value2, ...)
%
% INPUT:
%    modelCom:   A community COBRA model structure with the following fields (created using createMultipleSpeciesModel)
%                (the first 5 fields are required, at least one of the last two is needed. Can be obtained using `getMultiSpecisModelId`):
%
%                  * S - Stoichiometric matrix
%                  * b - Right hand side
%                  * c - Objective coefficients
%                  * lb - Lower bounds
%                  * ub - Upper bounds
%                  * infoCom - structure containing community reaction info
%                  * indCom - the index structure corresponding to `infoCom`
%
% OPTIONAL INPUTS:
%    options:    struct with the following possible fields:
%
%                  * GR - The growth rate at which FVA is performed. If not
%                    given, find the maximum growth rate by `SteadyComCplex.m`
%                  * optBMpercent - Only consider solutions that yield at least a certain percentage of the optimal biomass (Default = 99.99)
%                  * rxnNameList - List of reactions (index row vector or subset of `*.rxns`) for which FVA is performed.
%                    (Default = biomass reaction of each species)
%                    Or a :math:`(N_{rxns} + N_{organism}) x K` matrix for FVA of `K` linear combinations of fluxes and/or abundances
%                    e.g., `[1; -2; 0]` for finding the max/min of :math:`1 v_1 - 2 v_2 + 0 v_3`
%                  * rxnFluxList - List of reactions (index vector or subset of `*.rxns`) whose fluxes are
%                    also returned along with the FVA result of each entry in `rxnNameList`
%                    (Default = biomass reaction of each species)
%                    (the two parameters below are usually determined by solving the problem during the program.
%                    Provide them only if you want to constrain the total biomass to a particular value)
%                  * BMmaxLB - lower bound for the total biomass (default 1)
%                  * BMmaxUB - upper bound for the total biomass (other parameters below)
%                  * saveFVA - If non-empty, become the filename to save the FVA results
%                    (default empty, not saving)
%                  * saveFre - save frequency. Save every `(#rxns for FVA) * saveFre` (default 0.1)
%                  * threads - for parallelization: > 1 for explicitly stating the no. of threads used,
%                    0 or -1 for using all available threads. Default 1.
%                    (Requires Matlab parallel toolbox)
%                  * verbFlag - Verbose output. 1 to have waitbar, >1 to have stepwise output (default 3)
%                  * loadModel - (`ibm_cplex` only) String of filename to be loaded. If non-empty, load the cplex
%                    model ('loadModel.mps'), basis ('loadModel.bas') and parameters ('loadModel.prm').
%                    (May add also other parameters in `SteadyCom` for calculating the maximum growth rate.)
%
%    LP :        LP problem structure (Cplex object for `ibm_cplex`) from calling `SteadyComFVA`.
%                Leave empty if calling this function alone.
%    parameter:  structure for solver-specific parameters.
%                'param1', value1, ...   name-value pairs for `solveCobraLP` parameters. See `solveCobraLP` for details
%
% OUTPUTS:
%    minFlux:    Minimum flux for each reaction
%    maxFlux:    Maximum flux for each reaction
%
% OPTIONAL OUTPUTS:
%    minFD:      :math:`rxnFluxList * rxnNameList` matrix containing the fluxes in `options.rxnFluxList`
%                corresponding to minimizing each reaction in `options.rxnNameList`
%    maxFD:      :math:`rxnFluxList * rxnNameList` matrix containing the fluxes in `options.rxnFluxList`
%                corresponding to maximizing each reaction in `options.rxnNameList`
%    LP:         `LP` problem structure (`Cplex LP` object for `ibm_cplex`)
%    GR:         the growth rate at which FVA is performed

global CBT_LP_SOLVER

[modelCom, ibm_cplex, feasTol, solverParams, parameters, varNameDisp, ...
    xName, m, n, nSp, nRxnSp] = SteadyComSubroutines('initialize', modelCom, varargin{:});
% Initialization above
if nargin < 2 || isempty(options)
    options = struct();
end
% handle solveCobraLP name-value arguments that are specially treated in SteadyCom functions
[options, varargin] = SteadyComSubroutines('solveCobraLP_arg', options, parameters, varargin);

[GR, optBMpercent, rxnNameList, rxnFluxList, ...
    GRfx, BMmaxLB, BMmaxUB, ...
    threads, verbFlag, loadModel, saveFVA, saveFre] = SteadyComSubroutines('getParams',  ...
    {'GR', 'optBMpercent', 'rxnNameList', 'rxnFluxList', ...
    'GRfx', 'BMmaxLB', 'BMmaxUB',...
    'threads', 'verbFlag', 'loadModel', 'saveFVA', 'saveFre'}, options, modelCom);

if (~isfield(modelCom, 'b'))
    modelCom.b = zeros(size(modelCom.S,1),1);
end
%% setup LP structure
checkBMrow = false;
if isempty(GR)
    % if the growth rate not given, find it and get the LP problem
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
        LP = Cplex('fva');
        LP.readModel([loadModel '.mps']);
        LP.readBasis([loadModel '.bas']);
        LP.readParam([loadModel '.prm']);
        LP.DisplayFunc = [];
        fprintf('Load model ''%s'' successfully.\n', loadModel);
        checkBMrow = true;
    else
        % get the LP structure using SteadyComCplex
        options2 = options;
        options2.LPonly = true;
        [~, ~, LP] = SteadyCom(modelCom, options2, varargin{:});
        addRow = true;  % no constraint on total biomass using LPonly option
    end
else
    % GR given as input and LP is supplied, expected when called by SteadyComFVA
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
    nRxnFVA = numel(rxnNameList);
else
    nRxnFVA = size(rxnNameList, 2);
end
if ~(dev <= feasTol)
    warning('Model not feasible.')
    [minFlux, maxFlux] = deal(NaN(nRxnFVA, 1));
    [minFD, maxFD] = deal(NaN(numel(rxnFluxList), nRxnFVA));
    return
end
if ibm_cplex
    BMmax0 = LP.Model.lhs(idRow);  % the actual required biomass after adjustment for feasibility
else
    BMmax0 = LP.b(idRow);  % the actual required biomass after adjustment for feasibility
end

% fluxes to return
if isnumeric(rxnFluxList)
    rxnFluxId = rxnFluxList;
elseif iscell(rxnFluxList) || ischar(rxnFluxList)
    rxnFluxId = findRxnIDs(modelCom,rxnFluxList);
end
if any(rxnFluxId) == 0
    error('Invalid names in rxnFluxList.');
end

% reactions/linear combinations of reactions subject to FVA in matrix form
objList = SteadyComSubroutines('rxnList2objMatrix', rxnNameList, varNameDisp, xName, n, nVar, 'rxnNameList');

% parallel computation

if threads ~= 1
    try
        if isempty(gcp('nocreate'))
            if threads > 1
                %given explicit no. of threads
                parpool(ceil(threads));
            else
                %default max no. of threads (input 0 or -1 etc)
                parpool;
            end
        end
    catch
        threads = 1;
    end
end
if threads ~= 1 && ~isfield(parameters, 'solver')
    % add explicitly the solver name to avoid error in parallel computation
    varargin = [varargin(:); {'solver'; CBT_LP_SOLVER}];
end
% check save directory
if ~isempty(saveFVA)
    directory = strsplit(saveFVA,filesep);
    if numel(directory) > 1
        % not saving in the current directory. Check existence
        directory = strjoin([{pwd}, directory(1:end-1)],filesep);
        if ~exist(directory, 'dir')
            mkdir(directory);
        end
    end
end
if verbFlag
    fprintf('\nFVA for %d sets of fluxes/biomass at growth rate %.6f :\n',...
        nRxnFVA, GR);
end

%% main loop of FVA
if threads == 1
    % single-thread FVA
    if (verbFlag == 1)  % in a fashion similar to fluxVariability.m
        h = waitbar(0, 'Flux variability analysis in progress ...');
    end
    if (verbFlag > 1)
        fprintf('%4s\t%4s\t%10s\t%9s\t%9s\n', 'No', '%', 'Name', 'Min', 'Max');
    end

    m = 0;
    [maxFlux, minFlux] = deal(zeros(nRxnFVA, 1));
    [minFD, maxFD] = deal(sparse(numel(rxnFluxId), nRxnFVA));
    i0 = 0;
    if ~isempty(saveFVA)
        % continue from previous saved file
        if ~isempty(saveFVA)
            if exist([saveFVA '.mat'], 'file')
                load([saveFVA '.mat'], 'i0', 'minFlux', 'maxFlux', 'minFD', 'maxFD');
                if i0 == nRxnFVA
                    fprintf('FVA was already finished previously and saved in %s.mat.\n', saveFVA);
                    return
                else
                    fprintf('Continue FVA from i = %d.\n', i0);
                end
            end
        end
    end
    saveFreAbs = max(floor(saveFre * nRxnFVA), 1);
    for i = (i0 + 1):nRxnFVA
        if (verbFlag == 1)
            fprintf('iteration %d.  skipped %d\n', i, round(m));
        end
        if ibm_cplex
            % maximize
            LP.Model.obj = -full(objList(:, i));
            [LP, maxFlux, maxFD] = FVAoptCplex(LP, maxFlux, maxFD, i, 'max', feasTol, BMmax0, idRow, rxnFluxId);
            LP.Model.lhs(idRow) = BMmax0;  % restore the original BMmax0
            % minimize
            LP.Model.obj = full(objList(:,i));
            [LP, minFlux, minFD] = FVAoptCplex(LP, minFlux, minFD, i, 'min', feasTol, BMmax0, idRow, rxnFluxId);
            LP.Model.lhs(idRow) = BMmax0;  % restore the original BMmax0
        else
            % maximize
            LP.c = -full(objList(:, i));
            [LP, maxFlux, maxFD] = FVAopt(LP, maxFlux, maxFD, i, 'max', feasTol, BMmax0, idRow, rxnFluxId, varargin{:});
            LP.b(idRow) = BMmax0;  % restore the original BMmax0
            % minimize
            LP.c = full(objList(:, i));
            [LP, minFlux, minFD] = FVAopt(LP, minFlux, minFD, i, 'min', feasTol, BMmax0, idRow, rxnFluxId, varargin{:});
            LP.b(idRow) = BMmax0;  % restore the original BMmax0
        end

        if verbFlag == 1
            waitbar(i/length(rxnNameList),h);
        elseif verbFlag > 1
            rxnNameDisp = strjoin(varNameDisp(objList(:, i) ~= 0, :), ' + ');
            fprintf('%4d\t%4.0f\t%10s\t%9.6f\t%9.6f\n', i, 100 * i / nRxnFVA, rxnNameDisp, minFlux(i), maxFlux(i));
        end
        if mod(i, saveFreAbs) == 0
            if ~isempty(saveFVA)
                %save intermediate results
                i0 = i;
                save([saveFVA '.mat'], 'i0', 'minFlux', 'maxFlux', 'minFD', 'maxFD')
            end
        end
    end
    if ~isempty(saveFVA)
        %save final results
        i0 = i;
        save([saveFVA '.mat'], 'i0', 'minFlux', 'maxFlux', 'minFD', 'maxFD')
    end
    if (verbFlag == 1)
        if ( regexp( version, 'R20') )
            close(h);
        end
    end
else
    %% parallel FVA
    i0P = 0;
    if ~isempty(saveFVA)
        %check if previous results from single-thread computation exist
        if exist([saveFVA '.mat'], 'file')
            load([saveFVA '.mat'], 'i0');
            i0P = i0;
            clear i0
            if i0P == nRxnFVA
                fprintf('FVA was already finished previously and saved in %s.mat.\n', saveFVA);
                load([saveFVA '.mat'], 'minFlux', 'maxFlux', 'minFD', 'maxFD');
                return
            else
                fprintf('Continue FVA from i = %d.\n', i0P);
            end
        end
    end

    p = gcp;
    numPool = p.NumWorkers;
    %assign reactions to each thread, from reaction i0P to nRxnFVA
    rxnRange = cell(numPool,1);
    remainder = mod(nRxnFVA - i0P,numPool);
    kRxnDist = i0P;
    for jP = 1:numPool
        if jP <= remainder
            rxnRange{jP} = (kRxnDist + 1):(kRxnDist + floor((nRxnFVA - i0P) / numPool) + 1);
        else
            rxnRange{jP} = (kRxnDist + 1):(kRxnDist + floor((nRxnFVA - i0P) / numPool));
        end
        kRxnDist = kRxnDist + numel(rxnRange{jP});
    end
    [LPmodel, LPstart] = deal([]);  % necessary for running the parallel code
    if ibm_cplex
        LPmodel = LP.Model;
        LPstart = LP.Start;
    end
    if ~isempty(saveFVA)
        save([saveFVA '_parInfo.mat'], 'options', 'rxnRange', 'numPool');
    end

    [maxFluxCell, minFluxCell, minFDCell, maxFDCell] = deal(cell(numPool,1));
    fprintf('%s\n',saveFVA);
    parfor jP = 1:numPool
        if ibm_cplex
            LPp = Cplex('subproblem');
            LPp.Model = LPmodel;
            LPp.Start = LPstart;
            LPp.DisplayFunc = [];
            LPp = setCplexParam(LPp, solverParams);
        else
            LPp = LP;
        end
        [maxFluxP, minFluxP] = deal(zeros(numel(rxnRange{jP}), 1));
        [minFDP, maxFDP] = deal(sparse(numel(rxnFluxId), numel(rxnRange{jP})));
        iCount = 0;  % counter of reactions to go
        iSkip = 0;  % previously finished reactions
        if ~isempty(saveFVA)
            % check if a previously saved file of parallel computation exists
            if exist([saveFVA '_thread' num2str(jP) '.mat'], 'file')
                [minFluxP, maxFluxP, minFDP, maxFDP, iSkip] = parLoad(jP, saveFVA);
                fprintf('Thread %d: continue FVA from i = %d.\n', jP, iSkip);
            end
        end
        saveFreAbs = max(floor(saveFre * numel(rxnRange{jP})), 1);
        for i = rxnRange{jP}
            iCount = iCount + 1;
            if i > iSkip
                if ibm_cplex
                    % maximize
                    LPp.Model.obj = -full(objList(:,i));
                    [LPp, maxFluxP, maxFDP] = FVAoptCplex(LPp, maxFluxP, maxFDP, iCount, 'max', feasTol, BMmax0, idRow, rxnFluxId);
                    LPp.Model.lhs(idRow) = BMmax0;  % restore the original BMmax0
                    % minimize
                    LPp.Model.obj = full(objList(:,i));
                    [LPp, minFluxP, minFDP] = FVAoptCplex(LPp, minFluxP, minFDP, iCount, 'min', feasTol, BMmax0, idRow, rxnFluxId);
                    LPp.Model.lhs(idRow) = BMmax0;  % restore the original BMmax0
                else
                    % maximize
                    LPp.c = -full(objList(:,i));
                    [LPp, maxFluxP, maxFDP] = FVAopt(LPp, maxFluxP, maxFDP, iCount, 'max', feasTol, BMmax0, idRow, rxnFluxId, varargin{:});
                    LPp.b(idRow) = BMmax0;  % restore the original BMmax0
                    % minimize
                    LPp.c = full(objList(:,i));
                    [LPp, minFluxP, minFDP] = FVAopt(LPp, minFluxP, minFDP, iCount, 'min', feasTol, BMmax0, idRow, rxnFluxId, varargin{:});
                    LPp.b(idRow) = BMmax0;  % restore the original BMmax0
                end

                if mod(iCount, saveFreAbs) == 0
                    if (verbFlag)
                        fprintf('Thread %d:\t%.2f%% finished. %04d-%02d-%02d %02d:%02d:%02.0f\n',...
                            jP, iCount / numel(rxnRange{jP}) * 100, clock);
                    end
                    % save intermediate data
                    if ~isempty(saveFVA)
                        parSave(minFluxP,maxFluxP,minFDP,maxFDP,i,jP,saveFVA)
                    end
                end
            end
        end
        if ~isempty(saveFVA)
            % save finished data for each thread
            parSave(minFluxP,maxFluxP,minFDP,maxFDP,i,jP,saveFVA)
        end
        maxFluxCell{jP} = maxFluxP;
        minFluxCell{jP} = minFluxP;
        maxFDCell{jP} = maxFDP;
        minFDCell{jP} = minFDP;
    end
    % collect all results
    [minFlux, maxFlux, minFD, maxFD] = deal([]);
    % include previously saved results
    if exist([saveFVA '.mat'], 'file')
        load([saveFVA '.mat'], 'minFlux', 'maxFlux', 'minFD', 'maxFD');
    end
    minFlux = [minFlux; zeros(nRxnFVA - numel(minFlux), 1)];
    maxFlux = [maxFlux; zeros(nRxnFVA - numel(maxFlux), 1)];
    minFD = [minFD, sparse(numel(rxnFluxId), nRxnFVA - size(minFD, 2))];
    maxFD = [maxFD, sparse(numel(rxnFluxId), nRxnFVA - size(maxFD, 2))];
    for jP = 1:numPool
        maxFlux(rxnRange{jP}) = maxFluxCell{jP};
        minFlux(rxnRange{jP}) = minFluxCell{jP};
        maxFD(:, rxnRange{jP}) = maxFDCell{jP};
        minFD(:, rxnRange{jP}) = minFDCell{jP};
        [maxFluxCell{jP}, minFluxCell{jP}, maxFDCell{jP}, minFDCell{jP}] = deal([]);
    end
    if ~isempty(saveFVA)
        i0 = nRxnFVA;
        save([saveFVA '.mat'], 'i0', 'minFlux', 'maxFlux', 'minFD', 'maxFD');
    end
end

end

function [LP, flux, FD] = FVAoptCplex(LP, flux, FD, i, sense, feasTol, BMmax0, idRow, rxnFluxId)
LP.solve();
while ~isprop(LP, 'Solution')
    try
        LP.solve();
    catch
        % should not happen
        fprintf('Error in solving!')
    end
end
% infeasibility can occur occasionally due to numerical instability. Keep trying to relax the maximum biomass
eps0 = 1e-8;
while ~(checkSolFeas(LP) <= feasTol) && eps0 * 10 <= 1e-3
    eps0 = eps0 * 10;
    LP.Model.lhs(idRow) = BMmax0 * (1 - eps0);
    LP.solve();
end
if ~(checkSolFeas(LP) <= feasTol)
    %infeasible (suggests numerical issues)
    flux(i) = NaN;
    FD(:,i) = NaN;
else
    %LP.Solution.fval can sometimes return NaN even if a solution is found
    switch sense
        case 'max'
            flux(i) = -LP.Model.obj' * LP.Solution.x;
        case 'min'
            flux(i) = LP.Model.obj' * LP.Solution.x;
    end
    FD(:,i) = LP.Solution.x(rxnFluxId);
end
end

function [LP, flux, FD] = FVAopt(LP, flux, FD, i, sense, feasTol, BMmax0, idRow, rxnFluxId, varargin)
solution = solveCobraLP(LP, varargin{:});
if isfield(solution, 'basis')
    LP.basis = solution.basis;  % reuse basis
end
% infeasibility can occur occasionally due to numerical instability. Keep trying to relax the maximum biomass
eps0 = 1e-8;
while ~(checkSolFeas(LP, solution) <= feasTol) && eps0 * 10 <= 1e-3
    eps0 = eps0 * 10;
    LP.b(idRow) = BMmax0 * (1 - eps0);
    solution = solveCobraLP(LP, varargin{:});
    if isfield(solution, 'basis')
        LP.basis = solution.basis;  % reuse basis
    end
end
if ~(checkSolFeas(LP, solution) <= feasTol)
    %infeasible (suggests numerical issues)
    flux(i) = NaN;
    FD(:,i) = NaN;
else
    switch sense
        case 'max'
            flux(i) = -LP.c(:)' * solution.full;
        case 'min'
            flux(i) = LP.c(:)' * solution.full;
    end
    FD(:,i) = solution.full(rxnFluxId);
end
end

function parSave(minFluxP,maxFluxP,minFDP,maxFDP,i0,jP,saveFVA)
save([saveFVA '_thread' num2str(jP) '.mat'], 'i0', 'minFluxP', 'maxFluxP', 'minFDP', 'maxFDP', 'jP')
end

function [minFluxP,maxFluxP,minFDP,maxFDP,i0] = parLoad(jP,saveFVA)
load([saveFVA '_thread' num2str(jP) '.mat'], 'i0', 'minFluxP', 'maxFluxP', 'minFDP', 'maxFDP')
end
