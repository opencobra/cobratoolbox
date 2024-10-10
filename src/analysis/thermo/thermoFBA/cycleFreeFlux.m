function [Vthermo,thermoConsistentFluxBool] = cycleFreeFlux(V0, C, model, SConsistentRxnBool, param)
% Removes stoichiometrically balanced cycles from FBA solutions when
% possible.
%
% A Matlab implementation of the CycleFreeFlux algorithm from Desouki et
% al., 2015. Minimises the one norm of fluxes subject to bounds determined
% by input flux.
%
% USAGE:
%
%    Vthermo = cycleFreeFlux(V0, C, model, SConsistentRxnBool, relaxBounds);
%
% INPUTS:
%  V0:       `n x k` matrix of `k` FBA solutions
%  C:        `n x k` matrix of `k` FBA objectives
%  model:    COBRA model structure with required fields:
%                * .S  - `m x n` stoichiometric matrix

%                * .lb - `n x 1` lower bound vector
%                * .ub - `n x 1` lower bound vector
%  model.SIntRxnBool:
%
% OPTIONAL INPUTS:
%  model.b:  - `m x 1` RHS vector (default 0's)   
%  model.csense: - 'm x 1' character vector of constraint sense (default 'E')
%  model.C:  - Coupling constraints         
%  model.d:  - RHS of coupling constraints         
%  model.dsense: - Coupling constraint sense
%  model.SConsistentMetBool: `m x 1` logical array, true for stoichioemtrically consistent metabolites
%  model.SConsistentRxnBool: `n x 1` logical array, true for stoichiometrically consistent reactions
%
%  param.printLevel:       print Level
%  param.eta               Minimum change in flux considered nonzero. Default feasTol*10
%  param.relaxBounds:      Relax bounds that don't include zero. Default is false.
%  param.parallelize:      Turn parfor use on or off. Default is true if k > 12.
%  param.enforceCoupling:  {(0),1} where 1 = enforce coupling constraint
%  param.approach:         {'lp',('regularised')} formulation of cycleFreeFlux problem.
%                          'lp' is a linear optimisation based formulation, which is prone to infeasibility due to numerical issues.
%                          'regularised' a quadratically regularised version, which is less sensitive to numerical issues but slower.
%  param.debug:            {(0),1} where 1 = extra debugging steps
%  param.removeFixedBool:  {(0),1} where 1 = moves variables with equal upper and lower bounds to rhs
%
% OUTPUT:
%  Vthermo:    `n x k` matrix of cycle free flux vectors
%  thermoConsistentFluxBool: `n x 1` logical array, true for thermodynamically consistent flux 
%
% EXAMPLE:
%    % Remove cycles from a single flux vector
%    solution = optimizeCbModel(model);
%    Vthermo = cycleFreeFlux(solution.v, model.c, model);
%
%    % Remove cycles from multiple flux vectors
%    [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, 0, 'max', model.rxns, 0, 1, 'FBA');
%    V0 = [Vmin, Vmax];
%    n = size(model.S, 2);
%    C = [eye(n), eye(n)];
%    Vthermo = cycleFreeFlux(V0, C, model);
%
% .. Author: - Hulda S. Haraldsdottir, 25/5/2018, Ronan M.T. Fleming 2019 - 2022, regularisation, debug, relaxation etc.

if ~exist('SConsistentRxnBool', 'var') || isempty(SConsistentRxnBool) % Set defaults
    if isfield(model,'SConsistentRxnBool')
        SConsistentRxnBool = model.SConsistentRxnBool;
        SConsistentMetBool = model.SConsistentMetBool;
    elseif isfield(model, 'SIntRxnBool')
        warning('Assuming SConsistentMetBool and SConsistentRxnBool heuristically. Better to use findStoichConsistentSubset')
        SConsistentRxnBool = model.SIntRxnBool;
        SConsistentMetBool = true(size(model.S,1),1);
    else
        tmp = model;
        tmp.c(:) = 0;

        if isfield(tmp, 'biomassRxnAbbr')
            tmp = rmfield(tmp, 'biomassRxnAbbr');
        end

        [SConsistentMetBool, SConsistentRxnBool] = findStoichConsistentSubset(tmp, 0, 0);

        clear tmp
    end
else
    SConsistentMetBool = getCorrespondingRows(model.S,true(size(model.S,1),1),SConsistentRxnBool,'inclusive');
end


if ~exist('param','var')
    param = struct();
end

if ~isfield(param,'relaxBounds')
    param.relaxBounds = false;
end

if ~isfield(param,'parallelize')
    param.parallelize = false;
end

if ~isfield(param,'enforceCoupling')
    param.enforceCoupling = false;
    %param.enforceCoupling = true; %TODO need to debug this further
end

if ~isfield(param,'approach')
    %param.approach = 'lp'; %faster
    param.approach = 'regularised';%slower but more robust
end

feasTol = getCobraSolverParams('LP', 'feasTol');
if ~isfield(param,'eta')
    param.eta = feasTol*10;
end

if ~isfield(param,'debug')
    param.debug = 0;
end

if isfield(param,'printLevel')
    printLevel=param.printLevel;
else
    printLevel = 0;
end

if ~isfield(model,'b')
    model.b=zeros(size(model.S,1),1);
end
if ~isfield(model,'csense')
    model.csense(1:size(model.S,1),1)='E';
end

[n,k] = size(V0);

if param.debug
    %check the bounds on the model
    if any(model.lb>model.ub)
        error('Model Lower bounds cannot be greater than upper bounds')
    end
    
    %double check to see if the model admits a steady state flux
    solution = optimizeCbModel(model);
    if solution.stat~=1
        error('Model does not admit a steady state flux')
    end
    
    %check if the bounds are ok.
    for i=1:k
        if k>1
            disp(i)
        end
        v0 = V0(:, i);
        
        %check if the solution provided is an accurate steady state
        bool = SConsistentMetBool & model.csense == 'E';
        res = norm(model.S(bool,:)*v0 - model.b(bool),inf);
        if res>feasTol
            disp(res)
            error('Solution provided is not a steady state')
        end
        
        bool_ub = v0 > model.ub;
        if any(bool_ub)
            bool_ub2 = v0 > model.ub + feasTol;
            if any(bool_ub2)
                model.rxns(bool_ub)
                error(['Input flux vector majorly violated upper bounds, in ' int2str(i) 'th flux vector'])
            else
                if printLevel>0
                    warning('Input flux vector minorly violated upper bounds, setting some input fluxes to ub.')
                end
                V0(bool_ub,i) = model.ub(bool_ub);
            end
        end
        bool_lb = model.lb > V0;
        if any(bool_ub)
            
            bool_lb2 = model.lb - feasTol > V0;
            if any(bool_lb2)
                model.rxns(bool_lb)
                error(['Input flux vector  solution majorly violated lower bounds, in ' int2str(i) 'th flux vector'])
            else
                if printLevel>0
                    warning('Input flux vector solution minorly violated lower bounds, setting some input fluxes to lb.')
                end
                V0(bool_lb,i) = model.lb(bool_lb);
            end
        end
        
    end
end

% Check for parallel computing toolbox
try
    gcp('nocreate');
    hasPCT = true;
catch
    hasPCT = false;
end

if param.parallelize
    if hasPCT && k > 12
        param.parallelize = true;
    else
        param.parallelize = false;
    end
end



% parameters
[model_S, model_b, model_csense, model_lb, model_ub] = deal(model.S(SConsistentMetBool,:), model.b(SConsistentMetBool), model.csense(SConsistentMetBool), model.lb, model.ub);

if isfield(model,'C') && param.enforceCoupling
    [model_C,model_d,model_dsense] = deal(model.C, model.d, model.dsense);
else
    model_C = [];
    model_d = [];
    model_dsense = [];
end
[~,osense] = getObjectiveSense(model);

%preallocate output
Vthermo = zeros(n,k);
thermoConsistentFluxBool = false(n,k);

param.printLevel=printLevel-1;

eta = param.eta;

% loop through input flux vectors
if param.parallelize
    error('param.parallelize = true not fully supported, set param.parallelize = false')
    environment = getEnvironment();
    parfor i = 1:k
        restoreEnvironment(environment,0);
        
        v0 = V0(:, i);
        c0 = C(:, i);
        
        try
            v1 = computeCycleFreeFluxVector(v0, c0, osense, model_S, model_b, model_csense, model_lb, model_ub, model_C, model_d, model_dsense, SConsistentRxnBool); % see subfunction below
            Vthermo(:, i) = v1;
            thermoConsistentFluxBool(:,i) = abs(v0 - v1) < eta;
        catch
            disp(ME.message)
            v2 = computeCycleFreeFluxVector(v0, c0, osense, model_S, model_b, model_csense, model_lb, model_ub, model_C, model_d, model_dsense, SConsistentRxnBool); % see subfunction below
            Vthermo(:, i) = v2;
            thermoConsistentFluxBool(:,i) = abs(v0 - v2) < eta;
            %fprintf('%s\n','computeCycleFreeFluxVector: infeasible problem without relaxation of positive lower bounds and negative upper bounds')
        end
    end
else
    for i = 1:k
        v0 = V0(:, i);
        c0 = C(:, i);
        
        try
            v1 = computeCycleFreeFluxVector(v0, c0, osense, model_S, model_b, model_csense, model_lb, model_ub, model_C, model_d, model_dsense, SConsistentRxnBool, param); % see subfunction below
            Vthermo(:, i) = v1;
            thermoConsistentFluxBool(:,i) = abs(v0 - v1) < eta;
            forcedFwdRxnBool = SConsistentRxnBool & model_lb > 0 & model_ub > 0 ;
            forcedRevRxnBool = SConsistentRxnBool & model_lb < 0 & model_ub < 0 ;
            if param.relaxBounds
                %if bounds can be relaxed, forced internal reaction assumed to be thermodynamically consistent if reparied flux in the same direction and greater as the forcing
                bool = forcedFwdRxnBool & thermoConsistentFluxBool & v1 < model_lb;
                if any(bool) && length(bool)<10
                    disp(bool)
                end
                thermoConsistentFluxBool(bool) = 0;
                bool = forcedRevRxnBool & thermoConsistentFluxBool & v1 > model_ub;
                if any(bool) && length(bool)<10
                    disp(bool)
                end
                thermoConsistentFluxBool(bool) = 0;
            else
                %if bounds cannot be relaxed, any forced internal reaction is assumed not to be thermodynamically consistent, unless the repaired flux is not on the forcing bound
                thermoConsistentFluxBool(forcedFwdRxnBool & abs(v1 - model_lb) < eta)=0;
                thermoConsistentFluxBool(forcedRevRxnBool & abs(v1 - model_ub) < eta)=0;
            end
        catch ME
            disp(ME.message)
            if 0
                rethrow(ME)
            end
            fprintf('%s\n','computeCycleFreeFlux: lp error, switching to regularised approach.')
            param.approach = 'regularised';
            %param.relaxBounds=1;
            v2 = computeCycleFreeFluxVector(v0, c0, osense, model_S, model_b, model_csense, model_lb, model_ub, model_C, model_d, model_dsense, SConsistentRxnBool, param); % see subfunction below
            if ~isempty(v2)
                Vthermo(:, i) = v2;
                thermoConsistentFluxBool(:,i) = abs(v0 - v2) < eta;
                
                %fprintf('%s\n','computeCycleFreeFluxVector: infeasible problem without relaxation of positive lower bounds and negative upper bounds')
                if ~param.relaxBounds
                    %if bounds cannot be relaxed, any forced internal reaction is assumed not to be thermodynamically consistent, unless the repaired flux is not on the forcing bound
                    forcedFwdRxnBool = SConsistentRxnBool & model_lb > 0 & model_ub > 0 & abs(v2 - model_lb) < eta;
                    forcedRevRxnBool = SConsistentRxnBool & model_lb < 0 & model_ub < 0 & abs(v2 - model_ub) < eta;
                    thermoConsistentFluxBool(forcedFwdRxnBool)=0;
                    thermoConsistentFluxBool(forcedRevRxnBool)=0;
                end
            else
                fprintf('%s\n','computeCycleFreeFlux: regularised approach failed, likely infeasible.')
                if 0
                    getReport(ME)
                end
            end
            
        end
    end
end

end

function v1 = computeCycleFreeFluxVector(v0, c0, osense, model_S, model_b, model_csense, model_lb, model_ub, model_C, model_d, model_dsense, SConsistentRxnBool, param)

if ~isfield(param,'removeFixedBool')
    %by default, do not remove fixed variables, let the solver deal with them
    param.removeFixedBool = 0;
end

if ~isfield(param,'approach')
    %by default, use the regularised approach, even though it is slower, it is less numerically sensitive
    param.approach = 'lp';
end
if ~isfield(param,'printLevel')
    param.printLevel=0;
end
if any(model_lb>model_ub)
    error('Model lower bounds cannot be greater than upper bounds')
end

feasTol = getCobraSolverParams('LP', 'feasTol');
if any(model_ub-model_lb<feasTol & model_ub~=model_lb)
    warning('cycleFreeFlux: Unperturbed lower and upper bounds closer than feasibility tolerance. May cause numerical issues.')
end

bool = abs(v0)<feasTol/100;
if any(bool)
    if param.printLevel>0
        disp(['cycleFreeFlux: Assuming flux in ' int2str(nnz(bool)) ' reactions that is less than feasibility tolerance/100 is zero, as otherwise it may cause numerical issues.'])
    end
end
        
v0(bool) = 0;

[m,n] = size(model_S);
p = sum(SConsistentRxnBool);

D = sparse(p, n);
D(:, SConsistentRxnBool) = speye(p);

clt1 = ~isempty(model_C)*1;
clt = size(model_C,1);

switch param.approach
    case 'regularised'
        % variables
        %       v            x
        % regularisation variables
        %      r, s, t, u
        if any(c0)
            A = [...
                %     v              x                r               s               t               u
                model_S    sparse(m, p)     speye(m, m)    sparse(m, p)    sparse(m, p)   sparse(m,clt); % Sv + r  = b (steady state)
                model_C   sparse(clt,p)  sparse(clt, m)  sparse(clt, p)  sparse(clt, p)  speye(clt,clt); % Cv + u <= d (coupling, if present)
                c0'        sparse(1, p)    sparse(1, m)    sparse(1, p)    sparse(1, p)   sparse(1,clt); % c0'v = c0'v0
                D             -speye(p)    sparse(p, m)     speye(p, p)    sparse(p, p)   sparse(p,clt); %   v - x + s <= 0
                -D            -speye(p)    sparse(p, m)    sparse(p, p)     speye(p, p)   sparse(p,clt)];% - v - x + t <= 0
            
            b = [model_b;  model_d; (1-feasTol)*c0'*v0; zeros(2*p, 1)];
            
            csense = repmat('E', size(A, 1), 1);
            csense(1:m) = model_csense;
            if ~isempty(model_dsense)
                csense(m+clt1:m+clt) = model_dsense;
            end
            
            %this approach is more numerically robust than forcing the new objective to equal the
            %previous objective
            if osense == 1
                csense(m+clt1+1) = 'L';
            else
                csense(m+clt1+1) = 'G';
            end
            
            csense(m+clt1+2:end) = 'L';
            
        else
            A = [...
                %     v              x                r               s               t               u
                model_S    sparse(m, p)      speye(m, m)    sparse(m, p)    sparse(m, p)  sparse(m,clt); % Sv + r  = b (steady state)
                model_C   sparse(clt,p)   sparse(clt, m)  sparse(clt, p)  sparse(clt, p) speye(clt,clt); % Cv + u <= d (coupling, if present)
                D             -speye(p)     sparse(p, m)     speye(p, p)    sparse(p, p)  sparse(p,clt); %   v - x + s <= 0
                -D            -speye(p)     sparse(p, m)    sparse(p, p)     speye(p, p) sparse(p,clt)]; % - v - x + t <= 0
            
            b = [model_b; model_d; zeros(2*p, 1)];
            
            csense = repmat('E', size(A, 1), 1);
            csense(1:m) = model_csense;
            if ~isempty(model_dsense)
                csense(m+clt1:m+clt) = model_dsense;
            end
            csense(m+clt1+1:end) = 'L';
        end
        
        isF = [SConsistentRxnBool & v0 > 0; false(3*p+m,1)]; % net forward internal flux
        isR = [SConsistentRxnBool & v0 < 0; false(3*p+m,1)]; % net reverse internal flux
        
        % lower and upper bounds - fixed exchange and zero fluxes
        if 1
            lb = [v0-feasTol; zeros(p, 1); zeros(m, 1); -inf*ones(2*p + clt,1)];
            ub = [v0+feasTol; inf*ones(p,1); inf*ones(m, 1); inf*ones(2*p + clt,1)];
        else
            maxUB = 100/feasTol;
            lb = [v0; zeros(p, 1); zeros(m, 1); -maxUB*ones(2*p + clt,1)];
            ub = [v0; maxUB*ones(p,1); maxUB*ones(m, 1); maxUB*ones(2*p + clt,1)];
        end
        if param.relaxBounds
            lb(isF) = 0; % internal reaction directionality same as in input flux
            ub(isR) = 0;
        else
            lb(isF) = max(0,model_lb(isF)); % Keep lower bound if it is > 0 (forced positive flux)
            ub(isR) = min(0,model_ub(isR)); % Keep upper bound if it is < 0 (forced negative flux)
        end
        
        % objective: minimize one-norm of auxilliary variable x
        c = [zeros(n, 1); 0.1*ones(p, 1); zeros(m+2*p+clt, 1)]; % variables: [v; x; r; s; t; u]
        % objective: minimise two-norm of regularisation variables: r, s, t, u
        F = spdiags([sparse(n+p,1);100*ones(m+2*p + clt,1)],0,n+3*p+m+clt,n+3*p+m+clt); % variables: [v; x; r; s; t; u]
        
        qp = struct('osense', 1, 'c', c, 'A', A, 'csense', csense, 'b', b, 'lb', lb, 'ub', ub,'F',F);
        
        solution = solveCobraQP(qp);
        
        if solution.stat==1 || solution.stat==3
            if solution.stat==3
                if param.printLevel>1
                    disp(['cycleFreeFlux, regularised: ' solution.origStatText])
                end
            end
            
            if param.debug && param.printLevel>1
                z0 = v0(SConsistentRxnBool);
                z = solution.full(1:n);
                z = z(SConsistentRxnBool);
                x = solution.full(n+1:n+p);
                r = solution.full(n+p+1:n+p+m);
                s = solution.full(n+p+m+1:n+2*p+m);
                t = solution.full(n+2*p+m+1:n+3*p+m);
                u = solution.full(n+3*p+m+clt1:n+3*p+m+clt);
                
                figure
                subplot(3,3,1)
                plot(z,z0,'.')
                title('z vs z0')
                xlabel('z')
                ylabel('z0')
                
                subplot(3,3,2)
                histogram(z0-z)
                title('z0 - z')
                
                subplot(3,3,3)
                histogram(z)
                title('z')
                
                subplot(3,3,4)
                bool=abs(s)>1e-6;
                plot(z0(bool),s(bool),'.')
                xlabel('z0')
                ylabel('s')
                
                subplot(3,3,5)
                histogram(x)
                title('x')
              
                subplot(3,3,6)
                bool=abs(t)>1e-6;
                plot(z0(bool),t(bool),'.')
                xlabel('z0')
                ylabel('t')
                
                subplot(3,3,7)
                if 0
                    histogram(r)
                    title('r')
                else
                    histogram(u)
                    title('u')
                end
                
                subplot(3,3,8)
                histogram(s)
                title('s')
                
                subplot(3,3,9)
                histogram(t)
                title('t')
            end
        else
            fprintf('%s','cycleFreeFlux: No quadratically regularised solution found. Relaxing LP version...');
            qp = rmfield(qp,'F');
            paramRelax.relaxedPrintLevel=1;
            [solutionRelaxed, relaxedqp] = relaxedFBA(qp,paramRelax);
            
        end
    case 'lp0'
        %numerical instability may arise due to small flux magnitudes, so deal with
        %that, in one way or another
        if 1
            %zeroing out very small fluxes seems to work reliably for recon3
            isSmall = abs(v0)<feasTol & v0~=0;
            if any(isSmall)
                if param.debug
                    fprintf('%s\n',['cycleFreeFlux: Flux magnitude in ' int2str(nnz(isSmall)) ' reactions is less than ' num2str(feasTol) ', so they are bound between [-' num2str(feasTol) ', ' num2str(feasTol) '].'])
                end
                v0(isSmall)=0;
            end
        else
            %relax bounds on non fixed variables
            if 1
                isSmall = model_ub-model_lb>feasTol & model_ub~=model_lb;
                model_lb(isSmall)=model_lb(isSmall)-epsilon/2;
                model_ub(isSmall)=model_ub(isSmall)+epsilon/2;
            else
                %adaption to deal with infeasibility due to numerical imprecision
                %https://cran.r-project.org/web/packages/sybilcycleFreeFlux/index.html
                model_lb = model_lb -epsilon/2;
                model_ub = model_ub + epsilon/2;
            end
        end
        
        if 0
            %adaption to deal with infeasibility due to numerical imprecision
            isSmall = model_ub-model_lb>feasTol & model_ub~=model_lb;
            model_lb(isSmall)=model_lb(isSmall)-feasTol/2;
            model_ub(isSmall)=model_ub(isSmall)+feasTol/2;
        end
        
        [m,n] = size(model_S);
        p = sum(SConsistentRxnBool);
        
        D = sparse(p, n);
        D(:, SConsistentRxnBool) = speye(p);
        
        
        isF = [SConsistentRxnBool & v0 > 0; false(p,1)]; % net forward flux
        isR = [SConsistentRxnBool & v0 < 0; false(p,1)]; % net reverse flux
        
        if param.debug
            %internal reactions in larger problem size structure
            isInternal = [SConsistentRxnBool; false(p,1)];
            isExternal = [~SConsistentRxnBool; false(p,1)];
            isAuxiliary = [false(size(model_S,2),1);true(p,1)];
        end
        
        % objective: minimize one-norm
        c = [zeros(n, 1); ones(p, 1)]; % variables: [v; x]
        
        % constraints

        if any(c0)
            A = [...
              %       v            x
                model_S   sparse(m, p); % Sv = b (steady state)
                c0'       sparse(1, p); % c0'v = c0'v0
                D        -speye(p)    ; %   v - x <= 0
                -D        -speye(p)   ]; % - v - x <= 0
            
            
            b = [model_b;  c0' * v0; zeros(2*p, 1)];
            
            csense = repmat('E', size(A, 1), 1);
            csense(1:m) = model_csense;
            csense(m+2:end) = 'L';
            
            %this approach is more numerically robust than forcing the new objective to equal the
            %previous objective
            if osense == 1
                csense(m+1) = 'L';
            else
                csense(m+1) = 'G';
            end
            
        else
            A = [...
                model_S   sparse(m, p); % Sv = b (steady state)
                D        -speye(p)    ; %   v - x <= 0
                -D        -speye(p)   ]; % - v - x <= 0
            
            b = [model_b; zeros(2*p, 1)];
            
            csense = repmat('E', size(A, 1), 1);
            csense(1:m) = model_csense;
            csense(m+1:end) = 'L';
        end
        
        % bounds % fixed exchange fluxes
        lb = [v0; zeros(p, 1)];
        ub = [v0; abs(v0(SConsistentRxnBool))+10]; %allow x to be slightly greater
        
        if param.debug
            bool =ub-lb<feasTol & ub~=lb;
            if any(bool)
                if param.debug>1
                    figure;
                    hist(ub(bool)-lb(bool))
                end
                title('Perturbed lower, and upper bounds closer than feasibility tolerance')
                fprintf('%s\n',['cycleFreeFlux: #1 Perturbed lower and upper bounds closer than ' num2str(feasTol) ', this may cause numerical issues.'])
            end
        end
        
        %this is useful on some models but on others is causing instability
        if 1
            % slightly relax bounds on exchange reactions with non-zero net flux
            % because fixing them can lead to infeasibility due to numerical issues
            isExF = [~SConsistentRxnBool & v0 > 0; false(p,1)]; % net forward flux
            isExR = [~SConsistentRxnBool & v0 < 0; false(p,1)]; % net reverse flux
            lb(isExF) = (1-feasTol)*v0(isExF);
            ub(isExF) = (1+feasTol)*v0(isExF);
            lb(isExR) = (1+feasTol)*v0(isExR);
            ub(isExR) = (1-feasTol)*v0(isExR);
        end
        
        if param.debug
            bool =ub-lb<feasTol & ub~=lb;
            if any(bool)
                if param.debug>1
                    figure;
                    hist(ub(bool)-lb(bool))
                    title('Perturbed lower, and upper bounds closer than feasibility tolerance')
                end
                fprintf('%s\n',['cycleFreeFlux: #2 Perturbed lower and upper bounds closer than ' num2str(feasTol) ', this may cause numerical issues.'])
            end
        end
        
        if param.relaxBounds
            lb(isF) = 0; % internal reaction directionality same as in input flux
        else
            lb(isF) = max(0,model_lb(isF)); % Keep lower bound if it is > 0 (forced positive flux)
        end
        
        if param.debug
            bool =ub-lb<feasTol & ub~=lb;
            if any(bool)
                if param.debug>1
                    figure;
                    hist(ub(bool)-lb(bool))
                    title('Perturbed lower, and upper bounds closer than feasibility tolerance')
                end
                fprintf('%s\n',['cycleFreeFlux: #3 Perturbed lower and upper bounds closer than ' num2str(feasTol) ', this may cause numerical issues.'])
            end
        end
        
        if param.relaxBounds
            ub(isR) = 0;
        else
            ub(isR) = min(0,model_ub(isR)); % Keep upper bound if it is < 0 (forced negative flux)
        end
        
        if param.debug
            if any(ub-lb<feasTol & ub~=lb)
                fprintf('%s\n','cycleFreeFlux: #4 Perturbed lower and perturbed upper bounds closer than feasibility tolerance, this could cause numerical issues.')
            end
        end
        
        %allow reactions with small flux to have small flux with a change in sign
        lb(isSmall) = -feasTol;
        ub(isSmall) =  feasTol;
        
        if any(lb(1:n)>ub(1:n))
            if norm(lb(lb(1:n)>ub(1:n))-ub(lb(1:n)>ub(1:n)),inf)<feasTol
                lb(lb(1:n)>ub(1:n))=ub(lb(1:n)>ub(1:n));
                if param.printLevel>0
                    fprintf('%s\n','cycleFreeFlux: #5 Lower bounds slightly greater than upper bounds, set to the same.')
                end
            else
                error('cycleFreeFlux: Lower bounds cannot be greater than upper bounds')
            end
        end
        
        if any(lb(n+1:n+p)>ub(n+1:n+p))
            error('cycleFreeFlux: Lower bounds cannot be greater than upper bounds')
        end
        
        
        if param.debug
            if any(ub-lb<feasTol & ub~=lb)
                fprintf('%s\n','cycleFreeFlux: Perturbed lower and upper bounds closer than feasibility tolerance, this could cause numerical issues.')
            end
        end
        
        if any(lb>ub)
            error('cycleFreeFlux: Lower bounds cannot be greater than upper bounds')
        end
        
        lp = struct('osense', 1, 'c', c, 'A', A, ...
            'csense', csense, 'b', b, 'lb', lb, 'ub', ub);
        
        if param.removeFixedBool
            % net zero flux
            isZero = SConsistentRxnBool & v0 == 0;
            %remove the fixed variables from the problem
            zeroBool = [isZero; false(p,1)];
            if 0
                fixedBool = lp.lb == lp.ub | zeroBool;
            else
                %assume the external reactions are also fixed
                fixedBool = lp.lb == lp.ub | zeroBool | [~SConsistentRxnBool;false(p,1)];
            end
        end
        
        if param.removeFixedBool==1
            lp.b = lp.b - lp.A(:,fixedBool)*lp.lb(fixedBool);
            lp.A = lp.A(:,~fixedBool);
            lp.lb = lp.lb(~fixedBool);
            lp.ub = lp.ub(~fixedBool);
            lp.c = lp.c(~fixedBool);
        end
        
        % solve LP
        solution = solveCobraLP(lp);
        
    case 'lp'
        %numerical instability may arise due to small flux magnitudes
        isSmall = abs(v0)<feasTol & v0~=0;
        if any(isSmall)
            if param.debug
                fprintf('%s\n',['cycleFreeFlux: Flux magnitude in ' int2str(nnz(isSmall)) ' reactions is between [' num2str(feasTol/100) ', ' num2str(feasTol) '] in magnitude.'])
            end
        end
        
        if 0
            %zeroing out very small fluxes seems to work reliably for recon3
            v0(isSmall)=0;
        end
        
        if 0
            %relax bounds on non fixed variables
            if 1
                isSmall = model_ub-model_lb>feasTol & model_ub~=model_lb;
                model_lb(isSmall)=model_lb(isSmall)-epsilon/2;
                model_ub(isSmall)=model_ub(isSmall)+epsilon/2;
            else
                %adaption to deal with infeasibility due to numerical imprecision
                %https://cran.r-project.org/web/packages/sybilcycleFreeFlux/index.html
                model_lb = model_lb -epsilon/2;
                model_ub = model_ub + epsilon/2;
            end
        end
        
        if 0
            %adaption to deal with infeasibility due to numerical imprecision
            isSmall = model_ub-model_lb>feasTol & model_ub~=model_lb;
            model_lb(isSmall)=model_lb(isSmall)-feasTol/2;
            model_ub(isSmall)=model_ub(isSmall)+feasTol/2;
        end
        
        isF = [SConsistentRxnBool & v0 >= 0; false(p,1)]; % zero or net forward flux
        isR = [SConsistentRxnBool & v0 < 0; false(p,1)]; % net reverse flux
        
        
        % objective: minimize one-norm
        c = [zeros(n, 1); ones(p, 1)]; % variables: [v; x]
        
        % constraints
        %       v            x
        if any(c0)
            A = [...
                model_S   sparse(m, p); % Sv = b (steady state)
                model_C   sparse(clt,p); %Cv <= d (coupling, if present)
                c0'       sparse(1, p); % c0'v = c0'v0
                 D        -speye(p)   ; %   v - x <= 0
                -D        -speye(p)   ]; % - v - x <= 0
            
            
            b = [model_b;  model_d; (1-feasTol)*c0'*v0; zeros(2*p, 1)];
            
            csense = repmat('E', size(A, 1), 1);
            csense(1:m) = model_csense;
            if ~isempty(model_dsense)
                csense(m+clt1:m+clt) = model_dsense;
            end
            
            %this approach is more numerically robust than forcing the new objective to equal the
            %previous objective
            if osense == 1
                csense(m+clt1+1) = 'L';
            else
                csense(m+clt1+1) = 'G';
            end
            
            csense(m+clt1+2:end) = 'L';
        else
            A = [...
                model_S   sparse(m, p); % Sv = b (steady state)
                model_C   sparse(clt,p); %Cv <= d (coupling, if present)
                D        -speye(p)    ; %   v - x <= 0
                -D        -speye(p)   ]; % - v - x <= 0
            
            b = [model_b; model_d; zeros(2*p, 1)];
            
            csense = repmat('E', size(A, 1), 1);
            csense(1:m) = model_csense;
            if ~isempty(model_dsense)
                csense(m+clt1:m+clt) = model_dsense;
            end
            csense(m+clt1+1:end) = 'L';
        end
        
        % lower and upper bounds - fixed exchange fluxes
        lb = [v0; zeros(p, 1)];
        if 0
            ub = [v0; abs(v0(SConsistentRxnBool))+10]; %allow auxiliary variable to be slightly greater
        else
            ub = [v0; inf*ones(p,1)]; 
        end
        
        if param.debug
            bool =ub-lb<feasTol & ub~=lb;
            if any(bool)
                if param.debug>1
                    figure;
                    hist(ub(bool)-lb(bool))
                end
                title('Perturbed lower, and upper bounds closer than feasibility tolerance')
                fprintf('%s\n',['cycleFreeFlux: #1 Perturbed lower and upper bounds closer than ' num2str(feasTol) ', this may cause numerical issues.'])
            end
        end
        
        %this is useful on some models but on others it is causing instability
        if 0
            % slightly relax bounds on exchange reactions with non-zero net flux
            % because fixing them can lead to infeasibility due to numerical issues
            isExF = [~SConsistentRxnBool & v0 > 0; false(p,1)]; % net forward flux
            isExR = [~SConsistentRxnBool & v0 < 0; false(p,1)]; % net reverse flux
            lb(isExF) = (1-feasTol)*v0(isExF);
            ub(isExF) = (1+feasTol)*v0(isExF);
            lb(isExR) = (1+feasTol)*v0(isExR);
            ub(isExR) = (1-feasTol)*v0(isExR);
        end
        
        if 0
            %dont fix both bounds on objective reaction
            objBool = c0~=0;
            if nnz(objBool)==1
                if osense==1
                    lb(objBool) = -inf;
                else
                    ub(objBool) =  inf;
                end
            end
        end
        
        if param.debug
            bool =ub-lb<feasTol & ub~=lb;
            if any(bool)
                if param.debug>1
                    figure;
                    hist(ub(bool)-lb(bool))
                    title('Perturbed lower, and upper bounds closer than feasibility tolerance')
                end
                fprintf('%s\n',['cycleFreeFlux: #2 Perturbed lower and upper bounds closer than ' num2str(feasTol) ', this may cause numerical issues.'])
            end
        end
        
        if 0
            ub(isF) = v0(isF) + 10*feasTol;
        end
        if param.relaxBounds
            lb(isF) = 0; % internal reaction directionality same as in input flux
        else
            lb(isF) = max(0,model_lb(isF)); % Keep lower bound if it is > 0 (forced positive flux)
        end
        
        if param.debug
            bool =ub-lb<feasTol & ub~=lb;
            if any(bool)
                if param.debug>1
                    figure;
                    hist(ub(bool)-lb(bool))
                    title('Perturbed lower, and upper bounds closer than feasibility tolerance')
                end
                fprintf('%s\n',['cycleFreeFlux: #3 Perturbed lower and upper bounds closer than ' num2str(feasTol) ', this may cause numerical issues.'])
            end
        end
        
        if 0
            lb(isR) = v0(isR) - 10*feasTol;
        end
        
        if param.relaxBounds
            ub(isR) = 0;
        else
            ub(isR) = min(0,model_ub(isR)); % Keep upper bound if it is < 0 (forced negative flux)
        end
        
        if param.debug
            if any(ub-lb<feasTol & ub~=lb)
                fprintf('%s\n','cycleFreeFlux: #4 Perturbed lower and perturbed upper bounds closer than feasibility tolerance, this could cause numerical issues.')
            end
        end
        
        if 0
            %allow reactions with small flux to have small flux with a change in sign
            lb(isSmall) = -100*feasTol;
            ub(isSmall) =  100*feasTol;
        end
        
        if any(lb(1:n)>ub(1:n))
            if norm(lb(lb(1:n)>ub(1:n))-ub(lb(1:n)>ub(1:n)),inf)<feasTol
                lb(lb(1:n)>ub(1:n))=ub(lb(1:n)>ub(1:n));
                if param.printLevel>0
                    fprintf('%s\n','cycleFreeFlux: #5 Lower bounds slightly greater than upper bounds, set to the same.')
                end
            else
                error('cycleFreeFlux: Lower bounds cannot be greater than upper bounds')
            end
        end
        
        if any(lb(n+1:n+p)>ub(n+1:n+p))
            error('cycleFreeFlux: Lower bounds cannot be greater than upper bounds')
        end
        
        
        if param.debug
            if any(ub-lb<feasTol & ub~=lb)
                fprintf('%s\n','cycleFreeFlux: Perturbed lower and upper bounds closer than feasibility tolerance, this could cause numerical issues.')
            end
        end
        
        if any(lb>ub)
            error('cycleFreeFlux: Lower bounds cannot be greater than upper bounds')
        end
        
        lp = struct('osense', 1, 'c', c, 'A', A, ...
            'csense', csense, 'b', b, 'lb', lb, 'ub', ub);
        
        if param.removeFixedBool
            % net zero flux
            isZero = SConsistentRxnBool & v0 == 0;
            %remove the fixed variables from the problem
            zeroBool = [isZero; false(p,1)];
            if 0
                fixedBool = lp.lb == lp.ub | zeroBool;
            else
                %assume the external reactions are also fixed
                fixedBool = lp.lb == lp.ub | zeroBool | [~SConsistentRxnBool;false(p,1)];
            end
            
            lp.b = lp.b - lp.A(:,fixedBool)*lp.lb(fixedBool);
            lp.A = lp.A(:,~fixedBool);
            lp.lb = lp.lb(~fixedBool);
            lp.ub = lp.ub(~fixedBool);
            lp.c = lp.c(~fixedBool);
        end
        
        % solve LP
        solution = solveCobraLP(lp);
end

if solution.stat ==1 || solution.stat ==3
    if param.removeFixedBool==1
        %rebuild optimal flux vector
        full = zeros(n+p,1);
        full(fixedBool)=lb(fixedBool);
        full(~fixedBool)=solution.full;
        solution.full = full;
    end
    
    v1 = solution.full(1:n);
    
    %zero out small values 
    v1(abs(v1)<feasTol/100)=0;
else

    if param.debug
        fprintf('%s',['cycleFreeFlux: No solution found with approach: ' param.approach ' , so relaxing bounds by feasTol*10 ...']);
    end
    if param.debug && exist('lp','var')
        bool = lp.lb~=lp.ub & lp.lb~=0;
        lpRelaxed = lp;
        lpRelaxed.ub(bool) = lp.ub(bool) + feasTol*10;
        lpRelaxed.lb(bool) = lp.lb(bool) - feasTol*10;
        solution = solveCobraLP(lpRelaxed);
        if solution.stat==1
            v1 = solution.full(1:n);
            if param.debug
                fprintf('%s\n','...solution found.')
            end
        else
            fprintf('\n%s\n%s\n','cycleFreeFlux: No solution found.','Debugging relaxation etc...');
            disp(solution)
            save('debug_cycleFreeFlux_infeasibility.mat')
            
            %%
            %lp = struct('osense', 1, 'c', c, 'A', A, 'csense', csense, 'b', b, 'lb', lb, 'ub', ub);
            infeasModel=lp;
            infeasModel.S = lp.A;
            infeasModel = rmfield(infeasModel,'A');
            infeasModel.SIntRxnBool=true(size(lp.A,2),1);
            
            param.printLevel = 1;
            param.steadyStateRelax = 1; %try to make it feasible with bound relaxation only
            param.internalRelax  = 0;
            param.exchangeRelax = 0;
            [solution, relaxedModel] = relaxedFBA(infeasModel, param);
            
            param.steadyStateRelax = 0; %try to make it feasible with bound relaxation only
            param.internalRelax  = 0;
            param.exchangeRelax = 2;
            [solution, relaxedModel] = relaxedFBA(infeasModel, param);
            
            
            param.printLevel = 1;
            param.steadyStateRelax = 0; %try to make it feasible with bound relaxation only
            param.internalRelax  = 1;
            param.exchangeRelax = 0;
            [solution, relaxedModel] = relaxedFBA(infeasModel, param);
            
            P=table(find(solution.p>0),solution.p(find(solution.p>0)),find(solution.p>0)<size(model_S,2));
            Q=table(find(solution.q>0),solution.q(find(solution.q>0)),find(solution.q>0)<size(model_S,2));
            %%
            norm(model_S*v0-model_b,'inf')
            
            belowLowerBound = v0-model_lb;
            belowLowerBound(belowLowerBound>0)=0;
            min(belowLowerBound)
            
            aboveUpperBound = model_ub-v0;
            aboveUpperBound(aboveUpperBound>0)=0;
            min(aboveUpperBound)
            
            solution
            
            lpRelaxed = lp;
            lpRelaxed.ub = lp.ub + feasTol*10;
            lpRelaxed.lb = lp.lb - feasTol*10;
            solutionRelaxed1 = solveCobraLP(lpRelaxed)
            
            lpRelaxed.lb(:) = -10;
            lpRelaxed.ub(:) =  10;
            solutionRelaxed2 = solveCobraLP(lpRelaxed)
            
            lpRelaxed.lb(:) = -inf;
            lpRelaxed.ub(:) =  inf;
            solutionRelaxed3 = solveCobraLP(lpRelaxed)
            
        end
    end
    v1 = [];
    warning('cycleFreeFlux: No solution found.');
end

end
