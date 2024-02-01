function [solution, modelOut] = entropicFluxBalanceAnalysis(model, param)
%% TBC
% minimize             g.*vf'*(log(vf) -1) + (cf + ci)'*vf 
% vf,vr,w,x,x0       + g.*vr'*(log(vr) -1) + (cr - ci)'*vr
%                    + f.*x' *(log(x)  -1) + u0'*x 
%                    + f.*x0'*(log(x0) -1) + u0'*x0
%                    + ce'*w
%                    + (1/2)v'*Q*v
%                    + (1/2)(v-h)'*H*(v-h)
%
% subject to      [N B]*[v w] <=> b   : y_N
% subject to      N*(vf - vr)  + B*w = x - x0 = dx/dt 
%
% subject to      N*(vf - vr) - x + x0  <=> b   : y_N
%                 C*(vf - vr)           <=> d   : y_C
%                     lb <= [vf - vr; w] <= ub  : y_v
%                         dxl <= x  - x0 <= dxu : z_dx
%                         vfl <= vf      <= vfu : z_vf
%                         vrl <=      vr <= vru : z_vr
%                          xl <= x       <= xu  : z_x
%                         x0l <=      x0 <= x0u : z_x0
%
% with Biochemical optimality conditions
%  || N*(vf - vr) - x + x0 - b ||_inf
%  || C*(vf - vr) - d ||_inf
%  || g*log(vf) + ci + cf + N'*y_N + C'*y_C + y_v + z_vf ||_inf
%  || g*log(vr) - ci + cr - N'*y_N - C'*y_C - y_vi + z_vr ||_inf
%  || f.*log(x)  + u0 - y_N + z_dx - z_x  ||_inf
%  || f.*log(x0) + u0 + y_N - z_dx + z_x0 ||_inf
%
% with  Derived biochemical optimality conditions (fluxes)
% || g*log(vr/vf) + cr - cf - 2*(ci + N'*y_N + C'*y_C + y_vi) + z_vr - z_vf ||_inf
%
% with  Derived biochemical optimality conditions (concentrations)
% || f.*log(x/x0) - 2*y_N + 2*z_dx + z_x - z_x0 ||_inf
% || f.*log(x.*x0) + 2*u0 + z_x + z_x0 ||_inf
%
% Derived biochemical optimality conditions (fluxes and concentrations)
% || g*log(vf) + cf + ci + N'*(u0 + log(x) + z_dx + z_x) + C'*y_C + y_vi + z_vf ||_inf
% || g*log(vr) + cr - ci - N'*(u0 + log(x) + z_dx + z_x) - C'*y_C - y_vi + z_vr ||_inf
%
% Derived biochemical optimality conditions (fluxes and concentrations, combining forward and reverse)
% || g*log(vr/vf) + cr - cf - 2*(ci + N'*(u0 + f*log(x)  + z_dx +   z_x) + C'*y_C + y_vi) - z_vf + z_vr ||_inf
% || g*log(vr/vf) + cr - cf - 2*(ci - N'*(u0 + f*log(x0) - z_dx + z_x0) + C'*y_C + y_vi) - z_vf + z_vr ||_inf
%
% If (but not only if) the input data is as follows:
% g = 2, f = 1, cr = cf, ci = 0,
% C = 0, d = 0,  <=> y_C = 0
% vl = -inf, vu = inf <=> y_v = 0
% dxl = -inf, dxu = inf, <=> z_dx = 0
% ub = inf, <=> z_vf = 0
% lb = - inf, <=> z_vr = 0
% x0l = -inf, x0u = inf, <=> z_x0 = 0
% then the above reduces to
% || log(vr/vf) = N'*(u0 + log(x) + z_x) ||_inf
% where z_x is the dual variable to the bounds on concentration x.
%
% USAGE:
%
%    [solution, modelOut] = entropicFluxBalanceAnalysis(model,param)
%
% INPUT:
%    model:             (the following fields are required - others can be supplied)
%
%          * S  - `m x (n + k)` Stoichiometric matrix
%          * c  - `(n + k) x 1` Linear objective coefficients
%          * lb - `(n + k) x 1` Lower bounds on net flux
%          * ub - `(n + k) x 1` Upper bounds on net flux
%
% OPTIONAL INPUTS:
% model.osenseStr: Maximize ('max')/minimize ('min') (opt, default = 'max') linear part of the objective. 
%                  Nonlinear parts of the objective are always assumed to be minimised.
%
% model.b         `m x 1` change in concentration with time
% model.csense    `m x 1` character array with entries in {L,E,G}
%
% model.C:       `c x (n + k)` Left hand side of C*v <= d
% model.d:       `c x (n + k)` Right hand side of C*v <= d
% model.dsense   `c x 1` character array with entries in {L,E,G}
%
% model.g         n x 1    strictly positive weight on internal flux entropy maximisation (default 2)
% model.cf:       n x 1    real valued linear objective coefficients on internal forward flux (default 0)
% model.cr:       n x 1    real valued linear objective coefficients on internal reverse flux (default 0)
% model.vfl:      n x 1    non-negative lower bound on internal forward flux (default 0) 
% model.vfu:      n x 1    non-negative upper bound on internal forward flux (default inf) 
% model.vrl:      n x 1    non-negative lower bound on internal reverse flux (default 0) 
% model.vru:      n x 1    non-negative upper bound on internal reverse flux (default 0) 
%
% model.f:       m x 1    strictly positive weight on concentration entropy maximisation (default 1)
% model.u0:      m x 1    real valued linear objective coefficients on concentrations (default 0)  
% model.x0l:     m x 1    non-negative lower bound on initial molecular concentrations 
% model.x0u:     m x 1    non-negative upper bound on initial molecular concentrations
% model.xl:      m x 1    non-negative lower bound on final molecular concentrations 
% model.xu:      m x 1    non-negative lower bound on final molecular concentrations
% model.dxl:     m x 1    real valued lower bound on difference between final and initial molecular concentrations  
% model.dxu:     m x 1    real valued upper bound on difference between final and initial initial molecular concentrations  
%        
% model.Q        (n + k) x (n + k)    positive semi-definite matrix to minimise (1/2)v'*Q*v
%
% model.SConsistentMetBool: m x 1  boolean indicating  stoichiometrically consistent metabolites
% model.SConsistentRxnBool: n x 1  boolean indicating  stoichiometrically consistent metabolites
%
%  param.solver:                    {('pdco'),'mosek'}
%  param.method:                    {('fluxes'),'fluxesConcentrations','fluxTracer')} maximise entropy of fluxes or also concentrations
%  param.printLevel:                {(0),1}
%
%
% Parameters related with flux optimisation
%  param.maxUnidirectionalFlux:     scalar real valued maximum expected value of unidirectional flux
%  param.internalNetFluxBounds:     'original' (default) maintains direction and magnitude of net flux from model.lb & model.ub
%                                   'directional' maintains direction of net flux from model.lb & model.ub but not magnitude
%                                   'random' random net flux direction, replacing constraints from model.lb & model.ub
%
%  Parameters related with concentration optimisation:
%  param.maxConc:                   scalar maximum permitted metabolite concentration
%  param.externalNetFluxBounds:
%
%  model.gasConstant:    scalar gas constant (default 8.31446261815324 J K^-1 mol^-1)
%  model.T:              scalar temperature (default 310.15 Kelvin)
%
%
% OUTPUTS:
% solution: solution structure with the following fields
%
%           *.v:   n x 1 double net flux
%           *.vf:  n x 1 double unidirectional forward internal reaction flux
%           *.vr:  n x 1 double unidirectional reverse internal reaction flux
%           *.vt:  scalar total internal reaction flux sum(vf + vr)
%           *.y_N: m × 1 double dual variable to steady state constraints
%           *.y_C: z × 1 double dual variable to coupling constraints
%           *.y_vi: n x 1 double dual variable to box constraints on internal net flux
%           *.z_v: (n + k) x 1 double dual variable to box constraints on net flux
%           *.z_vf: n x 1 double dual variable to box constraints on forward flux
%           *.z_vr: n x 1 double dual variable to box constraints on reverse flux
%           *.time: solve time
%           *.stat: COBRA toolbox standard solution status
%           *.origStat: solution status as provided by the solver
%
%  modelOut: solved model with optional input fields populated by defaults, if they were not provided           
%                                   
% EXAMPLE:
%
% NOTE:
%
% Author(s): Ronan M.T. Fleming 2021
    
%%
if ~exist('param','var')
    param = struct();
end
if ~isfield(param,'printLevel')
    param.printLevel=1;
end
if ~isfield(param,'debug')
    param.debug=false;
end
if ~isfield(param,'solver')
    param.solver='mosek';
end
if ~isfield(param,'method')
    param.method='fluxes';
end

if ~isfield(model,'osenseStr') || isempty(model.osenseStr)
    %default linear objective sense is maximisation
    model.osenseStr = 'max';
end
[~,osense] = getObjectiveSense(model);

if ~isfield(model, 'csense')
    % if csense is not declared in the model, assume that all
    % constraints are equalities.
    model.csense(1:size(model.S, 1), 1)='E';
end

if ~isfield(model, 'b')
    model.b = zeros(size(model.S, 1), 1);
end

if isfield(model,'C') && ~isfield(model,'d')
    error('model.C present but model.d missing in C*v <=> d')
end

%find the maximal set of metabolites and reactions that are stoichiometrically consistent
if ~isfield(model,'SConsistentMetBool') || ~isfield(model,'SConsistentRxnBool')
    massBalanceCheck=0;
    [~, ~, ~, ~, ~, ~, model, ~] = findStoichConsistentSubset(model, massBalanceCheck, param.printLevel-1);
end
if 0
    %find the maximal set of metabolites and reactions that are flux consistent
    if ~isfield(model,'fluxConsistentMetBool') || ~isfield(model,'fluxConsistentRxnBool')
        findFluxConsistentSubset.z_x0= 1e-6;
        [fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool, model, fluxConsistModel] = findFluxConsistentSubset(model, param, param.printLevel)
    end
    %only use that part of model.S which is stoichiometrically and flux
    %consistent
    N=model.S(model.SConsistentMetBool & fluxConsistentMetBool,model.SConsistentRxnBool & fluxConsistentRxnBool);
end

if any(~model.SConsistentMetBool) || 0
    error(['model.S is incorrectly specified as it contains ' int2str(nnz(~model.SConsistentMetBool)) ' stoichiometrically inconsistent metabolites'])
end

N = model.S(:,model.SConsistentRxnBool);
B = model.S(:,~model.SConsistentRxnBool);

[m,n] = size(N);  % number of metabolities & internal reactions
[~,k] = size(B);  % number of external reactions

%% processing for fluxes
[vl,vu,vel,veu,vfl,vfu,vrl,vru,ci,ce,cf,cr,g] = processFluxConstraints(model,param);

%% optionally processing for concentrations
processConcConstraints

%matrices for padding
Omn = sparse(m,n);
Onm = sparse(n,m);
Onk=sparse(n,k);
Om=sparse(m,m);
Omk=sparse(m,k);
On1 = sparse(n,1);
O1n = sparse(1,n);
O1k=sparse(1,k);
Om1 = sparse(m,1);

Im = speye(m);
In = speye(n);
I1n = ones(1,n);
e   = ones(n,1);

if isfield(model,'C')
    C = model.C(:,model.SConsistentRxnBool);
    nConstr = size(model.C,1);
    Ocn = sparse(nConstr,n);
    Ocm = sparse(nConstr,m);
    D = model.C(:,~model.SConsistentRxnBool);
else
    C = [];
end


if isfield(model,'H')
    Hi = model.H(:,model.SConsistentRxnBool);
    if any(any(Hi))
        error('model.H corresponding to internal reactions is ignored')
    end
    bool = ~model.SConsistentRxnBool & ~isnan(model.h);
    h = model.h(bool);
    H = model.H(bool,bool);
    nH=nnz(bool);
    Och = sparse(nConstr,nH);
    Ohn = sparse(nH,n);
    Ih = speye(nH);
    Ihk = speye(n+k);
    Ihk = Ihk(bool,~model.SConsistentRxnBool);
    Omh = sparse(m,nH);
    Onh = sparse(n,nH);
end

