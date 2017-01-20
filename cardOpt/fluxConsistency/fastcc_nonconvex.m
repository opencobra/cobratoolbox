function [A,V] = fastcc_nonconvex(model,epsilon,printLevel,modeFlag)
% [A,V] = fastcc_nonconvex(model,epsilon,printLevel)
%
% The FASTCC algorithm for testing the consistency of a stoichiometric model
% Output A is the consistent part of the model
%
% INPUT
% model             cobra model structure containing the fields
%   S               m x n stoichiometric matrix    
%   lb              n x 1 flux lower bound
%   ub              n x 1 flux uppper bound
%   rxns            n x 1 cell array of reaction abbreviations
% 
% epsilon           flux threshold       
% printLevel        0 = silent, 1 = summary, 2 = debug
%
% OPTIONAL INPUT
% modeFlag          {(0),1}; 1=return matrix of modes V
%
% OUTPUT
% A                 n x 1 boolean vector indicating the flux consistent reactions
% V                 n x k matrix such that S(:,A)*V(:,A)=0 and |V(:,A)|'*1>0
 
% Hoai Minh LE      07/01/2016

if ~exist('printLevel','var')
    printLevel = 2;
end
if ~exist('modeFlag','var')
    modeFlag=0;
end

tic

% Set of all reactions
N = (1:size(model.S,2));

% Reactions assumed to be irreversible
I = find(model.lb==0);
% I = find(model.lb>=0 | model.ub <= 0);


A = [];

% J is the set of irreversible reactions
J = intersect( N, I );
% J = N;
if printLevel>1
    fprintf('|J|=%d  ', numel(J));
end

% V is the n x k matrix of maximum cardinality vectors
V=[];

% v is the flux vector that approximately maximizes the cardinality 
% of the set of irreversible reactions v(J)
% solution_NC = fastcc_nonconvex_maximise_card_J(J,model,epsilon);
% v = solution_NC.v;    
[v, basis] = LP7( J, model, epsilon);

% A is the set of reactions in v with absoulte value greater than epsilon
Supp = find( abs(v) >= 0.99*epsilon );
A = Supp;
if printLevel>1
    fprintf('|A|=%d\n', numel(A));
end

if length(A)>0 && modeFlag
    %save the first v
    V=[V,v];
end

%incI is the set of irreversible reactions that are flux inconsistent
incI = setdiff( J, A );
if ~isempty( incI )
    if printLevel>0
        fprintf('\n(flux inconsistent subset of I detected)\n');
    end
end

%J is the set of reactions with absolute value less than epsilon in V
J = setdiff( setdiff( N, A ), incI);
% J = setdiff( N, A );
if printLevel>1
    fprintf('|J|=%d  ', numel(J));
end

singleton = false;
while ~isempty( J )
    if singleton
        Ji = J(1);
        [v,LPsolution] = fastcc_nonconvex_check_consistency_one_reaction(Ji, model);
    else
        Ji = J;
        solution_NC = fastcc_nonconvex_maximise_card_J(J,model,epsilon);
        v = solution_NC.v;            
    end
    %Supp is the set of reactions in v with absoulte value greater than epsilon
    Supp = find( abs(v) >= 0.99*epsilon );
    %A is the set of reactions in V with absoulte value greater than epsilon
    nA1=length(A);
    A = union( A, Supp);
    nA2=length(A);
    
    %save v if new flux consistent reaction found
    if nA2>nA1 && modeFlag
            V=[V,v];
    end
        
    if printLevel>1
        fprintf('|A|=%d\n', numel(A));
    end
    
    if ~isempty( intersect( J, A ))
        %J is the set of reactions with absolute value less than epsilon in V
        J = setdiff( J, A );
        if printLevel>1
            fprintf('|J|=%d  ', numel(J));
        end
    else
        if singleton
            J = setdiff( J, Ji );
            if printLevel>1
                fprintf('%s','Flux inconsistent reversible reaction detected:');
            end
            if printLevel>10
                fprintf('%s\n',model.rxns{Ji});
                if printLevel>1
                    save A A;
                end
            end
        else
            singleton = true;
        end
    end
end

if modeFlag
    %sanity check
    if norm(model.S*V,inf)>epsilon/100
        fprintf('%g%s\n',epsilon/100, '= epsilon/100')
        fprintf('%g%s\n',norm(model.S*V,inf),' = ||S*V||.')
        if 0
            error('Flux consistency check failed')
        else
            warning('Flux consistency numerically challenged')
        end
    else
        fprintf('%s\n','Flux consistency check finished...')
        fprintf('%10u%s\n',sum(any(V,2)),' = Number of flux consistent columns.')
        fprintf('%10f%s\n\n',norm(model.S*V,inf),' = ||S*V||.')
    end
end

if numel(A) == numel(N)
    if printLevel>0
        fprintf('\n fastcc.m: The input model is consistent.\n');
    end
end
if printLevel>1
    toc
end
end


% =============================
% Maximises the number of feasible fluxes in J whose the absolute value is at least epsion
function [solution] = fastcc_nonconvex_maximise_card_J(J,model,epsilon)
%INPUT
% J                         indicies of reactions
% model                     cobra model structure
% epsilon                   tolerance
%
%OUTPUT
% solution                  structure containing the following fields
%       v                   optimal steady state flux vector
%       stat                status
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
    
nj = numel(J);
[m,n] = size(model.S);
    
% Initialisation
nbMaxIteration = 10;
nbIteration = 1;
stop = false;   
solution.v = [];
solution.stat = 1;

v           = zeros(n,1);
v(J)        = 1;
v_bar       = zeros(n,1);
rho         = zeros(n,1);
rho(J)      = 1;
obj_old = fastcc_nonconvex_maximise_card_J_compute_obj(v,rho,epsilon);

