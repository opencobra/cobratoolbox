function cpxControl=CPLEXParamSet
%this is a function which returns user specified CPLEX control
%parameters. It is not necessary to use a file like this if you want to use
%CPLEX default control parameters. It is intended to be a template for
%individual users to save with their own problem specific settings for 
%CPLEX.

% %e.g. 
% (1) Paddy saves this file as CPLEXParamSetPaddyLPJob1
% (2) Paddy edits CPLEXParamSetPaddyLPJob1 in a problem specific way
% (3) Paddy then passes the name of this file to solveCobraLP_CPLEX using something like:
%     [solution,LPProblem]=solveCobraLP_CPLEX(LPProblem,[],[],[],'CPLEXParamSetPaddyLPJob1');

% CPLEX consists of 4 different LP solvers which can be used to solve sysbio LP problems
% you can control which of the solvers, e.g. simplex or interior point solve using the 
% CPLEX control parameter cpxControl.LPMETHOD

%Ronan Fleming 10th June 2008
    
%SELECT CPLEX CONTROL PARAMETERS (alphabetical order)
% Description: Preprocessing aggregator application limit. Invokes the aggregator to use substitution where
% possible to reduce the number of rows and columns before the problem is solved. If set to a positive value, the
% aggregator is applied the specified number of times or until no more reductions are possible.
% -1 Automatic
% 0  Do not use any aggregator
% 1  Use aggregator
% Default: -1
cpxControl.AGGIND=-1;

%Description: Barrier column nonzeros.
% Used in the recognition of dense columns. If columns in the presolved and aggregated problem exist with more
% entries than this value, such columns are considered dense and are treated specially by the CPLEX Barrier
% Optimizer to reduce their effect. If the problem contains fewer than 400 rows, dense column handling is NOT
% initiated.
cpxControl.BARCOLNZ=0;

% Convergence tolerance for LP and QP problems.
% Sets the tolerance on complementarity for convergence.
% The barrier algorithm terminates with an optimal solution if the relative complementarity is
% smaller than this value. Changing this tolerance to a smaller value may result in greater numerical precision
% of the solution, but also increases the chance of a convergence failure in the algorithm and consequently may
% result in no solution at all. Therefore, caution is advised in deviating from the default setting.
%Any positive number >= 1e?12
%Default: 1e?8
cpxControl.BAREPCOMP=1e-8;

% Barrier iteration limit.
% Sets the number of Barrier iterations before termination. When set to 0, no Barrier iterations occur, but problem
% �setup� occurs and information about the setup is displayed (such as Cholesky factorization information).
% 0 No Barrier iterations
% or, any positive integer
% Default: Large (varies by computer)
cpxControl.BARITLIM=2000; %%%

% Barrier maximum correction limit.
% Sets the maximum number of centering corrections done on each iteration. An explicit value greater than 0
% may improve the numerical performance of the algorithm at the expense of computation time.
% -1 Automatically determined
% 0 None
% or, any positive integer
cpxControl.BARMAXCOR=-1;

% Barrier objective range.
% Sets the maximum absolute value of the objective function. The barrier algorithm looks at this limit to detect
% unbounded problems.
%Any positive number default 1e21
cpxControl.BAROBJRNG=1e21;

% Coefficient reduction setting.
% Determines how coefficient reduction is used. Coefficient reduction improves the objective value of the initial
% (and subsequent) LP relaxations solved during branch & cut by reducing the number of non-integral vertices.
%  0 Do not use coefficient reduction
% 1 Reduce only to integral coefficients
% 2 Reduce all potential coefficients
% Default: 2
cpxControl.COEREDIND=2;

% Lower cutoff.
% When the problem is a maximization problem, the LOWERCUTOFF parameter is used to cut off any nodes
% that have an objective value below the lower cutoff value. On a continued mixed integer optimization, the
% larger of these values and the updated cutoff found during optimization are used during the next mixed integer
% optimization. A too-restrictive value for the LOWERCUTOFF parameter may result in no integer solutions
% being found.
cpxControl.CUTLO=-1e76;

% Data consistency checking indicator.
% When set to 1 (On), extensive checking is performed on data in the array arguments, such as checking that
% indices are within range, that there are no duplicate entries and that values are valid for the type of data or are
% valid numbers. This is useful for debugging applications.
% default =1
cpxControl.DATACHECK=1;  %%%%


% Description: Markowitz tolerance.
% Influences pivot selection during basis factorization. Increasing the Markowitz threshold may improve the
% numerical properties of the solution.
% Any number from 0.0001 to 0.99999
% Default: 0.01
cpxControl.EPMRK =0.01;

% Optimality tolerance.
% Influences the reduced-cost tolerance for optimality. This parameter governs how closely CPLEX must approach
% the theoretically optimal solution.
% Any number from 10?9 to 10?1
% Default: 10^-6
cpxControl.EPOPT=1e-6;

