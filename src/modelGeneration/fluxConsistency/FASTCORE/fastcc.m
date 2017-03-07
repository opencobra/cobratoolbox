function [A,modelFlipped,V] = fastcc(model,epsilon,printLevel,modeFlag,method)
% [A,V] = fastcc(model,epsilon,printLevel)
%
% The FASTCC algorithm for testing the consistency of a stoichiometric model
% Output A is the consistent part of the model
%
% INPUT
% model         cobra model structure containing the fields
%   S           m x n stoichiometric matrix    
%   lb          n x 1 flux lower bound
%   ub          n x 1 flux uppper bound
%   rxns        n x 1 cell array of reaction abbreviations
% 
% epsilon       
% printLevel    0 = silent, 1 = summary, 2 = debug
%
% OPTIONAL INPUT
% modeFlag      {(0),1}; 1=return matrix of modes V
%
% OUTPUT
% A             n x 1 boolean vector indicating the flux consistent
%               reactions
% V             n x k matrix such that S(:,A)*V(:,A)=0 and |V(:,A)|'*1>0
 
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Ronan Fleming      2014 Commenting of inputs/outputs/code
% Ronan Fleming      2017 Added non-convex cardinality optimisation

if ~exist('printLevel','var')
    printLevel = 2;
end
if ~exist('modeFlag','var')
    modeFlag=0;
end
if ~exist('method','var')
    method='original';
end

tic

%number of reactions
N = (1:size(model.S,2));

veryOrigModel=model;

%reactions irreversible in the reverse direction
Ir = find(model.ub<=0);
%flip direction of reactions irreversible in the reverse direction
model.S(:,Ir) = -model.S(:,Ir);
tmp = model.ub(Ir);
model.ub(Ir) = -model.lb(Ir);
model.lb(Ir) = -tmp;

%save the model with only the flips of the reverse reactions
origModel=model;

%all irreversible reactions should only be in the forward direction
I  = find(model.lb>=0);
if any(model.lb<0 & model.ub<0)
    %Feb 13th 2017, Added by Ronan for the second time.
    error('fastcc only works for models with reversible or forward irreversible reactions')
end
    
A = [];

% J is the set of irreversible reactions
J = intersect( N, I );
if printLevel>1
    fprintf('%6u\t%s\n',numel(N),'Total reactions')
    fprintf('%6u\t%s\n',numel(N)-numel(I), 'Reversible reactions.');
    fprintf('%6u\t%s\n',numel(I), 'Irreversible reactions.');
    %fprintf('|J|=%d  ', numel(J));
end

%V is the n x k matrix of maximum cardinality vectors
V=[];

%v is the flux vector that approximately maximizes the cardinality 
%of the set of irreversible reactions v(J)
[v, basis] = LP7( J, model, epsilon);

%A is the set of reactions in v with absoulte value greater than epsilon
Supp = find( abs(v) >= 0.99*epsilon );
A = Supp;
if printLevel>1
    fprintf('%6u\t%s\n',numel(A), 'Flux consistent reactions, without flipping.');
    %fprintf('|A|=%d\n', numel(A));
end

if length(A)>0 && modeFlag
    %save the first v
    V=[V,v];
end

%incI is the set of irreversible reactions that are flux inconsistent
incI = setdiff( J, A );
if ~isempty( incI )
    if printLevel>1
        fprintf('%6u\t%s\n',numel(incI), 'Flux inconsistent irreversible reactions, without flipping.');
        %fprintf('\n(flux inconsistent subset of I detected)\n');
    end
end

%J is the set of reactions with absolute value less than epsilon in V
J = setdiff( setdiff( N, A ), incI);
if printLevel>1
    fprintf('%6u\t%s\n',numel(J), 'Flux inconsistent reactions, without flipping.');
    %fprintf('|J|=%d  ', numel(J));
end

