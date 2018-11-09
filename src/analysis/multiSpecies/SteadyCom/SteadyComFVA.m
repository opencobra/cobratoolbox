function [minFlux, maxFlux, minFD, maxFD, GRvector, result, LP] = SteadyComFVA(modelCom, options, varargin)
% Flux variability analysis for community model at community steady-state for a range of growth rates.
% The function is capable of saving intermediate results and continuing from previous results
% if the file path is given in `options.saveFVA`. It also allows switch from single thread to parallel
% computation from intermediate results (but not the other way round).
%
% USAGE:
%    [minFlux, maxFlux, minFD, maxFD, GRvector, result, LP] = SteadyComFVA(modelCom, options, parameter, 'param1', value1, 'param2', value2, ...)
%
% INPUT:
%    modelCom:     A community COBRA model structure with the following fields (created using `createMultipleSpeciesModel`)
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
%    options:    struct with the following possible fields:
%
%                  * optGRpercent - A vector of percentages. Perform FVA at these percents of max. growth rate (Default = [99.99])
%                  * optBMpercent - Only consider solutions that yield at least a certain percentage of the optimal biomass (Default = 99.99)
%                  * rxnNameList - List of reactions (index row vector or subset of `*.rxns`) for which FVA is performed.
%                    (Default = biomass reaction of each species)
%                    Or a :math:`(N_{rxns} + N_{organism}) x K` matrix for FVA of `K` linear combinations of fluxes and/or abundances
%                    e.g., `[1; -2; 0]` for finding the max/min of :math:`1 v_1 - 2 v_2 + 0 v_3`
%                  * rxnFluxList - List of reactions (index vector or subset of `*.rxns`) whose fluxes are
%                    also returned along with the FVA result of each entry in `rxnNameList`
%                    (Default = biomass reaction of each species)
%                  * GRmax - maximum growth rate of the model (default to be found `SteadyCom.m`)
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
%    GRvector:   a vector of growth rates at which FVA has been performed
%    result:     result structure from `SteadyCom`
%    LP:         `LP` problem structure (`Cplex LP` object for `ibm_cplex`)

[modelCom, ibm_cplex, feasTol, solverParams, parameters] = SteadyComSubroutines('initialize', modelCom, varargin{:});
% Initialization above
if nargin < 2 || isempty(options)
    options = struct();
end
% handle solveCobraLP name-value arguments that are specially treated in SteadyCom functions
[options, varargin] = SteadyComSubroutines('solveCobraLP_arg', options, parameters, varargin);

% get SteadyCom paramters. If a required parameter is in options, get its value, else equal to the
% default value in SteadyComSubroutines('getParams') if there is. Otherwise an empty matrix.
[GRmax, optGRpercent, rxnNameList, rxnFluxList, ...
    GRfx, BMmaxLB, BMmaxUB, ...
    verbFlag, loadModel, saveFVA, threads] = SteadyComSubroutines('getParams',  ...
    {'GRmax', 'optGRpercent', 'rxnNameList', 'rxnFluxList',...
    'GRfx','BMmaxLB','BMmaxUB', ...
    'verbFlag', 'loadModel','saveFVA','threads'}, ...
    options, modelCom);

[m, n] = size(modelCom.S);  % model size
nSp = numel(modelCom.indCom.spBm);  % number of organisms
nRxnSp = sum(modelCom.indCom.rxnSps > 0);  % number of organism-specific rxns

if ischar(rxnNameList)
    rxnNameList = {rxnNameList};
end
if iscell(rxnNameList) || (min(size(rxnNameList)) == 1 && size(rxnNameList, 1) < n)
    nRxnFVA = numel(rxnNameList);
else
    nRxnFVA = size(rxnNameList, 2);
end
if ischar(rxnFluxList)
    rxnFluxList = {rxnFluxList};
end

addRow = false;
GRgiven = false;
if isempty(GRmax)
    % get maximum growth rate
    [sol, result, LP] = SteadyCom(modelCom, options, varargin{:});
    if strcmp(result.stat,'infeasible')
        % infeasible model
        warning('The model is infeasible.');
        [minFlux, maxFlux] = deal(NaN(nRxnFVA, 1));
        [minFD, maxFD] = deal(NaN(numel(rxnFluxList), nRxnFVA));
        GRvector = NaN(numel(optGRpercent), 1);
        return
    end
    GRmax = result.GRmax;
    if ibm_cplex
        idRow = size(LP.Model.A, 1);  % row that constrains the total biomass
    else
        idRow = size(LP.A, 1);  % row that constrains the total biomass
    end
