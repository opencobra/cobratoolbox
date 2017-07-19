function [POAtable, fluxRange, Stat, GRvector] = SteadyComPOA(modelCom, options, varargin)
% Analyze pairwise relationship between reaction fluxes/biomass variables for a community model
% at community steady-state at a given growth rate. See `tutorial_SteadyCom` for more details.
%
% USAGE:
%    [POAtable, fluxRange, Stat, GRvector] = SteadyComPOA(modelCom, options, parameters, 'param1', value1, 'param2', value2, ...)
%
% INPUT:
%    modelCom:  A community COBRA model structure with the following fields (created using `createMultipleSpeciesModel`)
%               (the first 5 fields are required, at least one of the last two is needed. Can be obtained using `getMultiSpecisModelId`):
%
%                 * S - Stoichiometric matrix
%                 * b - Right hand side
%                 * c - Objective coefficients
%                 * lb - Lower bounds
%                 * ub - Upper bounds
%                 * infoCom - structure containing community reaction info
%                 * indCom - the index structure corresponding to `infoCom`
%
% OPTIONAL INPUTS:
%    options:    option structure with the following fields:
%
%                  * GRmax - maximum growth rate of the model (default to be found SteadyCom.m)
%                  * optGRpercent - A vector of percentages. Perform FVA at these percents of max. growth rate (Default = [99.99])
%                  * optBMpercent - Only consider solutions that yield at least a certain percentage of the optimal biomass (Default = 99.99)
%                  * rxnNameList - list of reactions (IDs or .rxns) to be analyzed. Use a :math:`(N_{rxns} + N_{organism}) x K` matrix for POA of `K`
%                    linear combinations of fluxes and/or abundances (Default = biomass reaction of each organism,
%                  * pairList - pairs in `rxnNameList` to be analyzed. `N_pair` by 2 array of:
%
%                    * - indices referring to the rxns in `rxnNameList`, e.g., `[1 2]` to analyze `rxnNameList{1}` vs `rxnNameList{2}`
%                    * - rxn names which are members of `rxnNameList`, e.g., `{'EX_glc-D(e)', 'EX_ac(e)'}`
%                    If not supplied, analyze all `K(K-1)` pairs from the `K` targets in `rxnNameList`.
%                  * symmetric - true to avoid running symmetric pairs (e.g. analyze pair `(j,k)` only if :math:`j > k`, total :math:`K(K-1)/2 pairs)`.
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
%    POAtable:    `K x K` cells. Each `(i, i)` -cell contains a `Nstep x 1 x N_gr` matrix of the fluxes at which `rxnNameList{i}` is fixed.
%                  Each `(i, j)` -cell contains a `Nstep x 2 x N_gr` matrix, the `(p,:,q)` -entry being the range of `rxnNameList{j}`
%                  when `rxnNameList{i}` is fixed at `POAtable{i, i}(p, 1, q)` at growth rate = GRvector(q)
%    fluxRange:   `K x 2 x N_gr` matrix of flux range for each entry in `rxnNameList`
%    Stat:        `K x K x N_gr` structure array with fields:
%
%                   * -'cor': the slope from linear regression between the fluxes of a pair
%                   * -'r2':  the corresponding coefficient of determination (R-square)
%    GRvector:    vector of growth rates being analyzed

[modelCom, ibm_cplex, feasTol, solverParams, parameters, varNameDisp, ...
    xName, m, n, nSp, nRxnSp] = SteadyComSubroutines('initialize', modelCom, varargin{:});
% Initialization above
if nargin < 2 || isempty(options)
    options = struct();
end
% handle solveCobraLP name-value arguments that are specially treated in SteadyCom functions
[options, varargin] = SteadyComSubroutines('solveCobraLP_arg', options, parameters, varargin);

% get SteadyCom paramters. If a required parameter is in options, get its value, else equal to the
% default value in SteadyComSubroutines('getParams') if there is. Otherwise an empty matrix.
[GRmax, optGRpercent, Nstep, GRfx, BMmaxLB, BMmaxUB, ...
    rxnNameList, pairList, symmetric, verbFlag, savePOA, loadModel] = SteadyComSubroutines('getParams',  ...
    {'GRmax', 'optGRpercent', 'Nstep', 'GRfx','BMmaxLB','BMmaxUB',...
    'rxnNameList', 'pairList', 'symmetric', 'verbFlag', 'savePOA','loadModel'}, options, modelCom);

if isempty(savePOA)
    error('A non-empty file name must be provided to save the POA results.');
end

init = true;  % start solving from the beginning or not
if exist([savePOA '_MasterModel.mat'], 'file')
    if ibm_cplex
        load([savePOA '_MasterModel.mat'],'LPstart','LPmodel','GRvector','kDisp','idRow');
        LP = Cplex('POA');
        LP.Model = LPmodel;
        LP.Start = LPstart;
        LP.DisplayFunc = [];
        LP = setCplexParam(LP, solverParams);
        if ~isfield(options, 'BMmaxLB')
            options.BMmaxLB = LP.Model.lhs(idRow);
        end
        if ~isfield(options, 'BMmaxUB')
            options.BMmaxUB = LP.Model.rhs(idRow);
        end
    else
        load([savePOA '_MasterModel.mat'],'LP','GRvector','kDisp','idRow');
        if ~isfield(options, 'BMmaxLB')
            options.BMmaxLB = LP.b(idRow);
        end
        if ~isfield(options, 'BMmaxUB')
            options.BMmaxUB = LP.b(idRow - 1);
        end
    end
    init = false;
end
if numel(Nstep) > 1
    Nstep = numel(Nstep);  % number of steps in each analysis
end
if (~isfield(options, 'rxnNameList') || isempty(options.rxnNameList)) && isfield(options, 'pairList') && iscell(options.pairList)
    % get rxnNameList from pairList if only pairList given
    rxnNameList = options.pairList(:);
end
if ischar(rxnNameList)
    rxnNameList = {rxnNameList};
end
% number of target reactions to be analyzed
if iscell(rxnNameList) || (min(size(rxnNameList)) == 1 && size(rxnNameList, 1) < n)
    nRxnPOA = numel(rxnNameList);
else
    nRxnPOA = size(rxnNameList, 2);
end
if init
    addRow = false;
    % get maximum growth rate
    if isempty(GRmax)
        [~, result, LP] = SteadyCom(modelCom, options, varargin{:});
        if strcmp(result.stat,'infeasible')
            % infeasible model
            warning('Model is infeasible.');
            POAtable = cell(nRxnPOA);
            GRvector = NaN(numel(optGRpercent), 1);
            fluxRange = NaN(nRxnPOA, 2, numel(GRvector));
            Stat = repmat(struct('cor', [], 'r2', []), nRxnPOA, nRxnPOA, numel(GRvector));
            return
        end
        GRmax = result.GRmax;
        if ibm_cplex
            idRow = size(LP.Model.A, 1);  % row that constrains the total biomass
        else
            idRow = size(LP.A, 1);  % row that constrains the total biomass
        end
    else
        %If GRmax is given, BMmaxLB and BMmaxUB should be included in options in this case to ensure feasibility
        if ibm_cplex && ~isempty(loadModel)
            % load solution if given and growth rate is known
            LP = Cplex('SteadyComPOA');
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
            %get LP using SteadyCom if only growth rate is given
            options2 = options;
            options2.LPonly = true;
            [~, ~, LP] = SteadyCom(modelCom, options2, varargin{:});
            addRow = true;  % no constraint on total biomass using LPonly option
        end
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
            fprintf('BMmax adjustment: %d\n',kBMadjust);
        end
    end
    if ~(dev <= feasTol)   % dev can be NaN, which still means infeasibility. So use ~(dev <= feasTol) instead of dev > feasTol
        warning('Model is infeasible.');
        POAtable = cell(nRxnPOA);
        GRvector = NaN(numel(optGRpercent), 1);
        fluxRange = NaN(nRxnPOA, 2, numel(GRvector));
        Stat = repmat(struct('cor', [], 'r2', []), nRxnPOA, nRxnPOA, numel(GRvector));
        return
    end
    if ibm_cplex
        if ~isfield(options, 'BMmaxLB')
            options.BMmaxLB = LP.Model.lhs(idRow);
        end
        if ~isfield(options, 'BMmaxUB')
            options.BMmaxUB = LP.Model.rhs(idRow);
        end
    else
        if ~isfield(options, 'BMmaxLB')
            options.BMmaxLB = LP.b(idRow);
        end
        if ~isfield(options, 'BMmaxUB')
            options.BMmaxUB = LP.b(idRow - 1);
        end
    end

    GRvector = GRmax * optGRpercent / 100;
    % decide number of digits in the save name
    if numel(optGRpercent) == 1
        kDisp = 2;
    else
        d = max(GRvector(2:end) - GRvector(1:end-1));
        if d < 1
            kDisp = abs(floor(log10(abs(d))));
        else
            kDisp = 0;
        end
    end
end
if ibm_cplex
    nVar = size(LP.Model.A, 2);
else
    nVar = size(LP.A, 2);
end
% reactions/linear combinations of reactions to be analyzed in matrix form
rxnNameList = SteadyComSubroutines('rxnList2objMatrix', rxnNameList, varNameDisp, xName, n, nVar, 'rxnNameList');
options.rxnNameList = rxnNameList;
% pairs to be analyzed in the correct format
if isempty(pairList)
    % if pairList not given, run for all pairs
    pairList = [reshape(repmat(1:nRxnPOA, nRxnPOA, 1),nRxnPOA ^ 2, 1), repmat((1:nRxnPOA)', nRxnPOA, 1)];
    if symmetric
        % the option 'symmetric' is only used here when pairList is not supplied to avoid running symmetric pairs (e.g. j vs k and k vs j)
        pairList(pairList(:, 1) > pairList(:, 2), :) = [];
    end
elseif size(pairList, 2) ~= 2
    error('pairList must be an N-by-2 array denoting the pairs (rxn names or indices in rxnNameList) to analyze!')
elseif iscell(pairList)
    % transform pairList into matrix form and find the IDs
    pairList = SteadyComSubroutines('rxnList2objMatrix', pairList(:), varNameDisp, xName, n, nVar, 'pairList');
    [yn, id] = ismember(pairList', rxnNameList', 'rows');
    if ~all(yn)
        error('Some entries in options.pairList are not in options.rxnNameList');
    end
    pairList = reshape(id, numel(id) / 2, 2);
end
options.pairList = pairList;

% check the directory for saving
directory = strsplit(savePOA, filesep);
if numel(directory) > 1
    directory = strjoin([{pwd}, directory(1:end-1)],filesep);
    if ~exist(directory,'dir')
        mkdir(directory);
    end
end
if init  % save a master model
    if ibm_cplex
        LPstart = LP.Start;
        LPmodel = LP.Model;
        save([savePOA '_MasterModel.mat'], 'LPstart', 'LPmodel', 'GRvector', 'kDisp', 'idRow', 'GRmax', 'solverParams', 'parameters', 'options');
        clear LPstart LPmodel  % save memory
    else
        save([savePOA '_MasterModel.mat'], 'LP', 'GRvector', 'kDisp', 'idRow', 'GRmax', 'solverParams', 'parameters', 'options');
    end
end
for j = 1:numel(GRvector)
    optionsJ = options;
    optionsJ.GR = GRvector(j);
    optionsJ.savePOA = sprintf(['%s_GR%.' num2str(kDisp) 'f'], savePOA, GRvector(j));
    if j > 1  % reset the model to ensure feasibility
        if ibm_cplex
            load([savePOA '_MasterModel.mat'], 'LPstart', 'LPmodel');
            LP.Model = LPmodel;
            LP.Start = LPstart;
            LP = setCplexParam(LP, solverParams);
        else
            load([savePOA '_MasterModel.mat'], 'LP');
        end
    end
    clear LPmodel LPstart  % save memory
    SteadyComPOAgr(modelCom, optionsJ, LP, varargin{:});
end

%collect output from save file
POAtable = cell(nRxnPOA, nRxnPOA);
Stat = repmat(struct('cor',0,'r2',0), [nRxnPOA, nRxnPOA, numel(GRvector)]);
fluxRange = zeros(nRxnPOA, 2, numel(GRvector));

for j = 1:numel(GRvector)
    data = load(sprintf(['%s_GR%.' num2str(kDisp) 'f.mat'], savePOA, GRvector(j)), 'POAtable', 'fluxRange', 'Stat');
    for p = 1:nRxnPOA
        for q = 1:nRxnPOA
            if isempty(data.POAtable{p, q})
                POAtable{p, q} = [];
            elseif size(data.POAtable{p, q}, 1) == 1
                %single point, no range
                POAtable{p, q}(:, :, j) = repmat(data.POAtable{p, q}, Nstep, 1);
            else
                POAtable{p, q}(:, :, j) = data.POAtable{p, q};
            end
            Stat(p, q, j).cor = data.Stat(p, q).cor;
            Stat(p, q, j).r2 = data.Stat(p, q).r2;
            fluxRange(:, :, j) = data.fluxRange;
        end
    end
end

end
