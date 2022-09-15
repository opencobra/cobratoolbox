function solution = optCardThermo(model,param)
% Finds a thermodynamically feasible net flux biased toward presence/absence of metabolites
% and activity/inactivity of certain reactions by solving the following optimisation
% problem
% 
% min  beta*g1.*(p + q) + g0.*|z|_0 + h0(-ve).*|s|_0 + h0(+ve).*|s|_0 + c*[z;w]
% 
% s.t. N*z + B*w     = b
%      C*z + D*w    <= d (optionally)
%        z - p  + q  = 0
%      A(p + q) - s  = 0
%      Az - r        = 0
%      lb <= [z;w]  <= ub
%      0 <= p
%      0 <= q
%
% where [N, B] := model.S;
%            A := F + R,
%            F := -min(N,0)
%            R : = max(N,0)
%
%
% INPUT:
%    model:             (the following fields are required - others can be supplied)
%
%                         * S  - `m x n` Stoichiometric matrix
%                         * c  - `n x 1` Linear objective coefficients
%                         * lb - `n x 1` Lower bounds on reaction rate
%                         * ub - `n x 1` Upper bounds on reaction rate
% OPTIONAL INPUTS:
%    model:             (optional fields)
%          * .SConsistentRxnBool - 'm x 1' boolean vector indicating stoichiometrically consistent reactions
%          * .b - `m x 1` change in concentration with time
%          * .csense - `m x 1` character array with entries in {L,E,G}
%          * .osenseStr - Maximize ('max')/minimize ('min')
%                       (opt, default = 'max') only affects the interpretation of linear part of the objective (from model.c).
%          * .C - `k x n` Left hand side of C*v <= d
%          * .d - `k x n` Right hand side of C*v <= d
%          * .dsense - `k x 1` character array with entries in {L,E,G}
%
%          * .h0  - `m x 1`, local weight on zero norm of rate of production of  each metabolite by internal reactions.
%
%          * .g0  - `n x 1` , local weight on zero norm of the net flux of each reaction
%          * .g1  - `n x 1` , local weight on one norm of the net flux of each reaction
%
%          * .presentMet - `m x 1` boolean vector indicating metabolites
%                          that must be produced by internal reactions in the submodel
%          * .absentMet - `m x 1` boolean vector indicating metabolites
%                          that must be produced by internal reactions in the submodel
%          * .activeRxn - `n x 1` boolean vector indicating reactions that must be active in the submodel
%          * .inactiveRxn - `n x 1` boolean vector indicating reactions that must be active in the submodel
%
%          * .lambda0 - trade-off parameter on minimise `||x||_0`
%          * .lambda1 - trade-off parameter on minimise `||x||_1`
%          * .delta0  - trade-off parameter on maximise `||y||_0`
%          * .delta1  - trade-off parameter on minimise `||y||_1'
%          * .beta    - trade-off parameter on minimise `||p||_1' + `||q||_1', increase to incentivise thermodynamic feasibility

%    param:      Parameters structure:
%                   * .printLevel - greater than zero to recieve more output
%                   * .thermoConsistencyMethod - method to check thermo consistency, default: 'cycleFreeFlux'
%                   * .bigNum - definition of a large positive number (Default value = 1e6)
%                   * .nbMaxIteration - stopping criteria - number maximal of iteration (Default value = 100)
%                   * .epsilon - stopping criteria - (Default value = 10e-6)
%                   * .theta - parameter of the approximation (Default value = 2)
%                              For a sufficiently large theta, the Capped-L1 approximate problem
%                              and the original cardinality optimisation problem are have the same set of optimal solutions
%                   *.acceptRepairedFlux -for cycleFreeFlux, 0 = do not accept reparied flux, 1 = accept the repaired flux vector. 
%
%
% OUTPUT:
%    solution:       solution object:
%
%             * v - ntot x 1 reaction flux
%             * p - n x 1 equal to reaction flux if positive (not a unidirectional reaction flux in a thermodynamic sense)
%             * q - n x 1 equal to reaction flux if negative (not a unidirectional reaction flux in a thermodynamic sense)
%             * s - m x 1 sum of the rates of production plus consumption of each metabolite
%             * r - m x 1 (net) consumpton/production rate, depending on formulation
%             * y - m x 1 dual to steady state constraints
%             * thermoConsistentFluxBool - n x 1 boolean vector indicating thermodynamically consistent reaction fluxes, obtained from checkThermoFeasibility.m
%                                          Zero internal fluxes may be thermodynamically consistent, and all external reaction fluxes are thermodynamically infeasible.                 
%
%             * stat - Solver status in standardized form:
%                   * 0 - Infeasible problem
%                   * 1 - Optimal solution
%                   * 2 - Unbounded solution
%                   * 3 - Almost optimal solution
%                   * -1 - Some other problem (timelimit, numerical problem etc)

% .. Author: - Ronan Fleming 2022
% .. Please cite:
% Fleming RMT, Haraldsdottir HS, Le HM, Vuong PT, Hankemeier T, Thiele I. 
% Cardinality optimisation in constraint-based modelling: Application to human metabolism, 2022 (submitted).

if ~exist('param','var')
    param = struct();
end
if ~isfield(param,'printLevel')
    param.printLevel = 0;
end
if ~isfield(param,'thermoConsistencyMethod')
    param.thermoConsistencyMethod='cycleFreeFlux';
end
if ~isfield(param,'bigNum')
    param.bigNum = 1e4;
end
if ~isfield(param,'formulation')
    if isfield(model,'h0') && any(model.h0~=0)
        param.formulation ='pqzwrs';
    else
        param.formulation ='pqzw';
    end
end
if ~isfield(param,'regularizeOuter')
    param.regularizeOuter =0;
end
if isfield(param, 'g0')
    error('param.g0 should be model.g0')
end
if isfield(param, 'h0')
    error('param.h0 should be model.h0')
end
if ~isfield(param, 'debug')
    param.debug=0; %switch this to 1 if numerical issues
end
if ~isfield(param, 'relaxBounds')
    %0 is the default for cycleFreeFlux, but setting to one allows the bounds
    %to be relaxed when repairing a thermodynamically infeasible flux. 
    param.relaxBounds=0; 
end
if ~isfield(param, 'acceptRepairedFlux')
    %0 is the default for cycleFreeFlux, but setting to one allows to accept the repaired flux. 
    param.acceptRepairedFlux=0; 
end
feasTol = getCobraSolverParams('LP', 'feasTol');
if ~isfield(param, 'epsilon')
    param.epsilon=feasTol; 
end
if ~isfield(param, 'theta')
    param.theta = 0.1;%smaller than default 
end
if ~isfield(param, 'rpos')
    %param.rpos = 1;%was default before summer 22
    param.rpos = 0;
end

[nMet, nRxn] = size(model.S);

if isfield(model,'g0')
    if isempty(model.g0)
        model.g0 = zeros(nRxn,1);
        %by default, minimisation of cardinality of internal reactions
        model.g0(model.SConsistentRxnBool) = 1;
    else
        if length(model.g0)~= nRxn
            error('length(model.g0) must equal size(model.S,2)')
        end
    end
else
    model.g0 = zeros(nRxn,1);
    %by default, minimisation of cardinality of internal reactions
    model.g0(model.SConsistentRxnBool) = 1;
end

if isfield(model,'g1')
    if length(model.g1)~= nRxn
        error('length(model.g1) must equal size(model.S,2)')
    end
else
    %one norm minimisation of internal reaction rates only
    model.g1 = ones(nRxn,1);
    model.g1(~model.SConsistentRxnBool)=0;
end

if isfield(model,'h0')
    if isempty(model.h0)
        model.h0 = zeros(nMet,1);
    else
        if length(model.h0)~= nMet
            error('length(model.h0) must equal size(model.S,1)')
        end
        if any(model.h0) && ~strcmp(param.formulation,'pqzwrs')
            warning('param.formulation = ''pqzwrs'' works better for weights on metabolites')
        end
    end
else
    model.h0 = zeros(nMet,1);
end

if isfield(model,'presentMet')
    if length(model.presentMet)~= nMet
        error('length(model.presentMet) must equal size(model.S,1)')
    end
else
    model.presentMet = false(nMet,1);
end

if isfield(model,'absentMet')
    if length(model.absentMet)~= nMet
        error('length(model.absentMet) must equal size(model.S,1)')
    end
else
    model.absentMet = false(nMet,1);
end

if isfield(model,'activeRxn')
    if length(model.activeRxn)~= nRxn
        error('length(model.activeRxn) must equal size(model.S,2)')
    end
else
    model.activeRxn = false(nRxn,1);
end

if isfield(model,'inactiveRxn')
    if length(model.inactiveRxn)~= nRxn
        error('length(model.inactiveRxn) must equal size(model.S,2)')
    end
else
    model.inactiveRxn = false(nRxn,1);
end

if isfield(model, 'osenseStr')
    if strcmp(model.osenseStr,'max') || ~any(model.c~=0)
        osense = -1;
    elseif strcmp(model.osenseStr,'min')
        osense = 1;
    else
        error('model.osenseStr must be either min or max')
    end