% reversible reactions have to be tried for flux consistency in both
% directions
flipped = false;
singleton = false;
JiRev=[];
orientation=ones(size(model.S,2),1);
while ~isempty( J )
    switch method
        case 'original'
            if singleton
                Ji = J(1);
                [v, basis] = LP3( Ji, model, basis);
            else
                Ji = J;
                [v, basis] = LP7( Ji, model, epsilon, basis);
            end
        case 'nonconvex'
            if singleton
                Ji = J(1);
                [v,LPsolution] = fastcc_nonconvex_check_consistency_one_reaction(Ji, model);
            else
                Ji = J;
                solution_NC = fastcc_nonconvex_maximise_card_J(J,model,epsilon,printLevel);
                v = solution_NC.v;
            end
    end
    %Supp is the set of reactions in v with absoulte value greater than epsilon
    Supp = find( abs(v) >= 0.99*epsilon );
    %A is the set of reactions in V with absoulte value greater than epsilon
    nA1=length(A);
    A = union( A, Supp);
    nA2=length(A);
    
    %save v if new flux consistent reaction found
    if nA2>nA1
        if modeFlag
            if ~isempty(JiRev)
                %make sure the sign of the flux is consistent with the sign of
                %the original S matrix if any reactions have been flipped
                len=length(orientation);
                vf=spdiags(orientation,0,len,len)*v;
                V=[V,vf];
                
                %sanity check
                if norm(origModel.S*vf)>epsilon/100
                    fprintf('%g%s\n',epsilon/100, '= epsilon/100')
                    fprintf('%s\t%g\n','should be zero :',norm(model.S*v)) % should be zero
                    fprintf('%s\t%g\n','should be zero :',norm(origModel.S*vf)) % should be zero
                    fprintf('%s\t%g\n','may not be zero:',norm(model.S*vf)) % may not be zero
                    fprintf('%s\t%g\n','may not be zero:',norm(origModel.S*v)) % may not be zero
                    error('Flipped flux consistency step failed.')
                end
            else
                V=[V,v];
            end
        end
        if printLevel>1
            fprintf('%6u\t%s\n',numel(A), 'Flux consistent reactions.');
            %fprintf('|A|=%d\n', numel(A));
        end
    end
        
    %if the set of reactions in V with absolute value less than epsilon has
    %no reactions in common with the set of reactions in V with absolute value
    %greater than epsilon, then flip the sign of the reactions with absolute
    %value less than epsilon because perhaps they are flux consistent in
    %the reverse direction
    if ~isempty( intersect( J, A ))
        %J is the set of reactions with absolute value less than epsilon in V
        J = setdiff( J, A );
        if printLevel>1
            fprintf('%6u\t%s\n',numel(J), 'Flux inconsistent reversible reactions left to flip.');
            %fprintf('|J|=%d  ', numel(J));
        end
        flipped = false;
    else
        %do not flip the direction of exclusively forward reactions
        JiRev = setdiff( Ji, I );
        
        if flipped || isempty( JiRev )
            %if reactions flipped, check if first reaction without flux
            %can really not carry flux
            %if only forward reactions are candidates suggested to be flipped
            %then report reaction as flux inconsistent
            flipped = false;
            if singleton
                J = setdiff( J, Ji );
                if printLevel>2
                    fprintf('%s\t%s\n',model.rxns{Ji}, 'is flux inconsistent.');
                end
            else
                singleton = true;
            end
        else
            %flipping the orientation of reactions
            model.S(:,JiRev) = -model.S(:,JiRev);
            tmp = model.ub(JiRev);
            model.ub(JiRev) = -model.lb(JiRev);
            model.lb(JiRev) = -tmp;
            flipped = true;
            %need to keep track of the orientation of model.S compared with
            %origModel.S
            orientation(JiRev)=orientation(JiRev)*-1;
            if printLevel>3
                fprintf('%6u\t%s\n',length(JiRev), ' reversible reaction flipped.');
                %fprintf('%s\n',['Flipped ' num2str(length(JiRev)) ' reaction.']);
            end
        end
    end
end

modelFlipped=model;

if modeFlag
    flippedReverseOrientation=ones(size(model.S,2),1);
    flippedReverseOrientation(Ir)=-1;
    %flip the direction of the returned fluxes
    V=spdiags(flippedReverseOrientation,0,size(model.S,2),size(model.S,2))*V;
    
    %sanity check
    if norm(veryOrigModel.S*V,inf)>epsilon/100
        if printLevel>0
            fprintf('%g%s\n',epsilon/100, '= epsilon/100')
            fprintf('%g%s\n',norm(veryOrigModel.S*V,inf),' = ||S*V||.')
        end
        if 0
            error('Flux consistency check failed')
        else
            warning('Flux consistency numerically challenged')
        end
    else
        if printLevel>0
            fprintf('%s\n','Flux consistency check finished...')
            fprintf('%10u%s\n',sum(any(abs(V)>=0.99*epsilon,2)),' = Number of flux consistent columns.')
            fprintf('%10f%s\n\n',norm(veryOrigModel.S*V,inf),' = ||S*V||.')
        end
    end
end
origModel=veryOrigModel;
if numel(A) == numel(N)
    if printLevel>0
        fprintf('%s\n','fastcc.m: The input model is entirely flux consistent.\n');
    end
end
if printLevel>2
    toc
end
end

%% Helper functions for the nonconvex method
% =============================
% Maximises the number of feasible fluxes in J whose the absolute value is at least epsion
function [solution] = fastcc_nonconvex_maximise_card_J(J,model,epsilon,printLevel)
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
            if printLevel>2
                disp(strcat('DCA - Iteration: ',num2str(nbIteration)));
                disp(strcat('Obj:',num2str(obj_new)));
                disp(strcat('Stopping criteria error: ',num2str(min(error_v,error_obj))));
                disp('=================================');
            end
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


%code to test nullspace acceleration
% tic
% if 1 || ~isfield(model,'fluxConsistentMetBool') || ~isfield(model,'fluxConsistentRxnBool')
%     param.epsilon=1e-4;
%     param.modeFlag=1;
%     param.method='null_fastcc';
%     printLevel = 2;
%     [fluxConsistentMetBool2,fluxConsistentRxnBool2,fluxInConsistentMetBool2,fluxInConsistentRxnBool2,modelOpen] = findFluxConsistentSubset(modelOpen,param,printLevel);
% end
% fprintf('%6u\t%6u\t%s\n',nnz(fluxInConsistentMetBool2),nnz(fluxInConsistentRxnBool2),' flux inconsistent.')
% toc
% 
% tic
% if 1 || ~isfield(model,'fluxConsistentMetBool') || ~isfield(model,'fluxConsistentRxnBool')
%     param.epsilon=1e-4;
%     param.modeFlag=1;
%     param.method='fastcc';
%     %param.method='nonconvex';
%     printLevel = 2;
%     [fluxConsistentMetBool,fluxConsistentRxnBool,fluxInConsistentMetBool,fluxInConsistentRxnBool,modelOpen] = findFluxConsistentSubset(modelOpen,param,printLevel);
% end
% fprintf('%6u\t%6u\t%s\n',nnz(fluxInConsistentMetBool),nnz(fluxInConsistentRxnBool),' flux inconsistent.')
% toc