% Perturbation constant.
% Sets the amount by which CPLEX perturbs the upper and lower bounds on the variables when a problem is
% perturbed. This parameter can be set to a smaller value if the default value creates too large a change in the
% problem.
% Any positive number  10?8
% Default: 10?6
cpxControl.EPPER=1e-6;

% FeasOpt tolerance.
% Sets epsilon used to measure relaxation in FeasOpt.
% Any positive number
cpxControl.EPRELAX=1e-6;

% Feasibility tolerance.
% The feasibility tolerance specifies the degree to which a problem�s basic variables may violate their bounds.
% FEASIBILITY influences the selection of an optimal basis and can be reset to a higher value when a problem
% is having difficulty maintaining feasibility during optimization. You may also wish to lower this tolerance after
% finding an optimal solution if there is any doubt that the solution is truly optimal. If the feasibility tolerance is
% set too low, CPLEX may falsely conclude that a problem is infeasible. If you encounter reports of infeasibility
% during Phase II of the optimization, a small adjustment in the feasibility tolerance may improve performance.
% Any number from 10?9 to 10?1
% Default: 10?6
cpxControl.EPRHS=1e-6;

%FeasOpt settings.
% FeasOpt works in two phases. In its first phase, it attempts to minimize its relaxation of the infeasible model.
% That is, it attempts to find a feasible solution that requires minimal change. In its second phase, it finds an
% optimal solution among those that require only as much relaxation as it found necessary in the first phase.
% 0 Minimize the sum of all required relaxations
%   in first phase only
% 1 Minimize the sum of all required relaxations
%   in first phase and execute second phase to
%   find optimum among minimal relaxations
% 2 Minimize the number of constraints and
%   bounds requiring relaxation in first phase
%   only
% 3 Minimize the number of constraints and
%   bounds requiring relaxation in first phase and
%   execute second phase to find optimum among
%   minimal relaxations
% 4 Minimize the sum of squares of required
%   relaxations in first phase only
% 5 Minimize the sum of squares of required
%   relaxations in first phase and execute second
%   phase to find optimum among minimal relaxations
% Default: 0
cpxControl.FEASOPTMODE=0;

% Simplex maximum iteration limit.
% Sets the maximum number of iterations to be performed before the algorithm terminates without reaching
% optimality.
% default = Large e.g. 5000
cpxControl.ITLIM=5000; %%%Changed

% Method for linear optimization.
% Determines which algorithm is used. Currently, the behavior of the Automatic setting is that CPLEX almost
% always invokes the dual simplex method. The one exception is when solving the relaxation of an MILP model
% when multiple threads have been requested. In this case, the Automatic setting will use the concurrent optimization
% method. The Automatic setting may be expanded in the future so that CPLEX chooses the method
% based on additional problem characteristics.
%  0 Automatic
% 1 Primal Simplex
% 2 Dual Simplex
% 3 Network Simplex (Does not work for almost all stoichiometric matrices)
% 4 Barrier (Interior point method)
% 5 Sifting
% 6 Concurrent Dual, Barrier and Primal
% Default: 0
cpxControl.LPMETHOD=0;  %%% was changed now default

% Numerical emphasis.
%  0 Off: Do not emphasize extreme caution in
% computation
% 1 On: Emphasize extreme caution in computation
% Default: Off
cpxControl.NUMERICALEMPHASIS=0; %%%


% Polishing best solution.
% Regulates the amount of time spent on polishing the best solution found. During solution polishing, CPLEX
% applies its effort to improve the best feasible solution. Polishing can yield better solutions in some situations.
% The default value of the polishing time parameter is 0 (zero); that is, spend no time polishing.
% Any positive number in seconds
% Default: 0
cpxControl.POLISHTIME=0; %%% Changed

% Scale parameter.
% Sets the method to be used for scaling the problem matrix.
% -1 No scaling
% 0 Equilibrium scaling method
% 1 More aggressive scaling
% Default: 0
cpxControl.SCAIND=0; %%%

% Simplex iteration display information.
% Determines how often CPLEX reports during simplex optimization.
% 0 No iteration messages until solution
% 1 Iteration info after each refactorization
% 2 Iteration info for each iteration
% Default: 1
cpxControl.SIMDISPLAY=1; %%%

% Computation time reporting.
% Determines how computation times are measured.
% 1 CPU time
% 2 Wall clock time (total physical time elapsed)
% Default: 1
cpxControl.CLOCKTYPE=1; %Changed

% Global time limit.
% Sets the maximum time, in seconds, for computations before termination, as measured according to the setting
% of the CLOCKTYPE parameter. The time limit applies to primal simplex, dual simplex, barrier, and mixed
% integer optimizations, as well as infeasibility finder computations. (Network simplex and barrier crossover
% operations are exceptions; these processes do not terminate if the time limit is exceeded.) The time limit
% includes preprocessing time. For �hybrid� optimizations (such as network optimization followed by dual or
% primal simplex, barrier optimization followed by crossover), the
% cumulative time applies.
cpxControl.TILIM=600;%sec

