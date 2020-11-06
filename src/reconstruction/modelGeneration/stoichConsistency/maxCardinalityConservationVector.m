function  [maxConservationMetBool, maxConservationRxnBool, solution] = maxCardinalityConservationVector(S, param)
% Maximises the cardinality of the conservation vector:
%
% .. math::
%
%    max  ~& ||l||_0 \\
%    st.  ~& S^T l = 0 \\
%         ~& 0 \leq l
%
% When param.method = 'optimizeCardinality'; then approximately solve the problem
%    max  ~& ||l||_0 \\
%    st.  ~& S^T l = 0 \\
%         ~& 0 \leq l \leq 1/epsilon
%
% When param.method = 'quasiConcave'; then solve the linear problem
%       max 1'*z
%       s.t S'*l = 0
%           z <= l
%           0 <= l <= 1/epsilon
%           0 <= z <= epsilon
%
% When param.method = 'optimizeCardinality'; then solve the difference of convex function problem 
% were the `l0` norm is approximated by the capped `l1` norm. 
% The resulting problem is solved with a DC program.
%
% When param.method = 'dc'; then solve the difference of convex function problem 
% were the `l0` norm is approximated by the capped `l1` norm. 
% The resulting problem is solved with a DC program. Should give the same
% answer as optimizeCardinality.
%
% USAGE:
%
%    [maxConservationMetBool, maxConservationRxnBool, solution] = maxCardinalityConservationVector(S, param)
%
% INPUT:
%    S:                         `m` x `n` stoichiometric matrix
%
% OPTIONAL INPUTS:
%    param:   structure with:
%
%              * .nbMaxIteration - Stopping criteria - maximal number of iteration (Default value 1000)
%              * .eta - Smallest value considered non-zero (Default value feasTol*1000)
%              * .epsilon - `1/epsilon` is the largest molecular mass considered (Default value 1e-4)
%              * .zeta - Stopping criteria - threshold (Default value 1e-6)
%              * .theta - Parameter of capped `l1` approximation (Default value 0.5)
%              * .method - {'quasiConcave', ('optimizeCardinality')}
% 
% OUTPUTS:
%    maxConservationMetBool:    `m` x 1 boolean for consistent metabolites
%    maxConservationRxnBool:    `n` x 1 boolean for reactions exclusively involving consistent metabolites
%    solution:                  Structure containing the following fields:
%
%                                 * l - `m` x 1 molecular mass vector
%                                 * k - `n` x 1 reaction complex mass vector 
%                                 * stat - status:
%
%                                   * 1 =  Solution found
%                                   * 2 =  Unbounded
%                                   * 0 =  Infeasible
%                                   * -1=  Invalid input
%
% .. Author: - Ronan Fleming Feb, 14th 2017

feasTol = getCobraSolverParams('LP', 'feasTol');
% Format inputs
if ~exist('param','var')
    param.nbMaxIteration = 1000;
    param.eta = feasTol*1000;%changed to 1000
    param.zeta = 1e-6;
    param.theta   = 0.5;    %parameter of capped l1 approximation
    param.epsilon = 1e-4;
    param.method = 'optimizeCardinality';
    param.printLevel = 0;
else
    if isfield(param,'nbMaxIteration') == 0
        param.nbMaxIteration = 1000;
    end

    if isfield(param,'eta') == 0
        param.eta = feasTol*1000;
    end

    if isfield(param,'epsilon') == 0
        param.epsilon = 1e-4;
    end

    if isfield(param,'zeta') == 0
        param.zeta = 1e-6;
    end

    if isfield(param,'theta') == 0
        param.theta   = 0.5;    %parameter of capped l1 approximation
    end
    if isfield(param,'method') == 0
        param.method   = 'optimizeCardinality';
    end
    if ~isfield(param,'printLevel')
        param.printLevel = 0;
    end
end


% Get data from the model
[mlt,nlt] = size(S);


[nbMaxIteration,zeta,theta,epsilon,method] = deal(param.nbMaxIteration,param.zeta,param.theta,param.epsilon,param.method);

