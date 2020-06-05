% cplexStatus analyzes the CPLEX output Inform code and returns
% the CPLEX solution status message in ExitText and the TOMLAB exit flag
% in ExitFlag
%
% function [ExitText,ExitFlag] = cplexStatus(Inform)
%
% INPUT:
%
% Inform      Integer status number from CPLEX run
%
% OUTPUTS:
%
% ExitText    CPLEX solution status message
% ExitFlag    Exit status, TOMLAB standard
%
%   Inform   CPLEX information parameter, see TOMLAB /CPLEX User's Guide.
%            S = Simplex, B = Barrier.
%
%      LP/QP Inform values
%
%       1 (S,B) Optimal solution found
%       2 (S,B) Model has an unbounded ray
%       3 (S,B) Model has been proved infeasible
%       4 (S,B) Model has been proved either infeasible or unbounded
%       5 (S,B) Optimal solution is available, but with infeasibilities after unscaling
%       6 (S,B) Solution is available, but not proved optimal, due to numeric difficulties
%      10 (S,B) Stopped due to limit on number of iterations
%      11 (S,B) Stopped due to a time limit
%      12 (S,B) Stopped due to an objective limit
%      13 (S,B) Stopped due to a request from the user
%
%      14 (S,B) Feasible relaxed sum found (FEASOPTMODE)
%      15 (S,B) Optimal relaxed sum found (FEASOPTMODE)
%      16 (S,B) Feasible relaxed infeasibility found (FEASOPTMODE)
%      17 (S,B) Optimal relaxed infeasibility found (FEASOPTMODE)
%      18 (S,B) Feasible relaxed quad sum found (FEASOPTMODE)
%      19 (S,B) Optimal relaxed quad sum found (FEASOPTMODE)
%
%      20 (B) Model has an unbounded optimal face
%      21 (B) Stopped due to a limit on the primal objective
%      22 (B) Stopped due to a limit on the dual objective
%
%      30 The model appears to be feasible; no conflict is available
%      31 The conflict refiner found a minimal conflict
%      32 A conflict is available, but it is not minimal
%      33 The conflict refiner terminated because of a time limit
%      34 The conflict refiner terminated because of an iteration limit
%      35 The conflict refiner terminated because of a node limit
%      36 The conflict refiner terminated because of an objective limit
%      37 The conflict refiner terminated because of a memory limit
%      38 The conflict refiner terminated because a user terminated the application
%
%     101 Optimal integer solution found
%     102 Optimal sol. within epgap or epagap tolerance found
%     103 Solution is integer infeasible
%     104 The limit on mixed integer solutions has been reached
%     105 Node limit exceeded, integer solution exists
%     106 Node limit exceeded, no integer solution
%     107 Time limit exceeded, integer solution exists
%     108 Time limit exceeded, no integer solution
%     109 Terminated because of an error, but integer solution exists.
%     110 Terminated because of an error, no integer solution
%     111 Limit on tree memory has been reached, but an integer solution exists
%     112 Limit on tree memory has been reached; no integer solution
%     113 Stopped, but an integer solution exists
%     114 Stopped; no integer solution
%     115 Problem is optimal with unscaled infeasibilities
%     116 Out of memory, no tree available, integer solution exists
%     117 Out of memory, no tree available, no integer solution
%     118 Model has an unbounded ray
%     119 Model has been proved either infeasible or unbounded
%
%     120 (MIP) Feasible relaxed sum found (FEASOPTMODE)
%     121 (MIP) Optimal relaxed sum found (FEASOPTMODE)
%     122 (MIP) Feasible relaxed infeasibility found (FEASOPTMODE)
%     123 (MIP) Optimal relaxed infeasibility found (FEASOPTMODE)
%     124 (MIP) Feasible relaxed quad sum found (FEASOPTMODE)
%     125 (MIP) Optimal relaxed quad sum found (FEASOPTMODE)
%     126 (MIP) Relaxation aborted due to limit (FEASOPTMODE)
%     129 (MIP) All possible solutions have been found by populate
%     130 (MIP) All possible solutions within tolerances found by populate
%     131 (MIP) Deterministic time limit exceeded, integer solution exists.
%     132 (MIP) Deterministic time limit exceeded, no integer solution.
%
%     301 (MUL) Multi-objective optimal solution
%     302 (MUL) Multi-objective infeasible
%     303 (MUL) Multi-objective infeasible or unbounded
%     305 (MUL) Multi-objective non-optimal point
%     306 (MUL) Multi-objective stopped
%     307 (MUL) Multi-objective unbounded
%
%     1001 Insufficient memory available
%     1014 CPLEX parameter is too small
%     1015 CPLEX parameter is too big
%     1100 Lower and upper bounds contradictory
%     1101 The loaded problem contains blatant infeasibilities or unboundedness
%
%     1106 The user halted preprocessing by means of a callback
%     1117 The loaded problem contains blatant infeasibilities
%     1118 The loaded problem contains blatant unboundedness
%     1225 Numeric entry is not a double precision number (NAN)
%     1233 Data checking detected a number too large
%     1256 CPLEX cannot factor a singular basis
%     1261 No basic solution exists (use crossover)
%     1262 No basis exists (use crossover)
%     1719 No conflict is available
%     3413 Tree memory limit exceeded
%
%     5002 Non-positive semidefinite matrix in quadratic problem
%     5012 Non-symmetric matrix in quadratic problem
%
%     32201 A licensing error has occurred
%     32024 Licensing problem: Optimization algorithm not licensed
%
%     -1    Parameter Tuning (without solving) was requested
%
%     otherwise  Unknown CPLEX Status value. Please contact support.