else
    osense = 1;% minimise is the default
end

if ~isfield(model,'fluxConsistentMetBool') || ~isfield(model,'fluxConsistentRxnBool')
    fluxConsistentParam.method='fastcc';%can handle additional constraints
    fluxConsistentParam.printLevel=1;
    [~,~,~,~,model]= findFluxConsistentSubset(model,fluxConsistentParam);
end
if any(~model.fluxConsistentRxnBool)
    if param.printLevel>0
        fprintf('%u%s\n',nnz(~model.fluxConsistentMetBool),' flux inconsistent metabolites in the model.')
        fprintf('%u%s\n',nnz(~model.fluxConsistentRxnBool),' flux inconsistent reactions in the model.')
    end
end
if isfield(model,'thermoFluxConsistentRxnBool') && any(~model.thermoFluxConsistentRxnBool)
    if param.printLevel>0
        fprintf('%u%s\n',nnz(~model.thermoFluxConsistentMetBool),' thermodyamically flux inconsistent metabolites in the model.')
        fprintf('%u%s\n',nnz(~model.thermoFluxConsistentRxnBool),' thermodynamically flux inconsistent reactions in the model.')
    end
end

if ~isfield(model,'SConsistentRxnBool')  || ~isfield(model,'SConsistentMetBool')
    if ~isfield(param,'SConsistentMethod') && isfield(model,'mets')
        param.SConsistentMethod = 'findSExRxnInd';
    else
        param.SConsistentMethod = 'findStoichConsistentSubset';
    end
    switch param.SConsistentMethod
        case 'findSExRxnInd'
            %finds the reactions in the model which export/import from the model
            %boundary i.e. mass unbalanced reactions
            %e.g. Exchange reactions
            %     Demand reactions
            %     Sink reactions
            model = findSExRxnInd(model,[],param.printLevel-1);
            model.SConsistentMetBool= model.SIntMetBool;
            model.SConsistentRxnBool= model.SIntRxnBool;
        case 'findStoichConsistentSubset'
            % Finds the subset of `S` that is stoichiometrically consistent using
            % an iterative cardinality optimisation approach
            [SConsistentMetBool, SConsistentRxnBool, ...
                SInConsistentMetBool, SInConsistentRxnBool, ...
                unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model] ...
                = findStoichConsistentSubset(model);
    end
else
    if length(model.SConsistentRxnBool)~=nRxn
        error('Length of model.SConsistentRxnBool must equal the number of cols of model.S')
    end
    if length(model.SConsistentMetBool)~=nMet
        error('Length of model.SConsistentMetBool must equal the number of rows of model.S')
    end
end

if ~isfield(model,'dummyMetBool')
    if any(~model.SConsistentMetBool)
        if param.printLevel>0
            fprintf('%u%s\n',nnz(~model.SConsistentMetBool),' stoichiometrically inconsistent metabolites')
            fprintf('%u%s\n',nnz(~model.SConsistentRxnBool),' stoichiometrically inconsistent reactions')
        end
    end
end

nIntRxn = nnz(model.SConsistentRxnBool);
nExRxn = nnz(~model.SConsistentRxnBool);

if any(model.c(model.SConsistentRxnBool))
    fprintf('%s\n','model.c optimising internal reactions, this may interfere with thermodynamic feasibility.')
end

if isfield(model,'presentMet')
    if any(~model.fluxConsistentMetBool & model.presentMet)
        warning('Flux inconsistent core metabolites had to be excluded')
        disp(model.mets(~model.fluxConsistentMetBool & model.presentMet))
        model.presentMet(~model.fluxConsistentMetBool)=0;
    end
end
if isfield(model,'activeRxn')
    if any(~model.fluxConsistentRxnBool & model.activeRxn)
        warning('Flux inconsistent core reactions had to be excluded')
        disp(model.rxns(~model.fluxConsistentRxnBool & model.activeRxn))
        model.activeRxn(~model.fluxConsistentRxnBool)=0;
    end
end

% * .lambda0 - trade-off parameter on minimise `||x||_0`
if isfield(model,'lambda0')
    cardProb.lambda0 = model.lambda0;
else
    cardProb.lambda0 = 1;
end

% * .lambda1 - trade-off parameter on minimise `||x||_1`
if isfield(model,'lambda1')
    cardProb.lambda1 = model.lambda1;
else
    cardProb.lambda1 = feasTol;
end

%  * .delta0 - trade-off parameter on maximise `||y||_0`
if isfield(model,'delta0')
    cardProb.delta0 = model.delta0;
else
    cardProb.delta0 = 1;
end

%  * .delta1 - trade-off parameter on minimise `||y||_1
if isfield(model,'delta1')
    cardProb.delta1 = model.delta1;
else
    cardProb.delta1 = feasTol;
end

%global weight on one-norm minimisation for cardinality free variables
if isfield(model,'alpha1')
    cardProb.alpha1 = model.alpha1;
else
    cardProb.alpha1 = feasTol;
end

if ~isfield(model,'beta')
    model.beta = 1;
end

% INPUT:
%    problem:     Structure containing the following fields describing the problem:
%
%     * .p - size of vector `x` OR a `size(A,2) x 1` boolean indicating columns of A corresponding to x (min zero norm).
%     * .q - size of vector `y` OR a `size(A,2) x 1` boolean indicating columns of A corresponding to y (max zero norm).
%     * .r - size of vector `z` OR a `size(A,2) x 1`boolean indicating columns of A corresponding to z .
%     * .A - `s x size(A,2)` LHS matrix
%     * .b - `s x 1` RHS vector
%     * .csense - `s x 1` Constraint senses, a string containing the constraint sense for
%                  each row in `A` ('E', equality, 'G' greater than, 'L' less than).
%     * .lb - `size(A,2) x 1` Lower bound vector
%     * .ub - `size(A,2) x 1` Upper bound vector
%     * .c -  `size(A,2) x 1` linear objective function vector
%
% OPTIONAL INPUTS:
%    problem:     Structure containing the following fields describing the problem:
%                   * .osense - Objective sense  for problem.c only (1 means minimise (default), -1 means maximise)
%                   * .k - `p x 1` OR a `size(A,2) x 1` strictly positive weight vector on minimise `||x||_0`
%                   * .d - `q x 1` OR a `size(A,2) x 1` strictly positive weight vector on maximise `||y||_0`
%                   * .lambda0 - trade-off parameter on minimise `||x||_0`
%                   * .lambda1 - trade-off parameter on minimise `||x||_1`
%                   * .delta0 - trade-off parameter on maximise `||y||_0`
%                   * .delta1 - trade-off parameter on minimise `||y||_1
%                   * .o `size(A,2) x 1` strictly positive weight vector on minimise `||[x;y;z]||_1`
%
%    param:      Parameters structure:
%                   * .printLevel - greater than zero to recieve more output
%                   * .nbMaxIteration - stopping criteria - number maximal of iteration (Default value = 100)
%                   * .epsilon - stopping criteria - (Default value = 1e-6)
%                   * .theta - starting parameter of the approximation (Default value = 0.5)
%                              For a sufficiently large parameter , the Capped-L1 approximate problem
%                              and the original cardinality optimisation problem are have the same set of optimal solutions
%                   * .thetaMultiplier - at each iteration: theta = theta*thetaMultiplier
%                   * .epsilon - Smallest value considered non-zero (Default value feasTol*1000)

forcedIntRxnBool = (model.lb>0 | model.ub<0) & model.SConsistentRxnBool;

if param.printLevel>0
    fprintf('%s\n','optCardThermo parameters:')
    disp(param)
end

if param.printLevel>0
    fprintf('%s\n','optCardThermo objective data:')
    fprintf('%12.2g%s\n',model.beta,' = beta, the global weight on one-norm of internal reaction rate.')
    fprintf('%12.2g%s\n',min(model.g0(model.SConsistentRxnBool)),' = min(g0), the local weight on zero-norm of internal reaction rate.')
    fprintf('%12.2g%s\n',max(model.g0(model.SConsistentRxnBool)),' = max(g0), the local weight on zero-norm of internal reaction rate.')
    fprintf('%12.2g%s\n',min(model.g0(~model.SConsistentRxnBool)),' = min(g0), the local weight on zero-norm of external reaction rate.')
    fprintf('%12.2g%s\n',max(model.g0(~model.SConsistentRxnBool)),' = max(g0), the local weight on zero-norm of external reaction rate.')
    fprintf('%12.2g%s\n',min(model.h0),' = min(h0), the local weight on zero-norm of metabolite production rate.')
    fprintf('%12.2g%s\n',max(model.h0),' = max(h0), the local weight on zero-norm of metabolite production rate.')
end
    
