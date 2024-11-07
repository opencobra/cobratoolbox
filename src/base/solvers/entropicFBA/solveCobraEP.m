function sol = solveCobraEP(EPproblem, varargin)
% Solves the following optimisation problem:
%
% minimize   osense*(c.*d)'x + d.*x'(log(x) -1) + (1/2)*x'*Q*x
%   x
%
% subject to    A*x    <=> b         : y
%               lb <= x  <=  ub      : z
%
% or 
% subject to    blc <= A*x <= buc   : y
%               lb <= x  <=  ub     : z
%
%
% However, when EPproblem.P is present, the following optimisation problem
% is solved:
% 
% minimize   osense*(c.*d)'*x  + (d.*x)'*log(x./q) + (1/2)*x'*Q*x = osense*(c.*d)'*x  + (d.*x)'*log(x) - (d.*x)'*log(q) + (1/2)*x'*Q*x
%   x,q
%
% subject to    A*x    <=> b         : y
%               P*x - q =  0         : r  
%               lb <= x  <=  ub      : z
%
% or 
% subject to    blc <= A*x <= buc   : y
%               P*x  -q =  0        : r 
%               lb <= x  <=  ub     : z
%
%
%
% USAGE:
%    sol = solveCobraEP(EPproblem, varargin)
%
% INPUT:
%    EPproblem:     Structure containing the following fields describing the EP problem to be solved
%                     * .A  - m x n Linear constraint matrix
%                     * .c  - n x 1 Linear objective coeff vector
%                     * .lb - n x 1 Lower bound vector
%                     * .ub - n x 1 Upper bound vector
%                     * .d  - n x 1 Non-negative vector indicating the non-negative
%                                   variables whose entropy is maximised. If d(i)==0
%                                   then there is only a linear objective on x(i).
%                     * .osense - Linear objective sense (-1 means maximise, 1 means minimise)
%
%                   With either the following fields
%                     * .b - m x 1 right hand side vector i.e. A <=> b
%                     * .csense - m x 1 string containting the constraint sense for
%                                 each row in A ('E', equality, 'G' greater than, 'L' less than).
%
%                   Or with the following fields
%                     * .blc - m x 1  left hand side vector i.e.  blc <= A*x
%                     * .buc - m x 1 right hand side vector i.e.  A*x <= buc
%
%
% OPTIONAL INPUTS:
%    EPproblem:     Structure containing the following fields describing the EP problem to be solved
%                     * .P - p x n matrix with entries {0,1}, such that q_i := P_{i,:}*x is the sums
%                            of the x corresponding to nonzero columns of the ith row of P, i.e. P_{i,:}.
%                            Used for normalised entropy maximisation.
%
%                     * .Q - positive semidefinite matrix for quadratic part of objective (see above)
%
%    varargin:      Additional parameters either as parameter struct, or as
%                   parameter/value pairs. A combination is possible, if
%                   the parameter struct is either at the beginning or the
%                   end of the optional input.
%                   All fields of the struct which are not COBRA parameters
%                   (see `getCobraSolverParamsOptionsForType`) for this
%                   problem type will be passed on to the solver in a
%                   solver specific manner. Some optional parameters which
%                   can be passed to the function as parameter value pairs,
%                   or as part of the options struct are listed below:
%                  'verify'
%                  'printLevel'
%                  'debug'
%                  'feasTol'
%                  'optTol'
%                  'solver'
%
%
%    printLevel:    Printing level
%
%                     * 0 - Silent (Default)
%                     * 1 - Warnings and Errors
%                     * 2 - Summary information
%                     * 3 - More detailed information
%                     * > 10 - Pause statements, and maximal printing (debug mode)
%
%   solver:         Optimisation solver used, {('mosek'),'pdco'}
%   feasTol:        Feasibility tolerance
%   optTol:         Optimality tolerance
%
% OUTPUT:
%    sol:      Structure containing the following fields describing a LP sol:
%                     *.obj:          Objective value
%                     *.objLinear      osense*c'*x;
%                     *.objEntropy     d.*x'*(log(x) -1);
%                     *.objQuadratic   (1/2)*x'*Q*x;
%                     *.v:  n+k ×1 double
%                     *.vf: n × 1 double
%                     *.vr: n × 1 double
%                     *.vt: 1'*vt + 1'*vr
%                     *.y_N: m x 1 double   dual sol to constraints :math: `A*x ('E' | 'G' | 'L') b`
%                     *.z_dx: 0
%                     *.z_vf: n × 1 double    dual sol to :math:`lb <= vr <= ub`
%                     *.z_vr: n × 1 double    dual sol to :math:`lb <= vf <= ub`
%                     *.z_vi: n × 1 double    dual sol to :math:`lb <= v <= ub`
%                     *.z_v: n + k × 1 double dual sol to :math:`lb <= w <= ub`
%                     * .stat:         Solver status in standardized form
%                       * 0 - Infeasible problem
%                       * 1 - Optimal sol
%                       * 2 - Unbounded sol
%                       * 3 - Almost optimal sol
%                       * -1 - Some other problem (timelimit, numerical problem etc)
%                     * .origStat:         Original status returned by the specific solver
%                     * .origStatText:     Original status text returned by the specific solver
%                     * .time:         Solve time in seconds
%                     * .solver:       Solver used to solve EP problem
%                     * .epmethod: solver method used e.g. 'CONIC'

% OPTIONAL OUTPUT (from conic optimisation with mosek):
%  sol.auxPrimal:  auxiliary primal variable
%  sol.auxRcost:   dual to auxiliary primal variable
%  sol.coneF:      affine constraint matrix
%  sol.coneDual:   dual to affine constraints
%  sol.dualNorm:   dual to the probability normalisation constraint
%
% OPTIONAL OUTPUT (from optimisation with pdco):
%  sol.d1:  primal regularisation parameter, see pdco.m
%  sol.d2:  dual regularisation parameter, see pdco.m
%
% EXAMPLE:
%
%
% Author(s): Ronan M.T. Fleming, 2024


[problemTypeParams, solverParams] = parseSolverParameters('EP', varargin{:});
param = mergeCobraParams(solverParams,problemTypeParams);
clear problemTypeParams solverParams