% Kenneth Holmstrom, Tomlab Optimization Inc., E-mail: tomlab@tomopt.com
% Copyright (c) 1999-2007 by Tomlab Optimization Inc., $Release: 11.0.0$
% Written July 8, 1999.      Last modified Dec 13, 2007.

function [ExitText,ExitFlag] = cplexStatus(Inform)

if nargin < 1
    error('cplexStatus needs the Inform value as input');
end

% Exit texts, depending on Inform
switch Inform
    case 1, Text='Optimal solution found';
    case 2, Text='Model has an unbounded ray';
    case 3, Text='Model has been proved infeasible';
    case 4, Text='Model has been proved either infeasible or unbounded';
    case 5, Text='Optimal solution is available, but with infeasibilities after unscaling';
    case 6, Text='Solution is available, but not proved optimal, due to numeric difficulties';
    case 10, Text='Stopped due to limit on number of iterations';
    case 11, Text='Stopped due to a time limit';
    case 12, Text='Stopped due to an objective limit';
    case 13, Text='Stopped due to a request from the user';

    case 14, Text='Feasible relaxed sum found (FEASOPTMODE)';
    case 15, Text='Optimal relaxed sum found (FEASOPTMODE)';
    case 16, Text='Feasible relaxed infeasibility found (FEASOPTMODE)';
    case 17, Text='Optimal relaxed infeasibility found (FEASOPTMODE)';
    case 18, Text='Feasible relaxed quad sum found (FEASOPTMODE)';
    case 19, Text='Optimal relaxed quad sum found (FEASOPTMODE)';

    case 20, Text='Model has an unbounded optimal face';
    case 21, Text='Stopped due to a limit on the primal objective';
    case 22, Text='Stopped due to a limit on the dual objective';
    case 25, Text='Stopped due to deterministic time limit';

    case 30, Text='The model appears to be feasible; no conflict is available';
    case 31, Text='The conflict refiner found a minimal conflict';
    case 32, Text='A conflict is available, but it is not minimal';
    case 33, Text='The conflict refiner terminated because of a time limit';
    case 34, Text='The conflict refiner terminated because of an iteration limit';
    case 35, Text='The conflict refiner terminated because of a node limit';
    case 36, Text='The conflict refiner terminated because of an objective limit';
    case 37, Text='The conflict refiner terminated because of a memory limit';
    case 38, Text='The conflict refiner terminated because a user terminated the application';

    case 101, Text='Optimal integer solution found';
    case 102, Text='Optimal sol. within epgap or epagap tolerance found';
    case 103, Text='Solution is integer infeasible';
    case 104, Text='The limit on mixed integer solutions has been reached';
    case 105, Text='Node limit exceeded, integer solution exists';
    case 106, Text='Node limit exceeded, no integer solution';
    case 107, Text='Time limit exceeded, integer solution exists';
    case 108, Text='Time limit exceeded, no integer solution';
    case 109, Text='Terminated because of an error, but integer solution exists';
    case 110, Text='Terminated because of an error, no integer solution';
    case 111, Text='Limit on tree memory has been reached, but an integer solution exists';
    case 112, Text='Limit on tree memory has been reached; no integer solution';
    case 113, Text='Stopped, but an integer solution exists';
    case 114, Text='Stopped; no integer solution';
    case 115, Text='Problem is optimal with unscaled infeasibilities';
    case 116, Text='Out of memory, no tree available, integer solution exists';
    case 117, Text='Out of memory, no tree available, no integer solution';
    case 118, Text='Model has an unbounded ray';
    case 119, Text='Model has been proved either infeasible or unbounded';

    case 120, Text='Feasible relaxed sum found (FEASOPTMODE)';
    case 121, Text='Optimal relaxed sum found (FEASOPTMODE)';
    case 122, Text='Feasible relaxed infeasibility found (FEASOPTMODE)';
    case 123, Text='Optimal relaxed infeasibility found (FEASOPTMODE)';
    case 124, Text='Feasible relaxed quad sum found (FEASOPTMODE)';
    case 125, Text='Optimal relaxed quad sum found (FEASOPTMODE)';
    case 126, Text='Relaxation aborted due to limit (FEASOPTMODE)';
    case 128, Text='Maximum number of solutions found by populate';
    case 129, Text='All possible solutions have been found by populate';
    case 130, Text='All possible solutions within tolerances found by populate';
    case 131, Text='Deterministic time limit exceeded, integer solution exists';
    case 132, Text='Deterministic time limit exceeded, no integer solution';

    case 301, Text='Multi-objective optimal solution';
    case 302, Text='Multi-objective infeasible';
    case 303, Text='Multi-objective infeasible or unbounded';
    case 305, Text='Multi-objective non-optimal point';
    case 306, Text='Multi-objective stopped';
    case 307, Text='Multi-objective unbounded';

      % Severe errors may generate a status value among:
    case 1001, Text='Insufficient memory available';
    case 1014, Text='CPLEX parameter is too small';
    case 1015, Text='CPLEX parameter is too big';
    case 1100, Text='Lower and upper bounds contradictory';
    case 1101, Text='The loaded problem contains blatant infeasibilities or unboundedness';

    case 1106, Text='The user halted preprocessing by means of a callback';
    case 1117, Text='The loaded problem contains blatant infeasibilities';
    case 1118, Text='The loaded problem contains blatant unboundedness';
    case 1225, Text='Numeric entry is not a double precision number (NAN)';
    case 1233, Text='Data checking detected a number too large';
    case 1256, Text='CPLEX cannot factor a singular basis';
    case 1261, Text='No basic solution exists (use crossover)';
    case 1262, Text='No basis exists (use crossover)';
    case 1719, Text='No conflict is available';
    case 3413, Text='Tree memory limit exceeded';

    case 5002, Text='Non-positive semidefinite matrix in quadratic problem';
    case 5012, Text='Non-symmetric matrix in quadratic problem';

    case 32201, Text='A licensing error has occurred';
    case 32024, Text='Licensing problem: Optimization algorithm not licensed';

    case -1,     Text='Parameter Tuning without solve was requested';

   otherwise, Text='Unknown CPLEX Status value';
end 
ExitText = Text;

% Exitflags, depending on Inform
switch(Inform)

    case {1,101,102,128,129,301,-1} % Successful
        ExitFlag = 0;

    case {10,11,12,13,25,33,34,35,36,37,104,105,106,107,108,131,132,306,1106} % Time/Iterations limit exceeded
        ExitFlag = 1;

    case {2,20,118,303,307,1118} % Unbounded
        ExitFlag = 2;

    case {3,4,5,14,15,16,17,18,19,21,22,31,32,103,115,119,120,121,122,123,124,125,126,307,1101,1117} % Infeasible
        ExitFlag = 4;

    case {6,30,38,109,110,1014,1015,1100,1225,1233,1256,1261,1262,1719,5002,5012,32201,32024} % Input errors
        ExitFlag = 10;

    case {111,112,113,114,116,117,1001,3413} % Memory errors
        ExitFlag = 11;

    otherwise % Other Inform values
        ExitFlag = -1;
end

% MODIFICATION LOG:
%
% 070223 hkh  Written, based on cplexTL
% 070611 med  Corrected