function [result_tab, error_code, nb_warm_start, z]=SparseLP_old(c,polyhedron, zeps, max_warm_start)

% Compute the sparsest solution of a linear program (LP)
% min c'x
% s.t.  Sx=b
%       lb <= x <= ub
%

 n=size(c,1);error_code=0;

% Compute the optimal value of the LP
% [x0, err_init]=LPSolve(c,Aeq,beq,Ain,bin,lb,ub);
 [x0, err_init]=LPSolve(c,polyhedron);
 err_init
if err_init~=1
 init_result=length(find(abs(x0)>zeps));
 optvalue=x0'*c;

% Heuristic to get 0 if optimal value is 0.
 if optvalue==0 && max(polyhedron.Aeq*zeros(n,1)-polyhedron.beq)==0 && max(polyhedron.Ain*zeros(n,1)-polyhedron.bin)<=0 && max(polyhedron.lb-zeros(n,1))<=0 && max(zeros(n,1)-polyhedron.ub)<=0
	z=zeros(n,1);result_tab=[0]; error_code=0; nb_warm_start=0;
 else

% Generate final polyhedron with optimal value as a constraint.
 polyhedron=struct('Aeq',[polyhedron.Aeq;c'],'beq',[polyhedron.beq;optvalue],'Ain',polyhedron.Ain,'bin',polyhedron.bin,'lb',polyhedron.lb,'ub',polyhedron.ub);

%#################################################################################
% MAIN : Algorithm call with warm start if we didn't improve l1-norm solution or if we have precision problem

 nb_warm_start=-1;tic;
 [x, err_l1]=L1Solve(polyhedron); l1_result=length(find(abs(x)>zeps));
 err_l1
 if err_l1~=1
	result_tab=[init_result, l1_result];
 else
	result_tab=[init_result];
 end

% Parameters
 nb_itemax_r=50; nb_itemax_sla=2; update_param=0.5;rstop=sqrt(eps); move=1;

 while err_l1~=1 && nb_warm_start<max_warm_start && init_result>0 && ( nb_warm_start==-1 || nnz_z<=min(result_tab)) && move

  [z, nnz_z, error_code] = ThetaL0(polyhedron, @theta1, @dtheta1, nb_itemax_r, rstop, update_param, nb_itemax_sla, zeps, x);
% Update
	nb_warm_start=nb_warm_start+1;
	if nnz_z<min(result_tab)
		result_tab=[result_tab, nnz_z];x=z;
	elseif z==x
		move=0;
	end

 end
 if err_l1==1
	z=x0;nnz_z=-1;error_code=1;
 end
%################################################################################
 toc
 end
else
 result_tab=[]; error_code=1;nb_warm_start=0;z=x0;
end
end

%################################################################################
%# Declaration of functions thetas and their derivatives :

function y = theta1(t,r)
	y=abs(t)./(abs(t)+r);
end

function y = dtheta1(t,r)
	y=sign(t).*r./((abs(t)+r).^2);
end

function y = theta2(t,r)
	y=1-exp(-abs(t)/r);
end

function y = dtheta2(t,r)
	y=sign(t).*exp(-abs(t)./r)./r;
end

%######################################################################################################################
%######################################################################################################################
function [x, nnz_x, error_code] = ThetaL0(polyhedron, theta_func, dtheta_func, nb_itemax_r, rstop, update_param, nb_itemax_sla, zero_precision, init_point)

% Citation :  A Smoothing Method for Sparse Optimization over Polyhedral Sets, Modelling, Computation and Optimization in Information Systems and Management Sciences Advances in Intelligent Systems and Computing Volume 359, 2015, pp 369-379   Tangi Migot, Mounir Haddou, 2015

% error_code :
% -2 : maximum iteration in r
% -1 : maximum iteration in SLA
% 0 : success
% 1 : unbounded
% 2 : precision

 error_code=0;
% code d'erreur SLA : (init in 1 : in case no SLA are done)
 err_code=1;

% for debug :
minx=[];rtab=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization

% if no initial point we take the solution of l1-norm problem
 if isempty(init_point)
	init_point=L1Solve(polyhedron);
 end

 sol=init_point;
 nnz_current=length(find(abs(sol)>zero_precision));nnzero=[];soltab=[];minx=[min(sol(sol>0))];
% initialization of parameter r
 i=1;r0=1;rold=r0;r=rold;rtab=[r0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Main Loop

 while i<nb_itemax_r && theta_func(min(sol(sol>zero_precision)),rold)<nnz_current/(nnz_current+1) && r>rstop
% Scaling to put variables in [0,1] box
	scal=max(abs(sol))/2;z=sol/scal;

	spolyhedron=struct('Aeq',polyhedron.Aeq,'beq',polyhedron.beq/scal,'Ain',polyhedron.Ain,'bin',polyhedron.bin/scal,'lb',polyhedron.lb/scal,'ub',polyhedron.ub/scal);
% Concave program
	[z, err_code] = ThetaSLA(spolyhedron, z,r, nb_itemax_sla, theta_func, dtheta_func);

	    if err_code==1
	     error_code=1;i=nb_itemax_r; % unbounded
	    else
	     	sol=z*scal;soltab=[soltab;sol'];minx=[minx;min(sol(sol>0))];rtab=[rtab,r];
	     	nnzk=length(find(abs(sol)>zero_precision));nnzero=[nnzero, nnzk];
% Update
	     	i=i+1;rold=r;r=r*update_param;
	    end
	    if err_code==-1
	     error_code=-1; % max iteration SLA
	    end

 end
%%%%% End Main Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Best solution find :
if err_code ~=1
 nnz_x=min(nnzero);index=find(nnzero==nnz_x);x=soltab(index(1),:)';
else
 nnz_x=length(find(abs(sol)>zero_precision));x=init_point;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error code :
 if i==nb_itemax_r && error_code~=1
	error_code=-2; % max iteration in r
 end

 if ( (~isempty(polyhedron.Aeq) && norm(polyhedron.Aeq*x-polyhedron.beq,Inf)>sqrt(eps)) || (~isempty(polyhedron.Ain) && max(polyhedron.Ain*x-polyhedron.bin)>sqrt(eps)) || (~isempty(polyhedron.lb) && max(polyhedron.lb-x)>sqrt(eps)) || (~isempty(polyhedron.ub) && max(x-polyhedron.ub)>sqrt(eps))) && error_code~=1
	error_code=2; % precision
 end

end
%######################################################################################################################
%
% Solve concave program of minimization Theta with Successiv Linearization Algorithm
%
%######################################################################################################################
function [x, error_code] =ThetaSLA(polyhedron,init_point,r_param,ite_max, theta_func, dtheta_func)

% err_code :
% -1 : maximum iteration
%  0 : success
%  1 : unbounded linear program
%  2 : precision
 error_code=0;

 j=1;y=init_point;zero_precision=sqrt(eps);

 while j<ite_max && (j==1 || abs(c'*yold-c'*x)>zero_precision)
	% Objectiv theta function with scaling :

%	c=dtheta_func(y,r_param)/(theta_func(1,r_param))
	c=dtheta_func(y,r_param)*r_param;

	[x,bool_LP]=LPSolve(c,polyhedron);
	% update :
	yold=y;y=x;j=j+1;

	if bool_LP==1
		error_code=1;j=ite_max;
	end
 end

 if error_code~=1
	 if j==ite_max
		error_code=-1;
	 end

	 if (~isempty(polyhedron.Aeq) && norm(polyhedron.Aeq*x-polyhedron.beq,Inf)>zero_precision) || (~isempty(polyhedron.Ain) && max(polyhedron.Ain*x-polyhedron.bin)>zero_precision) || (~isempty(polyhedron.lb) &&max(polyhedron.lb-x)>sqrt(eps)) || (~isempty(polyhedron.ub) &&max(x-polyhedron.ub)>sqrt(eps))
		error_code=2;
	 end
 end
end
%######################################################################################################################
%
% Solve convex program of minimization l1-norm
%
%######################################################################################################################
function [x,error_code]=L1Solve(polyhedron)
%{
% here we use SeDuMi from CVX Matlab package
 n=size(polyhedron.lb,1);error_code=0;
% min c'x
% s.t.  Aeq x == beq
%       Ain x <= bin
%       lb <= x <= ub

 cvx_begin quiet
     cvx_precision best
%     cvx_solver sdpt3
     variable x(n)
     minimize(norm(x,1))
     subject to
         polyhedron.Aeq*x == polyhedron.beq;
         polyhedron.Ain*x <= polyhedron.bin;
         x >= polyhedron.lb;
         x <= polyhedron.ub;
 cvx_end

% error 1 : unbounded
 if cvx_optval<=-Inf || cvx_optval>=Inf
	error_code=1;
 end

% error 2 : precision
 if norm(polyhedron.Aeq*x-polyhedron.beq,Inf)>sqrt(eps) || max(polyhedron.Ain*x-polyhedron.bin)>sqrt(eps) || max(polyhedron.lb-x)>sqrt(eps) || max(x-polyhedron.ub)>sqrt(eps)
	error_code=2;
 end
%}
%######################################################################################################################
% Solveur GUROBI

% solver with Gurobi (reformulation comme un LP)
if isempty(polyhedron.Aeq)
	%On a pas besoin des égalités
	AEQ=[];
else
	m1=size(polyhedron.beq,1);n=size(polyhedron.Aeq,2);AEQ=[polyhedron.Aeq, zeros(m1,n)];
end
if isempty(polyhedron.Ain)
	n=size(polyhedron.lb,1);
	AIN=[eye(n), -eye(n); -eye(n), -eye(n)];
	BIN=[zeros(n,1); zeros(n,1)];
else
	m2=size(polyhedron.bin,1);n=size(polyhedron.Ain,2);
	AIN=[polyhedron.Ain, zeros(m2,n); eye(n), -eye(n); -eye(n), -eye(n)];
	BIN=[polyhedron.bin;zeros(n,1); zeros(n,1)];
end
if isempty(polyhedron.lb)
	LB=[];
else
	n=size(polyhedron.lb,1);LB=[polyhedron.lb; zeros(n,1)];
end
if isempty(polyhedron.ub)
	UB=[];
else
	n=size(polyhedron.ub,1);temp=max(abs(polyhedron.lb),abs(polyhedron.ub));UB=[polyhedron.ub; temp];
end

polyhedron_l1=struct('Aeq',AEQ,'beq',polyhedron.beq,'Ain',AIN,'bin',BIN,'lb',LB,'ub',UB);
c=[zeros(n,1);ones(n,1)];

[x,error_code]=LPSolve(c,polyhedron_l1);
x=x(1:n);

end
%######################################################################################################################
%
% Solve linear Program
%
%######################################################################################################################
function [x,error_code]=LPSolve(c,polyhedron)
%{
% Solveur SEDUMI
 n=size(c,1);error_code=0;
% min c'x
% s.t.  Aeq x == beq
%       Ain x <= bin
%       lb <= x <= ub

 cvx_begin quiet
    cvx_precision best
    cvx_solver sedumi
    variable x(n)
    minimize(c'*x)
    subject to
	polyhedron.Aeq*x == polyhedron.beq;
	polyhedron.Ain*x <= polyhedron.bin;
	x >= polyhedron.lb;
	x <= polyhedron.ub;
 cvx_end

% error 1 : unbounded
 if cvx_optval<=-Inf || cvx_optval>=Inf
	error_code=1;
 end

% error 2 : precision
 if norm(polyhedron.Aeq*x-polyhedron.beq,Inf)>sqrt(eps) || max(polyhedron.Ain*x-polyhedron.bin)>sqrt(eps) || max(polyhedron.lb-x)>sqrt(eps) || max(x-polyhedron.ub)>sqrt(eps)
	error_code=2;
 end
%}
%######################################################################################################################
% Solveur GUROBI

[x, fval, exitflag] = linprog_gurobi(c, polyhedron.Ain, polyhedron.bin, polyhedron.Aeq, polyhedron.beq, polyhedron.lb, polyhedron.ub);

if exitflag==1 || exitflag==0
 error_code=0;
elseif exitflag==-2 || exitflag==-3
 error_code=1;
end

% error 2 : precision
 if (~isempty(polyhedron.Aeq) && norm(polyhedron.Aeq*x-polyhedron.beq,Inf)>sqrt(eps)) || (~isempty(polyhedron.Ain) && max(polyhedron.Ain*x-polyhedron.bin)>sqrt(eps)) || (~isempty(polyhedron.lb) &&max(polyhedron.lb-x)>sqrt(eps)) || (~isempty(polyhedron.ub) &&max(x-polyhedron.ub)>sqrt(eps))
	error_code=2;
 end

end
function [x, fval, exitflag] = linprog_gurobi(f, A, b, Aeq, beq, lb, ub)
%LINPROG A linear programming example using the Gurobi MATLAB interface
%
%   This example is based on the linprog interface defined in the
%   MATLAB Optimization Toolbox. The Optimization Toolbox
%   is a registered trademark of The MathWorks, Inc.
%
%   x = LINPROG(f,A,b) solves the linear programming problem:
%
%   minimize     f'*x
%   subject to   A*x <= b
%
%
%   x = LINPROG(f,A,b,Aeq,beq) solves the problem:
%
%   minimize     f'*x
%   subject to     A*x <= b,
%                Aeq*x == beq.
%
%   x = LINPROG(f,A,b,Aeq,beq,lb,ub) solves the problem:
%
%   minimize     f'*x
%   subject to     A*x <= b,
%                Aeq*x == beq,
%          lb <=     x <= ub.
%
%   You can set lb(j) = -inf, if x(j) has no lower bound,
%   and ub(j) = inf, if x(j) has no upper bound.
%
%   [x, fval] = LINPROG(f, A, b) returns the objective value
%   at the solution. That is, fval = f'*x.
%
%   [x, fval, exitflag] = LINPROG(f, A, b) returns an exitflag
%   containing the status of the optimization. The values for
%   exitflag and corresponding status codes are:
%      1 - OPTIMAL,
%      0 - ITERATION_LIMIT,
%     -2 - INFEASIBLE,
%     -3 - UNBOUNDED.
%

if nargin < 3
    error('linprog(f, A, b)')
end

if nargin > 7
    error('linprog(f, A, b, Aeq, beq, lb, ub)');
end

if ~isempty(A)
    n = size(A, 2);
elseif nargin > 4 && ~isempty(Aeq)
    n = size(Aeq, 2);
else
    error('No linear constraints specified')
end

if ~issparse(A)
    A = sparse(A);
end

if nargin > 3 && ~issparse(Aeq)
    Aeq = sparse(Aeq);
end


model.obj = f;

if nargin < 4
    model.A = A;
    model.rhs = b;
    model.sense = '<';
else
    model.A = [A; Aeq];
    model.rhs = [b; beq];
    model.sense = [repmat('<', size(A,1), 1); repmat('=', size(Aeq,1), 1)];
end

if nargin < 6
    model.lb = -inf(n,1);
else
    model.lb = lb;
end

if nargin == 7
   model.ub = ub;
end

params.outputflag = 0;
result = gurobi(model, params);


if strcmp(result.status, 'OPTIMAL')
    exitflag = 1;
elseif strcmp(result.status, 'ITERATION_LIMIT')
    exitflag = 0;
elseif strcmp(result.status, 'INF_OR_UNBD')
    params.dualreductions = 0;
    result = gurobi(model, params);
    if strcmp(result.status, 'INFEASIBLE')
        exitflag = -2;
    elseif strcmp(result.status, 'UNBOUNDED')
        exitflag = -3;
    else
        exitflag = nan;
    end
elseif strcmp(result.status, 'INFEASIBLE')
    exitflag = -2;
elseif strcmp(result.status, 'UNBOUNDED')
    exitflag = -3;
else
    exitflag = nan;
end


if isfield(result, 'x')
    x = result.x;
else
    x = nan(n,1);
end

if isfield(result, 'objval')
    fval = result.objval;
else
    fval = nan;
end
end