switch param.formulation
    case 'v'
        wSign = sign(model.g0);
        
        cardProb.p = wSign ==   1;%minimisation
        cardProb.q = wSign ==  -1;%maximisation
        cardProb.r = wSign == 0;
        
        bool = cardProb.p | cardProb.q  | cardProb.r;
        if ~all(bool)
            error('cardProb.p | cardProb.q  | cardProb.r must be all true')
        end
        
        cardProb.A = model.S;
        cardProb.b = model.b;
        cardProb.csense = model.csense;
        
        cardProb.lb = model.lb;
        cardProb.ub = model.ub;
        
        cardProb.c = osense*model.c;
        
        %local weights on cardinality optimisation
        cardProb.k = zeros(nRxn,1);
        cardProb.k(cardProb.p,1) =  model.g0(cardProb.p);
        cardProb.d = zeros(nRxn,1);
        cardProb.d(cardProb.q,1) = -model.g0(cardProb.q);

        

        %local weight on one-norm minimisation
        cardProb.o =  model.g1;
        %add weight to minimise one-norm of all internal reactions
        thermoWeight = model.SConsistentRxnBool~=0;
        cardProb.o(model.SConsistentRxnBool,1) = thermoWeight + model.g1(model.SConsistentRxnBool);
        
        sol = optimizeCardinality(cardProb, param);
        
        % OUTPUT:
        %    solution:    Structure containing the following fields:
        %
        %                   * .x - `p x 1` solution vector
        %                   * .y - `q x 1` solution vector
        %                   * .z - `r x 1` solution vector
        %                   * .stat - status
        %
        %                     * 1 =  Solution found
        %                     * 2 =  Unbounded
        %                     * 0 =  Infeasible
        %                     * -1=  Invalid input
        
        solution.v = sol.xyz(1:nRxn,1);
        solution.stat = sol.stat;
    case 'pq'
        Omn=sparse(nMet,nIntRxn);
        In=speye(nIntRxn,nIntRxn);
        D = sparse(nIntRxn,nRxn);
        D(:,model.SConsistentRxnBool) = speye(nIntRxn);
        
        cardProb.A = [...
            model.S,   Omn,   Omn;...
            D,   -In,    In];
        
        cardProb.b = [model.b;zeros(nIntRxn,1)];
        cardProb.csense(1:nMet+nIntRxn,1) = 'E';
        
        cardProb.lb = [model.lb;zeros(2*nIntRxn,1)];
        ubb=max(abs(model.lb(model.SConsistentRxnBool)),abs(model.ub(model.SConsistentRxnBool)));
        cardProb.ub = [model.ub;ubb;ubb];
        
        cardProb.c = [osense*model.c;ones(2*nIntRxn,1)];
        cardProb.osense = 1; %minimise
        
        %weights on cardinality optimisation
        wSign = [sign(model.g0);zeros(2*nIntRxn,1)];
        
        cardProb.p = wSign ==   1;%minimisation
        cardProb.q = wSign ==  -1;%maximisation
        cardProb.r = wSign ==  0;
        
        bool = cardProb.p | cardProb.q  | cardProb.r;
        if ~all(bool)
            error('cardProb.p | cardProb.q  | cardProb.r must be all true')
        end
        
        cardProb.k = sparse(nRxn+2*nIntRxn,1);
        cardProb.k(cardProb.p,1) =  model.g0(cardProb.p);
        cardProb.d = sparse(nRxn+2*nIntRxn,1);
        cardProb.d(cardProb.q,1) = -model.g0(cardProb.q);
        
        sol = optimizeCardinality(cardProb, param);
        
        % OUTPUT:
        %    solution:    Structure containing the following fields:
        %
        %                   * .x - `p x 1` solution vector
        %                   * .y - `q x 1` solution vector
        %                   * .z - `r x 1` solution vector
        %                   * .stat - status
        %
        %                     * 1 =  Solution found
        %                     * 2 =  Unbounded
        %                     * 0 =  Infeasible
        %                     * -1=  Invalid input
        
        solution.v = sol.xyz(1:nRxn,1);
        solution.p = sol.xyz(nRxn+1:nRxn+nIntRxn,1);
        solution.q = sol.xyz(nRxn+nIntRxn+1:nRxn+2*nIntRxn,1);
        solution.stat = sol.stat;
    case 'pqs'
        N = model.S(:,model.SConsistentRxnBool);
        B = model.S(:,~model.SConsistentRxnBool);

        Omn=sparse(nMet,nIntRxn);
        Onk=sparse(nIntRxn,nExRxn);
        On=sparse(nIntRxn,nIntRxn);
        In=speye(nIntRxn,nIntRxn);
        
        if isfield(model,'C')
            C = model.C(:,model.SConsistentRxnBool);
            nConstr = size(model.C,1);
            Ocn = sparse(nConstr,nIntRxn);
            D = model.C(:,~model.SConsistentRxnBool);
            
            cardProb.A = [...
                % p     q     s    w
                 N,   -N,   Omn,   B;
                In,   In,   -In, Onk;
               -In,   In,    On, Onk;
                In,  -In,    On, Onk;
                 C,   -C,   Ocn,   D];
            
            cardProb.b = [model.b;zeros(nIntRxn,1);-model.lb(model.SConsistentRxnBool);model.ub(model.SConsistentRxnBool);model.d];
            
            cardProb.csense(1:nMet,1) = model.csense;
            cardProb.csense(1:nMet+nIntRxn,1) = 'E';
            cardProb.csense(nMet+nIntRxn+1:nMet+3*nIntRxn,1)='L';
            cardProb.csense(nMet+3*nIntRxn+1:nMet+3*nIntRxn+nConstr,1)=model.dsense;
        else
            cardProb.A = [...
                % p     q     s    w
                N,    -N,   Omn,   B;
                In,   In,   -In, Onk;
                -In,  In,    On, Onk;
                In,  -In,    On, Onk];
            
            cardProb.b = [model.b;zeros(nIntRxn,1);-model.lb(model.SConsistentRxnBool);model.ub(model.SConsistentRxnBool)];
            
            cardProb.csense(1:nMet+nIntRxn,1) = 'E';
            cardProb.csense(nMet+nIntRxn+1:nMet+3*nIntRxn,1)='L';
        end
        
        cardProb.lb = [zeros(3*nIntRxn,1);model.lb(~model.SConsistentRxnBool)];
        cardProb.ub = [param.bigNum*ones(3*nIntRxn,1);model.ub(~model.SConsistentRxnBool)];
        
        cardProb.c = [...
            model.beta*ones(nIntRxn,1) + osense*model.c(model.SConsistentRxnBool);...
            model.beta*ones(nIntRxn,1) - osense*model.c(model.SConsistentRxnBool);...
            zeros(nIntRxn,1);...
            osense*model.c(~model.SConsistentRxnBool)];

        cardProb.osense = 1;%minimise by default
        
        %weights on cardinality optimisation
        wSign = [zeros(2*nIntRxn,1);sign(model.g0(model.SConsistentRxnBool));sign(model.g0(~model.SConsistentRxnBool))];
        w     = [zeros(2*nIntRxn,1);      model.g0(model.SConsistentRxnBool);model.g0(~model.SConsistentRxnBool)];
        
        cardProb.p = wSign ==   1;%minimisation
        cardProb.q = wSign ==  -1;%maximisation
        cardProb.r = wSign ==   0;
        
        bool = cardProb.p | cardProb.q  | cardProb.r;
        if ~all(bool)
            error('cardProb.p | cardProb.q  | cardProb.r must be all true')
        end
        
        cardProb.k = zeros(3*nIntRxn+nExRxn,1);
        cardProb.k(cardProb.p,1) =  w(cardProb.p);
        cardProb.d = zeros(3*nIntRxn+nExRxn,1);
        cardProb.d(cardProb.q,1) = -w(cardProb.q);
               
        sol = optimizeCardinality(cardProb, param);
        
        % OUTPUT:
        %    solution:    Structure containing the following fields:
        %
        %                   * .x - `p x 1` solution vector
        %                   * .y - `q x 1` solution vector
        %                   * .z - `r x 1` solution vector
        %                   * .stat - status
        %
        %                     * 1 =  Solution found
        %                     * 2 =  Unbounded
        %                     * 0 =  Infeasible
        %                     * -1=  Invalid input
        if sol.stat~=1
            error('optimizeCardinality did not solve')
        end
        solution.p = NaN*ones(nRxn,1);
        solution.p(model.SConsistentRxnBool) = sol.xyz(1:nIntRxn,1);
        solution.q = NaN*ones(nRxn,1);
        solution.q(model.SConsistentRxnBool) = sol.xyz(nIntRxn+1:2*nIntRxn,1);
        solution.s = NaN*ones(nRxn,1);
        solution.s(model.SConsistentRxnBool) = sol.xyz(2*nIntRxn+1:3*nIntRxn,1);
        
        solution.v = zeros(nRxn,1);
        solution.v(model.SConsistentRxnBool)= sol.xyz(1:nIntRxn,1)-sol.xyz(nIntRxn+1:2*nIntRxn,1);
        solution.v(~model.SConsistentRxnBool)= sol.xyz(3*nIntRxn+1:3*nIntRxn+nExRxn,1);
        
        solution.stat = sol.stat;
    case 'pqs1'
        N = model.S(:,model.SConsistentRxnBool);
        B = model.S(:,~model.SConsistentRxnBool);

        Omn=sparse(nMet,nIntRxn);
        Onk=sparse(nIntRxn,nExRxn);
        On=sparse(nIntRxn,nIntRxn);
        In=speye(nIntRxn,nIntRxn);
        O1n=sparse(1,nIntRxn);
        I1n=ones(1,nIntRxn);
        O1k=zeros(1,nExRxn);
        
        if isfield(model,'C')
            C = model.C(:,model.SConsistentRxnBool);
            nConstr = size(model.C,1);
            Ocn = sparse(nConstr,nIntRxn);
            D = model.C(:,~model.SConsistentRxnBool);
            
            cardProb.A = [...
                % p     q     s    w
                N,   -N,   Omn,   B;
                In,   In,   -In, Onk;
                -In,   In,    On, Onk;
                In,  -In,    On, Onk;
                C,   -C,   Ocn,   D; %coupling constraints
                O1n, O1n,   I1n, O1k];% lower bound on sum of internal unidirectional fluxes];
            
            cardProb.b = [model.b;zeros(nIntRxn,1);-model.lb(model.SConsistentRxnBool);model.ub(model.SConsistentRxnBool);model.d;1];%last constraint = 1
            
            cardProb.csense(1:nMet,1) = model.csense;
            cardProb.csense(1:nMet+nIntRxn,1) = 'E';
            cardProb.csense(nMet+nIntRxn+1:nMet+3*nIntRxn,1)='L';
            cardProb.csense(nMet+3*nIntRxn+1:nMet+3*nIntRxn+nConstr,1)=model.dsense;
            cardProb.csense(nMet+3*nIntRxn+nConstr+1,1)='G';
        else
            cardProb.A = [...
                % p     q     s    ve
                N,   -N,   Omn,   B;
                In,   In,   -In, Onk;
                -In,   In,    On, Onk;
                In,  -In,    On, Onk;
                O1n, O1n,   I1n, O1k];% lower bound on sum of internal unidirectional fluxes];
            
            cardProb.b = [model.b;zeros(nIntRxn,1);-model.lb(model.SConsistentRxnBool);model.ub(model.SConsistentRxnBool);1];%last constraint = 1
            
            cardProb.csense(1:nMet+nIntRxn,1) = 'E';
            cardProb.csense(nMet+nIntRxn+1:nMet+3*nIntRxn,1)='L';
            cardProb.csense(nMet+3*nIntRxn+1,1)='G';
        end
        
