% Example of using sparseLP solver
% Find the minimal set of reactions subject to a LP objective
% min ||v||_0
% s.t   Sv = b
%       c'v = f (optimal value of objective)
%       l <= v <= u
% Hoai Minh Le	07/01/2016
%

% Solver is chosen in demoSparseLP.m;
% if standalone: changeCobraSolver('gurobi6','all');

epsilon = 1e-6; % Tolerance for non-zero flux

%% Load a COBRA model
load('iLC915.mat');

%% Solve FBA
% max c'v
% s.t   Sv = b
%       l <= v <= u

% Define the LP structure
[c,S,b,lb,ub] = deal(model.c,model.S,model.b,model.lb,model.ub);
[m,n] = size(S);
if ~isfield(model,'csense')
    csense = repmat('E',m,1);
end

LPproblem = struct('c',-c,'osense',1,'A',S,'csense',csense,'b',b,'lb',lb,'ub',ub);

% Call solveCobraLP to solve the FBA problem
LPsolution = solveCobraLP(LPproblem);
if LPsolution.stat == 1
        vFBA = LPsolution.full(1:n);
else
        vFBA = [];
        error('FBA problem error!')
end
display('---FBA')
display(strcat('|vFBA|_0 = ',num2str(length(find(abs(vFBA)>0)))));

%% Minimise the number of reactions by keeping same max objective found previously
% One adds the constraint : c'v = c'vFBA
% min ||v||_0
% s.t   Sv = b
%       c'v = fFBA
%       l <= v <= u

constraint.A = [S ; c'];
constraint.b = [b ; c'*vFBA];
constraint.csense = [csense;'E'];
constraint.lb = lb;
constraint.ub = ub;

% Call sparseLP solver
% Try all non-convex approximations of zero norm and take the best result
approximations = {'cappedL1','exp','log','SCAD','lp-','lp+'};
bestResult = n;
bestAprox = '';
for i=1:length(approximations)
    solution = sparseLP(char(approximations(i)),constraint);

    if solution.stat == 1
        if bestResult > length(find(abs(solution.x)>epsilon))
            bestResult=length(find(abs(solution.x)>epsilon));
            bestAprox = char(approximations(i));
            solutionL0 = solution;
        end
    end
end

if ~isequal(bestAprox,'')
        v = solutionL0.x;
else
        v = [];
        error('Min L0 problem error !!!!')
end


display('---Non-convex approximation')
display(strcat('Best approximation:',bestAprox));
display(strcat('|vL0|_0 = ',num2str(length(find(abs(solutionL0.x)>eps)))));
display(strcat('Feasibily error =',num2str(norm(constraint.A * solutionL0.x - constraint.b,2))));


%% Heuristically check if the selected set of reactions is minimal
reducedModel = model;
%Set of predicted active reactions
index_ActiveRxns = find(abs(solutionL0.x)>epsilon);
nb_ActiveRnxs = length(index_ActiveRxns);
activeRxns = false(n,1);
activeRxns(index_ActiveRxns) = true;
isInMinnimalSet = true(nb_ActiveRnxs,1);

%Close all predicted non-active reactions by setting their lb = ub = 0
reducedModel.lb(~activeRxns) = 0;
reducedModel.ub(~activeRxns) = 0;

%Remove one by one the predicted active reaction and verify if whether
%or not the optimal objective value can be achieved

A = reducedModel.S;
b = reducedModel.b;

for i=1:nb_ActiveRnxs
    % Close the reaction
    ubSub = reducedModel.ub;
    lbSub = reducedModel.lb;
    ubSub(index_ActiveRxns(i)) = 0;
    lbSub(index_ActiveRxns(i)) = 0;

    % Check if one still can achieve the same objective
    LPproblem = struct('c',-reducedModel.c,'osense',1,'A',A,'csense',csense,'b',b,'lb',lbSub,'ub',ubSub);
    LPsolution = solveCobraLP(LPproblem);

    if LPsolution.stat == 1 && abs(LPsolution.obj - -c'*vFBA)<1e-8
        isInMinnimalSet(i) = false;
        reducedModel.ub(i) = 0;
        reducedModel.lb(i) = 0;
        v = LPsolution.full(1:n);
    end
end


display('---Non-convex approximation')
display(strcat('Best approximation:',bestAprox));
display(strcat('|vL0|_0 = ',num2str(length(find(abs(v)>epsilon)))));
display(strcat('Feasibily error =',num2str(norm(constraint.A * v - constraint.b,2))));
display(strcat('Nb of rxns that one can still remove = ',num2str(nb_ActiveRnxs - length(find(isInMinnimalSet==true)))));
if nb_ActiveRnxs - length(find(isInMinnimalSet==true))~=0
    if isfield(reducedModel,'rxns')
        display(reducedModel.rxns(~isInMinnimalSet))
    end
end
