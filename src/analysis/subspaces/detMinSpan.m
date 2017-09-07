function [finalVectors] = detMinSpan(model, params, vectors)
% Calculates the MinSpan vectors for a COBRA model. The
% algorithm determines a set of linearly independent basis vectors that
% span the nullspace that meet the criteria of the flux bounds of the
% network and minimizes the number of reactions used. The algorithm
% operates in an interative manner and checkes for convergence after each
% iteration. Parameters may be provided to skip convergence and terminate
% the problem when models are large. See Bordbar et al. Mol Syst Biol 2014
% for more details. This algorithm has only been tested and requires Gurobi
% as MILP solver.
%
% INPUTS:
%    model:             COBRA model structure (requires S, lb, ub)
%                       Note: MinSpan calculations are done w/o biomass
%                       reaction and all reactions must be able to carry a
%                       flux = 0 for the trivial solution to be feasible.
%                       model is auto corrected by bounds but biomass
%                       must be removed manually
%
% OPTIONAL INPUTS:
%    params:            Optional parameters to calculate MinSpan.
%                       Determining the MinSpan is a NP hard calculation.
%                       For large models, the algorithm may not converge
%                       and parameters must be provided to stop the
%                       algorithm to provide an approximate solution.
%
%                       * .coverage - Number of iterations to run the algorithm, if not
%                       converge (Default = 10)
%                       * .timeLimit - Time to spend on each MinSpan calculation (sec),
%                       (Default = 30)
%                       * .saveIntV - Save intermediate vectors in order to restart from
%                       latest iteration (Default = 0)
%                       * .cores - Number of cores to use (Default = 1)
%
%    vectors:           Set of intermediate MinSpan vectors that may
%                       have not yet reached convergence, allowing to
%                       pickup calculation from last spot.
%
% OUTPUTS:
%    finalVectors:      MinSpan vectors for COBRA model
%
% .. Author: Aarash Bordbar 05/15/2017
%            Ronan Fleming, nullspace computation with LUSOL

global CBT_MILP_SOLVER
global CBT_LP_SOLVER
global CBT_QP_SOLVER

if ~strcmp(CBT_MILP_SOLVER, 'gurobi') || ~strcmp(CBT_LP_SOLVER, 'gurobi') || ~strcmp(CBT_QP_SOLVER, 'gurobi')
    error('detMinSpan only runs with Gurobi.\nTry to run `changeCobraSolver(''gurobi'', ''MILP'')` to use Gurobi.');
end

% Ensure model has correct bounds
origModel = model;
model.lb(model.lb < 0) = -1000;
model.ub(model.ub > 0) = 1000;
model.lb(model.lb > 0) = 0;
model.ub(model.ub < 0) = 0;

% Reduce model to just reactions that can carry a flux
[minF, maxF] = fluxVariability(model, 0);
minF(abs(minF) < 1e-8) = 0;
maxF(abs(maxF) < 1e-8) = 0;
remRxns = model.rxns(minF == 0 & maxF == 0);
model = removeRxns(model, remRxns);

% Setup MILP and solving parameters
if ~exist('params', 'var')
    params.coverage = 10;
    params.timeLimit = 30;
    params.saveIntV = 0;
    params.cores = 1;
    params.nullAlg = 'matlab';
else
    if ~isfield(params, 'coverage')
        params.coverage = 10;
    end
    if ~isfield(params, 'timeLimit')
        params.timeLimit = 30;
    end
    if ~isfield(params, 'saveIntV')
        params.saveIntV = 1;
    end
    if ~isfield(params, 'cores')
        params.cores = 1;
    end
    if ~isfield(params, 'nullAlg')
        params.nullAlg = 'matlab';
    end
end

MILPparams.TimeLimit = params.timeLimit;
MILPparams.outputFlag = 1;
MILPparams.Presolve = 2;
MILPparams.Threads = params.cores;
MILPparams.DisplayInterval = 10;

if ~exist('vectors', 'var')
    if strcmp('params.nullAlg','lusol')
        error('nearly but not quite implemented yet')
        [vectors, ~] = getNullSpace(model.S, 0);
    else
        vectors = null(full(model.S));
    end
end

% Prepratory steps for MinSpan determination
rng('shuffle');

if strcmp('params.nullAlg','lusol')
    [N, ~] = getNullSpace(S, 0);
else
    N = null(full(model.S));
end

[m, n] = size(model.S);

locRev = find(model.lb < 0);
lengthRev = length(locRev);
revConstraintMat = zeros(lengthRev, n);
for i = 1:lengthRev
    revConstraintMat(i, locRev(i)) = 1;
end

