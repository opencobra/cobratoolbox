function cpxControl = CPLEXParamSet
%this is a function which returns user specified CPLEX control
%parameters. It is not necessary to use a file like this if you want to use
%CPLEX default control parameters. It is intended to be a template for
%individual users to save with their own problem specific settings for
%CPLEX.

% %e.g.
% (1) Paddy saves this file as CPLEXParamSetPaddyLPJob1
% (2) Paddy edits CPLEXParamSetPaddyLPJob1 in a problem specific way
% (3) Paddy then passes the name of this file to solveCobraLP_CPLEX using something like:
%     [solution,LPProblem] = solveCobraLP_CPLEX(LPProblem,[],[],[],'CPLEXParamSetPaddyLPJob1');

% CPLEX consists of 4 different LP solvers which can be used to solve sysbio LP problems
% you can control which of the solvers, e.g. simplex or interior point solve using the
% CPLEX control parameter cpxControl.LPMETHOD

% Ronan Fleming 10th June 2008
% Laurent Heirendt, April 2016
% =========================================================================================================

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
cpxControl.LPMETHOD = 0;  %%% was changed now default

% Parallel mode switch
% Sets the parallel optimization mode. Possible modes are automatic, deterministic, and opportunistic.
% -1 Opportunistic
% 0 AutoParallel
% 1 Deterministic
cpxControl.PARALLELMODE = 1;

%{
  Best performance for running on 4core/2threads server rack:

  CPX_PARAM_PARALLELMODE = 1
  CPX_PARAM_THREADS = 1
  CPX_PARAM_AUXROOTTHREADS = 2
%}

% Global Default Thread Count
% Sets the default maximal number of parallel threads that will be invoked by any CPLEX parallel optimizer.
% 0 	Automatic: let CPLEX decide; default
% 1 	Sequential; single threaded
% N 	Uses up to N threads; N is limited by available processors and Processor Value Units (PVU).
cpxControl.THREADS = 1;

% Auxiliary Root Threads
% Partitions the number of threads for CPLEX to use for auxiliary tasks while it solves the root node of a problem.
% On a system that offers N processors or N global threads, if you set this parameter to n, where
% N > n > 0
% -1 	Off: do not use additional threads for auxiliary tasks.
% 0 	Automatic: let CPLEX choose the number of threads to use; default
% N > n > 0 	Use n threads for auxiliary root tasks
cpxControl.AUXROOTTHREADS = 2;

% Reduces use of memory
% Directs CPLEX that it should conserve memory where possible. When you set this parameter to its nondefault value, CPLEX will choose tactics, such as data compression or disk storage, for some of the data computed by the simplex, barrier, and MIP optimizers. Of course, conserving memory may impact performance in some models. Also, while solution information will be available after optimization, certain computations that require a basis that has been factored (for example, for the computation of the condition number Kappa) may be unavailable.
%cpxControl.MEMORYEMPHASIS = 0;

% advanced start switch
% If set to 1 or 2, this parameter specifies that CPLEX should use advanced starting information when it initiates optimization.
% 0 	Do not use advanced start information
% 1 	Use an advanced basis supplied by the user; default
% 2 	Crush an advanced basis or starting vector supplied by the user
cpxControl.ADVIND = 2;

% Manual control of presolve
% primal and dual reduction type
% Specifies whether primal reductions, dual reductions, both, or neither are performed during preprocessing.
% 0 	CPX_PREREDUCE_NOPRIMALORDUAL 	No primal or dual reductions
% 1 	CPX_PREREDUCE_PRIMALONLY 	Only primal reductions
% 2 	CPX_PREREDUCE_DUALONLY 	Only dual reductions
% 3 	CPX_PREREDUCE_PRIMALANDDUAL 	Both primal and dual reductions; default
%cpxControl.REDUCE = 3;

% Node Presolve Switch
% Decides whether node presolve should be performed at the nodes of a mixed integer programming (MIP) solution.
% -1 	No node presolve
% 0 	Automatic: let CPLEX choose; default
% 1 	Force presolve at nodes
% 2 	Perform probing on integer-infeasible variables
% 3 	Perform aggressive node probing
%cpxControl.PRESLVND = 0;
