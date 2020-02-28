function [solution, all_obj] = runLPvariousSolvers(model, solverPkgs, params)
% tests the output from different LP solverPkgs to see if they are consistent
%
% INPUT:
%
% model:         COBRA model to test
% solverPkgs:    list of LP solver packages
% params:        additional solver parameters
%
% OUTPUT:
%
% solution:      solution object with solution information
% all_obj:       vector with the various objective values determined by the solvers in solverPkgs
%
% AUTHORS:
%     Ronan Fleming 18/11/2014 First version

%save the current solver
global CBT_LP_SOLVER
currentSolver = CBT_LP_SOLVER;

% model.A assumed to be matrix with coupling constraints
if ~isfield(model, 'A')
    model.A = model.S;
end
model.lb = double(full(model.lb));
model.ub = double(full(model.ub));
model.c = double(full(model.c));
model.osense = -1;
[m, n] = size(model.S);
if isfield(model, 'csense')
    model.csense = model.csense(:);
else
    model.csense(1:m, 1) = 'E';
end

% print size of model
try
    [m, n] = size(model.S);
catch
    [m, n] = size(model.A);
end

fprintf(['\nTesting model with linear constraint matrix that has ' num2str(m) ' rows and ' num2str(n) ' columns...\n']);

i = 1;
for k = 1:length(solverPkgs)
    solver = solverPkgs{k};

    fprintf('   Testing testDifferentLPSolvers using %s ... ', solverPkgs{k});

    if strcmp(solver, 'opti') && ispc
        % clp
        if exist('opts', 'var')
            clear opts
        end
        solverOK = changeCobraSolver(solver, 'LP', 0);
        opts.solver = 'clp';
        opts.tolrfun = 1e-9;
        opts.tolafun = 1e-9;
        opts.display = 'iter';
        opts.warnings = 'all';
        solution{i} = solveCobraLP(model, opts);
        i = i + 1;

        % clp:barrier
        if exist('opts', 'var')
            clear opts
        end
        solverOK = changeCobraSolver(solver, 'LP', 0);
        opts.solver = 'clp';
        opts.tolrfun = 1e-9;
        opts.tolafun = 1e-9;
        opts.display = 'iter';
        opts.warnings = 'all';
        opts.algorithm = 'barrier';
        solution{i} = solveCobraLP(model, opts);
        i = i + 1;

        % note that scip does not return the dual solution
        if exist('opts', 'var')
            clear opts
        end
        solverOK = changeCobraSolver(solver, 'LP', 0);
        opts.solver = 'scip';
        solution{i} = solveCobraLP(model, 'printLevel', 3, ...
                                   'optTol', 1e-9, ...
                                   opts);
        i = i + 1;

        if exist('opts', 'var')
            clear opts
        end
        solverOK = changeCobraSolver(solver, 'LP', 0);
        opts.solver = 'auto';
        opts.algorithm = 'automatic';
        solution{i} = solveCobraLP(model, 'printLevel', 3, ...
                                   'optTol', 1e-9, ...
                                   opts);
        i = i + 1;

        if exist('opts', 'var')
            clear opts
        end
        solverOK = changeCobraSolver(solver, 'LP', 0);
        opts.solver = 'auto';
        solution{i} = solveCobraLP(model, 'printLevel', 3, ...
                                   'optTol', 1e-9, ...
                                   opts);
        i = i + 1;
    end

    if strcmp(solver, 'dqqMinos') || strcmp(solver, 'quadMinos')
        if isunix
            [stat, res] = system('which csh');
            if ~isempty(res) && stat == 0
                solverOK = changeCobraSolver(solver, 'LP', 0);
                if solverOK
                    if strcmp(solver, 'dqqMinos')
                        param.Method = 1;
                        solution{i} = solveCobraLP(model, param);
                        clear param
                    elseif strcmp(solver, 'quadMinos')
                        solution{i} = solveCobraLP(model);
                    end
                    i = i + 1;
                end
            else
                warning(['You must have `csh` installed. Solver ', solver, ' cannot be tested.']);
            end
        end
    end

    if strcmp(solver, 'gurobi')

        % by default, the check for stoichiometric consistency omits the columns of S corresponding to exchange reactions
        solverOK = changeCobraSolver(solver, 'LP', 0);

        if solverOK
            for method = 1:4
                param.Method = method;
                solution{i} = solveCobraLP(model, param);
                i = i + 1;
                clear param
            end
        end
    end

    if strcmp(solver, 'mosek')

        % by default, the check for stoichiometric consistency omits the columns of S corresponding to exchange reactions
        solverOK = changeCobraSolver(solver, 'LP', 0);

        mskIPARoptimizers = {'MSK_OPTIMIZER_PRIMAL_SIMPLEX', 'MSK_OPTIMIZER_DUAL_SIMPLEX', 'MSK_OPTIMIZER_INTPNT'};

        if solverOK
            for p = 1:length(mskIPARoptimizers)
                param.MSK_IPAR_OPTIMIZER = mskIPARoptimizers{p};
                solution{i} = solveCobraLP(model, param);
                i = i + 1;
                clear param
            end
        end
    end

    if strcmp(solver, 'ibm_cplex')

        % ILOGcplex.param.lpmethod.Cur
        % Determines which algorithm is used. Currently, the behavior of the Automatic setting is that CPLEX almost
        % always invokes the dual simplex method. The one exception is when solving the relaxation of an MILP model
        % when multiple threads have been requested. In this case, the Automatic setting will use the concurrent optimization
        % method. The Automatic setting may be expanded in the future so that CPLEX chooses the method
        % based on additional problem characteristics.
        %  0 Automatic (default)
        % 1 Primal Simplex
        % 2 Dual Simplex
        % 3 Network Simplex (Does not work for almost all stoichiometric matrices)
        % 4 Barrier (Interior point method)
        % 5 Sifting
        % 6 Concurrent Dual, Barrier and Primal
        solverOK = changeCobraSolver(solver, 'LP', 0);

        if solverOK
            % test solveCobraLPCPLEX
            solution{i} = solveCobraLPCPLEX(model, 0, [], [], [], [], 'ILOGsimple');
            solution{i}.solver = solver;
            solution{i}.algorithm = 'default';
            i = i + 1;

            % test solveCobraLP
            for c = 0:6
                if c ~= 3
                    param.lpmethod.Cur = c;
                    solution{i} = solveCobraLP(model, param);
                    i = i + 1;
                    clear param
                end
            end
        end
    end

    if strcmp(solver, 'pdco')
        solverOK = changeCobraSolver(solver, 'LP', 0);
        if solverOK
            solution{i} = solveCobraLP(model, 'feasTol', params.feasTol, ...
                                       'pdco_method', params.pdco_method, ...
                                       'pdco_maxiter', params.pdco_maxiter, ...
                                       'pdco_xsize', params.pdco_xsize, ...
                                       'pdco_zsize', params.pdco_zsize);
            i = i + 1;
        end
    end

    if strcmp(solver, 'cplex_direct') || strcmp(solver, 'glpk') || strcmp(solver, 'matlab') || strcmp(solver, 'tomlab_cplex')
        solverOK = changeCobraSolver(solver, 'LP', 0);
        if solverOK
            solution{i} = solveCobraLP(model);
            i = i + 1;
        end
    end

    % solver with Windows-only compatibility
    if ispc && strcmp(solver, 'lp_solve')
        solverOK = changeCobraSolver(solver, 'LP', 0);
        if solverOK
            solution{i} = solveCobraLP(model);
            i = i + 1;
        end
    end

    % legacy interfaces
    if strcmp(solver, 'mosek_linprog')
        % test if mosek is installed
        solverOK = changeCobraSolver('mosek', 'LP', 0);
        if solverOK
            solution{i} = solveCobraLP(model, 'solver', 'mosek_linprog');
            i = i + 1;
        end
    end

    fprintf('Done.\n');