%method='quasiConcave';
%method='optimizeCardinality';
%method='dc';
switch method
    case 'quasiConcave'
        % Solve the linear problem
        %   max sum(z_i)
        %       s.t S'*l = 0
        %           z <= l
        %           0 <= l <= 1/epsilon
        %           0 <= z <= epsilon
        LPproblem.A=[S'      , sparse(nlt,mlt);
                        speye(mlt),-speye(mlt)];

        LPproblem.b=zeros(nlt+mlt,1);
        %LPproblem.lb=[           zeros(mlt,1)-eps;-ones(mlt,1)*epsilon];%small relaxation of lower bound can be necessary for numerical feasibility
        LPproblem.lb=[zeros(mlt,1);        zeros(mlt,1)];
        LPproblem.ub=[ones(mlt,1)*(1/epsilon); ones(mlt,1)*epsilon];
        LPproblem.c=zeros(mlt+mlt,1);
        LPproblem.c(mlt+1:2*mlt,1)=1;
        LPproblem.osense=-1;
        LPproblem.csense(1:nlt,1)='E';
        LPproblem.csense(nlt+1:nlt+mlt,1)='G';

        printLevel=0;
        sol = solveCobraLP(LPproblem,'printLevel',printLevel);

        if sol.stat==1
            solution.l=sol.full(1:mlt,1);
            %z=solution.full(mlt+1:end,1);
            solution.stat=sol.stat;
        else
            disp(sol.origStat)
            error('solve for maximal conservation vector failed, try to make epsilon larger, e.g. 1e-4.')
        end
    case 'optimizeCardinality'
        % min       c'(x,y,z) + lambda*||x||_0 - delta*||y||_0
        % s.t.      A*(x,y,z) <= b
        %           l <= (x,y,z) <=u
        %           x in R^p, y in R^q, z in R^r
        cardProblem.p=0;
        cardProblem.q=mlt;
        cardProblem.r=0;
        cardProblem.c=zeros(mlt,1);
        cardProblem.A=S';
        cardProblem.b=zeros(nlt,1);
        cardProblem.lb=zeros(mlt,1);
        if 0
            cardProblem.ub=(1/epsilon)*ones(mlt,1);
        else
            cardProblem.ub=inf*ones(mlt,1);
        end
        cardProblem.csense(1:nlt,1)='E';
        
        
        % lambda0 - trade-off parameter on minimise `||x||_0`
        % lambda1 - trade-off parameter on minimise `||x||_1`
        cardProblem.lambda0=0;   
        cardProblem.lambda1=0; 

        % delta0 - trade-off parameter on maximise `||y||_0`
        % delta1 - trade-off parameter on minimise `||y||_1`
        cardProblem.delta0=1;
        cardProblem.delta1=0; %sensitive to this value, 0 works for recon3model

        solution = optimizeCardinality(cardProblem,param);
        % OUTPUT
        % solution                  Structure containing the following fields
        %       x                   p x 1 solution vector
        %       y                   q x 1 solution vector
        %       z                   r x 1 solution vector
        %       stat                status
        %                           1 =  Solution found
        %                           2 =  Unbounded
        %                           0 =  Infeasible
        %                           -1=  Invalid input
        if solution.stat == 1
            solution.l = solution.y;
        end
    case 'dc'
        %Parameters
        nbIteration = 1;
        stop = false;
        solution.l = [];
        solution.stat = 1;

        m=mlt;
        n=nlt;
        % Variable
        l   = zeros(m,1);
        z   = zeros(m,1);

        %Create the linear sub-program that one needs to solve at each iteration
        %Both the objective, and the constraints change at each iteration.

        
        %Objective changes each iteration as theta changes
        % Define subproblem objective - variable (l,z)
        %c = [-theta*ones(m,1);ones(m,1)];
        osense = 1;%minimise
        
        % LHS of constraints change at each iteration as theta changes
        % S'*l = 0
        % z >= theta*l
        % A  = [             S',   sparse(n,m);
        %        theta*speye(m),     -speye(m)];
        
        b  = zeros(n+m,1);
        csense  = [repmat('E',n, 1);repmat('L',m, 1)];

        % Bound;
        % 0 <= l <= 1/epsilon
        % 1 <= z <=   inf
        lb  = [zeros(m,1);ones(m,1)];
        if 1
            ub  = [(1/epsilon)*ones(m,1);inf*ones(m,1)];
        else
            ub  = [inf*ones(m,1);inf*ones(m,1)];
        end

        %Basis
        basis = [];

        %Define the linear sub-problem
        subLPproblem = struct('osense',osense,'csense',csense,'b',b,'lb',lb,'ub',ub,'basis',basis);

        obj_old = maximiseConservationVector_obj(l,theta);
        %DCA
        while nbIteration < nbMaxIteration && stop ~= true

            l_old = l;
            z_old = z;

            %Solve the sub-linear program to obtain new l
            [l,z,LPsolution] = maximiseConservationVector_solveSubProblem(subLPproblem,S,theta);
            switch LPsolution.stat
                case 0
                    warning('Problem infeasible !!!!!');
                    solution.l = [];
                    solution.stat = 0;
                    stop = true;
                case 2
                    warning('Problem unbounded !!!!!');
                    solution.l = [];
                    solution.stat = 2;
                    stop = true;
                case 1
                    %Reuse basis
                    if isfield(LPsolution,'basis')
                        subLPproblem.basis=LPsolution.basis;
                    end
                    %Check stopping criterion
                    error_l = norm(l - l_old);
                    obj_new = maximiseConservationVector_obj(l,theta);
                    error_obj = abs(obj_new - obj_old);
                    if (error_l < zeta) || (error_obj < zeta)
                        stop = true;
                    else
                        obj_old = obj_new;
                    end
                    if param.printLevel>1
                        if nbIteration==1
                            fprintf('%20s%12.6s%12.5s%12.6s%12.6s%12.6s%12.6s\n','itn','theta','err_l','err_obj','obj','obj_l','obj_z');
                        end
                        obj_l = -theta*ones(m,1)'*l;
                        obj_z = ones(m,1)'*z;
                        fprintf('%20u%12.6g%12.5g%12.6g%12.6g%12.2g%12.6g\n',nbIteration,theta,min(error_l),min(error_obj),obj_new,obj_l,obj_z);
                    end
                     %update the approximation parameter theta
                    if theta < 1000
                        theta = theta * 1.5;
                    end
            end

            nbIteration = nbIteration + 1;
        end

        %find rows that are not all zero when a subset of reactions omitted
        zeroRowBool = ~any(S,2);
        if any(zeroRowBool)
            %any zero row of S is automatically inconsistent
            l(zeroRowBool)=0;
        end

        if solution.stat == 1
            solution.l = l;
        end
    case 'dc_old'
        %Parameters
        nbIteration = 1;
        stop = false;
        solution.l = [];
        solution.stat = 1;

        m=mlt;
        n=nlt;
        % Variable
        l   = zeros(m,1);
        z   = zeros(m,1);

        %Create the linear sub-programme that one needs to solve at each iteration, only its
        %objective function changes, the constraints set remains.

        % Define objective - variable (l,z)
        obj = [-theta*ones(m,1);ones(m,1)];

        % Constraints
        % S'*l = 0
        % z >= theta*l
        A2 = [S'             sparse(n,m);
            -theta*speye(m)   speye(m)];%signs were wrong %not sure
        b2 = [zeros(n+m,1)];
        csense2 = [repmat('E',n, 1);repmat('L',m, 1)];

        % Bound;
        % 0 <= l <= 1/epsilon
        % 0 <= z <=   epsilon
        lb2 = [zeros(m,1);zeros(m,1)];
        ub2 = [(1/epsilon)*ones(m,1);epsilon*ones(m,1)];

        %Basis
        basis = [];

        %Define the linear sub-problem
        subLPproblem = struct('c',obj,'osense',1,'A',A2,'csense',csense2,'b',b2,'lb',lb2,'ub',ub2,'basis',basis);

        obj_old = maximiseConservationVector_obj(l,theta);

        %DCA
        while nbIteration < nbMaxIteration && stop ~= true

            l_old = l;
            z_old = z;

            %Solve the sub-linear program to obtain new l
            [l,z, LPsolution] = maximiseConservationVector_solveSubProblem(subLPproblem,S,theta);
            switch LPsolution.stat
                case 0
                    warning('Problem infeasible !!!!!');
                    solution.l = [];
                    solution.stat = 0;
                    stop = true;
                case 2
                    warning('Problem unbounded !!!!!');
                    solution.l = [];
                    solution.stat = 2;
                    stop = true;
                case 1
                    %Reuse basis
                    if isfield(LPsolution,'basis')
                        subLPproblem.basis=LPsolution.basis;
                    end
                    %Check stopping criterion
                    error_l = norm(l - l_old);
                    obj_new = maximiseConservationVector_obj(l,theta);
                    error_obj = abs(obj_new - obj_old);
                    if (error_l < zeta) || (error_obj < zeta)
                        stop = true;
                    else
                        obj_old = obj_new;
                    end
                    % Automatically update the approximation parameter theta
                    if theta < 1000
                        theta = theta * 1.5;
                    end
                    %             disp(strcat('DCA - Iteration: ',num2str(nbIteration)));
                    %             disp(strcat('Obj:',num2str(obj_new)));
                    %             disp(strcat('Stopping criteria error: ',num2str(min(error_l,error_obj))));
                    %             disp('=================================');

            end

            nbIteration = nbIteration + 1;

        end

        %find rows that are not all zero when a subset of reactions omitted
        zeroRowBool = ~any(S,2);
        if any(zeroRowBool)
            %any zero row of S is automatically inconsistent
            l(zeroRowBool)=0;
        end

        if solution.stat == 1
            solution.l = l;
        end
    otherwise
        error('incorrect method selected')