%         cardProb.A = [...
%            % f     r     s    ve
%              N,   -N,   Omn,   B;
%             In,   In,   -In, Onk;
%            -In,   In,    On, Onk;
%             In,  -In,    On, Onk;
%             O1n, O1n,   I1n, O1k];% lower bound on sum of internal unidirectional fluxes
%         
%         cardProb.b = [model.b;zeros(nIntRxn,1);-model.lb(model.SConsistentRxnBool);model.ub(model.SConsistentRxnBool);1];
%         cardProb.csense(1:nMet+nIntRxn,1) = 'E';
%         cardProb.csense(nMet+nIntRxn+1:nMet+3*nIntRxn,1)='L';
%         cardProb.csense(nMet+3*nIntRxn+1,1)='G';
        
        cardProb.lb = [zeros(3*nIntRxn,1);model.lb(~model.SConsistentRxnBool)];
        cardProb.ub = [param.bigNum*ones(3*nIntRxn,1);model.ub(~model.SConsistentRxnBool)];
        
        cardProb.c = [...
            model.beta*ones(nIntRxn,1) + osense*model.c(model.SConsistentRxnBool);...
            model.beta*ones(nIntRxn,1) - osense*model.c(model.SConsistentRxnBool);...
            zeros(nIntRxn,1);...
            osense*model.c(~model.SConsistentRxnBool)];

        cardProb.osense = 1; %minimise by default
        
        %weights on cardinality optimisation
        wSign = [zeros(2*nIntRxn,1);sign(model.g0(model.SConsistentRxnBool));sign(model.g0(~model.SConsistentRxnBool))];
        w     = [zeros(2*nIntRxn,1);      model.g0(model.SConsistentRxnBool);model.g0(~model.SConsistentRxnBool)];
        
        cardProb.p = wSign ==   1;%minimisation
        cardProb.q = wSign ==  -1;%maximisation
        cardProb.r = wSign ==   0;
        
        bool = cardProb.p | cardProb.q  | cardProb.r;
        if ~all(bool)
            error('cardProb.p | cardProb.q  | cardProb.r must be all true')
        end
        
        cardProb.k = zeros(3*nIntRxn+nExRxn,1);
        cardProb.k(cardProb.p,1) =  w(cardProb.p);
        cardProb.d = zeros(3*nIntRxn+nExRxn,1);
        cardProb.d(cardProb.q,1) = -w(cardProb.q);
        
        sol = optimizeCardinality(cardProb, param);
        
        % OUTPUT:
        %    solution:    Structure containing the following fields:
        %
        %                   * .x - `p x 1` solution vector
        %                   * .y - `q x 1` solution vector
        %                   * .z - `r x 1` solution vector
        %                   * .stat - status
        %
        %                     * 1 =  Solution found
        %                     * 2 =  Unbounded
        %                     * 0 =  Infeasible
        %                     * -1=  Invalid input
        
        if sol.stat~=1
            error('optimizeCardinality did not solve')
        end
        
        solution.p = NaN*ones(nRxn,1);
        solution.p(model.SConsistentRxnBool) = sol.xyz(1:nIntRxn,1);
        solution.q = NaN*ones(nRxn,1);
        solution.q(model.SConsistentRxnBool) = sol.xyz(nIntRxn+1:2*nIntRxn,1);
        solution.s = NaN*ones(nRxn,1);
        solution.s(model.SConsistentRxnBool) = sol.xyz(2*nIntRxn+1:3*nIntRxn,1);
        
        solution.v = zeros(nRxn,1);
        solution.v(model.SConsistentRxnBool)= sol.xyz(1:nIntRxn,1)-sol.xyz(nIntRxn+1:2*nIntRxn,1);
        solution.v(~model.SConsistentRxnBool)= sol.xyz(3*nIntRxn+1:3*nIntRxn+nExRxn,1);
        
        solution.stat = sol.stat;    
    case 'pqsr'
        N = model.S(:,model.SConsistentRxnBool);
        F = -min(0,model.S(:,model.SConsistentRxnBool));
        R =  max(0,model.S(:,model.SConsistentRxnBool));
        B = model.S(:,~model.SConsistentRxnBool);

        Omn=sparse(nMet,nIntRxn);
        Onm=sparse(nIntRxn,nMet);
        Om =sparse(nMet,nMet);
        Onk=sparse(nIntRxn,nExRxn);
        Omk=sparse(nMet,nExRxn);
        On=sparse(nIntRxn,nIntRxn);
        In=speye(nIntRxn,nIntRxn);
        Im=speye(nMet,nMet);
        
        cardProb.A = [...
           % p     q      s     w     r
             N,   -N,   Omn,    B,   Om;
            In,   In,   -In,  Onk,  Onm;
            In,  -In,    On,  Onk,  Onm;
            In,  -In,    On,  Onk,  Onm;
             F,    R,   Omn,  Omk,  -Im];

        %lower bounds on the rate of production by internal reactions
        if ~isfield(model,'lbr')
            lbr = zeros(nMet,1);
            lbr(model.presentMet)=param.epsilon*1.1; %production of metabolite that must be present
        else
            lbr=model.lbr;
        end
        
        reversibleRxnBool = model.lb<-param.epsilon & model.ub>param.epsilon;
        fwdRxnBool = model.lb==0 & model.ub>param.epsilon;
        revRxnBool = model.lb<-param.epsilon & model.ub==0;
        allRxnBool = reversibleRxnBool | fwdRxnBool | revRxnBool;
        if ~any(allRxnBool)
            error('misspecified directionality')
        end
        
        %active reversible reactions
        boolActiveReversible = reversibleRxnBool & model.activeRxn & model.SConsistentRxnBool;
        lbz = zeros(nRxn,1);
        if any(boolActiveReversible)
            lbz(boolActiveReversible)=param.epsilon*2;%encourages nonzero p + q
        end
        lbz=lbz(model.SConsistentRxnBool);
            
        %forward
        bl = model.lb;
        %active forward reactions
        boolFwd = fwdRxnBool & model.activeRxn & model.SConsistentRxnBool;
        if any(boolFwd)
            %force some forward flux
            bl(boolFwd)=param.epsilon;
        end
        %inactive reaction
        bl(model.inactiveRxn)=0;
        bl = bl(model.SConsistentRxnBool);
        
        %reverse
        bu = model.ub;
        %active reverse reactions
        boolRev = revRxnBool & model.activeRxn & model.SConsistentRxnBool;
        if any(boolRev)
            %force some reverse flux
            bu(boolRev)=-param.epsilon;
        end
        %inactive reaction
        bu(model.inactiveRxn)=0;
        bu = bu(model.SConsistentRxnBool);
        
        cardProb.b = [model.b;zeros(nIntRxn,1);bl;bu;zeros(nMet,1)];
        cardProb.csense(1:nMet+nIntRxn,1) = 'E';
        cardProb.csense(nMet+nIntRxn+1:nMet+2*nIntRxn,1)='G';
        cardProb.csense(nMet+2*nIntRxn+1:nMet+3*nIntRxn,1)='L';
        cardProb.csense(nMet+3*nIntRxn+1:2*nMet+3*nIntRxn,1)='E';
        
        cardProb.lb = [zeros(2*nIntRxn,1);lbz;model.lb(~model.SConsistentRxnBool);lbr];
        
        ubz = param.bigNum*ones(nRxn,1);
        %inactive reaction
        %ubz(model.inactiveRxn)=0;%solver should recognise fixed variable
        ubz = ubz(model.SConsistentRxnBool);
        
        ubp = param.bigNum*ones(nRxn,1);
        %inactive reaction
        %ubp(model.inactiveRxn)=0; %no flux of reactions that must be inactive
        ubp = ubp(model.SConsistentRxnBool);
        ubq = param.bigNum*ones(nRxn,1);
        %inactive reaction
        %ubq(model.inactiveRxn)=0; %no flux of reactions that must be inactive
        ubq = ubq(model.SConsistentRxnBool);
        
        %upper bound on rate of production
        ubr = param.bigNum*ones(nMet,1);
        ubr(model.absentMet)=0;
        
        cardProb.ub = [ubp;ubq;ubz;model.ub(~model.SConsistentRxnBool);ubr];
        
        cardProb.c = [...
            model.beta*ones(nIntRxn,1) + osense*model.c(model.SConsistentRxnBool);...
            model.beta*ones(nIntRxn,1) - osense*model.c(model.SConsistentRxnBool);...
            zeros(nIntRxn,1);...
            osense*model.c(~model.SConsistentRxnBool);...
            zeros(nMet,1)];
        
        cardProb.osense = 1; %minimise by default
               
        wSign = [zeros(2*nIntRxn,1);sign(model.g0(model.SConsistentRxnBool));sign(model.g0(~model.SConsistentRxnBool));sign(model.h0)];
        w     = [zeros(2*nIntRxn,1);     model.g0(model.SConsistentRxnBool) ;     model.g0(~model.SConsistentRxnBool) ;     model.h0 ];
        
        cardProb.p = wSign ==   1;%minimisation
        cardProb.q = wSign ==  -1;%maximisation
        cardProb.r = wSign ==   0;
        
        bool = cardProb.p | cardProb.q  | cardProb.r;
        if ~all(bool)
            error('cardProb.p | cardProb.q  | cardProb.r must be all true')
        end
        
        cardProb.k = zeros(3*nIntRxn+nExRxn+nMet,1);
        cardProb.k(cardProb.p,1) =  w(cardProb.p);
        cardProb.d = zeros(3*nIntRxn+nExRxn+nMet,1);
        cardProb.d(cardProb.q,1) = -w(cardProb.q);
        
        if any(cardProb.lb>cardProb.ub)
            error('cardProb.lb>cardProb.ub')
        end
        sol = optimizeCardinality(cardProb, param);
        
        % OUTPUT:
        %    solution:    Structure containing the following fields:
        %
        %                   * .x - `p x 1` solution vector
        %                   * .y - `q x 1` solution vector
        %                   * .z - `r x 1` solution vector
        %                   * .stat - status
        %
        %                     * 1 =  Solution found
        %                     * 2 =  Unbounded
        %                     * 0 =  Infeasible
        %                     * -1=  Invalid input
        solution.stat = sol.stat;
        
        if solution.stat==1
            %zeroing out small magnitudes below feasTol
            sol.xyz(abs(sol.xyz)<feasTol)=0;
            
            solution.f = NaN*ones(nRxn,1);
            solution.f(model.SConsistentRxnBool) = sol.xyz(1:nIntRxn,1);
            solution.r = NaN*ones(nRxn,1);
            solution.r(model.SConsistentRxnBool) = sol.xyz(nIntRxn+1:2*nIntRxn,1);
            solution.s = NaN*ones(nRxn,1);
            solution.s(model.SConsistentRxnBool) = sol.xyz(2*nIntRxn+1:3*nIntRxn,1);
            solution.v = zeros(nRxn,1);
            solution.v(model.SConsistentRxnBool)  = sol.xyz(1:nIntRxn,1) - sol.xyz(nIntRxn+1:2*nIntRxn,1);
            solution.v(~model.SConsistentRxnBool) = sol.xyz(3*nIntRxn+1:3*nIntRxn+nExRxn,1);
            solution.d = sol.xyz(3*nIntRxn+nExRxn+1:3*nIntRxn+nExRxn+nMet,1);
        else
            sol
            error('optimizeCardinality did not solve')
        end
    case 'pqzwr'
        N = model.S(:,model.SConsistentRxnBool);
        F = -min(0,model.S(:,model.SConsistentRxnBool));
        R =  max(0,model.S(:,model.SConsistentRxnBool));
        B = model.S(:,~model.SConsistentRxnBool);
        
        Omn=sparse(nMet,nIntRxn);
        Onm=sparse(nIntRxn,nMet);
        Om =sparse(nMet,nMet);
        Onk=sparse(nIntRxn,nExRxn);
        Omk=sparse(nMet,nExRxn);
        On=sparse(nIntRxn,nIntRxn);
        In=speye(nIntRxn,nIntRxn);
        Im=speye(nMet,nMet);
        
        if param.rpos
            cardProb.A = [...
                % p        q      z     w     r
                Omn,      Omn,     N,    B,   Om;
                In,       -In,   -In,  Onk,  Onm;
                (F+R),  (F+R),   Omn,  Omk,  -Im];
            
            %zero lower bound on sum of rate of consumption + production
            lbr = zeros(nMet,1);
            %upper bound on sum of rate of consumption + production
            ubr = param.bigNum*ones(nMet,1);
            ubr(model.absentMet)=0;
        else
            cardProb.A = [...
                % p     q     z     w     r
                Omn,   Omn,   N,    B,   Om;
                In,  -In,   -In,  Onk,  Onm;
                Omn, Omn, (F+R),  Omk,  -Im];
            
            %lower bound on consumption/production approximation
            lbr = -param.bigNum*ones(nMet,1);
            lbr(model.absentMet)=0;
            %upper bound on sum of rate of consumption + production
            ubr = param.bigNum*ones(nMet,1);
            ubr(model.absentMet)=0;
        end
        
        cardProb.b = [model.b;zeros(nIntRxn,1);zeros(nMet,1)];
        cardProb.csense(1:2*nMet+nIntRxn,1) = 'E';
        
        reversibleRxnBool = model.lb<-param.epsilon & model.ub>param.epsilon;
        fwdRxnBool = model.lb==0 & model.ub>param.epsilon;
        revRxnBool = model.lb<-param.epsilon & model.ub==0;
        allRxnBool = reversibleRxnBool | fwdRxnBool | revRxnBool;
        if ~any(allRxnBool)
            error('misspecified directionality')
        end
        
        %lower bounds on net flux
        lb = model.lb;
        lb(model.inactiveRxn)=0; %no flux of reactions that must be inactive
        lbz = lb(model.SConsistentRxnBool);
        lbw = lb(~model.SConsistentRxnBool);
        
        cardProb.lb = [zeros(2*nIntRxn,1);lbz;lbw;lbr];
        
        %upper bounds
        ubp = param.bigNum*ones(nnz(model.SConsistentRxnBool),1);
        ubq = param.bigNum*ones(nnz(model.SConsistentRxnBool),1);
        
        %upper bounds on net flux
        ub = model.ub;
        ub(model.inactiveRxn)=0; %no flux of reactions that must be inactive
        ubz = ub(model.SConsistentRxnBool);
        ubw = ub(~model.SConsistentRxnBool);
        
        cardProb.ub = [ubp;ubq;ubz;ubw;ubr];
        
        cardProb.c = [...
            model.beta*ones(nIntRxn,1);...
            model.beta*ones(nIntRxn,1);...
            osense*model.c(model.SConsistentRxnBool);...
            osense*model.c(~model.SConsistentRxnBool);...
            zeros(nMet,1)];
        
        cardProb.osense = 1; %minimise by default
        
        wSign = [zeros(2*nIntRxn,1);sign(model.g0(model.SConsistentRxnBool));sign(model.g0(~model.SConsistentRxnBool));sign(model.h0)];
        w     = [zeros(2*nIntRxn,1);     model.g0(model.SConsistentRxnBool) ;     model.g0(~model.SConsistentRxnBool) ;     model.h0 ];
        
        cardProb.p = wSign ==   1;%minimisation
        cardProb.q = wSign ==  -1;%maximisation
        cardProb.r = wSign ==   0;
        
        bool = cardProb.p | cardProb.q  | cardProb.r;
        if ~all(bool)
            error('cardProb.p | cardProb.q  | cardProb.r must be all true')
        end
        
        cardProb.k = zeros(3*nIntRxn+nExRxn+nMet,1);
        cardProb.k(cardProb.p,1) =  w(cardProb.p);
        cardProb.d = zeros(3*nIntRxn+nExRxn+nMet,1);
        cardProb.d(cardProb.q,1) = -w(cardProb.q);
        
        if 1
            %no one-norm regularisation of (net) production/consumption
            %problem.o `size(A,2) x 1` strictly positive weight vector on minimise `||[x;y;z]||_1`
            cardProb.o = [zeros(2*nIntRxn,1);model.g0(model.SConsistentRxnBool)~=0;model.g0(~model.SConsistentRxnBool)~=0;zeros(nMet,1)];
        end
        
        if any(cardProb.lb>cardProb.ub)
            error('cardProb.lb>cardProb.ub')
        end
        sol = optimizeCardinality(cardProb, param);
        
        solution.stat = sol.stat;
        
        if solution.stat==1
            %zeroing out small magnitudes below feasTol
            sol.xyz(abs(sol.xyz)<feasTol)=0;
            
            solution.p = NaN*ones(nRxn,1);
            solution.p(model.SConsistentRxnBool) = sol.xyz(1:nIntRxn,1);
            solution.q = NaN*ones(nRxn,1);
            solution.q(model.SConsistentRxnBool) = sol.xyz(nIntRxn+1:2*nIntRxn,1);
            solution.v = NaN*ones(nRxn,1);
            solution.v(model.SConsistentRxnBool)  = sol.xyz(2*nIntRxn+1:3*nIntRxn,1);
            solution.v(~model.SConsistentRxnBool) = sol.xyz(3*nIntRxn+1:3*nIntRxn+nExRxn,1);
            solution.v(abs(solution.v)<feasTol) = 0;
            solution.r = sol.xyz(3*nIntRxn+nExRxn+1:3*nIntRxn+nExRxn+nMet,1);
        else
            sol
            error('optimizeCardinality did not solve')
        end
       case 'pqzw'
        N = model.S(model.SConsistentMetBool,model.SConsistentRxnBool);
        F = -min(0,model.S(model.SConsistentMetBool,model.SConsistentRxnBool));
        R =  max(0,model.S(model.SConsistentMetBool,model.SConsistentRxnBool));
        B = model.S(model.SConsistentMetBool,~model.SConsistentRxnBool);
      
        m = nnz(model.SConsistentMetBool);
        Omn=sparse(m,nIntRxn);
        Onk=sparse(nIntRxn,nExRxn);
        In=speye(nIntRxn,nIntRxn);
        
        if isfield(model,'C')
            %coupling constraints
            C = model.C(:,model.SConsistentRxnBool);
            nConstr = size(model.C,1);
            Ocn = sparse(nConstr,nIntRxn);
            D = model.C(:,~model.SConsistentRxnBool);
        else
            nConstr = 0;
            C   = sparse(nConstr,nIntRxn);
            Ocn = sparse(nConstr,nIntRxn);
            D   = sparse(nConstr,nExRxn);
        end
        
        if isfield(model,'dummyMetBool')
            % dummyModel.dummyMetBool:  m x 1 boolean vector indicating dummy metabolites i.e. contains(model.mets,'dummy_Met_');
            % dummyModel.dummyRxnBool:  n x 1 boolean vector indicating dummy reactions  i.e. contains(model.rxns,'dummy_Rxn_');
            g = nnz(model.dummyMetBool); %number of dummy metabolites
            G = model.S(model.dummyMetBool, model.SConsistentRxnBool);
            H = model.S(model.dummyMetBool,~model.SConsistentRxnBool);
        else
            g = 0; %number of dummy metabolites
            G = sparse(0,nIntRxn);
            H = sparse(0,nExRxn);
        end
        Ogn = sparse(g,nIntRxn);
        
        cardProb.A = [...
            % p         q     z     w
            Omn,     Omn,     N,    B;
            In,      -In,   -In,  Onk;
            Ocn,     Ocn,     C,    D;
            Ogn,     Ogn,     G,    H];

        cardProb.b = [model.b(model.SConsistentMetBool);zeros(nIntRxn,1)];
        cardProb.csense(1:m,1) = model.csense(model.SConsistentMetBool);
        cardProb.csense(m+1:m+nIntRxn,1) = 'E';
        
        if isfield(model,'C')
            cardProb.b = [cardProb.b;model.d];
            cardProb.csense = [cardProb.csense;model.dsense];
        end

        if isfield(model,'dummyMetBool')
            cardProb.b =  [cardProb.b;model.b(model.dummyMetBool)];
            cardProb.csense = [cardProb.csense; model.csense(model.dummyMetBool)];
        end

        reversibleRxnBool = model.lb<-param.epsilon & model.ub>param.epsilon;
        fwdRxnBool = model.lb==0 & model.ub>param.epsilon;
        revRxnBool = model.lb<-param.epsilon & model.ub==0;
        allRxnBool = reversibleRxnBool | fwdRxnBool | revRxnBool;
        if ~any(allRxnBool)
            error('misspecified directionality')
        end

        %lower bounds on net flux
        lbz = model.lb(model.SConsistentRxnBool);
        lbw = model.lb(~model.SConsistentRxnBool);
        
        cardProb.lb = [zeros(2*nIntRxn,1);lbz;lbw];
        
        %upper bounds
        ubp = param.bigNum*ones(nIntRxn,1);
        ubq = param.bigNum*ones(nIntRxn,1);

        %upper bounds on net flux
        ubz = model.ub(model.SConsistentRxnBool);
        ubw = model.ub(~model.SConsistentRxnBool);

        cardProb.ub = [ubp;ubq;ubz;ubw];
        
        cardProb.c = [...
            model.beta*ones(nIntRxn,1);...
            model.beta*ones(nIntRxn,1);...
            osense*model.c(model.SConsistentRxnBool);...
            osense*model.c(~model.SConsistentRxnBool)];
        
        cardProb.osense = 1;%minimise by default
                
        wSign = [zeros(2*nIntRxn,1);sign(model.g0(model.SConsistentRxnBool));sign(model.g0(~model.SConsistentRxnBool))];
        w     = [zeros(2*nIntRxn,1);     model.g0(model.SConsistentRxnBool) ;     model.g0(~model.SConsistentRxnBool) ];
        
        cardProb.p = wSign ==   1;%minimisation
        cardProb.q = wSign ==  -1;%maximisation
        cardProb.r = wSign ==   0;
        
        bool = cardProb.p | cardProb.q  | cardProb.r;
        if ~all(bool)
            error('cardProb.p | cardProb.q  | cardProb.r must be all true')
        end
        
        cardProb.k = zeros(3*nIntRxn+nExRxn,1);
        cardProb.k(cardProb.p,1) =  w(cardProb.p);
        cardProb.d = zeros(3*nIntRxn+nExRxn,1);
        cardProb.d(cardProb.q,1) = -w(cardProb.q);

        cardProb.o = [zeros(2*nIntRxn,1);model.g0(model.SConsistentRxnBool)~=0;model.g0(~model.SConsistentRxnBool)~=0];
        
        if any(cardProb.lb>cardProb.ub)
            error('cardProb.lb>cardProb.ub')
        end
        sol = optimizeCardinality(cardProb, param);
        
        solution.stat = sol.stat;
        
        if solution.stat==1
            solution.p = NaN*ones(nRxn,1);
            solution.p(model.SConsistentRxnBool) = sol.xyz(1:nIntRxn,1);
            solution.q = NaN*ones(nRxn,1);
            solution.q(model.SConsistentRxnBool) = sol.xyz(nIntRxn+1:2*nIntRxn,1);
            solution.v = NaN*ones(nRxn,1);
            solution.v(model.SConsistentRxnBool)  = sol.xyz(2*nIntRxn+1:3*nIntRxn,1);
            solution.v(~model.SConsistentRxnBool) = sol.xyz(3*nIntRxn+1:3*nIntRxn+nExRxn,1);
            
            if 1
                solution0 = solution;
                
                %check if the solution is an accurate steady state
                bool = model.SConsistentMetBool & model.csense == 'E';
                res = norm(model.S(bool,:)*solution.v - model.b(bool),inf);
                if res>feasTol
                    disp(res)
                    error('optimizeCardinality solution is not a steady state')
                end
                
                %zero out small values in the solution here
                solution.v(abs(solution.v)<(feasTol/100)) = 0;
                
                %check if the solution is an accurate steady state
                bool = model.SConsistentMetBool & model.csense == 'E';
                res = norm(model.S(bool,:)*solution.v - model.b(bool),inf);
                if res>feasTol
                    disp(res)
                    error('optimizeCardinality solution is not a steady state after zeroing out small net fluxes with absolute magnitude less than feasTol/100.')
                end
                
                %zero out small values in the solution here
                solution.p(abs(solution.p)<(feasTol/100)) = 0;
                solution.q(abs(solution.q)<(feasTol/100)) = 0;
                
                %check if the solution is an accurate steady state
                bool = model.SConsistentMetBool & model.csense == 'E';
                res = norm(model.S(bool,:)*(solution.p - solution.q) - model.b(bool),inf);
                if res>feasTol
                    disp(res)
                    error('optimizeCardinality solution is not a steady state after zeroing out small fluxes with absolute magnitude less than feasTol/100.')
                end
            end

        else
            sol
            norm(model.S(model.SConsistentMetBool,:)*solution.v - model.b(model.SConsistentMetBool),inf)
            norm(cardProb.A*sol.xyz - cardProb.b,inf)
            error('optimizeCardinality did not solve')
        end    
    case 'pqzwrs'
        N = model.S(model.SConsistentMetBool,model.SConsistentRxnBool);
        F = -min(0,model.S(model.SConsistentMetBool,model.SConsistentRxnBool));
        R =  max(0,model.S(model.SConsistentMetBool,model.SConsistentRxnBool));
        B = model.S(model.SConsistentMetBool,~model.SConsistentRxnBool);
      
        m = nnz(model.SConsistentMetBool);
        Omn=sparse(m,nIntRxn);
        Onm=sparse(nIntRxn,m);
        Om =sparse(m,m);
        Onk=sparse(nIntRxn,nExRxn);
        Omk=sparse(m,nExRxn);
        In=speye(nIntRxn,nIntRxn);
        Im=speye(m,m);
       
        %debugging
        %model = rmfield(model,'dummyMetBool');
        %model = rmfield(model,'C');

        if isfield(model,'dummyMetBool')
            % dummyModel.dummyMetBool:  m x 1 boolean vector indicating dummy metabolites i.e. contains(model.mets,'dummy_Met_');
            % dummyModel.dummyRxnBool:  n x 1 boolean vector indicating dummy reactions  i.e. contains(model.rxns,'dummy_Rxn_');
            g = nnz(model.dummyMetBool); %number of dummy metabolites
            G = model.S(model.dummyMetBool, model.SConsistentRxnBool);
            H = model.S(model.dummyMetBool,~model.SConsistentRxnBool);
        else
            g = 0; %number of dummy metabolites
            G = sparse(0,nIntRxn);
            H = sparse(0,nExRxn);
        end
        Ogn = sparse(g,nIntRxn);
        Ogm = sparse(g,m);
            
        if isfield(model,'C')
            %coupling constraints
            C = model.C(:,model.SConsistentRxnBool);
            nConstr = size(model.C,1);
            Ocn = sparse(nConstr,nIntRxn);
            Ocm = sparse(nConstr,m);
            D = model.C(:,~model.SConsistentRxnBool);
        else
            nConstr = 0;
            C   = sparse(nConstr,nIntRxn);
            Ocn = sparse(nConstr,nIntRxn);
            Ocm = sparse(nConstr,m);
            D   = sparse(nConstr,nExRxn);
        end
        
        if param.rpos
            cardProb.A = [...
                % p       q      z     w     r    s
                Omn,     Omn,     N,    B,   Om,  Om;
                In,      -In,   -In,  Onk,  Onm, Onm;
                F,         R,   Omn,  Omk,  -Im,  Om; % sum of consumption plus production is positive
                (F+R), (F+R),   Omn,  Omk,   Om, -Im; 
                Ocn,     Ocn,     C,    D,  Ocm, Ocm;
                Ogn,     Ogn,     G,    H,  Ogm, Ogm];
            
        else
            cardProb.A = [...
                % p         q     z     w     r    s
                Omn,     Omn,     N,    B,   Om,  Om;
                In,      -In,   -In,  Onk,  Onm, Onm;
                Omn,     Omn, (F+R),  Omk,  -Im,  Om;% approximation to net consumption plus production is not restricted in sign
%                 F,       R,    Omn,  Omk,  -Im,  Om;
                (F+R), (F+R),   Omn,  Omk,   Om, -Im;
                Ocn,     Ocn,     C,    D,  Ocm, Ocm;
                Ogn,     Ogn,     G,    H,  Ogm, Ogm];
        end
        
        cardProb.b = [model.b(model.SConsistentMetBool);zeros(nIntRxn,1);zeros(2*m,1)];
        cardProb.csense(1:m,1) = model.csense(model.SConsistentMetBool);
        cardProb.csense(m+1:3*m+nIntRxn,1) = 'E';
        
        if isfield(model,'C')
            cardProb.b = [cardProb.b;model.d];
            cardProb.csense = [cardProb.csense;model.dsense];
        end
        
        if isfield(model,'dummyMetBool')
            cardProb.b =  [cardProb.b;model.b(model.dummyMetBool)];
            %(3*m+nIntRxn+nConstr+1:3*m+nIntRxn+nConstr+g,1)
            cardProb.csense = [cardProb.csense; model.csense(model.dummyMetBool)];
        end
                          
        reversibleRxnBool = model.lb<-param.epsilon & model.ub>param.epsilon;
        fwdRxnBool = model.lb==0 & model.ub>param.epsilon;
        revRxnBool = model.lb<-param.epsilon & model.ub==0;
        allRxnBool = reversibleRxnBool | fwdRxnBool | revRxnBool;
        if ~any(allRxnBool)
            error('misspecified directionality')
        end
        
        %lower bounds on net flux
        lb = model.lb;
        lb(model.inactiveRxn)=0; %no flux of reactions that must be inactive
        lbz = lb(model.SConsistentRxnBool);
        lbw = lb(~model.SConsistentRxnBool);
        
        %lower bound on consumption/production approximation
        if param.rpos
            lbr = zeros(m,1); 
        else
            lbr = -param.bigNum*ones(m,1); 
        end
        
        cardProb.lb = [zeros(2*nIntRxn,1);lbz; lbw; lbr; zeros(m,1)];
        
        %upper bounds
        ubp = param.bigNum*ones(nnz(model.SConsistentRxnBool),1);
        ubq = param.bigNum*ones(nnz(model.SConsistentRxnBool),1);

        %upper bounds on net flux
        ub = model.ub;
        ub(model.inactiveRxn)=0; %no flux of reactions that must be inactive
        ubz = ub(model.SConsistentRxnBool);
        ubw = ub(~model.SConsistentRxnBool);
        
        %upper bound on consumption/production approximation
        ubr = param.bigNum*ones(m,1);
        
        %upper bound on sum of rate of consumption + production
        ubs = param.bigNum*ones(m,1);
        ubs(model.absentMet)=0;
        
        cardProb.ub = [ubp;ubq;ubz;ubw;ubr;ubs];
        
        cardProb.c = [...
            zeros(nIntRxn,1);...%one norm weights implemented below
            zeros(nIntRxn,1);...%one norm weights implemented below
            osense*model.c( model.SConsistentRxnBool);...
            osense*model.c(~model.SConsistentRxnBool);...
            zeros(2*m,1)];
        
        cardProb.osense = 1;%minimise by default
        
        %maximisation of cardinality via net rate of consumption + production
        if any(model.h0(~model.SConsistentMetBool)~=0)
            error('No optimisation of cardinality of dummy metabolites')
        end
        h0neg  = model.h0(model.SConsistentMetBool);
        h0neg(h0neg>0) = 0;
        
        %minimisation of cardinality via sum of rate of consumption + production
        h0pos  = model.h0(model.SConsistentMetBool);
        h0pos(h0pos<0) = 0;
        
        if 1
            %                       p,q                                        z                                          w            r           s
            wSign = [zeros(2*nIntRxn,1);sign(model.g0(model.SConsistentRxnBool));sign(model.g0(~model.SConsistentRxnBool)); sign(h0neg); sign(h0pos)];
            w     = [zeros(2*nIntRxn,1);     model.g0(model.SConsistentRxnBool) ;     model.g0(~model.SConsistentRxnBool) ;       h0neg;      h0pos];
        else
            %                       p,q                                        z                                          w            r                                        s
            wSign = [zeros(2*nIntRxn,1);sign(model.g0(model.SConsistentRxnBool));sign(model.g0(~model.SConsistentRxnBool)); sign(h0neg); sign(model.h0(model.SConsistentMetBool))];
            w     = [zeros(2*nIntRxn,1);     model.g0(model.SConsistentRxnBool) ;     model.g0(~model.SConsistentRxnBool) ;       h0neg;      model.h0(model.SConsistentMetBool)];
        end
        
        cardProb.p = wSign ==   1;%minimisation
        cardProb.q = wSign ==  -1;%maximisation
        cardProb.r = wSign ==   0;
        
        bool = cardProb.p | cardProb.q  | cardProb.r;
        if ~all(bool)
            error('cardProb.p | cardProb.q  | cardProb.r must be all true')
        end
        
        cardProb.k = zeros(3*nIntRxn+nExRxn+2*m,1);
        cardProb.k(cardProb.p,1) =  w(cardProb.p);
        cardProb.d = zeros(3*nIntRxn+nExRxn+2*m,1);
        cardProb.d(cardProb.q,1) = -w(cardProb.q);
        
        %one norm weight on individual variables
        %no one-norm regularisation of net rate of consumption + production, or sum of rate of consumption + production
        oneNormWeight = [...
            model.beta*model.g1(model.SConsistentRxnBool);... % p
            model.beta*model.g1(model.SConsistentRxnBool);... % q
            zeros(nIntRxn,1);...                   % z  
            zeros(nExRxn,1);...                    % w
            zeros(m,1);...                         % r no one-norm regularisation of sum of rate of consumption + production
            zeros(m,1)];                           % s no one-norm regularisation of net rate of consumption + production
        
        %problem.o `size(A,2) x 1` strictly positive weight vector on minimise `||[x;y;z]||_1`
        cardProb.o = zeros(3*nIntRxn+nExRxn+2*m,1);
        cardProb.o(cardProb.p,1) =  oneNormWeight(cardProb.p);
        cardProb.o(cardProb.q,1) =  oneNormWeight(cardProb.q);
        cardProb.o(cardProb.r,1) =  oneNormWeight(cardProb.r);
        
        if any(cardProb.lb>cardProb.ub)
            error('cardProb.lb>cardProb.ub')
        end
        sol = optimizeCardinality(cardProb, param);
        
        solution.stat = sol.stat;
        
        %check if the solution is an accurate steady state
        bool = model.SConsistentMetBool & model.csense == 'E';
        v = NaN*ones(nRxn,1);
        v(model.SConsistentRxnBool)  = sol.xyz(2*nIntRxn+1:3*nIntRxn,1);
        v(~model.SConsistentRxnBool) = sol.xyz(3*nIntRxn+1:3*nIntRxn+nExRxn,1);
        res = norm(model.S(bool,:)*v - model.b(bool),inf);
        if res>feasTol
            disp(res)
            error('optimizeCardinality solution is not a steady state')
        end
                
        if solution.stat==1 || solution.stat==3
            %zeroing out small magnitudes below feasTol
            sol.xyz(abs(sol.xyz)<feasTol/10)=0;
            
            solution.p = NaN*ones(nRxn,1);
            solution.p(model.SConsistentRxnBool) = sol.xyz(1:nIntRxn,1);
            solution.q = NaN*ones(nRxn,1);
            solution.q(model.SConsistentRxnBool) = sol.xyz(nIntRxn+1:2*nIntRxn,1);
            solution.v = NaN*ones(nRxn,1);
            solution.v(model.SConsistentRxnBool)  = sol.xyz(2*nIntRxn+1:3*nIntRxn,1);
            solution.v(~model.SConsistentRxnBool) = sol.xyz(3*nIntRxn+1:3*nIntRxn+nExRxn,1);
            solution.v(abs(solution.v)<feasTol) = 0;
            solution.r = sol.xyz(3*nIntRxn+nExRxn+1:3*nIntRxn+nExRxn+m,1);
            solution.s = sol.xyz(3*nIntRxn+nExRxn+m+1:3*nIntRxn+nExRxn+2*m,1);
        else
            sol
            error('optimizeCardinality did not solve')
        end
 