end

% change back to the old solver
fprintf('\n Summary:\n');
% compare solutions
ilt = i - 1;
fprintf('%3s%15s%15s%15s%15s%20s\t%30s\n', '   ', 'time', 'obj', 'y(rand)', 'w(rand)', 'solver', 'algorithm')

testIndex = 'max';
% remove empty entries
solution(~cellfun('isempty', solution));

switch testIndex
    case 'max'
        % pick a large entry in each dual vector, to check the signs
        randrcost = find(max(solution{1}.rcost) == solution{1}.rcost);
        if ~isempty(randrcost)
            randrcost = randrcost(1);
        end
        randdual = find(max(solution{1}.dual) == solution{1}.dual);
        if ~isempty(randdual)
            randdual = randdual(1);
        end

    case 'min'
        % pick a small entry in each dual vector, to check the signs
        randrcost = find(min(solution{1}.rcost) == solution{1}.rcost);
        if ~isempty(randrcost)
            randrcost = randrcost(1);
        end
        randdual = find(min(solution{1}.dual) == solution{1}.dual);
        if ~isempty(randdual)
            randdual = randdual(1);
        end

    case 'rand'
        % pick a random entry in each dual vector, to check the signs
        randrcost = ceil(rand * n);
        if ~isempty(randrcost)
            randrcost = randrcost(1);
        end
        randdual = ceil(rand * m);
        if ~isempty(randdual)
            randdual = randdual(1);
        end
end

for i = 1:ilt
    if isfield(solution{1}, 'stat') && solution{1}.stat == 1
        if isempty(solution{i}.dual)
            tmp_dual = NaN;
        else
            tmp_dual = solution{i}.dual(randdual);
        end

        if isempty(solution{i}.rcost)
            tmp_rcost = NaN;
        else
            tmp_rcost = solution{i}.rcost(randrcost);
        end
        fprintf('%3d%15f%15f%15f%15f%20s\t%30s\n', i, solution{i}.time, solution{i}.obj, tmp_dual, tmp_rcost, solution{i}.solver, solution{i}.algorithm)
        all_obj(i) = solution{i}.obj;
    else
        fprintf('%3d%15f%15f%15f%15f%20s\t%30s\n', i, solution{i}.time, solution{i}.obj, NaN, NaN, solution{i}.solver, solution{i}.algorithm)
        all_obj(i) = 0.0;
    end
end

%change back to original solver
solverOK = changeCobraSolver(currentSolver, 'LP', 0);

end