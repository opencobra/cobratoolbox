% Example of using sparseLP solver
% Find the minimal set of reactions subject to a LP objective
% min ||v||_0
% s.t   Sv = b
%       c'v = f (optimal value of objective)
%       l <= v <= u
% Hoai Minh Le	07/01/2016


params = struct('FeasibilityTol',1e-6);
changeCobraSolver('gurobi6','all');

%% Load a COBRA model 
load('iLC915.mat');

%% Maximize 
% max c'v
% s.t   Sv = b
%       l <= v <= u

% Define the LP structure
[c,S,b,lb,ub] = deal(model.c,model.S,model.b,model.lb,model.ub);
[m,n] = size(S);
csense = repmat('=',m,1);
LPproblem = struct('c',-c,'osense',1,'A',S,'csense',csense,'b',b,'lb',lb,'ub',ub);  

% Call solveCobraLP to solve the LP
LPsolution = solveCobraLP(LPproblem,params);
if LPsolution.stat == 1
        vFBA = LPsolution.full(1:n);
else
        vFBA = [];
        error('FBA problem error !!!!')
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
constraint.csense = repmat('=',m+1,1);
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
        if bestResult > length(find(abs(solution.x)>eps))
            bestResult=length(find(abs(solution.x)>eps));
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
index_selRxns = find(abs(solutionL0.x)>eps);
nb_selRnxs = length(index_selRxns);
selRxns = false(size(model.rxns));
selRxns(index_selRxns) = true;
selMets = any(model.S(:,selRxns),2);

isInMinnimalSet = true(nb_selRnxs,1);

subModel.S = model.S(selMets,selRxns);
subModel.b = model.b(selMets);
subModel.lb = model.lb(selRxns);
subModel.ub = model.ub(selRxns);
subModel.c = model.c(selRxns);
subModel.rxns = model.rxns(selRxns);
subModel.rxnNames = model.rxnNames(selRxns);
subModel.metNames = model.metNames(selMets);

[mSub,nSub] = size(subModel.S);

A = subModel.S;
b = subModel.b;
csense = repmat('E',mSub,1);

for i=1:nb_selRnxs
    ubSub = subModel.ub;
    lbSub = subModel.lb;
    ubSub(i) = 0;
    lbSub(i) = 0;
    
    % max c'v
    LPproblem = struct('c',-subModel.c,'osense',1,'A',A,'csense',csense,'b',b,'lb',lbSub,'ub',ubSub);  
    LPsolution = solveCobraLP(LPproblem,params);
    
    if LPsolution.stat == 1 && abs(LPsolution.obj - -c'*vFBA)<1e-8
        isInMinnimalSet(i) = false;
        subModel.ub(i) = 0;
        subModel.lb(i) = 0;
    end
end

display(strcat('Nb of rxns that one can still remove = ',num2str(nb_selRnxs - length(find(isInMinnimalSet==true)))));
if nb_selRnxs - length(find(isInMinnimalSet==true))~=0
    display(subModel.rxns(~isInMinnimalSet))


end