switch param.method
        case {'fluxConc','fluxConcNorm'}
        switch param.solver
            case 'pdco'
                %constraint matrix
                if isfield(model,'C')
                    EPproblem.A  =...
                        [   N,     -N,    Omn,     -Im,    Im,    Om;
                           In,    -In,    -In,     Onm,   Onm,   Onm;
                          Omn,     Omn,   Omn,      Im,   -Im,   -Im;
                            C,     -C,    Ocn,     Ocm,   Ocm,   Ocm];
                    %       vf      vr      v       x     x0     dx
                    EPproblem.b = [model.b;zeros(n+m,1);model.d];
                    
                    EPproblem.csense(1:m,1)=model.csense;
                    EPproblem.csense(m+1:m+n,1)='E';
                    EPproblem.csense(m+n+1:2*m+n,1)='E';
                    EPproblem.csense(2*m+n+1:2*m+n+nConstr,1) = model.dsense;
                else
                    EPproblem.A  = ... 
                        [   N,     -N,    Omn,     -Im,    Im,    Om;
                           In,    -In,    -In,     Onm,   Onm,   Onm;
                          Omn,     Omn,   Omn,      Im,   -Im,   -Im];
                    %       vf      vr      v       x     x0     dx
                    EPproblem.b = [model.b;zeros(n+m,1)];
                    EPproblem.csense(1:m,1)=model.csense;
                    EPproblem.csense(m+1:m+n,1)='E';
                    EPproblem.csense(m+n+1:2*m+n,1)='E';
                end
                
                
                EPproblem.c =...
                    [ci + cf;
                    -ci + cr;
                     zeros(n,1);
                     u0;
                     u0;
                     zeros(m,1)];
                EPproblem.osense = 1; %minimise
                
                %bounds
                EPproblem.lb = [vfl;vrl;vl;model.xl;model.x0l;model.dxl];
                EPproblem.ub = [vfu;vru;vu;model.xu;model.x0u;model.dxu];
                
                if any(EPproblem.lb > EPproblem.ub)
                    if any(vfl>vfu)
                        error('vfl>vfu, i.e. lower bound on dx cannot be greater than upper bound')
                    end
                    if any(vrl>vru)
                        error('vrl>vru, i.e. lower bound on dx cannot be greater than upper bound')
                    end
                    if any(vl>vu)
                        error('vl>vu, i.e. lower bound on dx cannot be greater than upper bound')
                    end
                    if any(model.xl>model.xu)
                        error('model.xl>model.xu i.e. lower bound on dx cannot be greater than upper bound')
                    end
                    if any(model.x0l>model.x0u)
                        error('model.x0l>model.x0u i.e. lower bound on dx cannot be greater than upper bound')
                    end
                    if any(model.dxl>model.dxu)
                        bool = (model.dxl~=0 | model.dxu~=0) & model.dxl>model.dxu;
                        T=table(model.dxl(bool),model.dxu(bool));
                        disp(T)
                        error('model.dxl>model.dxu i.e. lower bound on dx cannot be greater than upper bound')
                    end
                end
                %variables for entropy maximisation
                EPproblem.d=[g;g;zeros(n,1);f;f;zeros(m,1)];
                
                    
                solution = solveCobraEP(EPproblem,param);
        
                if param.printLevel>1
                    fprintf('%8.2g %s\n',norm(EPproblem.A*solution.full + solution.slack - EPproblem.b,inf),'||  A*x + s - b ||_inf')
                end
                
                y_N = solution.dual(1:m);%Already Rockafellar signs
                y_vi   = solution.dual(m+1:m+n);
                 z_dx   = solution.dual(m+n+1:2*m+n);
                if isfield(model,'C')
                    y_C = solution.dual(2*m+n+1:2*m+n+nConstr);
                end
                %fluxes
                vf = solution.full(1:n);
                vr = solution.full(n+1:2*n);
                v  = solution.full(2*n+1:3*n);
                x  = solution.full(3*n+1:3*n+m);
                x0 = solution.full(3*n+m+1:3*n+2*m);
                dx = solution.full(3*n+2*m+1:3*n+3*m);
                
                ve = -B'*(x - x0);
                
                % duals to bounds on unidirectional fluxes
                z_vf = solution.rcost(1:n,1);
                z_vr  = solution.rcost(n+1:2*n,1);
                % duals to bounds on net fluxes
                z_vi = solution.rcost(2*n+1:3*n,1);
                %dual to bounds on concentration
                z_x = solution.rcost(3*n+1:3*n+m,1);
                z_x0 = solution.rcost(3*n+m+1:3*n+2*m,1);
                %dual to bounds on change in concentration
                eta2 = solution.rcost(3*n+2*m+1:3*n+3*m,1);
                
                %extra checks
                if param.printLevel>0
                    fprintf('%s\n','Primal optimality conditions')
                    fprintf('%8.2g %s\n',norm(N*(vf - vr) - x + x0 - model.b,inf),'|| N*(vf - vr) - x + x0 - b ||_inf');
                    fprintf('%8.2g %s\n',norm(N*(vf - vr) + B*ve - model.b,inf),'|| N*(vf - vr) + B*ve - b ||_inf');
                    fprintf('%8.2g %s\n',norm(vf - vr - v,inf),'|| vf - vr - v ||_inf');
                    fprintf('%8.2g %s\n',norm(x - x0 - dx,inf),'|| x - x0 - dx ||_inf');
                    if isfield(model,'C')
                    
                    end
                    fprintf('%s\n','Dual optimality conditions (fluxes)')
                    if isfield(model,'C')
                        fprintf('%8.2g %s\n',norm(g.*reallog(vf) + ci + cf + N'*y_N + C'*y_C + y_vi + z_vf,inf), '|| g.*log(vf) + ci + cf + N''*y_N + C''*y_C + y_vi  + z_vf ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr) - ci + cr - N'*y_N - C'*y_C - y_vi + z_vr,inf),'|| g.*log(vr) - ci + cr - N''*y_N - C''*y_C - y_vi  + z_vr ||_inf');
                    else
                        fprintf('%8.2g %s\n',norm(g.*reallog(vf) + ci + cf + N'*y_N + y_vi + z_vf,inf), '|| g.*log(vf) + ci + cf + N''*y_N + y_vi  + z_vf ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr) - ci + cr - N'*y_N - y_vi + z_vr,inf),'|| g.*log(vr) - ci + cr - N''*y_N - y_vi  + z_vr ||_inf');
                    end
                    fprintf('%8.2g %s\n',norm(-y_vi + z_vi,inf),'|| - y_vi  + zeta2 ||_inf');
                    fprintf('%s\n','Dual optimality conditions (concentrations)')
                    fprintf('%8.2g %s\n',norm(f.*reallog(x) + u0 - y_N + z_dx + z_x,inf), '|| f.*log(x) + u0 - y_N + z_dx + z_x ||_inf');
                    fprintf('%8.2g %s\n',norm(f.*reallog(x0) + u0 + y_N - z_dx + z_x0,inf),'|| f.*log(x0) + u0 + y_N - z_dx + z_x0 ||_inf');
                    fprintf('%8.2g %s\n',norm(-z_dx + eta2,inf),'|| - z_dx  + eta2 ||_inf');
                    
  
                    fprintf('\n%s\n','Thermo conditions (fluxes)')
                    if isfield(model,'C')
                        fprintf('%8.2g %s\n',norm(reallog(vr./vf) - N'*y_N - C'*y_C,inf),'|| log(vr./vf) - N''*y_N - C''*y_C ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) - 2*N'*y_N - 2*C'*y_C,inf),'|| d.*log(vr./vf) - 2*N''*y_N - 2*C''*y_C ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*N'*y_N - 2*C'*y_C - 2*y_vi - z_vf + z_vr,inf),'|| g.*log(vr./vf) + cr - cf - 2*N''*y_N - 2*y_vi - z_vf + z_vr ||_inf');
                    else
                        fprintf('%8.2g %s\n',norm(reallog(vr./vf) - N'*y_N,inf),'|| log(vr./vf) - N''*y_N ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) - 2*N'*y_N,inf),'|| d.*log(vr./vf) - 2*N''*y_N ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*N'*y_N - 2*y_vi,inf),'|| g.*log(vr./vf) + cr - cf - 2*N''*y_N - 2*y_vi ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*N'*y_N - 2*y_vi + z_vf - z_vr,inf),'|| g.*log(vr./vf) + cr - cf - 2*N''*y_N - 2*y_vi + z_vf - z_vr ||_inf');
                    end
                    
                    fprintf('%s\n','Effects of internal bounds on fluxes')
                    fprintf('%8.2g %s\n',norm(y_vi,inf),'|| y_vi ||_inf');
                    fprintf('%8.2g %s\n',norm(z_vf,inf),'|| z_vf ||_inf');
                    fprintf('%8.2g %s\n',norm(z_vr,inf),'|| z_vr ||_inf');

                    
                    fprintf('\n%s\n','Thermo conditions (concentrations)')
                    fprintf('%8.2g %s\n',norm(f.*reallog(x./x0) - 2*y_N + 2*z_dx + z_x - z_x0,inf),'|| f.*log(x/x0) - 2*y_N + 2*z_dx + z_x - z_x0 ||_inf');
                    
                    fprintf('%s\n','Effects of internal bounds on concentrations')
                    fprintf('%8.2g %s\n',norm(z_dx,inf),'|| z_dx ||_inf');
                    fprintf('%8.2g %s\n',norm(z_x,inf),'|| z_x ||_inf');
                    fprintf('%8.2g %s\n',norm(z_x0,inf),'|| z_x0 ||_inf');                  
                    pause(0.001)
                    
                     if isfield(model,'C')
                         fprintf('\n%s\n','Effects of coupling constraints on fluxes')
                         fprintf('%8.2g %s\n',norm(y_C,inf),'|| y_C ||_inf');
                     end
                    d1=solution.d1;
                    d2=solution.d2;
                    fprintf('\n%s\n','Optimality conditions (regularised)')
                    fprintf('%8.2g %s\n',norm(N*(vf - vr) - x + x0 - model.b - (d2^2)*y_N,inf),'|| N*(vf - vr) + B*ve - b - (d2^2)*y_N ||_inf');
                    fprintf('%8.2g %s\n',norm(vf - vr - v - (d2^2)*y_vi,inf),'|| vf - vr - v -  (d2^2)*y_vi ||_inf');
                    if isfield(model,'C')
                        fprintf('%8.2g %s\n',norm(g.*reallog(vf) + cf + N'*y_N + C'*y_C + y_vi  + z_vf - (d1^2)*vf,inf), '|| g.*log(vf) + cf + N''*y_N + C''*y_C + y_vi  - z_vf - (d1^2)*vf||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr) + cr - N'*y_N - C'*y_C - y_vi  + z_vr - (d1^2)*vr,inf),  '|| g.*log(vr) + cr - N''*y_N - C''*y_C - y_vi -  z_vr - (d1^2)*vr||_inf');
                    else
                        fprintf('%8.2g %s\n',norm(g.*reallog(vf) + cf + N'*y_N + y_vi  + z_vf - (d1^2)*vf,inf), '|| g.*log(vf) + cf + N''*y_N + y_vi  - z_vf - (d1^2)*vf||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr) + cr - N'*y_N - y_vi  + z_vr - (d1^2)*vr,inf),  '|| g.*log(vr) + cr - N''*y_N - y_vi -  z_vr - (d1^2)*vr||_inf');
                    end
                    fprintf('%8.2g %s\n',norm(f.*reallog(x) + u0 - y_N + z_dx + z_x - (d1^2)*x,inf), '|| f.*log(x) + u0 - y_N + z_dx - z_x - (d1^2)*x ||_inf');
                    fprintf('%8.2g %s\n',norm(f.*reallog(x0) + u0 + y_N - z_dx + z_x0 - (d1^2)*x0,inf),'|| f.*log(x0) + u0 + y_N + z_dx + z_x0 - (d1^2)*x0 ||_inf');
                    
                    fprintf('\n%s\n','Thermo conditions (regularised)')
                    fprintf('%8.2g %s\n',norm((d1^2)*(vr - vf),inf),'|| (d1^2)*(vr - vf) ||_inf');
                    if isfield(model,'C')
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*N'*y_N - 2*C'*y_C - 2*y_vi - z_vf + z_vr - (d1^2)*(vr -vf),inf),'|| g.*log(vr./vf) + cr - cf - 2*N''*y_N - 2*y_vi - z_vf + z_vr - (d1^2)*(vr -vf) ||_inf');
                    else
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*N'*y_N - 2*y_vi + z_vf - z_vr + (d1^2)*(vr -vf),inf),'|| g.*log(vr./vf) + cr - cf - 2*N''*y_N - 2*y_vi + z_vf - z_vr + (d1^2)*(vr -vf) ||_inf');
                    end
                    fprintf('%8.2g %s\n',norm((d1^2)*(x - x0),inf),'|| (d1^2)*(x - x0) ||_inf');
                    fprintf('%8.2g %s\n',norm(f.*reallog(x./x0) - 2*y_N + 2*z_dx + z_x - z_x0 + (d1^2)*(x - x0),inf),'|| f.*log(x/x0) - 2*y_N + 2*z_dx + z_x - z_x0 + (d1^2)*(x - x0) ||_inf');
                    
                end
                
         case 'mosek'
                %%
                %         https://docs.mosek.com/modeling-cookbook/expo.html
                %         min  (d.*x)'*(log(x./y) + c)
                %         s.t. l <= A[x;y] <= u
                %
                %         where d,c,A,l,u are data and x,y are variables, is equivalent to
                %
                %         min   d*t + d*c*x
                %         s.t.   t >= x*log(x/y)
                %         l <= A[x;y] <= u
                %
                %         which is equivalent to:
                %
                %         min   d*t + d*c*x
                %         s.t.   (y, x, -t) \in K_{exp}
                %         l <= A[x;y] <= u
                %
                %         Such a problem could be formulated using the Affine conic constraints, as shown in the following code:
                
                %B=B*0;
                
                %constraint matrix
                if isfield(model,'C')    
                    EPproblem.A  = [ ...
                        N,    -N,     B,   -Im,    Im;
                        In,  -In,   Onk,   Onm,   Onm;
                        Omn,  Omn,  Omk,    Im,   -Im;
                        C,   -C,    D,   Ocm,   Ocm];
                    %     vf,   vr,    w,     x,    x0
                    EPproblem.blc = [model.b;vl;model.dxl;model.d];
                    EPproblem.buc = [model.b;vu;model.dxu;model.d];
                    csense(1:size(EPproblem.A,1),1)='E';
                    csense(1:m,1)=model.csense;
                    csense(2*m+n+1:2*m+n+nConstr,1) = model.dsense;
                else
                    EPproblem.A  =...
                        [N,     -N,    B,   -Im,    Im;
                        In,    -In,  Onk,   Onm,   Onm;
                         Omn,  Omn,  Omk,    Im,   -Im];
                    %     vf,   vr,    w,     x,    x0
                    EPproblem.blc = [model.b;vl;model.dxl];
                    EPproblem.buc = [model.b;vu;model.dxu];
                    csense(1:size(EPproblem.A,1),1)='E';
                    csense(1:m,1)=model.csense;
                end
                
                EPproblem.buc(csense == 'G') = inf;
                EPproblem.blc(csense == 'L') = -inf;
                
                if strcmp(param.method,'fluxConcNorm')
                    EPproblem.c =...
                        [ci + cf;
                        -ci + cr;
                        ce;
                        u0;
                        u0];
                else
                    EPproblem.c =...
                        [ci + cf - g;
                        -ci + cr - g;
                        ce;
                        u0 - f;
                        u0 - f];
                end
                EPproblem.osense = 1; %minimise
                
                %bounds
                EPproblem.lb = [vfl;vrl;vel;model.xl;model.x0l];
                EPproblem.ub = [vfu;vru;veu;model.xu;model.x0u];
                
                %variables for entropy maximisation
                %           vf, vr,         w, x, x0
                EPproblem.d=[g; g; zeros(k,1); f;  f];
                
                if strcmp(param.method,'fluxConcNorm')
                    P = sparse(3,size(EPproblem.A,2));
                    P(1,1:2*n)=1; % normalisation of forward + reverse fluxes
                    P(2,2*n+k+1:2*n+k+m)=1; % normalisation of concentration
                    P(3,2*n+k+m+1:2*n+k+2*m)=1;  %normalisation of initial concentration
                    EPproblem.P = P;
                    pBool=(sum(EPproblem.P,1)~=0)'; %identify normalised variables
                    [p,~] = size(EPproblem.P);
                    EPproblem.sumFluxes = 2*(sum(model.x0u)+1e-6);
                    EPproblem.sumConc  = sum(model.x0u)+1e-6;
                    EPproblem.sumConc0 = sum(model.x0u)+1e-6;
                else
                    P = zeros(3,size(EPproblem.A,2));
                    pBool = false(size(EPproblem.A,2),1);
                    p = 0;
                    EPproblem.sumFluxes = [];
                    EPproblem.sumConc = [];
                    EPproblem.sumConc0 = [];
                end
                q = any(EPproblem.d & ~pBool)+0;
                
                solution = solveCobraEP(EPproblem,param);
                
                if solution.stat~=1
                    nInfLB = nnz(~isfinite(EPproblem.lb));
                    nInfUB = nnz(~isfinite(EPproblem.ub));
                    disp([int2str(nInfLB) ' non-finite lower bounds'])
                    disp([int2str(nInfUB) ' non-finite upper bounds'])
                    disp(['solution.stat = ' num2str(solution.stat)])
                    disp(['solution.origStat = ' solution.origStat])
                    error('solveCobraEP did not solve')
                end
                
                % Primal variables
                % vf, vr, ve, x , x0
                vf = solution.full(1:n);
                vr = solution.full(n+1:2*n);
                ve = solution.full(2*n+1:2*n+k);
                x  = solution.full(2*n+k+1:2*n+k+m);
                x0 = solution.full(2*n+k+m+1:2*n+k+2*m);
                
                % Primal normalisation variables
                if q
                    t_1 = 0;
                else
                    t_1 = solution.auxPrimal(1);
                end
                if strcmp(param.method,'fluxConcNorm')
                    t_vfvr = solution.auxPrimal(q+1);
                    t_x = solution.auxPrimal(q+2);
                    t_x0 = solution.auxPrimal(q+3);
                else
                    t_vfvr = 1;
                    t_x    = 1;
                    t_x0   = 1;
                end
                
                %slack variable
                slack   = solution.slack;
                
                %% Dual variables corresponding to constraints
                % dual to steady state constraints
                y_N  = solution.dual(1:m); 
                %dual to bounds on net flux
                y_vi    = solution.dual(m+1:m+n); 
                %dual to bounds on change in concentration
                z_dx     = solution.dual(m+n+1:2*m+n); 
                %dual to coupling constraints
                if isfield(model,'C')
                    y_C = solution.dual(2*m+n+1:2*m+n+nConstr);
                end
                %dual to normalisation constraints
                if strcmp(param.method,'fluxConcNorm')
                    y_vt = solution.dualNorm(1);
                    y_xt = solution.dualNorm(2);
                    y_x0t = solution.dualNorm(3);
                else
                    y_vt = -g; %cancel out 
                    y_xt = -f;
                    y_x0t = -f;
                end
                
                % Primal auxiliary variables of affine conic constraints
                e_vf  = solution.auxPrimal(q+p+1:q+p+n);
                e_vr  = solution.auxPrimal(q+p+n+1:q+p+2*n);
                e_x  = solution.auxPrimal(q+p+2*n+1:q+p+2*n+m);
                e_x0 = solution.auxPrimal(q+p+2*n+m+1:q+p+2*n+2*m);
                
                % Dual variables to affine conic constraints
                y_K       = solution.coneDual;
                
                % Dual to affine conic constraints reordered by F matrix
                Fty_K = solution.coneF'*y_K; %Rockafeller signs
                k_vf  = Fty_K(1:n);
                k_vr  = Fty_K(n+1:2*n);
                k_ve  = Fty_K(2*n+1:2*n+k);
                k_x   = Fty_K(2*n+k+1:2*n+k+m);
                k_x0  = Fty_K(2*n+k+m+1:2*n+k+2*m);
                if q
                    k_e_1  = Fty_K(2*n+k+2*m+1);
                else
                    k_e_1 = 0;     
                end
                if strcmp(param.method,'fluxConcNorm')
                    k_vt    = Fty_K(q+2*n+k+2*m+1);
                    k_xt    = Fty_K(q+2*n+k+2*m+2);
                    k_x0t   = Fty_K(q+2*n+k+2*m+3);
                end
                k_e_vf  = Fty_K(q+2*n+k+2*m+p+1:q+3*n+k+2*m+p);
                k_e_vr  = Fty_K(q+3*n+k+2*m+p+1:q+4*n+k+2*m+p);
                k_tx  = Fty_K(q+4*n+k+2*m+p+1:q+4*n+k+3*m+p);
                k_tx0 = Fty_K(q+4*n+k+3*m+p+1:q+4*n+k+4*m+p);
                
                
                % duals to bounds on forward unidirectional fluxes
                z_vf   = solution.rcost(1:n,1);
                % duals to bounds on reverse unidirectional fluxes
                z_vr    = solution.rcost(n+1:2*n,1);
                %duals to bounds on final concentration
                z_x   = solution.rcost(2*n+k+1:2*n+k+m,1);
                %duals to bounds on initial concentration
                z_x0 = solution.rcost(2*n+k+m+1:2*n+k+2*m,1);
                
                if strcmp(param.method,'fluxConcNorm')
                    %dual to bounds on total forward and reverse flux
                    z_vt  = solution.rcost(2*n+k+2*m+1);
                    %dual to bounds on total concentration
                    z_xt    = solution.rcost(2*n+k+2*m+2);
                    %dual to bounds on total initial concentration
                    z_x0t  = solution.rcost(2*n+k+2*m+3);
                    %                 else
                    %                     z_vt = 0;
                    %                     z_xt = 0;
                    %                     z_x0t =0;
                end
                % Dual variables corresponding to bounds on auxiliary variables.
                if q
                    z_t   = solution.auxRcost(1); % 1
                else
                    z_t = 0; 
                end
                z_t_f   = solution.auxRcost(q+1:q+n); % tf
                z_t_r   = solution.auxRcost(q+n+1:q+2*n); % tr
                z_t_x   = solution.auxRcost(q+2*n+1:q+2*n+m); % tx
                z_t_x0  = solution.auxRcost(q+2*n+m+1:q+2*n+2*m); % tx0
                
                %         Tf = table(reallog(vf/vt), 1,cf,N'*y_N,e*z_dx,z_vf,wvf)
                %         Tf = table(reallog(vr/vt), 1,cr,N'*y_N,e*z_dx,z_vr,wvr)
                %         T = table(reallog(vf/vt),cf,N'*y_N)
                
                %extra checks
                if param.printLevel>0
                    fprintf('\n%s\n','Optimality conditions (biochemistry)')
                    %primal
                    fprintf('%8.2g %s\n',norm(N*(vf - vr) + B*ve - x + x0 - model.b,inf),'|| N*(vf - vr) + B*ve - x + x0 - b ||_inf');
                    %dual
                    if isfield(model,'C')
                        fprintf('%8.2g %s\n',norm(k_vf + cf + ci + N'*y_N + C'*y_C + y_vi - z_vf + y_vt,inf), '|| k_vf - g + cf + ci + N''*y_N + C''*y_C + y_vi - z_vf + y_vt ||_inf');
                        fprintf('%8.2g %s\n',norm(k_vr + cr - ci - N'*y_N - C'*y_C - y_vi - z_vr + y_vt,inf),  '|| k_vr - g + cr - ci - N''*y_N - C''*y_C - y_vi -  z_vr + y_vt ||_inf');
                    else
                        fprintf('%8.2g %s\n',norm(k_vf + cf + ci + N'*y_N + y_vi - z_vf + y_vt,inf), '|| k_vf - g + cf + ci + N''*y_N + y_vi - z_vf + y_vt ||_inf');
                        fprintf('%8.2g %s\n',norm(k_vr + cr - ci - N'*y_N - y_vi - z_vr + y_vt,inf),  '|| k_vr - g + cr - ci - N''*y_N - y_vi -  z_vr + y_vt ||_inf');
                    end
                    fprintf('%8.2g %s\n',norm(k_x + u0 - y_N + z_dx + z_x + y_xt,inf),   '|| k_x  + u0 - y_N + z_dx + z_x  + y_xt ||_inf');
                    fprintf('%8.2g %s\n',norm(k_x0 + u0 + y_N - z_dx + z_x0 + y_x0t,inf),'|| k_x0 + u0 + y_N - z_dx + z_x0 + y_x0t ||_inf');
                    
                    if strcmp(param.method,'fluxConcNorm')
                        fprintf('%8.2g %s\n',norm(k_vt - y_vt + z_vt,inf),'|| k_vt - y_vt + z_vt ||_inf');
                        fprintf('%8.2g %s\n',norm(k_xt - y_xt + z_xt,inf),'|| k_xt - y_xt + z_xt ||_inf');
                        fprintf('%8.2g %s\n',norm(k_x0t - y_x0t + z_x0t,inf),'|| k_x0t - y_x0t + z_x0t ||_inf');
                    else
                        fprintf('%8.2g %s\n',norm(k_e_1 + z_t,inf),'|| k_1 + z_t ||_inf');
                    end
                    
                    fprintf('%8.2g %s\n',norm(k_e_vf - g - z_t_f,inf),'|| k_e_vf - g - z_t_f ||_inf');
                    fprintf('%8.2g %s\n',norm(k_e_vr - g  - z_t_r,inf),'|| k_e_vr - g  - z_t_r ||_inf');
                    fprintf('%8.2g %s\n',norm(k_tx - f  - z_t_x,inf),'|| k_tx - f  - z_t_x ||_inf');
                    fprintf('%8.2g %s\n',norm(k_tx0 - f - z_t_x0,inf),'|| k_tx0 - f - z_t_x0 ||_inf');
                    
                    fprintf('%8.2g %s\n',norm(e_vf  +  vf.*reallog(vf./t_vfvr),inf), '|| t_f + vf*log(vf/(1''*(vf + vr))) ||_inf');
                    fprintf('%8.2g %s\n',norm(e_vr  +  vr.*reallog(vr./t_vfvr),inf), '|| t_r + vr*log(vr/(1''*(vf + vr))) ||_inf');
                    fprintf('%8.2g %s\n',norm(e_x  +   x.*reallog( x./t_x),inf), '|| t_x + x*log(x/(1''*x)) ||_inf');
                    fprintf('%8.2g %s\n',norm(e_x0 +  x0.*reallog(x0./t_x0),inf), '|| t_x0 + x0*log(x0/(1''*x0)) ||_inf');
                    
                    fprintf('\n%s\n','Derived optimality conditions (fluxes)')
                    if param.printLevel>1
                        fprintf('%8.2g %s\n',norm(k_vf - g.*reallog(vf./t_vfvr) - g,inf), '|| k_vf - g.*log(vf) - g ||_inf');
                        fprintf('%8.2g %s\n',norm(k_vr - g.*reallog(vr./t_vfvr) - g,inf), '|| k_vr - g.*log(vr) - g ||_inf');
                    end
                    
                    if isfield(model,'C')
                        fprintf('%8.2g %s\n',norm(g.*reallog(vf./t_vfvr) + cf + ci + N'*y_N + C'*y_C + y_vi - z_vf,inf), '|| g.*log(vf) + cf + ci + N''*y_N + C''*y_C + y_vi - z_vf ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./t_vfvr) + cr - ci - N'*y_N - C'*y_C - y_vi - z_vr,inf),'|| g.*log(vr) + cr - ci - N''*y_N  - C''*y_C - y_vi - z_vr ||_inf');
                    else
                        fprintf('%8.2g %s\n',norm(g.*reallog(vf./t_vfvr) + cf + ci + N'*y_N + y_vi +  - z_vf,inf), '|| g.*log(vf) + cf + ci + N''*y_N - z_vf ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./t_vfvr) + cr - ci - N'*y_N - y_vi +  - z_vr,inf),'|| g.*log(vr) + cr - ci - N''*y_N  +  - z_vr ||_inf');
                    end
                    
                    fprintf('\n%s\n','Effects of internal bounds on net fluxes')
                    fprintf('%8.2g %s\n',norm(y_vi,inf),'|| y_vi ||_inf');
                    fprintf('\n%s\n','Effects of internal bounds on forward fluxes')
                    fprintf('%8.2g %s\n',norm(z_vf,inf),'|| z_vf ||_inf');
                    fprintf('\n%s\n','Effects of internal bounds on reverse fluxes')
                    fprintf('%8.2g %s\n',norm(z_vr,inf),'|| z_vr ||_inf');
                    
                    
                    fprintf('\n%s\n','Derived optimality conditions (concentrations)')
                    if param.printLevel>1
                        fprintf('%8.2g %s\n',norm(k_x - f.*reallog(x./t_x) - f,inf),    '|| sx  - f.*log( x/ (1''*x)) - f ||_inf');
                        fprintf('%8.2g %s\n',norm(k_x0 - f.*reallog(x0./t_x0) - f,inf), '|| sx0 - f.*log(x0/(1''*x0)) - f ||_inf');
                        fprintf('%8.2g %s\n',norm(f.*reallog(x./t_x) + f  + u0 - y_N + z_dx + z_x + y_xt,inf), '|| f.*log(x/(1''*x)) + f + u0 - y_N + z_dx + z_x + y_vt ||_inf');
                        fprintf('%8.2g %s\n',norm(f.*reallog(x0./t_x0) + f + u0 + y_N - z_dx + z_x0 + y_x0t,inf),'|| f.*log(x0/(1''*x0)) + f + u0 + y_N - z_dx + z_x0 + y_xt ||_inf');
                        
                    end
                    fprintf('%8.2g %s\n',norm(f.*reallog(x./t_x)  + u0 - y_N + z_dx + z_x,inf), '|| f.*log(x/(1''*x)) + u0 - y_N + z_dx + z_x ||_inf');
                    fprintf('%8.2g %s\n',norm(f.*reallog(x0./t_x0) + u0 + y_N - z_dx + z_x0,inf),'|| f.*log(x0/(1''*x0)) + u0 + y_N - z_dx + z_x0 ||_inf');
                    
                    fprintf('\n%s\n','Thermo conditions (fluxes)')
                    if isfield(model,'C')
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) - 2*N'*y_N - 2*C'*y_C,inf),'|| g.*log(vr/vf) - 2*N''*y_N - 2*C''*y_C ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N - 2*C'*y_C - 2*y_vi,inf),'|| g.*log(vr/vf) + cr - cf - 2*ci - 2*N''*y_N - 2*C''*y_C - 2*y_vi ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N - 2*C'*y_C - 2*y_vi - z_vr + z_vf,inf),'|| g.*log(vr/vf) + cr - cf - 2*ci - 2*N''*y_N - 2*C''*y_C - 2*y_vi - z_vr + z_vf ||_inf');
                    else
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) - 2*N'*y_N,inf),'|| g.*log(vr/vf) - 2*N''*y_N ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N - 2*y_vi,inf),'|| g.*log(vr/vf) + cr - cf - 2*ci - 2*N''*y_N - 2*y_vi ||_inf');
                        fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N - 2*y_vi - z_vr + z_vf,inf),'|| g.*log(vr/vf) + cr - cf - 2*ci - 2*N''*y_N - 2*y_vi - z_vr + z_vf ||_inf');
                    end
                    
                    fprintf('\n%s\n','Thermo conditions (concentrations)')
                    if strcmp(param.method,'fluxConcNorm')
                        fprintf('%8.2g %s\n',norm(f.*reallog(x./t_x) - f.*reallog(x0./t_x0) - 2*y_N + 2*z_dx + z_x - z_x0 + y_xt - y_x0t,inf),'|| f.*(log(x/(1''*x)) - log(x0/(1''*x0))) - 2*y_N + 2*z_dx + z_x - z_x0 + y_xt - y_x0t ||_inf');
                    else
                        fprintf('%8.2g %s\n',norm(f.*reallog(x) - f.*reallog(x0) - 2*y_N + 2*z_dx + z_x - z_x0,inf),'|| f.*(log(x/x0)) - 2*y_N + 2*z_dx + z_x - z_x0 ||_inf');
                    end
                    
                    fprintf('\n%s\n','Effects of internal bounds on change in concentrations')
                    fprintf('%8.2g %s\n',norm(z_dx,inf),'|| z_dx ||_inf');
                    fprintf('\n%s\n','Effects of internal bounds on concentrations')
                    fprintf('%8.2g %s\n',norm(z_x,inf),'|| z_x ||_inf');
                    fprintf('\n%s\n','Effects of internal bounds on initial concentrations')
                    fprintf('%8.2g %s\n',norm(z_x0,inf),'|| z_x0 ||_inf');
                    
                    if isfield(model,'C')
                        fprintf('\n%s\n','Effects of coupling constraints on fluxes')
                        fprintf('%8.2g %s\n',norm(y_C,inf),'|| y_C ||_inf');
                    end
                    
                    fprintf('%8.2g %s\n',min(slack(slack~=0)), 'min(slack)');
                    fprintf('%8.2g %s\n',max(slack(slack~=0)), 'max(slack)');
                end
                
                
                switch param.externalNetFluxBounds
                    case 'dxReplacement'
                        ve = model.S(:,~model.SConsistentRxnBool)\(x-x0);
                        pause(0.1)
                end
        end
    case 'fluxes'
        switch param.solver
            case 'pdco'
                %constraint matrix
                if isfield(model,'C')
                    EPproblem.A  =[...
                         N,     -N,    Omn,     B;
                        In,    -In,    -In,   Onk;
                         C,     -C,    Ocn,     D];
                    %       vf      vr      v      w
                    EPproblem.b = [model.b;zeros(n,1);model.d];
                    EPproblem.csense(1:length(EPproblem.b),1)='E';
                    EPproblem.csense(1:m,1)=model.csense;
                    EPproblem.csense(m+n+1:m+n+nConstr,1) = model.dsense;
                else
                    EPproblem.A  = ...
                        [N,     -N,    Omn,    B;
                        In,    -In,    -In,   Onk];
                    %       vf      vr      v      w
                    EPproblem.b = [model.b;zeros(n,1)];
                    EPproblem.csense(1:length(EPproblem.b),1)='E';
                    EPproblem.csense(1:m,1)=model.csense;
                end
                
                if isfield(model,'Q')
                    EPproblem.Q = sparse(size(EPproblem.A,2),size(EPproblem.A,2));
                    Qv = model.Q(model.SConsistentRxnBool,model.SConsistentRxnBool);
                    EPproblem.Q(2*n+1:3*n,2*n+1:3*n) = Qv;
                    Qve = model.Q(~model.SConsistentRxnBool,~model.SConsistentRxnBool);
                    EPproblem.Q(3*n+1:3*n+k,3*n+1:3*n+k) = Qve;
                else
                    Qv = sparse(n,n);
                    Qve = sparse(k,k);
                end
                
                EPproblem.c =...
                    [ci + cf; %ci already includes sign for minimisation or maximisation
                    -ci + cr;
                    zeros(n,1);
                    ce];
                EPproblem.osense = 1; %minimise
                
                %bounds
                EPproblem.lb = [vfl;vrl;vl;vel];
                EPproblem.ub = [vfu;vru;vu;veu];
                
                %variables for entropy maximisation
                EPproblem.d=zeros(size(EPproblem.A,2),1);
                EPproblem.d(1:2*n)=[g;g];
                
                solution = solveCobraEP(EPproblem,param);
                if 0
                    save('infeasibleEPproblem.mat','EPproblem','model')
                    return
                end
                
                switch solution.stat
                    case 1
                        y_N = solution.dual(1:m);%Already Rockafellar signs
                        y_vi = solution.dual(m+1:m+n);
                        
                        if isfield(model,'C')
                            y_C = solution.dual(m+n+1:m+n+nConstr);
                            CtYC = ' + C''y_C';
                            mCtYC = ' - C''y_C';
                            CtYC2 = ' + 2*C''y_C';
                            mCtYC2 = ' - 2*C''y_C';
                        else
                            C = sparse(0,n);
                            y_C = sparse(0);
                            CtYC = '';
                            mCtYC = '';
                            CtYC2 = '';
                            mCtYC2 = '';
                        end
                        
                        if isfield(model,'Q')
                            Qdotv = ' + Q*v ';
                            %mQdotv = ' - Q*v ';
                            Qdotve = ' + Q*ve ';
                        else
                            Qdotv = '';
                            Qdotve = '';                           
                        end
                            
                        %fluxes
                        vf = solution.full(1:n);
                        vr = solution.full(n+1:2*n);
                        v  = solution.full(2*n+1:3*n);
                        ve  = solution.full(3*n+1:3*n+k);
                        
                        %slacks
                        s = solution.slack;
                        s_N = s(1:m,1);
                        if any(s_N)
                            sN = '+ s_N';
                        else
                            sN = '';
                        end
                        s_c = s(m+1:m+n,1);
                        if any(s_c)
                            sc = '+ s_c';
                        else
                            sc = '';
                        end
                        if isfield(model,'C')
                            s_C = s(m+n+1:m+n+nConstr,1);
                        else
                            s_C = sparse(1,0);
                        end
                        
                        % duals to bounds on unidirectional fluxes
                        z_vf = solution.rcost(1:n,1);
                        z_vr  = solution.rcost(n+1:2*n,1);
                        % duals to bounds on internal net fluxes
                        z_vi = solution.rcost(2*n+1:3*n,1);
                        % duals to bounds on external net fluxes
                        z_ve  = solution.rcost(3*n+1:3*n+k,1);

                        %extra checks
                        if param.printLevel>1 || param.debug
                            fprintf('%s\n','Optimality conditions (unregularised)')
                            fprintf('%8.2g %s\n',norm(N*(vf - vr) + B*ve + s_N - model.b,inf),['|| N*(vf - vr) + B*ve ' sN ' - b ||_inf']);
                            fprintf('%8.2g %s\n',norm(vf - vr - v + s_c,inf),['|| vf - vr - v ' sc '||_inf']);
                            if isfield(model,'C')
                                fprintf('%8.2g %s\n',norm(C*(vf - vr) + s_C - model.d,inf),'|| C*(vf - vr) + s_C - d ||_inf, sC = slack variable');
                            end
                            fprintf('%8.2g %s\n',norm(g.*reallog(vf) + cf + ci + N'*y_N  + C'*y_C + Qv*v + y_vi  + z_vf,inf), ['|| g.*log(vf) + g + cf + ci + N''*y_N' CtYC  Qdotv ' + y_vi  + z_vf ||_inf']);
                            fprintf('%8.2g %s\n',norm(g.*reallog(vr) + cr - ci - N'*y_N  - C'*y_C + Qv*v - y_vi  + z_vr,inf),['|| g.*log(vr) + g + cr - ci - N''*y_N' mCtYC  Qdotv ' - y_vi  + z_vr ||_inf']);
                            fprintf('%8.2g %s\n',norm(ce + B'*y_N  + Qve*ve + z_ve,inf),['|| ce + B''*y_N ' Qdotve ' + z_ve ||_inf']);

                            d1=solution.d1;
                            d2=solution.d2;
                            fprintf('\n%s\n','Optimality conditions (regularised)')
                            fprintf('%8.2g %s\n',norm(N*(vf - vr) + B*ve - model.b + (d2^2)*y_N,inf),'|| N*(vf - vr) + B*ve - b + (d2^2)*y_N ||_inf');
                            fprintf('%8.2g %s\n',norm(vf - vr - v + (d2^2)*y_vi,inf),'|| vf - vr - v +  (d2^2)*y_vi ||_inf');
                            fprintf('%8.2g %s\n',norm(g.*reallog(vf) + cf + ci + N'*y_N + C'*y_C + Qv*v + y_vi  + z_vf + (d1^2)*vf,inf), ['|| g.*log(vf) + g + cf + ci + N''*y_N' CtYC2  Qdotv ' + y_vi  + z_vf + (d1^2)*vf ||_inf']);
                            fprintf('%8.2g %s\n',norm(g.*reallog(vr) + cr - ci - N'*y_N - C'*y_C + Qv*v - y_vi  + z_vr + (d1^2)*vr,inf),  ['|| g.*log(vr) + g + cr - ci - N''*y_N' mCtYC2 Qdotv ' - y_vi +  z_vr + (d1^2)*vr ||_inf']);
                            fprintf('%8.2g %s\n',norm(ce + B'*y_N  + Qve*ve + z_ve + (d1^2)*ve,inf),['|| ce + B''*y_N ' Qdotve ' + z_ve  + (d1^2)*ve ||_inf']);

                            fprintf('\n%s\n','Thermo conditions (unregularised)')
                            fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N  - 2*C'*y_C - 2*y_vi - z_vf + z_vr,inf),['|| g.*log(vr./vf) + cr - cf - 2*ci - 2*N''*y_N' mCtYC2 ' - 2*y_vi + z_vf - z_vr ||_inf']);
                            fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N  - 2*C'*y_C - 2*y_vi,inf),['|| g.*log(vr./vf)  + cr - cf - 2*ci - 2*N''*y_N' mCtYC2 ' - 2*y_vi ||_inf']);
                            fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) - 2*ci - 2*N'*y_N,inf),'|| g.*log(vr./vf) - 2*ci - 2*N''*y_N ||_inf');
                            
                            fprintf('\n%s\n','Thermo conditions (regularised)')
                            fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N - 2*C'*y_C - 2*y_vi - z_vf + z_vr + (d1^2)*(vr -vf),inf),['|| g.*log(vr./vf) + cr - cf -2*ci - 2*N''*y_N' mCtYC2 ' - 2*y_vi - z_vf + z_vr + (d1^2)*(vr -vf) ||_inf']);
                            fprintf('%8.2g %s\n',norm(z_vf - z_vr + (d1^2)*(vr -vf),inf),'|| z_vf - z_vr + (d1^2)*(vr -vf) ||_inf');

                            fprintf('\n%s\n','Effects of internal bounds')
                            fprintf('%8.2g %s\n',norm(g.*reallog(vf) + cf + ci + N'*y_N + C'*y_C + Qv*v + y_vi  + z_vf,inf), ['|| g.*log(vf) + g + cf + ci + N''*y_N' CtYC Qdotv ' + y_vi  + z_vf ||_inf']);
                            fprintf('%8.2g %s\n',norm(g.*reallog(vr) + cr - ci - N'*y_N - C'*y_C + Qv*v - y_vi  + z_vr,inf),['|| g.*log(vr) + g + cr - ci - N''*y_N' mCtYC Qdotv ' - y_vi  + z_vr ||_inf']);
                            fprintf('%8.2g %s\n',norm(g.*reallog(vf) + cf + ci + N'*y_N + C'*y_C + Qv*v + y_vi ,inf), ['|| g.*log(vf) + g + cf + ci + N''*y_N' CtYC Qdotv ' + y_vi ||_inf']);
                            fprintf('%8.2g %s\n',norm(g.*reallog(vr) + cr - ci - N'*y_N - C'*y_C + Qv*v - y_vi ,inf),['|| g.*log(vr) + g + cr - ci - N''*y_N' mCtYC Qdotv ' - y_vi ||_inf']);
                            fprintf('%8.2g %s\n',norm(z_vf,inf),'|| z_vf ||_inf');
                            fprintf('%8.2g %s\n',norm(z_vr,inf),'|| z_vr ||_inf');
                            fprintf('%8.2g %s\n',norm(z_vi,inf),'|| z_vi ||_inf');
                            fprintf('%8.2g %s\n',norm(y_vi,inf),'|| y_vi ||_inf');
                            fprintf('%8.2g %s\n',norm(- y_vi + z_vi,inf),'|| -y_vi + z_vi||_inf');
                            
                            fprintf('\n%s\n','Effects of external bounds')
                            fprintf('%8.2g %s\n',norm(ce + B'*y_N  + Qve*ve + z_ve,inf),['|| ce + B''*y_N ' Qdotve ' + z_ve ||_inf']);
                            fprintf('%8.2g %s\n',norm(z_ve,inf),'|| z_ve ||_inf');

                        end
                end
            case 'mosek'
                %%
                %         https://docs.mosek.com/modeling-cookbook/expo.html
                %         min  (d.*x)'*(log(x./y) + c)
                %         s.t. l <= A[x;y] <= u
                %
                %         where d,c,A,l,u are data and x,y are variables, is equivalent to
                %
                %         min   d*t + d*c*x
                %         s.t.   t >= x*log(x/y)
                %         l <= A[x;y] <= u
                %
                %         which is equivalent to:
                %
                %         min   d*t + d*c*x
                %         s.t.   (y, x, -t) \in K_{exp}
                %         l <= A[x;y] <= u
                %
                %         Such a problem could be formulated using the Affine conic constraints, as shown in the following code:
                
                if isfield(model,'H') && isfield(model,'h')
                    if isfield(model,'C') && isfield(model,'d')
                        EPproblem.A  =...
                            [N,     -N,    B,  Omh;
                            In,    -In,  Onk,  Onh;
                            C,      -C,    D,  Och;
                            Ohn,    Ohn, Ihk,  -Ih];
                        %    vf      vr    w    dw
                        EPproblem.blc = [model.b;vl;model.d;h];
                        EPproblem.buc = [model.b;vu;model.d;h];
                        csense(1:size(EPproblem.A,1),1)='E';
                        csense(1:m,1)=model.csense;
                        csense(m+n+1:m+n+nConstr,1) = model.dsense;
                    else
                        EPproblem.A  = ...
                            [N,     -N,    B,  Omk;
                            In,    -In,  Onk,  Onk;
                            Ohn,    Ohn,  Ik,  -Ik];
                        %    vf      vr    w    dw
                        EPproblem.blc = [model.b;vl;h];
                        EPproblem.buc = [model.b;vu;h];
                        csense(1:size(EPproblem.A,1),1)='E';
                        csense(1:m,1)=model.csense;
                    end
                else
                    %constraint matrix
                    if isfield(model,'C') && isfield(model,'d')
                        EPproblem.A  =...
                            [N,     -N,    B;
                            In,    -In,  Onk;
                            C,     -C,   D];
                        %   vf     vr    w
                        EPproblem.blc = [model.b;vl;model.d];
                        EPproblem.buc = [model.b;vu;model.d];
                        csense(1:size(EPproblem.A,1),1)='E';
                        csense(1:m,1)=model.csense;
                        csense(m+n+1:m+n+nConstr,1) = model.dsense;
                    else
                        EPproblem.A  = ...
                            [N,     -N,   B;
                            In,    -In,   Onk];
                        %   vf      vr      w
                        EPproblem.blc = [model.b;vl];
                        EPproblem.buc = [model.b;vu];
                        csense(1:size(EPproblem.A,1),1)='E';
                        csense(1:m,1)=model.csense;
                    end
                end
                
                if isfield(model,'H') && isfield(model,'h')
                    EPproblem.Q = sparse(size(EPproblem.A,2),size(EPproblem.A,2));
                    %minimise Euclidean deviation from h
                    EPproblem.Q(2*n+k+1:2*n+k+nH,2*n+k+1:2*n+k+nH) = H;
                    if isfield(model,'Q')
                        Qv = model.Q(model.SConsistentRxnBool,model.SConsistentRxnBool);
                        EPproblem.Q(1:n,1:n)=Qv; %TODO - this minimises sum of vf + vr rather than difference
                        EPproblem.Q(n+1:2*n,n+1:2*n)=Qv;
                        Qve = model.Q(~model.SConsistentRxnBool,~model.SConsistentRxnBool);
                        EPproblem.Q(2*n+1:2*n+k,2*n+1:2*n+k)=Qve;
                    end
                    quadRows  = any(EPproblem.Q,2);
                    quadCols  = any(EPproblem.Q,1)';
                    quadBool  = quadRows | quadCols;
                    nQuadCone = nnz(quadBool);
                else
                    if isfield(model,'Q')
                        EPproblem.Q = sparse(size(EPproblem.A,2),size(EPproblem.A,2));
                        Qv = model.Q(model.SConsistentRxnBool,model.SConsistentRxnBool);
                        EPproblem.Q(1:n,1:n)=Qv;
                        EPproblem.Q(n+1:2*n,n+1:2*n)=Qv;
                        Qve = model.Q(~model.SConsistentRxnBool,~model.SConsistentRxnBool);
                        EPproblem.Q(2*n+1:2*n+k,2*n+1:2*n+k)=Qve;
                        
                        quadRows  = any(EPproblem.Q,2);
                        quadCols  = any(EPproblem.Q,1)';
                        quadBool  = quadRows | quadCols;
                        nQuadCone = nnz(quadBool);
                    else
                        Qv = sparse(n,n);
                        Qve = sparse(k,k);
                        nQuadCone = 0;
                    end
                end
                %%
                EPproblem.sumFluxes = [];
                EPproblem.sumConc = [];
                EPproblem.sumConc0 = [];
                
                EPproblem.buc(csense == 'G') = inf;
                EPproblem.blc(csense == 'L') = -inf;
                
                if isfield(model,'H') && isfield(model,'h')
                    EPproblem.c =...
                        [ci + cf;
                        -ci + cr;
                        ce;
                        zeros(nH,1)];
                    %bounds
                    EPproblem.lb = [vfl;vrl;vel;-inf*ones(nH,1)];
                    EPproblem.ub = [vfu;vru;veu; inf*ones(nH,1)];
                else
                    EPproblem.c =...
                        [ci + cf;
                        -ci + cr;
                        ce];
                    %bounds
                    EPproblem.lb = [vfl;vrl;vel];
                    EPproblem.ub = [vfu;vru;veu];
                end
                
                EPproblem.osense = 1; %minimise
                
                %variables for entropy maximisation
                EPproblem.d=zeros(size(EPproblem.A,2),1);
                EPproblem.d(1:2*n)=[g;g];
                expConeBool = EPproblem.d~=0;
                nExpCone  = nnz(expConeBool);
                
                %
                if 1
                    mosekParam=param;
                    mosekParam.printLevel=param.printLevel-1;
                    solution = solveCobraEP(EPproblem,mosekParam);
                else
                    [verify,method,printLevel,debug,feasTol,optTol,solver,param] =...
                        getCobraSolverParams('EP',getCobraSolverParamsOptionsForType('EP'),param);
                    
                    solution = solveCobraEP(EPproblem,...
                        'verify',verify,...
                        'method',method,...
                        'printLevel',printLevel,...
                        'debug',debug,...
                        'feasTol',feasTol,...
                        'optTol',optTol,...
                        'solver',solver,...
                        param);
                end
                
                switch solution.stat
                    case 1
                        % Primal variables
                        % vf, vr, ve
                        vf = solution.full(1:n);
                        vr = solution.full(n+1:2*n);
                        
                        zeroVfBool = vf==0;
                        zeroVrBool = vr==0;
                        bool = zeroVfBool | zeroVrBool;
                        if any(zeroVfBool | zeroVrBool)
                            ind = find(bool);
                            fprintf('%8s %8s %8s %8s %8s %8s\n','vfl','vf','vfu','vrl','vr','vru')
                            for i=1:length(ind)
                                fprintf('%8.4g %8.4g %8.4g %8.4g %8.4g %8.4g\n',vfl(ind(i)),vf(ind(i)),vfu(ind(i)),vrl(ind(i)),vr(ind(i)),vru(ind(i)));
                            end 
                        end
                            
                        ve = solution.full(2*n+1:2*n+k);
                        
                        
                        if isfield(model,'H') && isfield(model,'h')
                            dv = solution.full(2*n+k+1:2*n+k+nH);
                            %disp(norm(dv))
                        else
                            dv=[];
                        end
                        
                        
                        
                        expCone1 = (nExpCone>0)+0;
                        quadCone1 = (nQuadCone>0)+0;
                        
                        % Primal auxiliary variables
                        %  x,   1,  p,   e,  1,    q;
                        e_vf_vr = 0*ones(2*n,1);
                        e_1 = 0;
                        if nExpCone>0
                            e_1 = solution.auxPrimal(1);
                            e_vf_vr(expConeBool) = solution.auxPrimal(2:nExpCone+1);
                        end
                        e_vf = e_vf_vr(1:n,1);
                        e_vr = e_vf_vr(n+1:2*n,1);
                        
                        
                        q_vf_vr_ve = 0*ones(2*n+k,1);
                        q_1 = 0;
                        if nQuadCone>0
                            q_1 = solution.auxPrimal(nExpCone + double(nExpCone>0) + 1);
                            q_vf_vr_ve(quadBool) = solution.auxPrimal(nExpCone + double(nExpCone>0) + 2:nExpCone + double(nExpCone>0) + nQuadCone + 1);
                        end
                        q_vf = q_vf_vr_ve(1:n,1);
                        q_vr = q_vf_vr_ve(n+1:2*n,1);
                        q_ve = q_vf_vr_ve(2*n+1:2*n+k,1);
                        
                        
                        %slack variable
                        slack = solution.slack;
                        s_N = solution.slack(1:m);
                        s_v = solution.slack(m+1:m+n);
                        if isfield(model,'C')
                            s_C = solution.slack(m+n+1:m+n+nConstr);
                        end
                        
                        % Dual variables corresponding to constraints
                        y_N   = solution.dual(1:m); %dual to steady state constraints
                        y_vi   = solution.dual(m+1:m+n); %dual to bounds on net flux
                        if isfield(model,'C')
                            y_C   = solution.dual(m+n+1:m+n+nConstr);
                        else
                            y_C  = zeros(0,0);
                        end
                        
                        % Dual variables to affine conic constraints
                        y_K = solution.coneDual;
                        
                        % Dual variables corresponding to bounds on variables.
                        z_vf  = solution.rcost(1:n,1);
                        z_vr  = solution.rcost(n+1:2*n,1);
                        z_ve  = solution.rcost(2*n+1:2*n+k,1);
                                                
                        % Dual variables corresponding to bounds on auxiliary variables.
                        z_e_vf_vr = 0*ones(2*n+k,1);
                        z_e_1 = 0;
                        if nExpCone>0
                            z_e_1 = solution.auxRcost(1); % 1
                            z_e_vf_vr(expConeBool) = solution.auxRcost(2:nExpCone+1);
                        end
                        z_e_vf = z_e_vf_vr(1:n,1); % e_vf
                        z_e_vr = z_e_vf_vr(n+1:2*n,1); % e_vr
                        
                        z_q_vf_vr_ve = 0*ones(2*n+k,1);
                        z_q_1 = 0;
                        if nQuadCone>0
                            z_q_1 = solution.auxRcost(nExpCone + expCone1 + 1);
                            z_q_vf_vr_ve(quadBool) = solution.auxRcost(nExpCone + expCone1 + 2:nExpCone + expCone1 + nQuadCone + 1);
                        end
                        z_q_vf = z_q_vf_vr_ve(1:n,1);
                        z_q_vr = z_q_vf_vr_ve(n+1:2*n,1);
                        z_q_ve = z_q_vf_vr_ve(2*n+1:2*n+k,1);
                        
                        
%                     F = [...
%                         %  x,   1,  p,   e,  1,    q;
%                         Odn, Id1, Idp,  Od, Oz1, Odq;  % exp cone    x1  = 1 or y (if normalisation)
%                         Oqn, Ox1, Oqp, Oqd, Oq1,  Iq;  % quad cone   x1  = q 
%                         Idn, Od1, Odp,  Od, Oz1, Odq;  % exp cone    x2  = x
%                         Oqn, Ox1, Oqp, Oqd, Iq1,  Oq;  % quad cone   x2  = 1
%                         Odn, Od1, Odp,  Id, Oz1, Odq;  % exp cone    x3  = e
%                           R, Ox1, Oqp, Oqd, Oq1,  Oq]; % quad cone R*x3  = F3*x
                        
                        %DUAL to conic constraints ordered by original F matrix
                        Fty_K  = solution.coneF'*y_K; %Rockafeller signs
                        
                        %  x,   1,  p,   e,  1,    q;
                        %  x = vf, vr
                        k_vf = Fty_K(1:n);
                        k_vr = Fty_K(n+1:2*n);
                        %note that the rows of the F matrix include exchange reactions even though they are not involved in exponential cone
                        k_ve = Fty_K(2*n+1:2*n+k);
                        if isfield(model,'Q')
                            if max(max(Qve))==0 && norm(k_ve)~=0 %TODO - check if norm(Qve)~=0 >> norm(k_ve)~=0
                                error('k_ve should be zero')
                            end
                        end
                        
                        %dual to exponential cone variables
                        k_e_vf_vr = zeros(2*n,1);
                        k_e_1  = 0;
                        if nExpCone>0
                            k_e_1  = Fty_K(2*n+k+1);
                            k_e_vf_vr(expConeBool) = Fty_K(2*n+k+2:2*n+k+1+nExpCone);
                        end
                        k_e_vf = k_e_vf_vr(1:n,1); % e_vf
                        k_e_vr = k_e_vf_vr(n+1:2*n,1); % e_vr
                        
                        %dual to quadratic cone variable
                        kq_vf_vr_ve = zeros(2*n,1);
                        k_q_1 = 0;
                        if nQuadCone>0
                            k_q_1 = Fty_K(2*n+k+1+nExpCone+1);
                            kq_vf_vr_ve(quadBool) = Fty_K(2*n+k+3+nExpCone:2*n+k+2+nExpCone+nQuadCone);
                        end
                        kq_vf = kq_vf_vr_ve(1:n,1);
                        kq_vr = kq_vf_vr_ve(n+1:2*n,1);
                        
                        %TODO fix this piece of code (Index in position 1 exceeds array bounds )
                        if 0 && k>0
                            kq_ve = kq_vf_vr_ve(2*n+1:2*n+k,1);
                        else
                            kq_ve = [];
                        end
                        
                        %         Tf = table(reallog(vf/vt), 1,cf,N'*y_N,e*z_dx,z_vf,wvf)
                        %         Tf = table(reallog(vr/vt), 1,cr,N'*y_N,e*z_dx,z_vr,wvr)
                        %         T = table(reallog(vf/vt),cf,N'*y_N)
                        
                        %extra checks
                        if param.printLevel>0 || param.debug
                            fprintf('\n%s\n','Optimality conditions (biochemistry)')
                            %primal
                            fprintf('%8.2g %s\n',norm(N*(vf - vr) + B*ve - model.b,inf),'|| N*(vf - vr) + B*ve - b ||_inf');
                            if isfield(model,'C')
                                fprintf('%8.2g %s\n',norm(C*(vf - vr) + s_C - model.d,inf),'|| C*(vf - vr) + s_C - d ||_inf, s_C = slack variable');
                            end
                            %dual
                            if isfield(model,'C')
                                fprintf('%8.2g %s\n',norm(cf + ci + N'*y_N + C'*y_C + Qv*vf + y_vi + k_vf + z_vf,inf), '|| cf + ci + N''*y_N + C''*y_C + y_vi + Qv*vf + k_vf + z_vf ||_inf');
                                fprintf('%8.2g %s\n',norm(cr - ci - N'*y_N - C'*y_C + Qv*vr - y_vi + k_vr + z_vr,inf), '|| cr - ci - N''*y_N - C''*y_C - y_vi + Qv*vf + k_vr + z_vr ||_inf');
                            else
                                fprintf('%8.2g %s\n',norm(cf + ci + N'*y_N + Qv*vf + y_vi + k_vf + z_vf,inf), '|| cf + ci + N''*y_N + y_vi + Qv*vf + k_vf + z_vf ||_inf');
                                fprintf('%8.2g %s\n',norm(cr - ci - N'*y_N + Qv*vr - y_vi + k_vr + z_vr,inf), '|| cr - ci - N''*y_N - y_vi + Qv*vf + k_vr + z_vr ||_inf');
                            end
                            fprintf('%8.2g %s\n',norm(ce + B'*y_N + z_ve,inf),'|| ce + B''*y_N  + z_ve ||_inf');
                            
                            fprintf('%8.2g %s\n',norm(k_e_1 + z_e_1,inf),'|| k_e_1 + z_e_1 ||_inf');
                            
                            fprintf('%8.2g %s\n',norm(-g + k_e_vf + z_e_vf,inf),'|| -g + k_e_vf + z_e_vf||_inf');
                            fprintf('%8.2g %s\n',norm(-g + k_e_vr + z_e_vr,inf),'|| -g + k_e_vr + z_e_vr||_inf');
                            
                            if nExpCone>0
                                if any(expConeBool(1:n))
                                    fprintf('%8.2g %s\n',norm(e_vf(expConeBool(1:n)) + vf(expConeBool(1:n)).*reallog(vf(expConeBool(1:n))),inf), '|| e_vf + vf*log(vf) ||_inf');
                                   %TODO dual cone
                                   %fprintf('%7.2g\t%s\n',min(y1_K(1:nExpCone) + y3_K(1:nExpCone).*exp(y2_K(1:nExpCone)./y3_K(1:nExpCone))/exp(1)), 'min(y1_k + y3_k.*exp(y2_K./y3_K)/exp(1))  >= 0');
                                   %fprintf('%7.2g\t%s\n',min(-k_e_1 + -k_e_vf.*exp(-k_vf./-k_e_vf)/exp(1)), 'min(k_e_1 + k_e_vf.*exp(k_vf./k_e_vf)/exp(1)) >= 0 (Dual exponential cone)');

                                end
                                if any(expConeBool(n+1:2*n))
                                    fprintf('%8.2g %s\n',norm(e_vr(expConeBool(n+1:2*n)) + vr(expConeBool(n+1:2*n)).*reallog(vr(expConeBool(n+1:2*n))),inf), '|| e_vr + vr*log(vr) ||_inf');
                                end
                                

                            end
                            
                            if nQuadCone>0
                                fprintf('%8.2g %s\n',norm(k_q_1 + z_q_1,inf),'|| k_q_1 + z_q_1 ||_inf');
                                
                                if any(quadBool(1:n))
                                    fprintf('%8.2g %s\n',norm(double(kq_vf~=0) + kq_vf + z_q_vf,inf),'|| 1 + k_q_vf + z_q_vf ||_inf');
                                    bool = false(size(model.Q,1),1);
                                    bool(1:n,1)=1;
                                    fprintf('%8.2g %s\n',norm(q_vf(quadBool(1:n)) + (1/2)*vf'*model.Q(quadBool(n+1:2*n+k) & bool,quadBool(n+1:2*n+k) & bool)*vf,inf), '|| q_vf + 1/2*vf''*Q*vf ||_inf');
                                end
                                if any(quadBool(n+1:2*n))
                                    fprintf('%8.2g %s\n',norm(double(kq_vr~=0) + kq_vr + z_q_vr,inf),'|| 1 + k_q_vr + z_q_vr ||_inf');
                                    bool = false(size(model.Q,1),1);
                                    bool(1:n,1)=1;
                                    fprintf('%8.2g %s\n',norm(q_vr(quadBool(n+1:2*n)) + (1/2)*vr'*model.Q(quadBool(n+1:2*n+k) & bool,quadBool(n+1:2*n+k) & bool)*vr,inf), '|| q_vr + 1/2*vr''*Q*vr ||_inf');
                                end
                                
                                if any(quadBool(2*n+1:2*n+k)) && 0
                                    fprintf('%8.2g %s\n',norm(double(kq_ve~=0) + kq_ve + z_q_ve,inf),'|| 1 + k_q_ve + z_q_ve ||_inf');
                                    bool = false(size(model.Q,1),1);
                                    bool(n+1:n+k,1)=1;
                                    if 0
                                        %primal - Not sure how to interpret this
                                        fprintf('%8.2g %s\n',norm(q_ve(quadBool(2*n+1:2*n+k)) + (1/2)*ve'*model.Q(quadBool(n+1:2*n+k) & bool,quadBool(n+1:2*n+k) & bool)*ve,inf), '|| q_ve + 1/2*ve''*Q*ve ||_inf');
                                    end
                                    
                                    %dual
                                    fprintf('%8.2g %s\n',norm(ce + B'*y_N + k_ve + z_ve,inf), '|| ce + B''*y + k_ve + z_ve ||_inf');
                                end
                            end
                            
                            fprintf('\n%s\n','Derived optimality conditions (biochemistry)')
                            valf = k_vf - g.*reallog(vf) - g;
                            fprintf('%8.2g %s\n',norm(valf,inf), '|| g.*log(vf) + g - k_vf ||_inf');
                            bool = abs(valf) > 1e-4;
                            if any(bool) && param.printLevel>1
                                T = table(k_vf(bool),g(bool).*reallog(vf(bool)) + g(bool),vfl(bool),vfu(bool),z_vf(bool),vl(bool),vu(bool),y_vi(bool),'VariableNames',{'k_vf','glog(vf)+g','vfl','vfu','z_vf','vl','vu','z_vi'});
                                disp(T)
                            end
                            valr = k_vr - g.*reallog(vr) - g;
                            fprintf('%8.2g %s\n',norm(valr,inf), '|| g.*log(vr) + g - k_vr ||_inf');
                            
                            if isfield(model,'C')
                                fprintf('%8.2g %s\n',norm(cf + ci + N'*y_N + C'*y_C + Qv*vf + y_vi + g.*reallog(vf) + g + z_vf,inf), '|| cf + ci + N''*y_N + C''*y_C + y_vi + Qv*vf + g.*log(vf) + g + z_vf ||_inf');
                                fprintf('%8.2g %s\n',norm(cr - ci - N'*y_N - C'*y_C + Qv*vr - y_vi + g.*reallog(vr) + g + z_vr,inf), '|| cr - ci - N''*y_N - C''*y_C - y_vi + Qv*vf + g.*log(vr) + g + z_vr ||_inf');
                            else
                                fprintf('%8.2g %s\n',norm(cf + ci + N'*y_N + Qv*vf + y_vi + g.*reallog(vf) + g + z_vf,inf), '|| cf + ci + N''*y_N + y_vi + Qv*vf + g.*log(vf) + g + z_vf ||_inf');
                                fprintf('%8.2g %s\n',norm(cr - ci - N'*y_N + Qv*vr - y_vi + g.*reallog(vr) + g + z_vr,inf), '|| cr - ci - N''*y_N - y_vi + Qv*vf + g.*log(vr) + g + z_vr ||_inf');
                            end
                            
                            fprintf('\n%s\n','Thermo conditions')
                            if isfield(model,'C')
                                fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) - 2*N'*y_N - 2*C'*y_C,inf),'|| g.*log(vr/vf) - 2*N''*y_N - 2*C''*y_C ||_inf');
                                fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N - 2*C'*y_C - 2*y_vi,inf),'|| g.*log(vr/vf) + cr - cf - 2*ci - 2*N''*y_N - 2*C''*y_C - 2*y_vi ||_inf');
                                fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N - 2*C'*y_C - 2*y_vi - z_vr + z_vf,inf),'|| g.*log(vr/vf) + cr - cf - 2*ci - 2*N''*y_N - 2*C''*y_C - 2*y_vi - z_vr + z_vf ||_inf');
                            else
                                fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) - 2*N'*y_N,inf),'|| g.*log(vr/vf) - 2*N''*y_N ||_inf');
                                fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N - 2*y_vi,inf),'|| g.*log(vr/vf) + cr - cf - 2*ci - 2*N''*y_N - 2*y_vi ||_inf');
                                fprintf('%8.2g %s\n',norm(g.*reallog(vr./vf) + cr - cf - 2*ci - 2*N'*y_N - 2*y_vi - z_vr + z_vf,inf),'|| g.*log(vr/vf) + cr - cf - 2*ci - 2*N''*y_N - 2*y_vi - z_vr + z_vf ||_inf');
                            end
                            
                            fprintf('%8.2g %s\n',min(slack(slack~=0)), 'min(slack)');
                            fprintf('%8.2g %s\n',max(slack(slack~=0)), 'max(slack)');
                        end
                    otherwise
                end
                
            otherwise
                error('Incorrect solver choice');
        end
    case 'normalisedEntropy'
        switch param.solver
            case 'pdcoPrimal'
                %set the objective
                entropyhandle = @(x) normEntropyObj(x);
                
                %constraint matrix
                %         vf      vr      v    vt    w
                A  = [     N      -N    Omn   Om1    B;
                    In    -In    -In   On1  Onk;
                    -I1n   -I1n    O1n     1  O1k];
                
                b2 = [model.b; zeros(n+1,1)];
                
                %bounds
                vl = [vfl;vrl;vl;1;vel];
                vu = [vfu;vru;vu;inf;veu];
                
                %starting vector
                %x0 = (vl+vu)/2;          %initial primal variables
                %x0(~isfinite(x0))=1;
                x0 = ones(3*n+1+k,1);
                y0 = sparse(m+n+1,1);        %initial dual variables for constraints
                z0 = ones(3*n+1+k,1);     %initial reduced gradients
                xsize=1e6;
                zsize=1e2;
                
                %TODO - still have no idea what the best parameters for pdco are
                options = pdcoSet;
                %options.mu0       = 1; %very small only for entropy function
                options.mu0       = 0; %pdco chooses its own
                options.FeaTol    = 1e-6;
                options.OptTol    = 1e-6;
                %   If getting linesearch failures, slacken tolerances
                %   i.e. Linesearch failed (nf too big)
                %options.FeaTol    = 1e-6; %%Ecoli core working at 1e-7
                %options.OptTol    = 1e-6;
                %        options.StepSame  = 0; %(allow different primal and dual steps)
                d1 = 1e-4;
                d2 = 1e-4;     %(regularizations)
                %%%%%%
                %Additional parameter specifications by Ronan
                %increasing to 0.99 reduced the number of iterations required
                %options.StepTol   = 0.9;
                % needed more than 30 iterations when xsize & zsize not tuned set
                options.MaxIter   = 200;
                options.Method = 2;
                
                %         %options from Michael's pdcotestENTROPY
                %         xsize = 5/n;               % A few elements of x are much bigger than 1/n.
                %         xsize = min(xsize,1);      % Safeguard for tiny problems.
                %         zsize = 1;                 % This makes y (sic) about the right size.
                %         % 10 makes ||y|| even closer to 1,
                %         % but for some reason doesn't help.
                %
                %         x0min = xsize;             % Applies to scaled x1, x2
                %         z0min = zsize;             % Applies to scaled z1, z2
                %
                %         en    = ones(n,1);
                %         x0    = en*xsize;          %
                %         y0    = zeros(m,1);
                %         z0    = en*z0min;          % z is nominally zero (but converges to mu/x)
                %
                %         d1    = 0;                 % 1e-3 is normal.  0 seems fine for entropy
                %         d2    = 1e-3;              %
                %
                %         options = pdcoSet;
                %         options.MaxIter      =    50;
                %         options.FeaTol       =  1e-6;
                %         options.OptTol       =  1e-6;
                %         options.x0min        = x0min;  % This applies to scaled x1, x2.
                %         options.z0min        = z0min;  % This applies to scaled z1, z2.
                %         options.mu0          =  1e-5;  % 09 Dec 2005: BEWARE: mu0 = 1e-5 happens
                %         %    to be ok for the entropy problem,
                %         %    but mu0 = 1e-0 is SAFER IN GENERAL.
                %
                %         options.Method       =     3;  % 1=Chol  2=QR  3=LSQR
                %         options.LSMRatol1    =  1e-3;
                %         options.LSMRatol2    =  1e-6;
                %         options.wait         =     1;
                
                options.Print = param.printLevel-1;
                [x,t_vfvr,z,inform,~,~,~] = ...
                    pdco(entropyhandle,A,b2,vl,vu,d1,d2,options,x0,y0,z0,xsize,zsize);
                
                if (inform == 0)
                    stat = 1;
                    if ~any(model.csense == 'L' | model.csense == 'G')
                        slack = zeros(m,1);
                    else
                        slack = zeros(m,1);
                        slack(model.csense == 'L' | model.csense == 'G') = z(nRxn+1:end);
                        slack(model.csense == 'G') = -slack(model.csense == 'G');
                    end
                    %x=z(1:size(A,2));
                    %w=w(1:size(A,2));
                    if 0
                        norm(A*x + slack - b,inf)
                    end
                elseif (inform == 1 || inform == 2 || inform == 3)
                    stat = 0;
                else
                    stat = -1;
                end
                origStat=inform;
                
                y_N =-t_vfvr(1:m);%Rockafellar signs
                y_vi = -t_vfvr(m+1:m+n);
                z_dx = -t_vfvr(m+n+1);
                
                %fluxes
                vf = x(1:n);
                vr = x(n+1:2*n);
                v  = x(2*n+1:3*n);
                vt = x(3*n+1);
                ve  = x(3*n+2:3*n+1+k);
                
                % duals to bounds on unidirectional fluxes
                z_vf = z(1:n,1);
                z_vr  = z(n+1:2*n,1);
                % duals to bounds on net fluxes
                z_vi = z(2*n+1:3*n,1);
                %duals to the bounds on total flux
                y_C = z(3*n+1);
                
                %extra checks
                if param.debug
                    fprintf('%s\n','Optimality conditions (unregularised)')
                    fprintf('%8.2g %s\n',norm(N*(vf - vr) + B*ve - model.b,inf),'|| N*(vf - vr) + B*ve - b ||_inf');
                    fprintf('%8.2g %s\n',norm(vf - vr - v,inf),'|| vf - vr - v ||_inf');
                    fprintf('%8.2g %s\n',norm(-e'*(vf + vr) + vt,inf),'|| -1''*(vf + vr) + vt ||_inf');
                    fprintf('%8.2g %s\n',norm(reallog(vf/vt) + 1 + cf + N'*y_N + y_vi - e*z_dx,inf), '|| log(vf/vt) + 1 + cf + N''*y_N - e*z_dx ||_inf');
                    fprintf('%8.2g %s\n',norm(reallog(vr/vt) + 1 + cr - N'*y_N - y_vi - e*z_dx,inf),'|| log(vr/vt) + 1 + cr - N''*y_N - e*z_dx ||_inf');
                    fprintf('%8.2g %s\n',norm(reallog(vf/vt) + 1 + cf + N'*y_N + y_vi - e*z_dx - z_vf,inf), '|| log(vf/vt) + 1 + cf + N''*y_N - e*z_dx - z_vf ||_inf');
                    fprintf('%8.2g %s\n',norm(reallog(vr/vt) + 1 + cr - N'*y_N - y_vi - e*z_dx - z_vr,inf),'|| log(vr/vt) + 1 + cr - N''*y_N  - e*z_dx - z_vr ||_inf');
                    fprintf('%8.2g %s\n',norm(- y_vi - z_vi,inf),'|| -y_vi - z_vi||_inf');
                    fprintf('%8.2g %s\n',norm( -(e'*(vf + vr)/vt) + z_dx - y_C,inf),'|| -(e''*(vf + vr)/vt) + z_dx - y_C||_inf');
                    
                    
                    fprintf('\n%s\n','Optimality conditions (regularised)')
                    fprintf('%8.2g %s\n',norm(N*(vf - vr) + B*ve - model.b + (d2^2)*y_N,inf),'|| N*(vf - vr) + B*ve - b + (d2^2)*y_N ||_inf');
                    fprintf('%8.2g %s\n',norm(vf - vr - v + (d2^2)*y_vi,inf),'|| vf - vr - v +  (d2^2)*y_vi ||_inf');
                    fprintf('%8.2g %s\n',norm(-e'*(vf + vr) + vt + (d2^2)*z_dx,inf),'|| -1''*(vf + vr) + vt  + (d2^2)*z_dx ||_inf');
                    fprintf('%8.2g %s\n',norm(reallog(vf/vt) + 1 + cf + N'*y_N + y_vi - e*z_dx - z_vf + d1*vf,inf), '|| log(vf/vt) + 1 + cf + N''*y_N + y_vi - e*z_dx - z_vf + d1*vf||_inf');
                    fprintf('%8.2g %s\n',norm(reallog(vr/vt) + 1 + cr - N'*y_N - y_vi - e*z_dx - z_vr + d1*vr,inf),  '|| log(vr/vt) + 1 + cr - N''*y_N - y_vi - e*z_dx -  z_vr + d1*vr||_inf');
                    
                    fprintf('%8.2g %s\n',norm(- y_vi - z_vi + d1*v,inf),'|| -y_vi - z_vi + d1*v ||_inf');
                    fprintf('%8.2g %s\n',norm( -(e'*(vf + vr)/vt) + z_dx - y_C + d1*vt,inf),'|| -(e''*(vf + vr)/vt) + z_dx - y_C + d1*vt ||_inf');
                    
                    fprintf('\n%s\n','Thermo conditions (unregularised)')
                    fprintf('%8.2g %s\n',norm(reallog(vr./vf) - 2*N'*y_N,inf),'|| log(vr./vf) + cr - cf - 2*N''*y_N ||_inf');
                    fprintf('%8.2g %s\n',norm(reallog(vr./vf) + cr - cf - 2*N'*y_N - 2*y_vi,inf),'|| log(vr./vf) + cr - cf - 2*N''*y_N - 2*y_vi ||_inf');
                    fprintf('%8.2g %s\n',norm(reallog(vr./vf) + cr - cf - 2*N'*y_N - 2*y_vi + z_vf - z_vr,inf),'|| log(vr./vf) + cr - cf - 2*N''*y_N - 2*y_vi + z_vf - z_vr ||_inf');
                    
                    fprintf('\n%s\n','Thermo conditions (regularised)')
                    fprintf('%8.2g %s\n',norm(z_vf - z_vr + d1*(vr -vf),inf),'|| z_vf - z_vr + d1*(vr -vf) ||_inf');
                    fprintf('%8.2g %s\n',norm(reallog(vr./vf) + cr - cf - 2*N'*y_N - 2*y_vi + z_vf - z_vr + d1*(vr -vf),inf),'|| log(vr./vf) + cr - cf - 2*N''*y_N - 2*y_vi + z_vf - z_vr + d1*(vr -vf) ||_inf');
                end
                %T = table(reallog(vf/vt)+1+cf,N'*y_N,y_vi,e*z_dx,z_vf,d1*vf);
        end
    case 'fluxTracing'
    otherwise
        error('Incorrect method choice');
end

if 0
    %get nullspace of N
    [Z,rankS]=getNullSpace(N,param.printLevel-1);
    fprintf('%8.2g %s\n',norm(Z'*(z_vf - z_vr),inf),'|| Z''*(z_vf - z_vr) ||_inf');
end

switch solution.stat
    case 1
        switch param.solver
            case 'pdco'
                solution = rmfield(solution,{'full','dual','rcost','slack'});
                
            case 'mosek'
                solution = rmfield(solution,{'full','dual','rcost','slack','coneF','auxPrimal','auxRcost','coneDual'});
        end


        v=zeros(n+k,1);
        v(model.SConsistentRxnBool)= vf - vr;
        v(~model.SConsistentRxnBool) = ve;
        
        if ~exist('vt','var')
            vt = sum(vf) + sum(vr);
        end
        if ~exist('z_dx','var')
            z_dx = 0;
        end
        
        if ~exist('z_vi','var')
            if exist('y_vi','var')
                %mosek uses blc <= A*x < buc to enforce l < vf - vr < u
                z_vi = y_vi;
            else
                z_vi = 0;
            end
        end
        
        y_v=zeros(n+k,1);
        y_v(model.SConsistentRxnBool)= z_vi;
        y_v(~model.SConsistentRxnBool) = z_ve;
        z_v = y_v;
        
        [solution.v,solution.vf,solution.vr,solution.vt,solution.y_N,solution.y_v,solution.z_dx,solution.z_vf,solution.z_vr,solution.z_vi,solution.z_v,solution.stat,solution.osense] =...
            deal(v,vf,vr,vt,y_N,y_v,z_dx,z_vf,z_vr,z_vi,z_v,solution.stat,osense);
        
        if exist('x0','var')
            [solution.x, solution.x0, solution.z_x, solution.z_x0, solution.z_dx] = deal(x, x0, z_x, z_x0, z_dx);
        end
        
        if isfield(model,'C')
            solution.y_C=y_C;
        end
        if exist('messages','var')
            if isfield(solution,'messages')
                solution.messages = [solution.messages;messages];
            else
                solution.messages = messages;
            end
        else
            solution.messages = [];
        end
    otherwise
        solution_optimizeCbModel = optimizeCbModel(model);
        switch solution_optimizeCbModel.stat
            case 0
                message = 'entropicFluxBalanceAnalysis: EPproblem is not feasible, because LP part of model is not feasible according to optimizeCbModel.';
                warning(message)
            case 1
                message ='entropicFluxBalanceAnalysis: EPproblem is not feasible, but LP part of model is feasible according to optimizeCbModel.';
                warning(message)
        end
        if isfield(solution,'messages')
            solution.messages = [solution.messages;message];
        else
            solution.messages = cellstr(message);
        end
end

modelOut=model;
modelOut.lb(model.SConsistentRxnBool) = vl;
modelOut.ub(model.SConsistentRxnBool) = vu;
modelOut.lb(~model.SConsistentRxnBool) = vel;
modelOut.ub(~model.SConsistentRxnBool) = veu;
modelOut.cf = cf;
modelOut.cr = cr;
modelOut.g = g;

if contains(lower(param.method),'conc')
    modelOut.u0 = u0;
    modelOut.f = f;
end

end

% helper functions for pdco
function [obj,grad,hess] = normEntropyObj(x)
%NB PDCO SIGNS HERE
vf = x(1:n);
vr = x(n+1:2*n);
vi = x(2*n+1:3*n);
vt = x(3*n+1);
ve = x(3*n+2:3*n+1+k);

logvf = reallog(vf/vt);     % error if negative
logvr = reallog(vr/vt);
e     = ones(n,1);
obj  = vf'*logvf + vr'*logvr + cf'*vf + cr'*vr + [ci;ce]'*[vi;ve];
grad = [ logvf + e + cf;  % grad f(vf)
    logvr + e + cr;  % grad f(vr)
    ci;  % grad f(vnet)
    -(e'*(vf + vr))/vt; % grad f(vt)
    ce]; % grad f(ve)

hess = [1./vf; 1./vr; zeros(n,1); (e'*vf + e'*vr)/(vt^2);zeros(k,1)];
hess = diag(hess);
end

function [obj,grad,hess] = entropyObj(x,c,cr,cf,ci,ce,SConsistentRxnBool)

%NB PDCO SIGNS HERE
n=nnz(SConsistentRxnBool);
k=nnz(~SConsistentRxnBool);
vf = x(1:n);
vr = x(n+1:2*n);
vi = x(2*n+1:3*n);
ve = x(3*n+1:3*n+k);

logvf = reallog(vf);     % error if negative
logvr = reallog(vr);
e     = ones(n,1);
obj  = vf'*logvf + vr'*logvr + cf'*vf + cr'*vr + [ci;ce]'*[vi;ve];
grad = [ logvf + e + cf;  % grad f(vf)
    logvr + e + cr;  % grad f(vr)
    ci;  % grad f(vnet)
    ce]; % grad f(ve)

hess = [1./vf; 1./vr; zeros(n,1); zeros(k,1)];
hess = diag(hess);
end

function [obj,grad,hess] = dualEntropyObj(x,m,n,b,vfl,vfu,vrl,vru)
% objective for dual convex flux balance analysis problem

y  = x(1:m);
%dual to inequality constraints on fluxes
alphal=x(m+1:m+n);
alphau=x(m+n+1:m+2*n);
betal=x(m+2*n+1:m+3*n);
betau=x(m+3*n+1:m+4*n);
wf=x(m+4*n+1:m+4*n+n);
wr=x(m+4*n+n+1:m+4*n+2*n);

%take exponentials
wfexp  = exp(wf);
wrexp  = exp(wr);

if ~any(isfinite(wfexp))
    % Uncomment this to check if exp(-w) is getting to large
    fprintf('\n%s%g\n','Max exp(wf): ',max(wfexp));
end
if ~any(isfinite(wfexp))
    fprintf('%s%g\n','Max exp(wr): ',max(wrexp));
end

%NB PDCO SIGNS HERE
obj   = - b'*y ...
    - vfl'*alphal + vfu'*alphau...
    - vrl'*betal  + vru'*betau...
    + sum(wfexp) + sum(wrexp);
grad  = [-b;-vfl;vfu;-vrl;vru;wfexp;wrexp];
hess  = [zeros(m+4*n,1);wfexp;wrexp];
hess  = diag(sparse(hess));
end


function pdxxxdistrib( x,z )
%from pdco by Michael Saunders
% pdxxxdistrib(x) or pdxxxdistrib(x,z) prints the
% distribution of 1 or 2 vectors.
%
% 18 Dec 2000.  First version with 2 vectors.

  two  = nargin > 1;
  fprintf('\n\nDistribution of vector     x')
  if two, fprintf('         z'); end

  x1   = 10^(floor(log10(max(x)+eps)) + 1);
  z1   = 10^(floor(log10(max(z)+eps)) + 1);
  x1   = max(x1,z1);
  kmax = 10;

  for k = 1:kmax
    x2 = x1;    x1 = x1/10;
    if k==kmax, x1 = 0; end
    nx = length(find(x>=x1 & x<x2));
    fprintf('\n[%7.3g,%7.3g )%10g', x1, x2, nx);
    if two
      nz = length(find(z>=x1 & z<x2));
      fprintf('%10g', nz);
    end
  end

  disp(' ')
end
