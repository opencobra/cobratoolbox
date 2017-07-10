%% Sparse Linear Optimisation
%% Author: Ronan Fleming, Hoai Minh Le, Systems Biochemistry Group, University of Luxembourg.
%% Reviewer:
%% INTRODUCTION
% In this tutorial, we will show how to use the sparse LP solver. This solver 
% aims to solve the following optimisation problem
% 
% $$\begin{array}{ll}\min & \Vert x\Vert_{0}\\s.t & A_{eq}x=b_{eq}\\ & A_{ieq}x\leq 
% b_{ieq}\\ & l\leq x\leq u\end{array}$$
% 
% It has been proved that zero-norm is a non-convex function and the minimisation 
% of zero-norm is a NP-hard problem. Non-convex approximations of zero-norm extensively 
% developed. For a complete study of non-convex approximations of zero-norm, the 
% reader is referred to [<#LyXCite-sparsePaper sparsePaper>].
% 
% The method is described in [<#LyXCite-sparsePaper sparsePaper>]. The sparse 
% LP solver contains one convex (one-norm) and 6 non-convex approximation of zero-norms
% 
% * Capped-L1 norm
% * Exponential function
% * Logarithmic function
% * SCAD (Smoothly Clipped Absolute Deviation) function
% * p norm with    p<0    
% * p norm with    0<p<1   
% 
% The tutorial consist of two parts. Part 1 shows a basic usage of the solver. 
% In part 2 provides an application of the code for finding the minimal set of 
% reactions subject to a LP objective. Ready-made scripts are provided for both 
% parts.
%% PROCEDURE
% _Only if necessary, initialise The COBRA Toolbox._

global TUTORIAL_INIT_CB;
if ~isempty(TUTORIAL_INIT_CB) && TUTORIAL_INIT_CB==1
    initCobraToolbox
    changeCobraSolver('gurobi','all');
end
%% Example of using sparseLP solver on randomly generated data
% One randomly generates a matrix $A\in\mathcal{R}^{^{m\times n}}$   and a vector 
% $x_{0}\in\mathcal{R}^{^{n}}$ . The right hand side vector $b=A\cdot x_{0}$. 
% There are three optional inputs for the method.

n = 100; 
m = 50; 
x0 = rand(n,1); 
constraint.A = rand(m,n); 
constraint.b = constraint.A*x0; 
constraint.lb = -1000*ones(n,1); 
constraint.ub = 1000*ones(n,1); 
constraint.csense = repmat('E', m, 1); 
%% 
% The two first: maximum number of iterations (_nbMaxIteration_) and threshold 
% (_epsilon_) are stopping criterion conditions. _theta_ is the parameter of zero-norm 
% approximation. The greater the value of _theta_, the better the approximation 
% of the zero-norm. However, the greater the value of _theta_, the more local 
% solutions the problem <#eq_mainPrb eq:mainPrb> has. If the value of _theta _is 
% not given then the algorithm will use a default value and update it gradually.

params.nbMaxIteration = 100;    % stopping criteria
params.epsilon = 1e-6; 		% stopping criteria
params.theta   = 2;    		 % parameter of l0 approximation 
%% 
% Call the solver with a chosen approximation

solution = sparseLP('cappedL1',constraint,params); 
%% 
% or with default parameter

%solution = sparseLP('cappedL1',constraint);
%% Finding the minimal set of reactions subject to a LP objective
% Set the tolerance to distinguish between zero and non-zero flux, based on 
% the numerical tolerance of the currently installed optimisation solver.

feasTol = getCobraSolverParams('LP', 'feasTol');
%% 
% Load Recon3.0model, unless it is already loaded into the workspace.

clear model relaxOption
if ~exist('modelOrig','var')
    filename='Recon3.0model';
    directory='~/work/sbgCloud/programReconstruction/projects/recon2models/data/reconXComparisonModels';
    model = loadIdentifiedModel(filename,directory);
    model.csense(1:size(model.S,1),1)='E';
    modelOrig = model;
else
    model=modelOrig;
end
%% 
% Select the biomass reaction to optimise

model.biomassBool=strcmp(model.rxns,'biomass_reaction');
model.c(model.biomassBool)=1;
%% 
% We will firstly find the optimal value subject to a LP objective

%% Solve FBA  
% max c'v 
% s.t   Sv = b 
%       l <= v <= u
% Define the LP structure 
[c,S,b,lb,ub,csense] = deal(model.c,model.S,model.b,model.lb,model.ub,model.csense); 
[m,n] = size(S); 
LPproblem = struct('c',-c,'osense',1,'A',S,'csense',csense,'b',b,'lb',lb,'ub',ub);  
% Call solveCobraLP to solve the LP 
LPsolution = solveCobraLP(LPproblem);
vFBA = LPsolution.full;
%% 
% We will now find the minimum number of reactions needed to achieve the 
% same max objective found previously. Then one will add one more constraint: 
% $$c^{T}v=c^{T}v_{FBA}=:f_{FBA}$$.

constraint.A = [S ; c']; 
constraint.b = [b ; c'*vFBA]; 
constraint.csense = [csense;'E'];
constraint.lb = lb; 
constraint.ub = ub;
%% 
% Call the sparseLP solver to solve the problem
% 
% $$\begin{array}{ll}\min & \Vert v\Vert_{0}\\s.t & Sv=b\\ & c^{T}v=f_{FBA}\\ 
% & l\leq v\leq u\end{array}$$

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
%% 
% Now we call the sparse linear step function approximations  

bestResult = n;
bestAprox = '';
for i=1:length(approximations)
    solution = sparseLP(char(approximations(i)),constraint);
    if solution.stat == 1
        nnzSol=nnz(abs(solution.x)>feasTol);
        fprintf('%u%s%s',nnzSol,' active reactions in the sparseFBA solution with ', char(approximations(i)));
        if bestResult > nnzSol
            bestResult=nnzSol;
            bestAprox = char(approximations(i));
            solutionL0 = solution;
        end
    end
end
%% 
% Select the most sparse flux vector, unless there is a numerical problem.

if ~isequal(bestAprox,'')
    vBest = solutionL0.x;
else
    vBest = [];
    error('Min L0 problem error !!!!')
end
%% 
% Report the best approximation

display(strcat('Best step function approximation: ',bestAprox));
%% 
% Report the number of active reactions in the most sparse flux vector

fprintf('%u%s',nnz(abs(vBest)>feasTol),' active reactions in the best sparse flux balance analysis solution.');
%% 
% Warn if there might be a numerical issue with the solution

feasError=norm(constraint.A * solutionL0.x - constraint.b,2);
if feasError>feasTol
    fprintf('%g\t%s\n',feasError, ' feasibily error.')
    warning('Numerical issue with the sparseLP solution')
end
%% REFERENCES
% _ _[<#LyXCite-sparsePaper sparsePaper>] Le Thi, H.A., Pham Dinh, T., Le, H.M., 
% and Vo, X.T. (2015). DC approximation approaches for sparse optimization. European 
% Journal of Operational Research 244, 26–46.