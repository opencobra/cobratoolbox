function flux = geometricFBA(model,varargin)
%geometricFBA finds a unique optimal FBA solution that is (in some sense)
%central to the range of possible fluxes; as described in
%   K Smallbone, E Simeonidis (2009). Flux balance analysis: 
%   A geometric perspective. J Theor Biol 258: 311-315
%   http://dx.doi.org/10.1016/j.jtbi.2009.01.027
%
% flux = geometricFBA(model)
%
%INPUT
% model         COBRA model structure
%
%OPTIONAL INPUTS
% Optional parameters can be entered as parameter name followed by
% parameter value: i.e. ...,'epsilon',1e-9)
% printLevel    [default: 1]  printing level
%               = 0     silent
%               = 1     show algorithm progress and times
% epsilon       [default: 1e-6]	convergence tolerance of algorithm, 
%               defined in more detail in paper above
% flexRel       [default: 0] flexibility to flux bounds
%               try e.g. 1e-3 if the algorithm has convergence problems
%
%OUTPUT
% flux          unique centered flux
%
%kieran smallbone, 5 May 2010
%
% This script is made available under the Creative Commons
% Attribution-Share Alike 3.0 Unported Licence (see
% www.creativecommons.org). 

param = struct('epsilon',1e-6,'flexRel',0,'printLevel',1);
field = fieldnames(param);
if mod(nargin,2) ~= 1 % require odd number of inputs
    error('incorrect number of input parameters')
else
    for k = 1:2:(nargin-1)
        param.(field{strcmp(varargin{k},field)}) = varargin{k+1};
    end
end
param.flexTol = param.flexRel * param.epsilon; % absolute flexibility

% determine optimum
FBAsolution = optimizeCbModel(model);
ind = find(model.c);
if length(ind) == 1
    model.lb(ind) = FBAsolution.f;
end

A = model.S;
b = model.b;
L = model.lb;
U = model.ub;

% ensure column vectors
b = b(:); L = L(:); U = U(:);

% Remove negligible elements
J = any(A,2); A = A(J,:); b = b(J);

% presolve
v = nan(size(L));
J = (U-L < param.epsilon);
v(J) = (L(J)+U(J))/2;
J = find(isnan(v));

if param.printLevel
    fprintf('%s\t%g\n\n%s\t@%s\n','# reactions:',length(v),'iteration #0',datestr(now,16)); 
end

L0 = L; U0 = U;
for k = J(:)'
    f = zeros(length(v),1); f(k) = -1;
    [dummy,opt,conv] = easyLP(f,A,b,L0,U0);
    if conv
        vL = max(-opt,L(k));
    else
        vL = L(k);
    end
    [dummy,opt,conv] = easyLP(-f,A,b,L0,U0);
    if conv
        vU = min(opt,U(k));
    else vU = U(k);
    end
    if abs(vL) < param.epsilon
        vL = 0;
    end
    if abs(vU) < param.epsilon
        vU = 0;
    end
    vM = (vL + vU)/2;
    if abs(vM) < param.epsilon
        vM = 0;
    end
    if abs(vU - vL) < param.epsilon
        vL = (1-sign(vM)* param.flexTol)*vM; 
        vU = (1+sign(vM)* param.flexTol)*vM; 
    end
    L(k) = vL; U(k) = vU;
end

v = nan(size(L)); 
J = (U-L < param.epsilon);
v(J) = (L(J)+U(J))/2; v = v.*(abs(v) > param.epsilon);

if param.printLevel
    fprintf('%s\t\t%g\n%s\t\t%g\n\n','fixed:',sum(J),'@ zero:',sum(v==0));
end

% iterate
J  = find(U-L >= param.epsilon); 
n   = 1;
mu  = [];
Z   = [];