end

cycleFreeFluxParam.debug=param.debug;
cycleFreeFluxParam.relaxBounds=param.relaxBounds;
cycleFreeFluxParam.acceptRepairedFlux=param.acceptRepairedFlux;
cycleFreeFluxParam.epsilon = param.epsilon;

if solution.stat==1
    if any(strcmp(param.thermoConsistencyMethod,{'cycleFreeFlux','signProduct','cardOpt','v2QNty'}))
               
        if strcmp(param.thermoConsistencyMethod,'cycleFreeFlux')
            
            %sometimes the cycle free flux test is infeasible
            try
                %calls cycleFreeFlux
                [thermoConsistentFluxBool,solutionConsistency] = checkThermoFeasibility(model,solution,param.thermoConsistencyMethod,cycleFreeFluxParam);
                
                %small non-zeros already eliminated above
                nonZeroFluxBool = abs(solution.v)>=0;
                
                %Fraction of thermodynamically feasible internal fluxes
                if param.printLevel>0
                    pcent = round(100*nnz(nonZeroFluxBool & thermoConsistentFluxBool & model.SConsistentRxnBool)/nnz(nonZeroFluxBool & model.SConsistentRxnBool),2);
                    fprintf('%3.2f%s\n',pcent,['% thermodynamically feasible nonzero internal fluxes (checked by ' param.thermoConsistencyMethod ' method).'])
                end
                
                if cycleFreeFluxParam.acceptRepairedFlux
                    % accept repaired flux
                    
                    % consistency of unreparied flux vector
                    solution.thermoConsistentUnrepairedFluxBool = thermoConsistentFluxBool;
                    
                    
                    if cycleFreeFluxParam.relaxBounds
                        %when forcing bounds are allowed to be relaxed, all internal fluxes will be thermodynamically consistent after cycle free flux
                        thermoConsistentFluxBool(model.SConsistentRxnBool) = 1;
                    else
                        %when forcing bounds are not allowed to be relaxed, only internal reactions without forcing bounds are sure to be thermodynamically consistent
                        thermoConsistentFluxBool(model.SConsistentRxnBool & ~forcedIntRxnBool) = 1;
                    end
                    
                    %save the unrepaired flux
                    solution.vUnrepaired = solution.v;
                    
                    %accept the repaired thermodynamically feasible flux
                    solution.v = solutionConsistency.vThermo;
                    solution.dvThermo = solutionConsistency.dvThermo;
                    %identify the fluxes that were non-zero then add 1 to forward and reverse
                    bool = solutionConsistency.vThermo~=0;
                    solution.p = max(0,solutionConsistency.vThermo);
                    solution.p(bool)=solution.p(bool)+1;
                    solution.p(~model.SConsistentRxnBool) = NaN;
                    solution.q = -min(0,solutionConsistency.vThermo);
                    solution.q(bool)=solution.q(bool)+1;
                    solution.q(~model.SConsistentRxnBool) = NaN;
                    
                    switch param.formulation
                        case 'pqs'
                            solution.s = solution.p + solution.q;
                        case 'pqzwrs'
                            %                             if ~exist('F','var')
                            %                                 F = -min(0,model.S(:,model.SConsistentRxnBool));
                            %                                 R =  max(0,model.S(:,model.SConsistentRxnBool));
                            %                             end
                            if param.rpos
                                solution.r = F*solution.p(model.SConsistentRxnBool) + R*solution.q(model.SConsistentRxnBool);
                            else
                                solution.r = (F+R)*solution.v(model.SConsistentRxnBool);  %pre summer 22
                                %solution.r = (F-R)*(solution.p(model.SConsistentRxnBool) - solution.q(model.SConsistentRxnBool));
                            end
                            solution.s = (F+R)*(solution.p(model.SConsistentRxnBool) + solution.q(model.SConsistentRxnBool));
                    end
                    
                    %update the set of nonzero fluxes
                    nonZeroFluxBool = abs(solution.v)>=param.epsilon;
                    
                    if param.relaxBounds
                        %identify non-zero fluxes outside the bounds due to bound relaxation
                        outsideBounds = solution.v~=0 & solution.v<model.lb | solution.v>model.ub;
                        if any(outsideBounds)
                            if param.printLevel>0
                                pcent = round(100*nnz(nonZeroFluxBool & outsideBounds & model.SConsistentRxnBool)/nnz(nonZeroFluxBool & model.SConsistentRxnBool),2);
                                fprintf('%3.2f%s\n',pcent,['% nonzero internal fluxes thermodynamically feasible only after bound relaxation by ' param.thermoConsistencyMethod ' method).'])
                            end
                            %eliminate if outside the bounds due to bound relaxation
                            thermoConsistentFluxBool(outsideBounds)=0;
                        end
                    end
                    
                    %Fraction of thermodynamically feasible internal fluxes
                    if param.printLevel>0
                        pcent = round(100*nnz(nonZeroFluxBool & thermoConsistentFluxBool & model.SConsistentRxnBool)/nnz(nonZeroFluxBool & model.SConsistentRxnBool),2);
                        fprintf('%3.2f%s\n',pcent,['% thermodynamically feasible internal fluxes (after repair by ' param.thermoConsistencyMethod ' method).'])
                    end
                else
                    solution.vThermo = solutionConsistency.vThermo;
                end
                %annotate the solution structure with the reaction fluxes that are thermodynamically consistent
                solution.thermoConsistentFluxBool = thermoConsistentFluxBool;
                
            catch ME
                if cycleFreeFluxParam.debug || 1
                    disp(ME.message)
                    rethrow(ME)
                end
                if 0
                    %v2QNTy never seems to work
                    warning('cycleFreeFlux did not solve, trying v2QNTy')
                    if changeTol
                        %change it back
                        changeOK = changeCobraSolverParams('LP', 'feasTol', feasTol);
                    end
                    
                    param.thermoConsistencyMethod='v2QNty';
                    [thermoConsistentFluxBool,solutionConsistency] = checkThermoFeasibility(model,solution,param.thermoConsistencyMethod);
                    
                    %Fraction of thermodynamically feasible internal fluxes
                    if param.printLevel>0
                        pcent = round(100*nnz(thermoConsistentFluxBool & model.SConsistentRxnBool)/nnz(model.SConsistentRxnBool),2);
                        fprintf('%3.2f%s\n',pcent,['% thermodynamically feasible internal fluxes (checked by ' param.thermoConsistencyMethod ' method).'])
                    end
                    %annotate the solution structure with the reaction fluxes that are thermodynamically consistent
                    solution.thermoConsistentFluxBool = thermoConsistentFluxBool;
                else
                    warning('cycleFreeFlux did not solve.')
                    solution.thermoConsistentFluxBool=[];
                end
            end
        else
            fprintf('%s\n','Internal fluxes not double checked for thermodynamic consistency.')
        end
    end
end