else
    % if GRmax is given, BMmaxLB and BMmaxUB should be included in options in this case to ensure feasibility
    if ibm_cplex && ~isempty(loadModel)
        % load Cplex model if loadModel is given
        LP = Cplex('SteadyComFVA');
        LP.readModel([loadModel '.mps']);
        LP.readBasis([loadModel '.bas']);
        LP.readParam([loadModel '.prm']);
        LP.DisplayFunc = [];
        fprintf('Load model ''%s'' successfully.\n', loadModel);
        addRow = true;
        if size(LP.Model.A, 1) > m + 2 * nRxnSp + nSp
            %try to find the row that constrains total biomass
            [ynRow, idRow] = ismember(sparse(ones(nSp, 1), (n + 1) : (n + nSp), ones(nSp, 1), 1, n + nSp),...
                LP.Model.A((m + 2 * nRxnSp + nSp + 1):end, 1:(n + nSp)),'rows');
            if ynRow
                idRow = m + 2 * nRxnSp + nSp + idRow;
            end
            addRow = ~ynRow;
        end
    else
        % get the LP structure using SteadyCom
        options2 = options;
        options2.LPonly = true;
        [~, ~, LP] = SteadyCom(modelCom, options2, varargin{:});
        addRow = true;  % no constraint on total biomass using LPonly option
    end
    result = struct('GRmax',GRmax,'vBM',[],'BM',[],'Ut',[],'Ex',[],'flux',[],'iter0',[],'iter',[],'stat','optimal');
    GRgiven = true;
end
if addRow
    % add a row for constraining the sum of biomass if not exist
    if ibm_cplex
        LP.addRows(BMmaxLB, sparse(ones(1, nSp), (n + 1) : (n + nSp), ones(1, nSp), 1, size(LP.Model.A, 2)), BMmaxUB, 'UnityBiomass');
        idRow = size(LP.Model.A, 1);
    else
        LP.A = [LP.A; sparse([ones(nSp, 1); 2 * ones(nSp, 1)], repmat((n + 1):(n + nSp), 1, 2),...
            ones(nSp * 2, 1), 2, size(LP.A, 2))];
        LP.b = [LP.b; BMmaxUB; BMmaxLB];
        LP.csense = [LP.csense, 'LG'];
        idRow = size(LP.A, 1);
    end
else
    % using BMmaxLB and BMmaxUB stored in the LP if not given in options
    if ~isfield(options,'BMmaxLB')  % take from LP if not supplied
        if ibm_cplex
            BMmaxLB = LP.Model.lhs(idRow);
        else
            BMmaxLB = LP.b(idRow);
        end
    end
    if ~isfield(options,'BMmaxUB')  % take from LP if not supplied
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
        LP.Model.lhs(idRow) = BMmaxLB;
        LP.Model.rhs(idRow) = BMmaxUB;
    else
        LP.b(idRow) = BMmaxLB;
        LP.b(idRow - 1) = BMmaxUB;
    end
end
if ibm_cplex
    LP = setCplexParam(LP, solverParams);  % set Cplex parameters
    % update the LP to ensure the current growth rate is constrained
    LP.Model.A = SteadyComSubroutines('updateLPcom', modelCom, GRmax, GRfx, [], LP.Model.A, []);
    LP.Model.sense = 'minimize';
    LP.Model.obj(:) = 0;
    LP.solve();
    dev = checkSolFeas(LP);
else
    % update the LP to ensure the current growth rate is constrained
    LP.A = SteadyComSubroutines('updateLPcom', modelCom, GRmax, GRfx, [], LP.A, []);
    LP.c(:) = 0;
    LP.osense = 1;
    sol = solveCobraLP(LP, varargin{:});
    dev = checkSolFeas(LP, sol);
    if isfield(sol, 'basis')
        LP.basis = sol.basis;  % reuse basis
    end
end
% check and adjust for feasibility
% (LP from SteadyCom should pass this automatically as the row has been added in SteadyComCplex)
kBMadjust = 0;
while ~(dev <= feasTol) && kBMadjust < 10
    kBMadjust = kBMadjust + 1;
    % relax the required sum of biomass
    if ibm_cplex
        LP.Model.lhs(idRow) = BMmaxLB * (1 - feasTol/(11 - kBMadjust));
        LP.solve();
        dev = checkSolFeas(LP);
    else
        LP.b(idRow) = BMmaxLB * (1 - feasTol/(11 - kBMadjust));
        sol = solveCobraLP(LP, varargin{:});
        dev = checkSolFeas(LP, sol);
        if isfield(sol, 'basis')
            LP.basis = sol.basis;  % reuse basis
        end
    end
    if verbFlag
        fprintf('BMmax adjustment: %d\n', kBMadjust);
    end
