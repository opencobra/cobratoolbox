function [minFlux, maxFlux, optsol, ret, fbasol, fvamin, fvamax, statussolmin, statussolmax] = fastFVA(model, optPercentage, osenseStr, solverName, rxnsList, matrixAS, cpxControl, strategy, rxnsOptMode, printLevel)
% Flux variablity analysis optimized for the CPLEX solver.
% Solves LPs of the form:
%
% .. math::
%
%    \forall ~ v_j: ~&~ max/min ~&~ v_j\\
%                 ~&~ s.t.    ~&~ Sv = b\\
%                 ~&~         ~&~ l_b \leq v \leq u_b
%
% If the optional fields are supplied, following LPs are solved
%
% .. math::
%
%    \forall ~ v_j: ~&~ max/min ~&~ v_j\\
%                 ~&~ s.t.    ~&~ Av (c_sense) b\\
%                 ~&~         ~&~ l_b \leq v \leq u_b
%
% fastFVA returns vectors for the initial FBA in FBASOL together with matrices FVAMIN and
% FVAMAX containing the flux values for each individual min/max problem.
% Note that for large models the memory requirements may become prohibitive.
% To save large `fvamin` and `fvamax` matrices, toggle v7.3 in Preferences -> General -> MAT-Files
%
% If a `rxnsList` vector is specified then only the corresponding entries in
% minFlux and maxFlux are defined (all remaining entries are zero).
%
% USAGE:
%
%    [minFlux, maxFlux, optsol, ret, fbasol, fvamin, fvamax, statussolmin, statussolmax] = fastFVA(model, optPercentage, osenseStr, solverName, rxnsList, matrixAS, cpxControl, strategy, rxnsOptMode)
%
% INPUTS:
%   model:             COBRA model structure
%
%                        * .S - (required) Stoichiometric matrix
%                        * .b - (required) Right hand side vector
%                        * .c - (required) Objective coefficients
%                        * .lb - (required) Lower bounds
%                        * .ub - (required) Upper bounds
%                        * .A - (optional) Stoichiometric matrix (with constraints)
%                        * .csense - (optional) Type of constraints, `csense` is a vector with elements `E` (equal), `L` (less than) or `G` (greater than).
%   optPercentage:     Only consider solutions that give you at least a certain
%                      percentage of the optimal solution (default = `100`, equivalent to optimal solutions only)
%   osenseStr:         Objective ('min' or 'max') (default 'max')
%   solverName:        name of the solver, default: `ibm_cplex`
%
% OPTIONAL INPUTS:
%   matrixAS:          `A` or `S` - choice of the model matrix, coupled (A) or uncoupled (S)
%   cpxControl:        Parameter set of CPLEX loaded externally
%   rxnsList:          List of reactions to analyze (default all rxns, i.e. `1:length(model.rxns)``)
%   strategy:          Paralell distribution strategy of reactions among workers
%
%                       * 0 = Blind splitting: default random distribution
%                       * 1 = Extremal dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from both extremal indices of the sorted column density vector
%                       * 2 = Central dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from the beginning and center indices of the sorted column density vector
%   rxnsOptMode:       List of min/max optimizations to perform:
%                       * 0 = only minimization;
%                       * 1 = only maximization;
%                       * 2 = minimization & maximization;
%   printLevel:        Verbose level (default: 1)
%                       * 0 = mute
%                       * 1 = default
%
% OUTPUTS:
%   minFlux:           Minimum flux for each reaction
%   maxFlux:           Maximum flux for each reaction
%   optsol:            Optimal solution (of the initial FBA)
%   ret:               Zero if success (global return code from FVA)
%
% OPTIONAL OUTPUTS:
%   fbasol:            Initial FBA in FBASOL
%   fvamin:            matrix with flux values for the minimization problem
%   fvamax:            matrix with flux values for the maximization problem
%   statussolmin:      vector of solution status for each reaction (minimization)
%   statussolmax:      vector of solution status for each reaction (maximization)
%
%
% EXAMPLE:
%
%    load modelRecon1Biomass.mat % Human reconstruction network (Recon1)
%    setWorkerCount(4);
%    [minFlux,maxFlux] = fastFVA(model, 90);
%
% NOTE:
%
%    S. Gudmundsson and I. Thiele, Computationally efficient
%    Flux Variability Analysis. BMC Bioinformatics, 2010, 11:489
%
% NOTE:
%
%    * Matlab R2014a fully tested on UNIX and DOS Systems
%    * Matlab R2015b throws compatibility errors with CPLEX 12.6.3 on DOS Systems
%    * Matlab R2016b and the MinGW64 compiler are not compatible with the CPLEX 12.6.3 library
%
%    The version of fastFVA only supports the CPLEX solver. The code has been tested with
%    CPLEX 12.6.2, 12.6.3, 12.7.0 and 12.7.1. Install
%    CPLEX (64-bit) as explained `here`_.
%    A particular interface, such as TOMLAB, is not needed in order to run fastFVA.
%    Please note that only the 64-bit versions of CPLEX 12.7.1 are supported.
%    In order to run the code on 32-bit systems, the appropriate MEX files need to be generated
%    using generateMexFastFVA().
%
% .. _here: https://opencobra.github.io/cobratoolbox/docs/solvers.html
%
% .. Authors:
%       - Original author: Steinn Gudmundsson.
%       - Contributor: Laurent Heirendt, LCSB
%
% .. Last updated: October 2016

global CBTDIR

% save the userpath
originalUserPath = path;

% save the current directory
currentDir = pwd;

% the root path must be the root directory as the path to the logFiles is hard-coded
cd(CBTDIR);

% determine the printLevel
if (nargin < 10 || isempty(printLevel))
    printLevel = 1;
end

% determine the latest installed CPLEX version
cplexVersion = getCobraSolverVersion('ibm_cplex', printLevel);

% check if the provided fastFVA binaries are compatible with the current system configuration
checkFastFVAbin(cplexVersion);

% set a random log filename to avoid overwriting ongoing runs
rng('shuffle');
filenameParfor = ['parfor_progress_', datestr(now, 30), '_', num2str(randi(9)), '.txt'];
filenameParfor = [CBTDIR filesep '.tmp' filesep filenameParfor];

% turn on the load balancing for large problems
loadBalancing = 0;  % 0: off; 1: on

% define if information about the work load distriibution will be shown or not
showSplitting = 1;

% define the input arguments
if (nargin < 8 || isempty(strategy))
    strategy = 0;
end
if (nargin < 7 || isempty(cpxControl))
    cpxControl = struct([]);
end
if (nargin < 6 || isempty(matrixAS))
    matrixAS = 'S';
end
if (nargin < 5 || isempty(rxnsList))
    rxns = 1:length(model.rxns);
    rxnsList = model.rxns;
else
    % check here if the vector of rxns is sorted or not
    % this needs to be fixed to sort the flux vectors accordingly
    % as the find() function sorts the reactions automatically
    % ->> this is currently an issue on git
    [~, indexRxns] = ismember(model.rxns, rxnsList);
    nonZeroIndices = [];
    for i = 1:length(indexRxns)
        if indexRxns(i) ~= 0
            nonZeroIndices = [nonZeroIndices, indexRxns(i)];
        end
    end
    if issorted(nonZeroIndices) == 0
        error('\n-- ERROR:: Your input reaction vector is not sorted. Please sort your reaction vector first.\n\n')
    end

    rxns = find(ismember(model.rxns, rxnsList))';  % transpose rxns

end
if (nargin < 9 || isempty(rxnsOptMode))
    rxnsOptMode = 2 * ones(length(rxns), 1)';  % status = 2 (min & max) for all reactions
end
if (nargin < 4 || isempty(solverName))
    solverName = 'ibm_cplex';
end
if (nargin < 3 || isempty(osenseStr))
    osenseStr = 'max';
end
if (nargin < 2 || isempty(optPercentage))
    optPercentage = 100;
end

% define extra outputs if required
if nargout > 4 && nargout <= 7
    assert(nargout == 7);
    bExtraOutputs = true;
else
    bExtraOutputs = false;
end

% define extra outputs if required
if nargout > 7
    assert(nargout == 9);
    bExtraOutputs1 = true;
else
    bExtraOutputs1 = false;
end

% print a warning when output arguments are not defined.
if nargout ~= 4 && nargout ~= 7 && nargout ~= 9
    if printLevel > 0
        fprintf('\n-- Warning:: You may only ouput 4, 7 or 9 variables.\n\n')
    end
end

% define the osenseStr
if strcmpi(osenseStr, 'max')
    obj = -1;
elseif strcmpi(osenseStr, 'min')
    obj = 1;
else
    error('Unknown osenseStr');
end

% define the solverName
if strcmp('glpk', solverName)
    error('ERROR : GLPK is not (yet) supported as the binaries are not yet available.')
elseif strcmp('ibm_cplex', solverName)
    FVAc = str2func(['cplexFVA' cplexVersion]);
else
    error(['Solver ', solverName, ' not supported.']);
end

% define the CPLEX parameter set and the associated values - split the struct
namesCPLEXparams = fieldnames(cpxControl);
nCPLEXparams = length(namesCPLEXparams);
valuesCPLEXparams = zeros(nCPLEXparams, 1);
for i = 1:nCPLEXparams
    valuesCPLEXparams(i) = getfield(cpxControl, namesCPLEXparams{i});
end

% create an LP problem
LPproblem = buildLPproblemFromModel(model);

% define the stoichiometric matrix to be solved
if matrixAS == 'A'
    [A,b,csense,lb,ub,c] = deal(LPproblem.A,LPproblem.b,LPproblem.csense,LPproblem.lb,LPproblem.ub,LPproblem.c);
    if printLevel > 0
        fprintf(' >> Solving Model.A. (coupled) - Generalized\n');
    end
else
    if ~isfield(model,'csense')
        model.csense = repmat('E',size(model.S,1),1);
    end
    [A,b,csense,lb,ub,c] = deal(model.S,model.b,model.csense,model.lb,model.ub,model.c);
    if printLevel > 0
        fprintf(' >> Solving Model.S. (uncoupled) \n');
    end
end

if printLevel > 0
    fprintf(' >> The number of arguments is: input: %d, output %d.\n', nargin, nargout);
end

% define the matrix A as sparse in case it is not as
% C code assumes a sparse stochiometric matrix
if ~issparse(A)
    A = sparse(A);
end

% determine the size of the stoichiometric matrix
[m, n] = size(A);
if printLevel > 0
    fprintf(' >> Size of stoichiometric matrix: (%d,%d)\n', m, n);
end

% determine the number of reactions that are considered
nR = length(rxns);
if nR ~= n
    if printLevel > 0
        fprintf(' >> Only %d reactions of %d are solved (~ %1.2f%%).\n', nR, n, nR * 100 / n);
    end
    n = nR;
else
    if printLevel > 0
        fprintf(' >> All reactions are solved (%d reactions - 100%%).\n', n);
    end
end

% output how many reactions are min, max, or both
totalOptMode = length(find(rxnsOptMode == 0));
if totalOptMode == 1
    if printLevel > 0
        fprintf(' >> %d reaction out of %d is minimized (%1.2f%%).\n', totalOptMode, n, totalOptMode * 100 / n);
    end
else
    if printLevel > 0
        fprintf(' >> %d reactions out of %d are minimized (%1.2f%%).\n', totalOptMode, n, totalOptMode * 100 / n);
    end
end

totalOptMode = length(find(rxnsOptMode == 1));
if totalOptMode == 1
    if printLevel > 0
        fprintf(' >> %d reaction out of %d is maximized (%1.2f%%).\n', totalOptMode, n, totalOptMode * 100 / n);
    end
else
    if printLevel > 0
        fprintf(' >> %d reactions out of %d are maximized (%1.2f%%).\n', totalOptMode, n, totalOptMode * 100 / n);
    end
end

totalOptMode = length(find(rxnsOptMode == 2));
if totalOptMode == 1
    if printLevel > 0
        fprintf(' >> %d reaction out of %d is minimized and maximized (%1.2f%%).\n', totalOptMode, n, totalOptMode * 100 / n);
    end
else
    if printLevel > 0
        fprintf(' >> %d reactions out of %d are minimized and maximized (%1.2f%%).\n', totalOptMode, n, totalOptMode * 100 / n);
    end
end

% count the number of workers
poolobj = gcp('nocreate');  % If no pool, do not create new one.
if isempty(poolobj)
    nworkers = 1;
else
    nworkers = poolobj.NumWorkers;
end

% creates the directory where the log files will be generated
rootDirFastFVA = [CBTDIR filesep 'src' filesep 'analysis' filesep 'FVA' filesep 'fastFVA'];

% define the directory to the logFiles and results directories
logFileDir = [rootDirFastFVA filesep 'logFiles'];

% initialisations
istart(1) = 1;
maxFluxTmp = {};
minFluxTmp = {};

% launch fastFVA on 1 core
if nworkers <= 1

    % define the end of the index vector
    iend(1) = n;

    if ~isempty(rxnsList)
        rxnsKey = find(ismember(model.rxns, rxnsList));
    else
        rxnsKey = (1:n);
    end

    % sequential version
    if printLevel > 0
        fprintf(' \n WARNING: The Sequential Version might take a long time.\n\n');
    end
    if bExtraOutputs1
        [minFlux, maxFlux, optsol, ret, fbasol, fvamin, fvamax, statussolmin, statussolmax] = FVAc(c, A, b, csense, lb, ub, ...
                                                                                                   optPercentage, obj, rxnsKey, ...
                                                                                                   1, cpxControl, valuesCPLEXparams, rxnsOptMode, logFileDir, printLevel);
    elseif bExtraOutputs
        [minFlux, maxFlux, optsol, ret, fbasol, fvamin, fvamax] = FVAc(c, A, b, csense, lb, ub, ...
                                                                       optPercentage, obj, rxnsKey, ...
                                                                       1, cpxControl, valuesCPLEXparams, rxnsOptMode, logFileDir, printLevel);
    else
        [minFlux, maxFlux, optsol, ret] = FVAc(c, A, b, csense, lb, ub, ...
                                               optPercentage, obj, rxnsKey, ...
                                               1, cpxControl, valuesCPLEXparams, rxnsOptMode, logFileDir, printLevel);
    end

    if ret ~= 0 && printLevel > 0
        if printLevel > 0
            fprintf('Unable to complete the FVA, return code=%d\n', ret);
        end
    end

    % output the minimum and maximum fluxes
    minFluxTmp{1} = minFlux;
    maxFluxTmp{1} = maxFlux;

    % output the minimum and maximum flux vectors
    if bExtraOutputs || bExtraOutputs1
        fvaminRes{1} = fvamin;
        fvamaxRes{1} = fvamax;
        fbasolRes{1} = fbasol;
    end

    % output the solver status
    if bExtraOutputs1
        statussolminRes{1} = statussolmin;
        statussolmaxRes{1} = statussolmax;
    end
else
    % divide the reactions amongst workers

    % Note:
    %      The load balancing can be improved for certain problems, e.g. in case
    %      of problems involving E-type matrices, some workers will get mostly
    %      well-behaved LPs while others may get many badly scaled LPs.

    if n > 5000 && loadBalancing == 1
        % primitive load-balancing strategy for large problems
        nworkers = 4 * nworkers;
        if printLevel > 0
            fprintf(' >> The load is balanced and the number of virtual workers is %d.\n', nworkers);
        end
    end

    nrxn = repmat(fix(n / nworkers), nworkers, 1);
    i = 1;
    while sum(nrxn) < n
        nrxn(i) = nrxn(i) + 1;
        i = i + 1;
    end

    [Nmets, Nrxns] = size(A);
    assert(sum(nrxn) == n);
    iend(1) = nrxn(1);
    for i = 2:nworkers
        istart(i) = iend(i - 1) + 1;
        iend(i) = istart(i) + nrxn(i) - 1;
    end

    startMarker1 = istart;
    endMarker1 = iend;

    startMarker2 = istart;
    endMarker2 = iend;

    % calculate the column density and row density
    NrxnsList = length(rxnsList);

    % initialize the column density vector
    cdVect = zeros(NrxnsList, 1);

    for i = 1:NrxnsList
        tmpRxnID = findRxnIDs(model, rxnsList(i));

        columnDensity = nnz(A(:, tmpRxnID));
        columnDensity = columnDensity / Nmets * 100;
        cdVect(i) = columnDensity;
    end

    [~, indexcdVect] = sort(cdVect, 'descend');

    rxnsVect = linspace(1, NrxnsList, NrxnsList);

    sortedrxnsVect = rxnsVect(indexcdVect);

    if strategy > 0
        pRxnsHalfWorker = ceil(NrxnsList / (2 * nworkers));

        for i = 1:nworkers

            startMarker1(i) = (i - 1) * pRxnsHalfWorker + 1;
            endMarker1(i) = i * pRxnsHalfWorker;

            if strategy == 1
                startMarker2(i) = startMarker1(i) + ceil(NrxnsList / 2);
                endMarker2(i) = endMarker1(i) + ceil(NrxnsList / 2);
            elseif strategy == 2
                startMarker2(i) = ceil(NrxnsList / 2) + startMarker1(i);
                endMarker2(i) = startMarker2(i) + pRxnsHalfWorker + 1;
            end

            % avoid start indices beyond the total number of reactions
            if startMarker1(i) > NrxnsList
                startMarker1(i) = NrxnsList;
            end
            if startMarker2(i) > NrxnsList
                startMarker2(i) = NrxnsList;
            end

            % avoid end indices beyond the total number of reactions
            if endMarker1(i) > NrxnsList
                endMarker1(i) = NrxnsList;
            end
            if endMarker2(i) > NrxnsList
                endMarker2(i) = NrxnsList;
            end

            % avoid flipped chunks
            if startMarker1(i) > endMarker1(i)
                startMarker1(i) = endMarker1(i);
            end
            if startMarker2(i) > endMarker2(i)
                startMarker2(i) = endMarker2(i);
            end
        end
    end

    minFlux = zeros(length(model.rxns), 1);
    maxFlux = zeros(length(model.rxns), 1);
    iopt = zeros(nworkers, 1);
    iret = zeros(nworkers, 1);

    % initialize extra outputs
    if bExtraOutputs || bExtraOutputs1
        fvaminRes = {};
        fvamaxRes = {};
        fbasolRes = {};
    end

    if bExtraOutputs1
        statussolminRes = {};
        statussolmaxRes = {};
    end

    if printLevel > 0
        fprintf('\n -- Starting to loop through the %d workers. -- \n', nworkers);
        fprintf('\n -- The splitting strategy is %d. -- \n', strategy);
    end

    out = parfor_progress(nworkers, filenameParfor);

    parfor i = 1:nworkers

        rxnsKey = 0;  % silence warning

        % preparation of reactionKey
        if strategy == 1 || strategy == 2
            rxnsKey = [sortedrxnsVect(startMarker1(i):endMarker1(i)), sortedrxnsVect(startMarker2(i):endMarker2(i))];
        else
            rxnsKey = rxns(istart(i):iend(i));
        end

        t = getCurrentTask();
        if printLevel > 0
            fprintf('\n----------------------------------------------------------------------------------\n');
        end
        if strategy == 0
            if printLevel > 0
                fprintf('--  Task Launched // TaskID: %d / %d (LoopID = %d) <> [%d, %d] / [%d, %d].\n', ...
                    t.ID, nworkers, i, istart(i), iend(i), m, n);
            end
        else
            if printLevel > 0
                fprintf('--  Task Launched // TaskID: %d / %d (LoopID = %d) <> [%d:%d] & [%d:%d] / [%d, %d].\n', ...
                    t.ID, nworkers, i, startMarker1(i), endMarker1(i), ...
                    startMarker2(i), endMarker2(i), m, n);
            end
        end

        tstart = tic;

        minf = zeros(length(model.rxns), 1);
        maxf = zeros(length(model.rxns), 1);
        fvamin_single = 0; fvamax_single = 0; fbasol_single = 0; statussolmin_single = 0; statussolmax_single = 0;  % silence warnings

        if bExtraOutputs1
            [minf, maxf, iopt(i), iret(i), fbasol_single, fvamin_single, fvamax_single, ...
             statussolmin_single, statussolmax_single] = FVAc(model.c, A, b, csense, model.lb, model.ub, ...
                                                              optPercentage, obj, rxnsKey', ...
                                                              t.ID, cpxControl, valuesCPLEXparams, ...
                                                              rxnsOptMode(istart(i):iend(i)), logFileDir, printLevel);
        elseif bExtraOutputs
            [minf, maxf, iopt(i), iret(i), fbasol_single, fvamin_single, fvamax_single] = FVAc(model.c, A, b, csense, ...
                                                                                               model.lb, model.ub, ...
                                                                                               optPercentage, obj, rxnsKey', ...
                                                                                               t.ID, cpxControl, valuesCPLEXparams, ...
                                                                                               rxnsOptMode(istart(i):iend(i)), ...
                                                                                               logFileDir, printLevel);
        else
            if printLevel > 0
                fprintf(' >> Number of reactions given to the worker: %d \n', length(rxnsKey));
            end

            [minf, maxf, iopt(i), iret(i)] = FVAc(model.c, A, b, csense, model.lb, model.ub, ...
                                                  optPercentage, obj, rxnsKey', ...
                                                  t.ID, cpxControl, valuesCPLEXparams, ...
                                                  rxnsOptMode(istart(i):iend(i)), logFileDir, printLevel);
        end
        if printLevel > 0
            fprintf(' >> Time spent in FVAc: %1.1f seconds.', toc(tstart));
        end

        if iret(i) ~= 0 && printLevel > 0
            if printLevel > 0
                fprintf('Problems solving partition %d, return code=%d\n', i, iret(i))
            end
        end

        minFluxTmp{i} = minf;
        maxFluxTmp{i} = maxf;

        if bExtraOutputs || bExtraOutputs1
            fvaminRes{i} = fvamin_single;
            fvamaxRes{i} = fvamax_single;
            fbasolRes{i} = fbasol_single;
        end

        if bExtraOutputs1
            statussolminRes{i} = statussolmin_single;
            statussolmaxRes{i} = statussolmax_single;
        end
        if printLevel > 0
            fprintf('\n----------------------------------------------------------------------------------\n');
        end

        % print out the percentage of the progress
        percout = parfor_progress(-1, filenameParfor);

        if percout < 100
            if printLevel > 0
                fprintf(' ==> %1.1f%% done. Please wait ...\n', percout);
            end
        else
            if printLevel > 0
                fprintf(' ==> 100%% done. Analysis completed.\n', percout);
            end
        end
    end

    % aggregate results
    optsol = iopt(1);
    ret = max(iret);
    out = parfor_progress(0, filenameParfor);
end

% aggregate the results for the maximum and minimum flux vectors
for i = 1:nworkers
    % preparation of reactionKey
    if strategy == 1 || strategy == 2
        indices = [sortedrxnsVect(startMarker1(i):endMarker1(i)), sortedrxnsVect(startMarker2(i):endMarker2(i))];
    else
        indices = rxns(istart(i):iend(i));
    end

    % store the minFlux
    tmp = maxFluxTmp{i};
    maxFlux(indices, 1) = tmp(indices);

    % store the maxFlux
    tmp = minFluxTmp{i};
    minFlux(indices, 1) = tmp(indices);
end

if bExtraOutputs || bExtraOutputs1

    if nworkers > 1
        fbasol = fbasolRes{1};  % initial FBA solutions are identical across workers
    end

    fvamin = zeros(length(model.rxns), length(model.rxns));
    fvamax = zeros(length(model.rxns), length(model.rxns));

    if nworkers > 1
        if bExtraOutputs1
            statussolmin = -1 + zeros(length(model.rxns), 1);
            statussolmax = -1 + zeros(length(model.rxns), 1);
        end
    end

    for i = 1:nworkers
        % preparation of reactionKey
        if strategy == 1 || strategy == 2
            indices = [sortedrxnsVect(startMarker1(i):endMarker1(i)), sortedrxnsVect(startMarker2(i):endMarker2(i))];
        else
            indices = rxns(istart(i):iend(i));
        end

        fvamin(:, indices) = fvaminRes{i};
        fvamax(:, indices) = fvamaxRes{i};

        if bExtraOutputs1
            tmp = statussolminRes{i}';
            statussolmin(indices, 1) = tmp(indices);
            tmp = statussolmaxRes{i}';
            statussolmax(indices, 1) = tmp(indices);
        end
    end
end

if strategy == 0 && ~isempty(rxnsList)
    if bExtraOutputs || bExtraOutputs1
        fvamin = fvamin(:, rxns);  % keep only nonzero columns
        fvamax = fvamax(:, rxns);
    end

    if bExtraOutputs1
        statussolmin = statussolmin(rxns);
        statussolmax = statussolmax(rxns);
    end

    minFlux(find(~ismember(model.rxns, rxnsList))) = [];
    maxFlux(find(~ismember(model.rxns, rxnsList))) = [];
end

% restore the original path
path(originalUserPath);
addpath(originalUserPath);

% change back to the original directory
cd(currentDir);


function checkFastFVAbin(cplexVersion)
% determine the version of the CPLEX binaries by
% browsing to the folder with the binaries and the .tmp folder (if it exists)
% and retrieve all versions
%
% USAGE:
%    checkFastFVAbin(cplexVersion)
%
% INPUT:
%    cplexVersion:    CPLEX version (string), obtained using `getCobraSolverVersion`
%

global CBTDIR

% retrieve the contents of the binary directory (architecture dependent)
d1 = dir([CBTDIR filesep 'binary' filesep computer('arch') filesep 'bin' filesep 'fastFVA']);

% include CPLEX binaries that already have been generated using generateMexFastFVA
tmpDir = [CBTDIR filesep '.tmp'];
d2 = dir(tmpDir);

% create .tmp if not already present
if ~exist(tmpDir, 'dir')
    mkdir(tmpDir);
end

% concatenate both directories
d = {d1; d2};

for p = 1:length(d)
    tmpD = d{p};
    k = 1;
    for i = 1:numel(tmpD)
        if ~strcmpi(tmpD(i).name, '.') && ~strcmpi(tmpD(i).name, '..') && isempty(strfind(tmpD(i).name, '.txt')) && ~isempty(strfind(tmpD(i).name, 'cplexFVA'))
            tmpName = tmpD(i).name;
            tmpNameSplit = strsplit(tmpName, '.');
            tmpName = tmpNameSplit{1};
            binVersion{k} = tmpName(9:end);  % index 9 is equivalent to the number of characters of cplexFVA
            k = k + 1;
        end
    end
end

for k = 1:length(binVersion)
    throwBinGenerationError = false;
    if ~strcmpi(cplexVersion, binVersion)
        throwBinGenerationError = true;
        kp = k;
    end
end

if throwBinGenerationError
    error(['Official binaries are only available for CPLEX version ', binVersion{kp}, '. ', ...
            'You have installed version ', cplexVersion, '. Please run: ', ...
            '>> generateMexFastFVA() in order to generate a new binary file.']);
end