if ~isfield(param,'debug')
    param.debug = 1;
end

if any(EPproblem.lb>EPproblem.ub)
    error('EPproblem.lb>EPproblem.ub');
end


% assume constraint A*v = b if csense not provided
if isfield(EPproblem, 'csense')
    bool = EPproblem.csense == 'E' | EPproblem.csense == 'G' | EPproblem.csense == 'L';
    if any(~bool)
        error('Incorrect formulation of EPproblem.csense \n%s','EPproblem.csense must be an m x 1 character array containing the constraint sense {''E'',''L'',''G''} corresponding to each row of EPproblem.A')
    end
end

if isequal(param.solver,'mosek')
    if ~(isfield(EPproblem,'blc') || isfield(EPproblem,'blc'))
        % blc <= A*x <= buc
        EPproblem.blc = EPproblem.b;
        EPproblem.blc(EPproblem.csense == 'L',1) = -inf;
        EPproblem.buc = EPproblem.b;
        EPproblem.buc(EPproblem.csense == 'G',1) = inf;
        %remove other specification of constraints to avoid conflict
        EPproblem = rmfield(EPproblem,'csense');
        EPproblem = rmfield(EPproblem,'b');
    end
end

%% if in debug mode, test to see if the LP part of the problem is feasible
if param.debug && ~isfield(param,'useTestVKSolution') && ~isfield(param,'VKproblem') %avoid LP if being called in driver_optimiseVKmodel
    switch param.solver
        case 'pdco'
            solutionLP2 = solveCobraLP(EPproblem);
            if param.printLevel>2
                disp(solutionLP2)
            end
            
        case 'mosek'
            [cmd,mosekParam] = setMosekParam(param);

            [res] = msklpopt(EPproblem.c,EPproblem.A,EPproblem.blc,EPproblem.buc,EPproblem.lb,EPproblem.ub,mosekParam,'minimize');
            
            %parse mosek result structure
           %[            stat,            origStat,x,y,yl,yu,z,zl,zu,k,basis,pobjval,dobjval] = parseMskResult(res)
            [solutionLP2.stat,solutionLP2.origStat,x,y,yl,yu,z,zl,zu,k,  basis,pobjval,dobjval] = parseMskResult(res);
        
            switch solutionLP2.stat
                case 0
                    sol = solutionLP2;
                    message = ['solveCobraEP: LP part of EPproblem is infeasible according to solveCobraLP with ' param.solver '.'];
                    warning(message)
                    
                    return
                case 2
                    sol = solutionLP2;
                    message = ['solveCobraEP: LP part of EPproblem is unbounded according to solveCobraLP with ' param.solver '.'];
                    warning(message)
                    
                    return
                case 1
                    message =['solveCobraEP: LP part of EPproblem is feasible according to solveCobraLP with ' param.solver '.'];
                    fprintf('%s\n',message)
                otherwise
                    error('inconclusive solveCobraLP')
            end
            messages = cellstr(message);
    end
end

if ~isfield(EPproblem, 'b')
    EPproblem.b = zeros(size(EPproblem.A, 1), 1);
end

if ~isfield(EPproblem,'d')
    EPproblem.d = zeros(size(EPproblem.A,2),1);
end
if ~isfield(EPproblem,'sumFluxes')
    EPproblem.sumFluxes = [];
end
if ~isfield(EPproblem,'sumConc')
    EPproblem.sumConc = [];
end
if ~isfield(EPproblem,'sumConc0')
    EPproblem.sumConc0 = [];
end
if ~isfield(EPproblem,'Q')
    if isfield(EPproblem,'F')
        % solveCobraQP uses F for a positive semidefinite matrix
        % we use Q instead, because F is used to denote the matrix of
        % affine constraints arising from conic reformulation
        EPproblem.Q = EPproblem.F;
        EPproblem = rmfield(EPproblem,'F');
    end
end

[A,lb,ub,c,osense,d] = ...
    deal(EPproblem.A,EPproblem.lb,EPproblem.ub,EPproblem.c,EPproblem.osense,EPproblem.d);

if isfield(EPproblem,'b')
    b = EPproblem.b;
else
    b = zeros(size(A,1),1);
end

if isfield(EPproblem,'csense')
    csense = EPproblem.csense;
    if isfield(EPproblem,'blc')
        error('Ambiguous specification of EP problem to have EPproblem.blc and EPproblem.csense')
    end
end

if isfield(EPproblem,'blc')
    blc = EPproblem.blc;
    buc = EPproblem.buc;
    if any(blc> buc)
        error('EPproblem.blc must be less than or equal to EPproblem.buc')
    end
    if isfield(EPproblem,'csense')
        error('Ambiguous specification of EP problem to have EPproblem.blc and EPproblem.csense')
    end
end

[mlt,nlt]=size(A);

