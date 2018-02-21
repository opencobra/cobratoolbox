function solution = feasOpt(LPProblem,lhs,rhs,lb,ub,mode,tol,Rxnscore)
%
% feasOpt is IBM CPLEX routine to relax an infeasible model.
% It returns a feasible/optimal solution and a minimal relaxation. 
% Standard LP formulation
%         min/max c^T.v
%            s.t. lhs <= S.v <= rhs
%                 lb <= v <= ub
%                 S(m,n);v(n,1);rhs(m,1)
%
% USAGE:
%
%    solution = feasOpt(LPProblem,lhs,rhs,lb,ub,mode,tol,Rxnscore);
%
% INPUTS:
%    LPProblem: COBRA model structure
%    lhs/rhs:   vector of length m where 0 excludes the corresponding metabolite
%               from relaxation and >0 sets the weights for
%               relaxation, [] excludes all metabolites
%    lb/ub:   vector of length n where 0 excludes the corresponding
%             reaction from relaxation, and >0 sets the weights for
%             relaxation, [] excludes all reacation
%    mode:    corresponds to the cplex parameter CPX_PARAM_FEASOPTMODE
%                 0: Minimize the sum of all required relaxations 
%                    (weighted sum of the penalties)
%                 1: 0+find optimum among minimal relaxations (default)
%                 (0 and 1 perform one-norm minimization: minimal amplitude 
%                  of relaxation and cardinal of reaction set relaxed)
%                 2: Minimize the number of constraints and bounds
%                    requiring relaxation (weighted number of relaxed bounds and constraints)
%                 3: 2+find optimum among minimal relaxations
%                 (2 and 3 perform zero-norm minimization: minimal cardinal of
%                  reaction set relaxed)
%                 4: Minimize the sum of squares of required relaxations 
%                    (the weighted sum of the squared penalties of the relaxations )
%                 5: 4+find optimum among minimal relaxations
%                 (4 and 5 will distribute the relaxation on a large number
%                  of reactions such as each reaction is relaxed by a small amplitude)
%
%    tol:      corresponds to the cplex parameter CPX_PARAM_EPRELAX
%    Rxnscore: 0 (Default)
%              1 Uses the inverse reaction confidence score as weights for relaxation
%                which allows relaxation of low confidence reactions
%
% OUTPUT:
%    solution.p: relaxation ot the lower bound v > lb-p
%    solution.q: relxation to the upper bound v < ub+q
%    solution.r: relaxation to the rhs S.v+r < rhs
%    solution.s: relaxation to the lhs lhs < s-S.v 
%    solution.v: optimal/feasible solution
%
% IMPORTATNT:
% 1. If the bounds are set to inf then feasopt will relax infinitely, make
% sure the bounds are set to a real number in the model e.g., +-1000
% 2. It is recommended to set the c vector to zeros prior to the function call
% to avoid pushing the boundaries in the -c direction
%
% .. Author: Marouen Ben Guebila 24/07/2017

if ~changeCobraSolver('ibm_cplex')
    fprintf('This function requires IBM ILOG CPLEX');
end

if (nargin < 6)
    mode=1;
end
if nargin <7
   tol=1e-6;
end
if nargin <8
    Rxnscore=0;
end

if Rxnscore==1
    lb=1/LPProblem.rxnConfidenceScores;
    ub=1/LPProblem.rxnConfidenceScores;
end

if ~isfield(LPProblem,'A')
    if ~isfield(LPProblem,'S')
            error('Equality constraint matrix must either be a field denoted A or S.')
    end
    LPProblem.A=LPProblem.S;
end

if ~isfield(LPProblem,'csense')
    nMet=size(LPProblem.A);
    if printLevel>0
        fprintf('%s\n','Assuming equality constraints, i.e. S*v=b');
    end
    %assuming equality constraints
    LPProblem.csense(1:nMet,1)='E';
end

if ~isfield(LPProblem,'osense')
    %assuming maximisation
    LPProblem.osense=-1;
        fprintf('%s\n','Assuming maximisation of objective');
end

if size(LPProblem.A,2)~=length(LPProblem.c)
    error('dimensions of A & c are inconsistent');
end

if size(LPProblem.A,2)~=length(LPProblem.lb) || size(LPProblem.A,2)~=...
        length(LPProblem.ub)
    error('dimensions of A & bounds are inconsistent');
end

%get data
[c,x_L,x_U,b,csense,osense] = deal(LPProblem.c,LPProblem.lb,LPProblem.ub,...
    LPProblem.b,LPProblem.csense,LPProblem.osense);
%modify objective to correspond to osense
c=full(c*osense);

%cplex expects it dense
b=full(b);

%call cplex
%complex ibm ilog cplex interface
if ~isempty(csense)
	%set up constant vectors for CPLEX
	b_L(csense == 'E',1) = b(csense == 'E');
	b_U(csense == 'E',1) = b(csense == 'E');
	b_L(csense == 'G',1) = b(csense == 'G');
	b_U(csense == 'G',1) = Inf;
	b_L(csense == 'L',1) = -Inf;
	b_U(csense == 'L',1) = b(csense == 'L');
else
	b_L = b;
	b_U = b;
end

%Initialize the CPLEX object
try
    ILOGcplex = Cplex('fba');
catch ME
    error('CPLEX not installed or licence server not up')
end

ILOGcplex.Model.sense = 'minimize';

% Now populate the problem with the data
ILOGcplex.Model.obj   = c;
ILOGcplex.Model.lb    = x_L;
ILOGcplex.Model.ub    = x_U;
ILOGcplex.Model.A     = LPProblem.A;
ILOGcplex.Model.lhs   = b_L;
ILOGcplex.Model.rhs   = b_U;

% Optimize the problem
ILOGcplex.Param.feasopt.mode.Cur=mode;
ILOGcplex.Param.feasopt.tolerance.Cur=tol;
ILOGcplex.feasOpt(lhs,rhs,lb,ub)
        
if ismember(ILOGcplex.Solution.status,[14,15,16,17,18,19,1,23])
	p=ILOGcplex.Model.lb    -  ILOGcplex.Solution.x;
	q=ILOGcplex.Solution.x  -  ILOGcplex.Model.ub;
	r=ILOGcplex.Solution.ax -  ILOGcplex.Model.rhs;
	s=ILOGcplex.Model.lhs   - ILOGcplex.Solution.ax;
	p(p < 0) = 0;
	q(q < 0) = 0;
	r(r < 0) = 0;
	s(s < 0) = 0;
	v = ILOGcplex.Solution.x; 
	if ismember(ILOGcplex.Solution.status,[14,16,18])
        fprintf('The relaxtion is optimal \n');
	elseif ismember(ILOGcplex.Solution.status,[15,17,19])
        fprintf('The relaxtion is feasible \n');
	elseif ILOGcplex.Solution.status == 23
        fprintf('The original model is feasible. Feasible solution available. \n')
	elseif ILOGcplex.Solution.status == 1
        fprintf('The original model is feasible. Optimal solution available. \n')
	end
else
	fprintf('The model is infeasible');
	p = [];q = [];r = [];s = [];v = [];
end

[solution.p,solution.q,solution.r,solution.s,solution.v]=deal(p,q,r,s,v);

end