while ~isempty(J)
    
    if param.printLevel
        fprintf('%s #%g\t@%s\n','iteration',n,datestr(now,16)); 
    end
    
    if n == 1
        M = zeros(size(L));
    else
        M = (L+U)/2;
    end
    
    mu(:,n) = M;                                                %#ok<AGROW>    
    allL = L; allU = U; allA = A; allB = b;    
    [a1,a2] = size(A);
    
    % build new matrices
    for k = 1:(n-1)
        [b1,b2] = size(allA);
        f = sparse(b2+2*a2,1); f((b2+1):end) = -1;
        opt = -Z(k);
        allA = [allA,sparse(b1,2*a2);
            speye(a2,a2),sparse(a2,b2-a2),-speye(a2),speye(a2);
            f(:)'];                                             %#ok<AGROW>
        allB = [allB;mu(:,k);opt];                              %#ok<AGROW>
        allL = [allL;zeros(2*a2,1)];                            %#ok<AGROW>
        allU = [allU;inf*ones(2*a2,1)];                         %#ok<AGROW>
    end
    
    [b1,b2] = size(allA);
    f = zeros(b2+2*a2,1); f((b2+1):end) = -1;
    allA = [allA,sparse(b1,2*a2);
        speye(a2,a2),sparse(a2,b2-a2),-speye(a2),speye(a2)];	%#ok<AGROW>
    allB = [allB;M];                                            %#ok<AGROW>
    allL = [allL;zeros(2*a2,1)];                                %#ok<AGROW>
    allU = [allU;inf*ones(2*a2,1)];                             %#ok<AGROW>
    
    [v,opt,conv] = easyLP(f,allA,allB,allL,allU);
    if ~conv, disp('error: no convergence'); flux = (L+U)/2; return; end    
    
    opt = ceil(-opt/eps)*eps;
    Z(n) = opt;                                                 %#ok<AGROW>    
    allA = [allA; sparse(f(:)')];                               %#ok<AGROW>
    allB = [allB; -opt];                                        %#ok<AGROW>
    
    for k = J(:)'        
        f = zeros(length(allL),1); f(k) = -1;
        [dummy,opt,conv] = easyLP(f,allA,allB,allL,allU);
        if conv
            vL = max(-opt,L(k));
        else
            vL = L(k); 
        end
        [dummy,opt,conv] = easyLP(-f,allA,allB,allL,allU);
        if conv
            vU = min(opt,U(k));
        else
            vU = U(k);
        end
        if abs(vL) < param.epsilon
            vL = 0;
        end
        if abs(vU) < param.epsilon
            vU = 0;
        end
        vM = (vL + vU)/2;
        if abs(vM) < param.epsilon
            vM = 0;
        end
        if abs(vU - vL) < param.epsilon
            vL = (1-sign(vM)* param.flexTol)*vM; 
            vU = (1+sign(vM)* param.flexTol)*vM; 
        end
        L(k) = vL; 
        U(k) = vU;
    end
    
    v = nan(size(L)); 
    J = (U-L < param.epsilon);
    v(J) = (L(J)+U(J))/2; v = v.*(abs(v) > param.epsilon);

    if param.printLevel
        fprintf('%s\t\t%g\n%s\t\t%g\n\n','fixed:',sum(J),'@ zero:',sum(v==0));
    end
    
    n = n+1;
    J = find(U-L >= param.epsilon);   
    
    flux = v;
end

function [v,fOpt,conv] = easyLP(c,A,b,lb,ub)
%easyLP
%
% solves the linear programming problem: 
%   max c'x subject to 
%   A x = b
%   lb <= x <= ub. 
%
% Usage: [v,fOpt,conv] = easyLP(c,A,b,lb,ub)
%
%   c           objective coefficient vector
%   A           LHS matrix
%   b           RHS vector
%   lb         lower bound
%   ub         upper bound
%
%   v           solution vector
%   fOpt        objective value
%   conv        convergence of algorithm [0/1]
%
% the function is a wrapper for the "solveCobraLP" script.
%
%kieran smallbone, 5 may 2010

csense(1:length(b)) = 'E';
model = struct('A',A,'b',b,'c',full(c),'lb',lb,'ub',ub,'osense',-1,'csense',csense);
solution = solveCobraLP(model);
v = solution.full;
fOpt = solution.obj;
conv = solution.stat == 1;