% Run MinSpan
tmpNvProd = [];
totalNNZ = [];
for k = 1:params.coverage

    numToCheck = randperm(size(N, 2));
    prevNNZ = nnz(vectors);

    for i = 1:length(numToCheck)
        tic;
        oldPath = vectors(:, numToCheck(i));
        pathLength = nnz(vectors(:, numToCheck(i)));
        vectors(:, numToCheck(i)) = zeros(n, 1);

        sizeN = 1;
        theta = N \ vectors;

        if strcmp('params.nullAlg','lusol')
            [Z, ~] = getNullSpace(theta', 0);
            tmpN = sparse(N * Z);
        else
            tmpN = sparse(N * null(theta'));
        end

        tmptmpNprod = tmpN' * oldPath;
        tmpN = tmpN * (1 / tmptmpNprod);

        % Model Formulation: A, b, csense, lb, ub, vartype, c
        MILPproblem.A = [model.S, sparse(m, n + 2 * sizeN);  % S. v = 0
                         revConstraintMat, 1e4 * revConstraintMat, sparse(lengthRev, 2 * sizeN);  % v >= -10000*b
                         speye(n), -1e4 * speye(n), sparse(n, 2 * sizeN);  % v <= 10000*b
                         tmpN', sparse(sizeN, n), (-1001) * speye(sizeN), sparse(sizeN, sizeN);  % N.v >= 1001*fi+ - 1000
                         -tmpN', sparse(sizeN, n), sparse(sizeN, sizeN), (-1001) * speye(sizeN);  % -N.v >= 1001*fi- - 1000
                         sparse(1, 2 * n), ones(1, 2 * sizeN);  % sum(fi+, fi-) >= 1
                         ];

        MILPproblem.b = [zeros(m, 1);  % S. v = 0
                         zeros(lengthRev, 1);  % v >= -10000*b
                         zeros(n, 1);  % v <= 10000*b
                         -1000 * ones(sizeN, 1);  % N.v >= 1000*fi+ - 1000
                         -1000 * ones(sizeN, 1);  % -N.v >= 1000*fi+ - 1000
                         1  % sum(vi+, vi-) >= 1
                         ];

        MILPproblem.csense = '';
        for l = 1:m
            MILPproblem.csense(end + 1, 1) = 'E';  % S.v = 0
        end
        for l = 1:lengthRev
            MILPproblem.csense(end + 1, 1) = 'G';  % v >= -10000*b
        end
        for l = 1:n
            MILPproblem.csense(end + 1, 1) = 'L';  % v <= 10000*b
        end
        for l = 1:sizeN
            MILPproblem.csense(end + 1, 1) = 'G';  % N.v >= 1000*fi+ - 1000
        end
        for l = 1:sizeN
            MILPproblem.csense(end + 1, 1) = 'G';  % -N.v >= 1000*fi+ - 1000
        end
        MILPproblem.csense(end + 1, 1) = 'G';  % sum(vi+, vi-) > 1

        MILPproblem.lb = [model.lb;  % v
                          zeros(n, 1);  % a
                          zeros(2 * sizeN, 1)];  % fi+, fi-

        MILPproblem.ub = [model.ub;  % v
                          ones(n, 1);  % a
                          ones(2 * sizeN, 1)];  % k+, k-

        MILPproblem.vartype = '';
        for l = 1:n
            MILPproblem.vartype(end + 1, 1) = 'C';  % v
        end
        for l = 1:n
            MILPproblem.vartype(end + 1, 1) = 'B';  % b
        end
        for l = 1:2 * sizeN
            MILPproblem.vartype(end + 1, 1) = 'B';  % fi+, fi-
        end

        MILPproblem.c = [zeros(n, 1);  % v
                         ones(n, 1);  % b
                         zeros(2 * sizeN, 1);  % fi+, fi-
                         ];

        MILPproblem.osense = 1;  % minimize

        % Setup initial solution
        binOldPath = zeros(length(oldPath), 1);
        binOldPath(find(oldPath)) = 1;
        MILPproblem.x0 = [oldPath; binOldPath; 1e101; 1e101];

        MILPsolution = solveCobraMILP(MILPproblem, MILPparams);

        % Check solution
        % If unable to find solution, break iteration
        if length(MILPsolution.cont) < n
            break
        end

        % If solution found, normalize and replace vector in intermediate
        % matrix
        vector = MILPsolution.full(1:n);
        vector(abs(vector) < 1e-6) = 0;

        if strcmp('params.nullAlg','lusol')
            [Z, ~] = getNullSpace((N \ [vectors, vector])', 0);
            tmpNullCheck = N * Z;
        else
            tmpNullCheck = N * null((N \ [vectors, vector])');
        end

        if nnz(vector) > 0 && isempty(tmpNullCheck)
            vector = vector / norm(vector);
            vectors(:, numToCheck(i)) = vector;
        else
            vectors(:, numToCheck(i)) = oldPath;
            vector = oldPath;
        end
        tmpNvProd = [tmpNvProd; tmpN' * vector];
        totalNNZ = [totalNNZ; nnz(vectors)];

        time(i, 1) = toc;

        % Save intermediate matrices (within iteration)
        if params.saveIntV == 1
            filename = strcat('save_', num2str(k), '_', num2str(i));
            save(filename, 'MILPproblem', 'MILPsolution', 'vectors', ...
                 'time', 'tmpNvProd', 'totalNNZ', 'numToCheck');
        end

        clear mex
    end

    newNum = nnz(vectors);

    % Save intermediate matrices (after a completed iteration)
    if params.saveIntV == 1
        filename = strcat('save_finalround_', num2str(k));
        save(filename, 'vectors', 'time');
    end

    % If MinSpan solution has converged (same NNZ as previous iteration)
    if newNum == prevNNZ
        break
    end
end

clear x
for i = 1:size(vectors, 2)
    x(i, 1) = nnz(vectors(:, i));
end

completedPaths = find(x < n & x > 0);
vectors = vectors(:, completedPaths);

% Normalize vectors such that smallest flux value in vector is 1
for i = 1:size(vectors, 2)
    loc = find(vectors(:, i));
    tmp = min(abs(vectors(loc, i)));
    vectors(:, i) = vectors(:, i) / tmp;
end

% Cast vectors from reduce model size to full model size
finalVectors = zeros(length(origModel.rxns), size(vectors, 2));
loc = find(ismember(origModel.rxns, model.rxns));
for i = 1:size(vectors, 2)
    finalVectors(loc, i) = vectors(:, i);
end