switch param.solver
    case 'pdco'
        % solves optimization problems of the form
        %
        %    minimize    phi(x) + 1/2 norm(D1*x)^2 + 1/2 norm(r)^2
        %      x,r
        %    subject to  A*x + D2*r = b,   bl <= x <= bu,   r unconstrained,
        
        %pdco only works with equality constraints and box constraints so
        %any other linear constraints need to be reformulated in terms of
        %slack variables
        %indl = find(csense == 'L'); %  A*x + s =   b
        %indg = find(csense == 'G'); % -A*x + s = - b
        
        if ~any(csense == 'L' | csense == 'G')
            Aeq  =  A;
            beq  =  b;
            lbeq = lb;
            ubeq = ub;
            ceq  =  osense*c;
            deq  = d;
            if isfield(EPproblem,'Q')
                Q = EPproblem.Q;
            end
        else
            Aeq = A;
            Aeq(csense == 'G',:) = -1*Aeq(csense == 'G',:);
            beq = b;
            beq(csense == 'G',:) = -1*beq(csense == 'G',:);
            K = speye(mlt);
            K = K(:,csense == 'L' | csense == 'G');
            Aeq = [Aeq K];
            nSlacks = nnz(csense == 'L' | csense == 'G');
            lbeq = [lb ; zeros(nSlacks,1)];
            ubeq = [ub ; inf*ones(nSlacks,1)];
            ceq  = [osense*c  ; zeros(nSlacks,1)];
            deq  = [d  ; zeros(nSlacks,1)];
            
            if isfield(EPproblem,'Q')
                %extend Q matrix to account for slack variables
                Q = sparse(size(Aeq,2),size(Aeq,2));
                Q(1:nlt,1:nlt) = EPproblem.Q;
                
            end
        end
        
        %add regularisation in case its not positive definite
        if isfield(EPproblem,'Q')
            try
                R = chol(Q);
                clear R;
            catch ME
                fprintf('%s\n',ME.message)
                Q = Q + diag(sparse(ones(size(Q,1),1)*1e-4));
            end
        end
                
        if isfield(param,'d1')
            d1 = param.d1;
        else
            d1 = 1e-4;
        end
        if isfield(param,'d2')
            d2 = param.d2;
        else
            d2 = 1e-4;
        end
        if isfield(param,'x0')
            x0 = param.x0;
        else
            x0 = ones(size(Aeq,2),1);
        end
        if isfield(param,'y0')
            y0 = param.y0;
        else
            y0 = ones(size(Aeq,1),1);
        end
        if isfield(param,'z0')
            z0 = param.z0;
        else
            z0 = ones(size(Aeq,2),1);
        end
        if isfield(param,'xsize')
            xsize = param.xsize;
        else
            xsize = 1;
        end
        if isfield(param,'zsize')
            zsize = param.zsize;
        else
            zsize = 1;
        end
        
        %TODO - still have no idea what the best parameters for pdco are
        options = pdcoSet;
        %options.mu0       = 1; %very small only for entropy function
        options.mu0       = 0; %pdco chooses its own
        options.FeaTol    = param.feasTol;
        options.OptTol    = param.optTol;
        %   If getting linesearch failures, slacken tolerances
        %   i.e. Linesearch failed (nf too big)
        %options.FeaTol    = 1e-6; %%Ecoli core working at 1e-7
        %options.OptTol    = 1e-6;
        %        options.StepSame  = 0; %(allow different primal and dual steps)
        
        %%%%%%
        %Additional parameter specifications by Ronan
        %increasing to 0.99 reduced the number of iterations required
        %options.StepTol   = 0.9;
        % needed more than 30 iterations when xsize & zsize not tuned set
        options.MaxIter   = 200;
        options.Method = 1;
        
        if 0
            %options from Michael's pdcotestENTROPY
            xsize = 5/nlt;               % A few elements of x are much bigger than 1/n.
            xsize = min(xsize,1);      % Safeguard for tiny problems.
            zsize = 1;                 % This makes y (sic) about the right size.
            % 10 makes ||y|| even closer to 1,
            % but for some reason doesn't help.
            
            x0min = xsize;             % Applies to scaled x1, x2
            z0min = zsize;             % Applies to scaled z1, z2
            
            en    = ones(size(Aeq,2),1);
            x0    = en*xsize;          %
            y0    = zeros(size(Aeq,1),1);
            z0    = en*z0min;          % z is nominally zero (but converges to mu/x)
            
            d1    = 0;                 % gamma. 1e-3 is normal.  0 seems fine for entropy
            d2    = 1e-3;              % delta
            
            options = pdcoSet;
            options.MaxIter      =    50;
            options.FeaTol       =  1e-6;
            options.OptTol       =  1e-6;
            options.x0min        = x0min;  % This applies to scaled x1, x2.
            options.z0min        = z0min;  % This applies to scaled z1, z2.
            options.mu0          =  1e-0;  % 09 Dec 2005: BEWARE: mu0 = 1e-5 happens
            %    to be ok for the entropy problem,
            %    but mu0 = 1e-0 is SAFER IN GENERAL.
            
            options.Method       =     1;  % 1=Chol  2=QR  3=LSQR
            options.LSMRatol1    =  1e-3;
            options.LSMRatol2    =  1e-6;
            options.wait         =     0;
        end
                 
        if 0
            %Michael Saunders suggestion for badly scaled/almost infeasible
            %problem
            options.FeaTol = 1e-8;
            options.OptTol = 1e-8;
            options.Method = 2;
            options.d1    = 1e-4;
            options.d2    = 1e-4;
            options.xsize = 1000;
            options.zsize = 1e+8;
        end
        
        %set the objective
        if isfield(EPproblem,'Q')
            objHandle = @(x) entropyQPObj(x,ceq,deq,Q);
        else
            objHandle = @(x) entropyObj(x,ceq,deq);
        end
        options.Print = param.printLevel-1;
        
        saveAndDebug=0;
        if saveAndDebug
            clearvars -except entropyhandle Aeq beq lbeq ubeq d1 d2 options x0 y0 z0 xsize zsize ceq deq saveAndDebug
        end
        tic;
        [x,y,z,inform,~,~,~] = ...
            pdco(objHandle,Aeq,beq,lbeq,ubeq,d1,d2,options,x0,y0,z0,xsize,zsize);
        
        logx = zeros(length(x),1);
        logx(deq~=0) = reallog(x(deq~=0));     % error if negative
        grad = ceq + deq.*logx;
        
        if param.printLevel > 2 || param.debug
            % determine the residuals
            fprintf('\n%s\n','KKT with pdco signs:')
            fprintf('%8.2g %s\n',norm(Aeq*x - beq,inf), '|| Aeq*x - beq ||_inf');
            fprintf('%8.2g %s\n',norm(Aeq*x - beq + (d2^2)*y,inf), '|| Aeq*x - beq + (d2^2)*y ||_inf');

            %gradient may differ depending on the solver
            % z includes (d1.^2).*x from the primal regularization.
            fprintf('%8.2g %s\n',norm(grad  - Aeq' * y - z,inf), '|| grad - Aeq''*y - z ||_inf');
            fprintf('%8.2g %s\n',norm(grad  - Aeq' * y - z - (d1^2)*x,inf), '|| grad - Aeq''*y - z - (d1^2)*x ||_inf');
        end
        if saveAndDebug
            save([datestr(now,29) '_pdco_problem_debug.mat'])
            return
        end
        
        sol.time = toc;
        sol.epmethod = options.Method;

        % inform = 0 if a sol is found;
        %        = 1 if too many iterations were required;
        %        = 2 if the linesearch failed too often;
        %        = 3 if the step lengths became too small;
        %        = 4 if Cholesky said ADDA was not positive definite.
        if (inform == 0)
            sol.stat = 1;
            

            if ~any(csense == 'L' | csense == 'G')
                slack = zeros(mlt,1);
            else
                slack = zeros(mlt,1);
                slack(csense == 'L' | csense == 'G') = x(nlt+1:end);
                slack(csense == 'G') = -slack(csense == 'G');
                %important to flip the signs of the dual variables for any
                %greater than constraint
                y(csense == 'G') = -y(csense == 'G');
            end
            
            sol.slack = slack;
            sol.full = x(1:nlt,1);
            sol.dual = -y;
            sol.rcost = -z(1:nlt,1);
            sol.origStat = inform;

            %objective
            logx = zeros(size(A,2),1);
            logx(d~=0) = reallog(sol.full(d~=0));     % error if negative
            if isfield(EPproblem,'Q')
                sol.obj  = c'*sol.full + (d.*sol.full)'*logx + (1/2)*sol.full'*EPproblem.Q*sol.full;
                grad = c + d.*logx + EPproblem.Q*sol.full;
            else
                sol.obj  = c'*sol.full + (d.*sol.full)'*logx;
                grad = c + d.*logx;
            end
            Aty = -A'*y;
            
            if param.printLevel > 2 || param.debug
                fprintf('\n%s\n','KKT with Rockafellar signs:')
                fprintf('%8.2g %s\n',norm(A*sol.full + sol.slack - b,inf), '|| A*x + s - b ||_inf');
                fprintf('%8.2g %s\n',norm(A*sol.full + sol.slack - b - (d2^2)*sol.dual,inf), '|| A*x + s - b - (d2^2)*y ||_inf');
                res2 = grad  + A'*sol.dual + sol.rcost;
                fprintf('%8.2g %s\n',norm(res2,inf), '|| grad + A''*y + z ||_inf');
                
                fprintf('%8.2g %s\n',norm(grad  + A'*sol.dual + sol.rcost - (d1^2)*sol.full,inf), '|| grad + A''*y + z - (d1^2)*x ||_inf');
                if param.debug
                    %res2 = grad  + Aty + sol.rcost;
                    res2 = grad  + A'*sol.dual + sol.rcost;
                    sol.T = table(res2,c,d.*logx, -A'*y, sol.rcost,...
                        'VariableNames',{'total','c','dlogx','Aty','z'});
                end
                if any(~isfinite(res2))
                    warning('Infinite variables in dual optimality condition')
                    sol.Tinf=sol.T(~isfinite(sol.T.total),:);
                    ind = find(~isfinite(sol.T.total));
                    sol.Tinf.ind = ind;
                end
            end
            
            sol.d1=d1;
            sol.d2=d2;
            
        elseif (inform == 1 || inform == 2 || inform == 3)
            sol.stat = 0;
            sol.obj = NaN;
        else
            sol.stat = -1;
            sol.obj = NaN;
        end
        sol.origStat = inform;
        
        %update parameters for testing optimality criterion
        param.feasTol = options.FeaTol;
        param.optTol = options.OptTol;
        %                     * .full:         Full LP sol vector
        %                     * .obj:          Objective value
        %                     * .rcost:        Reduced costs, dual sol to :math:`lb <= v <= ub`
        %                     * .dual:         dual sol to `A*v ('E' | 'G' | 'L') b`
        %                     * .solver:       Solver used to solve LP problem
        %                     * .algorithm:    Algorithm used by solver to solve LP problem
        %                     * .stat:         Solver status in standardized form
               
    case 'mosek'
        %%
        [cmd, mosekParam] = setMosekParam(param);

        %         https://docs.mosek.com/modeling-cookbook/expo.html
        %         https://docs.mosek.com/modeling-cookbook/qcqo.html#conic-reformulation
        %         min  (d.*x)'*(log(x./y) + c)  + (1/2)*x'*Q*x
        %         s.t. l <= A[x;y] <= u
        %
        %         Assuming Q is positive semidefinite, there exists an F such that Q = F'*F
        %
        %         min  (d.*x)'*(log(x./y) + c)  + (1/2)*x'*(F'*F)*x
        %         s.t. l <= A[x;y] <= u
        %
        %         where d,c,A,l,u,Q are data and x,y are variables, is equivalent to
        %
        %         min   d*e + d*c*x  + q
        %         s.t.   x*log(x/y)    <= e
        %                (1/2)*x'*Q'*x <= s
        %         l <= [A, 0, 0]*[x;y;e;s] <= u
        %
        %         which is equivalent to:
        %
        %         min   d*e + d*c*x + q 
        %         s.t.   (y, x, -e) \in K_{exp}     Exponential cone % MSK_CT_PEXP
        %                (1, s, Fx) \in Q^{k+2}_{r} Quadratic cone % MSK_CT_QUAD
        %         l <= [A, 0, 0]*[x;y;e;s] <= u
        %
        %         Such a problem could be formulated using the Affine conic constraints, as shown in the following code:
        
        
        % subject to    blc <=  A*x      <= buc   : y
        %               0   <= -P*x +  q <= 0     : r 
        %               lb  <=    x      <=  ub   : z
        %             -inf  <=    q      <=  inf  : z
        
        nExpCone  = nnz(d);
        expCone1 = (nExpCone>0)+0;
        
        if isfield(EPproblem,'Q')
            quadRows  = any(EPproblem.Q,2);
            quadCols  = any(EPproblem.Q,1)';
            quadBool  = quadRows | quadCols;
            nQuadCone = nnz(quadBool);
            R = sparse(nQuadCone,size(A,2));
            %cholesky factorisation of Q
            R(:,quadBool) = chol(EPproblem.Q(quadBool,quadBool));
        else
            R=[];
            nQuadCone = 0; 
        end

        if isfield(EPproblem,'P')
            p = size(EPproblem.P,1);
            P = EPproblem.P;
            pBool=(sum(P,1)~=0)'; %identify normalised variables
        else
            p = 0;
            P = [];
            pBool = false(size(d));
        end
        varNotNorm= any(d & ~pBool)+0;
        quadCone1 = (nQuadCone>0)+0;
        
        Om1 = sparse(size(A,1),varNotNorm);
        Omp = sparse(size(A,1),p);
        Omd = sparse(size(A,1),nExpCone);
        Omq = sparse(size(A,1),nQuadCone);
        Oz1 = sparse(size(A,1),quadCone1);
        
        Ox1 = sparse(p,varNotNorm);
        Ip  = spdiags(ones(p,1));
        Opd = sparse(p,nExpCone);
        Opq = sparse(p,nQuadCone);
        Op1 = sparse(p,quadCone1);
        
        prob.a = [...
           %x,   1,   p,   e,   1,    q;
            A, Om1, Omp, Omd, Oz1, Omq;
            P, Ox1, -Ip, Opd, Op1, Opq];
        

        %This should not be here!!!!!!!!!!!!!1
%         if isfield(EPproblem,'csense')
%             blc(csense == 'E',1) = b(csense == 'E');
%             buc(csense == 'E',1) = b(csense == 'E');
%             blc(csense == 'G',1) = b(csense == 'G');
%             buc(csense == 'G',1) = inf;
%             blc(csense == 'L',1) = -inf;
%             buc(csense == 'L',1) = b(csense == 'L');
%         else
%             blc = b;
%             buc = b;
%         end
        
        prob.blc = [blc;zeros(p,1)];
        prob.buc = [buc;zeros(p,1)];
        
        %remove the normalisation constant from the optimality conditions
        %ed = double(d~=0);
        
        %maximise the variable corresponding to the exponential cone
        %minimise the variable corresponding to the quadratic cone
        %                x,                  1,         p,       e,          1,                       q;
        prob.c = [osense*c;zeros(varNotNorm,1);zeros(p,1);-d(d~=0);zeros(quadCone1,1);ones(nQuadCone,quadCone1)];
        
        %fix the non-normalised variables corresponding to the exponential cone to one y = 1
        %            x,                  1,                                                          p,                    e, 1,                     q
        prob.blx = [lb; ones(varNotNorm,1);                                                 zeros(p,1);-inf*ones(nExpCone,1); ones(quadCone1,1);-inf*ones(nQuadCone,1)];
        prob.bux = [ub; ones(varNotNorm,1); EPproblem.sumFluxes; EPproblem.sumConc; EPproblem.sumConc0; inf*ones(nExpCone,1); ones(quadCone1,1); inf*ones(nQuadCone,1)];

        % Specify conic part of the problem
        % https://docs.mosek.com/9.2/toolbox/data-types.html#cones
        if param.printLevel>1 || param.debug
            [~, res] = mosekopt('symbcon echo(0)');
        else
            [~, res] = mosekopt('symbcon echo(0)');
        end
        % https://docs.mosek.com/9.2/toolbox/data-types.html#cones
%         For affine conic constraints Fx+g \in K, where K = K_1 * K_2 * ... * K_s, cones is a list consisting of concatenated cone descriptions. 
%         If a cone requires no additional parameters (quadratic, rotated quadratic, exponential, zero) then its description is [type,len]
%         where type is the type (conetype) and len is the length (dimension). The length must be present.
        
        %cone type 
        prob.cones(1:2:2*nExpCone) = res.symbcon.MSK_CT_PEXP;
        nCone = nExpCone+nQuadCone;
        if nQuadCone>0
            prob.cones(2*nExpCone+1:2:2*nCone) = res.symbcon.MSK_CT_QUAD;
        end
        %dimensions of cone
        prob.cones(2:2:2*nCone) = 3;
        
        %Conic problem with affine conic constraints
        %https://docs.mosek.com/9.2/toolbox/data-types.html#equation-doc-notation-conic
        %f (double[][]) – The matrix of affine conic constraints. It must be a sparse matrix.
        
        % Primal exponential cone.
        %  max e <= x * log(x/1),      x >= 0  <=> [ 1; x; e] \in K_{exp}
        %  min e >= x * log(1/x),      x >= 0  <=> [ 1; x;-e] \in K_{exp}
        % x3 <= x2 * log(x1 /x2), x1, x2 >= 0  <=> [x1;x2;x3] \in K_{exp}
        % x1 = 1 (no normalisation)
        % x2 = x
        % x3 = e
        
        % Primal exponential cone.
        % -e <=  x * log(y /x),    y,  x >= 0  <=> [y;  x;-e] \in K_{exp}
        %  e >=  x * log(x /y),    y,  x >= 0  <=> [y;  x; e] \in K_{exp}
        % x3 <= x2 * log(x1 /x2), x1, x2 >= 0  <=> [x1;x2;x3] \in K_{exp}
        % x1 = 1 or y (normalisation)
        % x2 = x
        % x3 = e
        Id=speye(nExpCone);
        Idn=speye(size(A,2));
        Idn = Idn(d~=0,:);
        Od1 = sparse(nExpCone,varNotNorm);
        Odp = sparse(nExpCone,p);
        Od  = sparse(nExpCone,nExpCone);
        Odn = sparse(nExpCone,size(A,2));
        
        if varNotNorm
            %entropy maximisation without normalisation
            Id1 = ones(size(A,2),varNotNorm);
            Id1(pBool)=0;
            Id1=Id1(d~=0); %zero out normalised variables from y=1;
        else
            %relative entropy maximsation with normalisation
            Id1 = sparse(nExpCone,varNotNorm);
        end
        Ox1 = sparse(nQuadCone,varNotNorm);
        Oz1 = sparse(nExpCone,quadCone1);
        
        if isfield(EPproblem,'P')
            Idp = P(:,d~=0)';
            Oqp = sparse(nQuadCone,size(Idp,2));
        else
            Idp = [];
            Oqp = [];
        end

        % Quadratic cone
        % https://docs.mosek.com/modeling-cookbook/cqo.html#convex-quadratic-sets
        % (1/2)*x'*(R'*R)*x <= q            <=>  [ q; 1; R*x] \in Q^{k+2}_{r} Quadratic cone
        % (1/2)*x3'*(R'*R)*x3 <= x1, x2 = 1 <=>  [x1;x2;R*x3] \in Q^{k+2}_{r} Quadratic cone
        % x1 =   q
        % x2 =   1
        % x3 = R*x      
        Iq  =  speye(nQuadCone);
        Iq1 =   ones(nQuadCone,quadCone1);
        Oq1 = sparse(nQuadCone,quadCone1);
        Oq  = sparse(nQuadCone,nQuadCone);
        Oqn = sparse(nQuadCone,size(A,2));
                
        %two cones
        Odq = sparse(nExpCone,nQuadCone);
        Oqd = sparse(nQuadCone,nExpCone);
        
        F = [...
            %  x,   1,  p,   e,  1,    q;
            Odn, Id1, Idp,  Od, Oz1, Odq;  % exp cone    x1  = 1 or y (if normalisation)
            Oqn, Ox1, Oqp, Oqd, Oq1,  Iq;  % quad cone   x1  = q 
            Idn, Od1, Odp,  Od, Oz1, Odq;  % exp cone    x2  = x
            Oqn, Ox1, Oqp, Oqd, Iq1,  Oq;  % quad cone   x2  = 1
            Odn, Od1, Odp,  Id, Oz1, Odq;  % exp cone    x3  = e
              R, Ox1, Oqp, Oqd, Oq1,  Oq]; % quad cone R*x3  = F3*x

        %permute the rows of F to form (x1, x2, x3) triples for each cone
        prob.f = sparse(size(F,1),size(F,2));
        prob.f(1:3:(3*nCone),:) = F((1:nCone)',:);
        prob.f(2:3:(3*nCone),:) = F((nCone+1:2*nCone)',:);
        prob.f(3:3:(3*nCone),:) = F((2*nCone+1:3*nCone)',:);
        
        %g (double[]) – The constant term of affine conic constraints. If not present or g==[] it is assumed g=0
        prob.g = zeros(size(prob.f,1),1);
        
        if nlt==1 && 0 %TODO implement for general small problem
            %names on all of the variables, used for debugging small
            %problems
            prob.names.var = cell(size(prob.a,2)+size(prob.f,1),1);    
            if 1
                prob.names.var{1,1} = 'f';
                prob.names.var{2,1} = 'r';
                prob.names.var{3,1} = 'vA';
                prob.names.var{4,1} = 'vB';
                prob.names.var{5,1} = 's';
                prob.names.var{6,1} = 'tf';
                prob.names.var{7,1} = 'tr';
                prob.names.var{8,1} = 'xf';
                prob.names.var{9,1} = 'xr';
                prob.names.var{10,1} = 'yf';
                prob.names.var{11,1} = 'yr';
                prob.names.var{12,1} = 'mtf';
                prob.names.var{13,1} = 'mtr';
                %rearrange the names of the variables according to ind
                prob.names.var(8:13)=prob.names.var(7+ind);
            else
                for i=1:nlt
                    prob.names.var{i,1} = ['f' int2str(i)];
                    prob.names.var{nlt+i,1} = ['r' int2str(i)];
                    prob.names.var{2*nlt+1+i,1} = ['tf' int2str(i)];
                    prob.names.var{3*nlt+1+i,1} = ['tr' int2str(i)];
                    prob.names.var{4*nlt+1+i,1} = ['xf' int2str(i)];
                    prob.names.var{5*nlt+1+i,1} = ['xr' int2str(i)];
                    prob.names.var{6*nlt+1+i,1} = ['yf' int2str(i)];
                    prob.names.var{7*nlt+1+i,1} = ['yr' int2str(i)];
                    prob.names.var{8*nlt+1+i,1} = ['mtf' int2str(i)];
                    prob.names.var{9*nlt+1+i,1} = ['mtr' int2str(i)];
                end
            end
            
            %print out the problem to diagnose problems manually
            mosekopt('write(problem.opf)',prob)
        end
        

        if isfield(param,'saveProb') && param.saveProb
            formattedTime = datestr(now, 'yyyymmddHHMMSS');
            EP.cmd=cmd;
            EP.prob=prob;
            EP.param=mosekParam;
            save([formattedTime '_EP_probBeforeMosekopt'],"EP");
        end

        %call mosek exponential cone solver
        tic;
        if 0
            %default
            [~,res]=mosekopt('minimize',prob);
        else
            [~,res]=mosekopt(cmd,prob,mosekParam);
        end
        sol.time = toc;
        if isfield(param,'epmethod')
            sol.epmethod = param.epmethod;
        else
            sol.epmethod = 'FREE';
        end

        %parse mosek result structure      
        [stat,origStat,x,y,yl,yu,z,zl,zu,k,basis,pobjval,dobjval] = parseMskResult(res);

        sol.stat = stat;
        sol.origStat = origStat;
        sol.obj = pobjval;
        switch stat
            case 1
                %check for zeros in variables within entropy functions
                zeroxBool = x(1:length(d))==0 & d~=0;
                if any(zeroxBool)
                    warning([num2str(nnz(zeroxBool)) ' optimal values that equal zero within entropy objective(s)'])
                    ind = find(zeroxBool);
                    fprintf('%8s %8s %8s\n','xl','x','xu')
                    for i=1:length(ind)
                        fprintf('%8.4g %8.4g %8.4g\n',prob.blx(ind(i)),x(ind(i)),prob.bux(ind(i)));
                    end
                end

                %slacks
                sbl = prob.a*x - prob.blc;
                sbu = prob.buc - prob.a*x;
                s = sbu - sbl; %TODO -double check this
                if param.printLevel>1
                    fprintf('%8.2g %s\n',min(sbl), ' min(sbl) = min(A*x - bl), (should be positive)');
                    fprintf('%8.2g %s\n',min(sbu), ' min(sbu) = min(bu - A*x), (should be positive)');
                end
                
                if param.printLevel > 1
                    % Problem definition here: https://docs.mosek.com/9.2/toolbox/prob-def-affine-conic.html
                    fprintf('%s\n','Optimality conditions (numerical)')
                    % Guide to interpreting the sol summary: https://docs.mosek.com/9.2/toolbox/debugging-log.html#continuous-problem
                    fprintf('%8.2g %s\n',norm(prob.a(prob.blc==prob.buc,:)*x - prob.blc(prob.blc==prob.buc),inf), '|| A*x - b ||_inf');
                    val = norm(prob.c - prob.a'*y - z - prob.f'*k,inf);
                    fprintf('%8.2g %s\n',val, '|| c - A''*y - z - F''*k ||_inf');
                    if val>1e-6 || param.debug
                        sol.T0 = table(prob.c - prob.a'*y - z - prob.f'*k,prob.c, prob.a'*y, z,prob.f'*k,'VariableNames',{'tot','c','Aty','z','Ftdoty'});
                    end
                    %fprintf('%8.2g %s\n',norm(prob.c - prob.f'*s,inf), '|| c - F''k ||_inf');
                    fprintf('%8.2g %s\n',norm(-y + res.sol.itr.slc - res.sol.itr.suc,inf), '|| -y + res.sol.itr.slc - res.sol.itr.suc ||_inf');
                    %fprintf('%8.2g %s\n',prob.c'*x - prob.b'*y, ' c''*x -b''*y');
                    
                    fprintf('%8.2g %s\n',(prob.f*x + prob.g)'*k, '(F*x + g)''*k >= 0');
                end
                
                %%% Reorder
                % Dual variables to affine conic constraints, based on original order of rows in F matrix
                y_K = zeros(length(k),1);
                y_K(1:nCone,1) = k(1:3:3*nCone);
                y_K(nCone+1:2*nCone,1) = k(2:3:3*nCone);
                y_K(2*nCone+1:3*nCone,1) = k(3:3:3*nCone);
                
                %check with the original order of the affine cone constraints
                val = norm(prob.c - prob.a'*y - z - F'*y_K,inf);
                if param.printLevel > 1
                    fprintf('%8.2g %s\n',val, '|| c - A''*y - z - F''*y_K ||_inf');
                end
                if val>1e-6 || param.debug
                    sol.T = table(prob.c - prob.a'*y - z - F'*y_K,prob.c, prob.a'*y, z,prob.f'*k,F'*y_K,'VariableNames',{'tot','c','Aty','z','Ftdoty','Fty_K'});
                end
                
                if param.printLevel > 1
                    x1 = F(1:nCone,:)*x;
                    x2 = F(nCone+1:2*nCone,:)*x;
                    x3 = F(2*nCone+1:3*nCone,:)*x;
                    
                    if nExpCone>0
                        fprintf('\n%s\n','Primal exponential cone:')
                        fprintf('%8.2g %s\n',min(x1(1:nExpCone) - x2(1:nExpCone).*exp(x3(1:nExpCone)./x2(1:nExpCone))), 'min(x1 - x2*exp(x3/x2)) >= 0');
                        %https://docs.mosek.com/modeling-cookbook/expo.html#entropy
                        fprintf('%8.2g %s\n',max(x3(1:nExpCone) - x2(1:nExpCone).*log(x1(1:nExpCone)./x2(1:nExpCone))), 'max(x3 - x2*log(x1/x2)) <= 0');
                        fprintf('%8.2g %s\n',norm(x3(1:nExpCone) - x2(1:nExpCone).*log(x1(1:nExpCone)./x2(1:nExpCone)),inf), '|| x3 - x2*log(x1/x2) ||_inf for exp cones');
                        
                        if nExpCone<=5 && isfield(prob,'names') && 0
                            %TODO complete for general input
                            for i=1:nExpCone %exp cones first
                                fprintf('%7.2g\t%s\n',norm(x3(i) - x2(i).*log(x1(i)/x2(i)),inf),...
                                    ['|| ' prob.names.var{2*n+1+i} ' - ' prob.names.var{i} '.* log(' prob.names.var{i} ' / ' prob.names.var{2*n+1} ') ||_inf']);
                            end
                        end
                    end
                    
                    if nQuadCone>0
                        fprintf('\n%s\n','Primal quadratic cone:')
                        % (1/2)*x'*(R'*R)*x <= q
                        % x1 =   q
                        % x2 =   1
                        % x3 = R*x
                        fprintf('%8.2g %s\n',min(x1 - (1/2)*(x3'*x3)), 'min(x1 - (1/2)*x3''*x3)) >= 0');
                    end
                    
                    y1_K = y_K(1:nCone);          % 1 should  be non-negative
                    y2_K = y_K(nCone+1:2*nCone);  % x
                    y3_K = y_K(2*nCone+1:3*nCone);% e should  be non-positive
                    
                    fprintf('\n%s\n','Dual exponential cone:')
                    % https://docs.mosek.com/9.2/toolbox/prob-def-affine-conic.html
                    % This is moseks convention to the dual exponential cone
                    fprintf('%7.2g\t%s\n',min(y1_K(1:nExpCone) + y3_K(1:nExpCone).*exp(y2_K(1:nExpCone)./y3_K(1:nExpCone))/exp(1)), 'min(y1_k + y3_k.*exp(y2_K./y3_K)/exp(1))  >= 0');
                end
                
                sol.full = x(1:size(A,2));
                %switch to Rockafellar signs
                sol.dual = -y(1:size(A,1));
                sol.dualNorm = -y(size(A,1)+1:size(A,1)+p);
                sol.rcost = -z(1:size(A,2)+p);
                sol.slack = s;
                
                %need to zero out the NaN due to log(0) for some variables
                logSolutionFull = real(log(sol.full));
                logSolutionFull(~isfinite(logSolutionFull))=0;
                if isfield(EPproblem,'Q')
                    sol.obj = EPproblem.c'*sol.full + (EPproblem.d.*sol.full)'*(logSolutionFull -1) + (1/2)*sol.full'*EPproblem.Q*sol.full;
                    sol.objLinear = EPproblem.c'*sol.full;
                    sol.objEntropy = -(EPproblem.d.*sol.full)'*(logSolutionFull -1);
                    sol.objQuadratic = (1/2)*sol.full'*EPproblem.Q*sol.full;
                else
                    sol.obj = EPproblem.c'*sol.full + (EPproblem.d.*sol.full)'*(logSolutionFull -1);
                    sol.objLinear = EPproblem.c'*sol.full;
                    sol.objEntropy = -(EPproblem.d.*sol.full)'*(logSolutionFull -1);
                    sol.objQuadratic = 0;

                end
                
                posRcost = sol.rcost>0;
                negRcost = sol.rcost<0;
                blx = prob.blx(1:size(A,2));
                bux = prob.bux(1:size(A,2));
                sol.lagRcost = sum(sol.rcost(negRcost)'*blx(negRcost) + sol.rcost(posRcost)'*bux(posRcost));
                
                %pass back the F matrix to check biochemical optimality criteria
                sol.coneF = F;
                sol.auxPrimal = x(size(A,2)+p+1:end);
                sol.auxRcost = -z(size(A,2)+p+1:end);
                sol.coneDual = -y_K;
                
                % variable to determine the residual 1
                b = prob.blc;
                % variable to determine the residual 2
                grad = prob.c - F'*y_K;
                grad = grad(1:size(A,2)+p,1);
                Aty = -prob.a'*y;
                Aty = Aty(1:size(A,2)+p,1);%strictly this is [A;P]'*y
                
            otherwise
                
                k = NaN*ones(size(prob.f,1),1);
        end              
    otherwise
        error([param.solver ' is an unrecognised solver'])
end

sol.solver=param.solver;

switch sol.stat
    case 0
        switch param.solver
            case 'pdco'
                %infeasible, debug the situtation
                disp(sol.origStat)
                %sol.origStat: 'PRIMAL_INFEASIBLE_CER'
                solutionLP = solveCobraLP(EPproblem);
                statLP=solutionLP.stat;
                
            case 'mosek'
                [cmd,mosekParam] = setMosekParam(param);

                [res] = msklpopt(EPproblem.c,EPproblem.A,EPproblem.blc,EPproblem.buc,EPproblem.lb,EPproblem.ub,mosekParam,cmd);

                [statLP,origStat,x,y,yl,yu,z,zl,zu,k,basis,pobjval,dobjval] = parseMskResult(res);
        end
        
        switch statLP
            case 1
                message =['solveCobraEP: EPproblem with ' param.solver ' is infeasible, but corresponding LPproblem is feasible according to solveCobraLP with ' param.solver];
                warning(message)
            otherwise
                message = ['solveCobraEP: EPproblem with ' param.solver ' is infeasible, because corresponding LPproblem is infeasible according to solveCobraLP with ' param.solver];
                warning(message)
        end
        if exist('messages','var')
            if isfield(sol,'messages')
                sol.messages = [messages;sol.messages;message];
            else
                sol.messages = [messages;message];
            end
        else
            sol.messages = cellstr(message);
        end
      
    case 1
        % check the optimality conditions for various solvers
        if ~isempty(sol.slack) && ~isempty(sol.full)
            % determine the residual 1
            switch param.solver
                case 'pdco'
                    feasTol = 1e-3;
                    res1 = A*sol.full + sol.slack - b;
                    res1(~isfinite(res1))=0;
                case 'mosek'
                    feasTol = param.feasTol * 1e2;
                    res1 = A(blc==buc,:)*sol.full - blc(blc==buc);
            end
            tmp1 = norm(res1, inf);
            
            % evaluate the optimality condition 1
            if tmp1 > feasTol
                if strcmp(param.solver,'pdco')
                    res1b = norm(A*sol.full + sol.slack - b + (d2^2)*y,inf);
                    tmp1b = norm(res1b, inf);
                    if tmp1b > feasTol
                        displayError = 1;
                    else
                        displayError = 0;
                        warning(['[' param.solver '] Primal optimality condition in solveCobraEP only approximately satisfied, residual = ' num2str(tmp1) ', regularised residual = ' num2str(tmp1b) ', while problem feasTol = ' num2str(feasTol) '.  origStat = ' sol.origStat])
                    end
                else
                    %TODO - debug why solver reporting optimal but unscaled seems less so.
                    displayError = 0;
                end
                if displayError
                    %disp(sol.origStat)
                    fprintf('%s\n',['[' param.solver '] Primal optimality condition in solveCobraEP not satisfied, residual = ' num2str(tmp1) ', while problem feasTol = ' num2str(feasTol) '.  origStat = ' sol.origStat])
                end
            else
                if param.printLevel > 0
                    fprintf(['\n > [' param.solver '] Primal optimality condition in solveCobraEP satisfied.']);
                end
            end
        end
        
        %gradient may differ depending on the solver
        res2 = grad  + Aty + sol.rcost;
        tmp2 = norm(res2, inf);
        
        if 0
            optTol = param.optTol * 1e2;
        else
            optTol = 5e-5;
        end
        % evaluate the optimality condition 2
        if tmp2 > optTol
            disp(sol.origStat)
            if ~(length(A)==1 && strcmp(param.solver,'pdco')) %todo, why does pdco choke on small A?
                warning(['[' param.solver '] Dual   optimality condition in solveCobraEP not satisfied, residual = ' num2str(tmp2) ', while problem optTol = ' num2str(optTol)])
            end
        else
            if param.printLevel > 0
                fprintf(['\n > [' param.solver '] Dual   optimality condition in solveCobraEP satisfied.\n']);
            end
        end
end



end


function [obj,grad,hess] = entropyObj(x,c,d)
    
n=length(x);
logx = zeros(n,1);
e = double(d~=0);
logx(d~=0) = reallog(x(d~=0));     % error if negative
obj  = c'*x + (d.*x)'*(logx - e);
grad = c + d.*logx;
hess = d./x;
hess(d==0)=0;
%hess = diag(hess); % not necessary as pdco knows to treat vector as a
%diagonal of a hessian.
end

function [obj,grad,hess] = entropyQPObj(x,c,d,Q)
    
n=length(x);
logx = zeros(n,1);
e = double(d~=0);
logx(d~=0) = reallog(x(d~=0));     % error if negative
obj  = c'*x + (d.*x)'*(logx - e) + 1/2*x'*Q*x;
grad = c + d.*logx + Q*x;
hess = d./x;
hess(d==0)=0;
hess = spdiags(hess,0,n,n) + Q;
end