end

if solution.stat==1
    %conserved if molecular mass is above epsilon
    maxConservationMetBool=solution.l>=param.eta;
    %columns matching stoichiometrically consistent rows
    maxConservationRxnBool = getCorrespondingCols(S,maxConservationMetBool,true(nlt,1),'exclusive');
    if param.printLevel>3
        fprintf('%6u\t%6u\t%s%s%s\n',nnz(maxConservationMetBool),nnz(maxConservationRxnBool),' stoichiometrically consistent by max cardinality of conservation vector. (', param.method ,' method)')
    end
    
    %relative mass of each reaction complex
    F=-min(S,0);
    solution.k = F'*solution.l;
    %for exchange reactions, there may be only one positive stoichiometric
    %coefficient
    ExRxnBoolOneCoefficient = sum(S~=0)==1;
    R = max(S,0);
    solution.k(ExRxnBoolOneCoefficient) = solution.k(ExRxnBoolOneCoefficient) + R(:,ExRxnBoolOneCoefficient)'*solution.l;
    %solution.k=solution.k';
else
    maxConservationMetBool=[];
    maxConservationRxnBool=[];
    disp(solution)
    error('solve for maximal conservation vector failed')
end

end


%Solve the linear sub-program to obtain new l
function [l,z,LPsolution] = maximiseConservationVector_solveSubProblem(subLPproblem,S,theta)

[m,n] = size(S);

% Change the objective - variable (l,z)
%subLPproblem.obj = [-theta*ones(m,1);ones(m,1)];
subLPproblem.c = [-theta*ones(m,1);ones(m,1)];

subLPproblem.A = [             S',   sparse(n,m);
                   theta*speye(m),     -speye(m)];
           
%Solve the linear problem
LPsolution = solveCobraLP(subLPproblem);

if LPsolution.stat == 1
    l = LPsolution.full(1:m);
    z = LPsolution.full(m+1:2*m);
else
    l = [];
    z = [];
end
end

%Compute the objective function
function obj = maximiseConservationVector_obj(l,theta)
m = length(l);
obj = ones(m,1)'*min(ones(m,1),theta*l);
end