%Create the linear sub-programme that one needs to solve at each iteration, only its
%objective function changes, the constraints set remains the same.

% Define objective - variable (v,t)
obj = [zeros(n,1);ones(nj,1)];

% Constraints
% Sv = 0
% t >= v/epsilon
% t >= -v/epsilon
    
Ij = sparse(nj,n); 
Ij(sub2ind(size(Ij),(1:nj)',J(:))) = 1/epsilon;
AA = [sparse(model.S)        sparse(m,nj);
      sparse(Ij)              -speye(nj);
      -sparse(Ij)             -speye(nj)];
bb = [zeros(m,1); zeros(2*nj,1)];
csense = [repmat('=',m, 1);repmat('<',2*nj, 1)];

% Bound;
% lb <= v <= ub
% 1  <= t <= max(|lb|,|ub|)
lb2 = [model.lb;ones(nj,1)];
ub2 = [model.ub;max(ones(nj,1),max(abs(model.lb(J))/epsilon,abs(model.ub(J))/epsilon))];
% ub2 = [model.ub;inf*ones(nj,1)];

LP_basis = [];

%Define the linear sub-problem  
subLPproblem = struct('c',obj,'osense',1,'A',AA,'csense',csense,'b',bb,'lb',lb2,'ub',ub2,'basis',LP_basis);

%DCA
while nbIteration < nbMaxIteration && stop ~= true, 
    
    v_old = v;
        
    %Compute v_bar in subgradient of second DC component   
    v_bar = (rho.*sign(v)) / epsilon;
    
    %Solve the linear sub-program to obtain new v    
    [v,LPsolution] = fastcc_nonconvex_maximise_card_J_solveSubProblem(subLPproblem,v_bar,nj);
    
    % Reuse for the next iteration
    if isfield(LPsolution,'basis')
        subLPproblem.basis=LPsolution.basis;
    else
        subLPproblem.basis=[];
    end
    
    switch LPsolution.stat
        case 0
%             disp('Problem infeasible !!!!!');
            solution.v = [];
            solution.stat = 0;
            stop = true;
        case 2
%             disp('Problem unbounded !!!!!');
            solution.v = [];
            solution.stat = 2;
            stop = true;
        case 1
            %Check stopping criterion 
            error_v = norm(v - v_old);
            obj_new = fastcc_nonconvex_maximise_card_J_compute_obj(v,rho,epsilon);
            error_obj = abs(obj_new - obj_old);
            if (error_v < epsilon) || (error_obj < epsilon)
                stop = true;
            else
                obj_old = obj_new;                
            end
            nbIteration = nbIteration + 1;
            disp(strcat('DCA - Iteration: ',num2str(nbIteration)));
            disp(strcat('Obj:',num2str(obj_new)));    
            disp(strcat('Stopping criteria error: ',num2str(min(error_v,error_obj))));
            disp('=================================');
    end   
end
if solution.stat == 1
    solution.v = v;
end

end

% Solve the linear sub-program to obtain new x
function [v,LPsolution] = fastcc_nonconvex_maximise_card_J_solveSubProblem(subLPproblem,v_bar,nj)
    
n = length(v_bar);

% Change the objective - variable (x,t)
subLPproblem.obj = [-v_bar;ones(nj,1)];
    
%Solve the linear problem  
LPsolution = solveCobraLP(subLPproblem);
        
if LPsolution.stat == 1
    v = LPsolution.full(1:n);
else
    v = [];
end

end
    
% Compute the objective function
function obj = fastcc_nonconvex_maximise_card_J_compute_obj(v,rho,epsilon)
obj = rho'*min(abs(v)/epsilon,1);
end
    
    
% Check flux consistency for one reaction 
%INPUT
% j                         indicie of reaction
% model                     cobra model structure
%
%OUTPUT
% solution                  structure containing the following fields
%       v                   optimal steady state flux vector
%       stat                status
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible

function [v,LPsolution] = fastcc_nonconvex_check_consistency_one_reaction(j, model)

[m,n] = size(model.S);

% Define the LP structure

obj = zeros(n,1);

% Steady state constraints Sv = 0
Aeq = model.S;
beq = zeros(m,1);

% bounds
lb = model.lb;
ub = model.ub;

LPproblem.A=Aeq;
LPproblem.b=beq;
LPproblem.csense(1:m)='E';
LPproblem.lb=lb;
LPproblem.ub=ub;
LPproblem.osense=1;%minimise
LPproblem.c=obj;


% If the reaction is forward irreversible reaction then max v_j
if model.lb(j) >= 0  
    LPproblem.c(j) = -1;    
    LPsolution = solveCobraLP(LPproblem);
    if LPsolution.stat == 1
        v = LPsolution.full(1:n);
    else
        v = [];
    end
% If the reaction is reverse irreversible reaction then min v_j    
elseif model.ub(j) <= 0
    LPproblem.c(j) = 1;
    LPsolution = solveCobraLP(LPproblem);
    if LPsolution.stat == 1
        v = LPsolution.full(1:n);
    else
        v = [];
    end
% If the reaction is reversible then need to check both side    
else
    % Check forward side
    LPproblem.c(j) = -1;
    LPsolution = solveCobraLP(LPproblem);
    if LPsolution.stat == 1
        v = LPsolution.full(1:n);
        % Only check reverse side if v(j) = 0
        if v(j) == 0
            LPproblem.c(j) = 1;
            LPsolution = solveCobraLP(LPproblem);
            if LPsolution.stat == 1
                v = LPsolution.full(1:n);
            else
                v = [];
            end                        
        end
    else
        v = [];
    end    
end
end