function  cplexProblem = buildCplexProblemFromCOBRAStruct(Problem)
% Build a cplex object from the given LP problem in COBRA Format
% USAGE:
%    cplexProblem = buildCplexProblemFromCOBRAStruct(LPproblem)
%
% INPUT:
%    LPproblem:         A COBRA style Problem with the following fields:
%                        * .A - The equality and in equality matrix
%                        * .b - The right hand side values of the constraints
%                        * .ub - the upper bounds of the variables
%                        * .lb - the lower bounds of the variables
%                        * .osense - The objective sense (-1 for max, 1 for min)
%                        * .c - the objective coefficient vector for the linear part
%                       OPTIONAL:
%                        * .F - The objective coefficient matrix for the quadratic part.
%                        * .varType - The variable types for mixed integer problems ('I', integer, 'C', continous,'B' binary)
%                        * .b_L - left hand sides of the constraints (will only be used if csense is empty)
%                        * .csense - The constraint senses, Default assumption is all 'E'
%                        * .x0 - Basis to use 
%


try
    cplexProblem = Cplex();
    %cplexProblem = Cplex('COBRAProblem');
catch ME
    error('CPLEX not installed or licence server not up')
end
if (~isempty(Problem.csense))
    % build the rhs/lhs of the problem.
    boolE = Problem.csense == 'E';
    b_L(boolE) = Problem.b(boolE);
    b_U(boolE) = Problem.b(boolE);
    boolG = Problem.csense == 'G';
    b_L(boolG) = Problem.b(boolG);
    b_U(boolG) = inf;
    boolL = Problem.csense == 'L';
    b_L(boolL) = -inf;
    b_U(boolL) = Problem.b(boolL);
elseif isfield(Problem.csense, 'b_L') && isfield(Problem, 'b_U')
    % or extract them 
    b_L = Problem.b_L;
    b_U = Problem.b_U;
else
    % or simply use the equality assumption.
    b_L = Problem.b;
    b_U = Problem.b;
end

cplexProblem.Model.A = Problem.A;
cplexProblem.Model.rhs = columnVector(b_U);
cplexProblem.Model.lhs = columnVector(b_L);
cplexProblem.Model.ub = Problem.ub;
cplexProblem.Model.lb = Problem.lb;

if isfield(Problem,'F')
    cplexProblem.Model.Q = Problem.F;
end

if isfield(Problem,'c')
    cplexProblem.Model.obj = Problem.c;
end
if isfield(Problem,'osense')
    if Problem.osense == 1
        cplexProblem.Model.sense = 'minimize';
    else
        cplexProblem.Model.sense = 'maximize';
    end
else
    cplexProblem.Model.sense = 'minimize';
end

if isfield(Problem,'vartype')
    cplexProblem.Model.ctype = columnVector(Problem.vartype)';
end

if isfield(Problem,'x0')
    cplexProblem.Start.x = Problem.x0;
end