end
if ~(dev <= feasTol)  % dev can be NaN, which still means infeasibility. So use ~(dev <= feasTol) instead of dev > feasTol
    warning('Model not feasible.')
    [minFlux, maxFlux] = deal(NaN(nRxnFVA, numel(optGRpercent)));
    [minFD, maxFD] = deal(NaN(numel(rxnFluxList), nRxnFVA, numel(optGRpercent)));
    GRvector = NaN(numel(optGRpercent), 1);
    result.stat = 'infeasible';
    return
end
if GRgiven
    % assign result structure if in the rare case of given growth rate
    if ibm_cplex
        flux = LP.Solution.x;
    else
        flux = sol.full;
    end
    result.vBM = flux(modelCom.indCom.spBm);
    result.BM = flux(n+1:n+nSp);
    % two different types of indexing
    if size(modelCom.indCom.EXcom, 2) == 2
        % uptake and excretion reactions separated
        result.Ut = flux(modelCom.indCom.EXcom(:,1));
        result.Ex = flux(modelCom.indCom.EXcom(:,2));
    else
        % uptake and excretion in one exchange reaction
        [result.Ut, result.Ex] = deal(flux(modelCom.indCom.EXcom(:,1)));
        result.Ut(result.Ut > 0) = 0;
        result.Ut = -result.Ut;
        result.Ex(result.Ex < 0) = 0;
    end
    result.flux = flux(1:n);
end
% update BMmaxLB and BMmaxUB for FVA at each given growth rate
if ~isfield(options, 'BMmaxLB')
    if ibm_cplex
        options.BMmaxLB = LP.Model.lhs(idRow);
    else
        options.BMmaxLB = LP.b(idRow);
    end
end
if ~isfield(options, 'BMmaxUB')
    if ibm_cplex
        options.BMmaxUB = LP.Model.rhs(idRow);
    else
        options.BMmaxUB = LP.b(idRow - 1);
    end
end

GRvector = GRmax * optGRpercent / 100;
if ~isempty(saveFVA)
    % decide number of digits in the save name
    if numel(optGRpercent) == 1
        kDisp = 2;
    else
        d = min(GRvector(2:end) - GRvector(1:end-1));
        if d < 1
            kDisp = abs(floor(log10(abs(d))));
        else
            kDisp = 0;
        end
    end
    directory = strsplit(saveFVA,filesep);
    if numel(directory) > 1
        % not saving in the current directory. Create the directory.
        directory = strjoin([{pwd}, directory(1:end-1)],filesep);
        if ~exist(directory, 'dir')
            mkdir(directory);
        end
    end
    if ibm_cplex
        LPmodel = LP.Model;  % the Cplex dynamic object is not good for saving
        LPstart = LP.Start;
        save([saveFVA '_model.mat'], 'LPmodel', 'LPstart', 'options', 'solverParams', 'parameters');
        clear LPmodel LPstart
    else
        save([saveFVA '_model.mat'], 'LP', 'options', 'solverParams', 'parameters');
    end
end

[minFlux, maxFlux] = deal(zeros(nRxnFVA, numel(GRvector)));
[minFD, maxFD] = deal(zeros(numel(rxnFluxList), nRxnFVA, numel(GRvector)));

%parallel computation
try
    p = gcp('nocreate');
    if isempty(p)
        if threads > 1
            %given explicit no. of threads
            parpool(ceil(threads));
        elseif threads ~= 1
            %default max no. of threads (input 0 or -1 etc)
            parpool;
        end
    end
catch
    %No parallel pool existent
end
%perform FVA at each growth rate
for j = 1:numel(GRvector)
    optionsJ = options;
    optionsJ.GR = GRvector(j);
    if ~isempty(saveFVA)
        optionsJ.saveFVA = sprintf(['%s_GR%.' num2str(kDisp) 'f'], saveFVA, GRvector(j));
    end
    [minFluxJ,maxFluxJ,minFDj,maxFDj,LP] = SteadyComFVAgr(modelCom,optionsJ, LP, varargin{:});
    minFlux(:, j) = minFluxJ;
    maxFlux(:, j) = maxFluxJ;
    minFD(:,:, j) = minFDj;
    maxFD(:,:, j) = maxFDj;
end

end
