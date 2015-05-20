function V = LP3( J, model, orig )
% V = LP3( J, model )
% CPLEX implementation of LP-3 for input set J (see FASTCORE paper)
% Maximizes the sum of fluxes of reactions in set J
% 
% J         indicies of maximized reaction  
% model     cobra model structure containing the fields
%   S         m x n stoichiometric matrix    
%   lb        n x 1 flux lower bound
%   ub        n x 1 flux upper bound
%   rxns      n x 1 cell array of reaction abbreviations
% 
%OPTIONAL INPUT
% orig 	    Indicator whether the original code or COBRA adjusted code 
%           should be used. If original code is requested, CPLEX needs 
%           to be installed (default 0)
%
%OUTPUT
% V         optimal steady state flux vector
%
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Ronan Fleming      02/12/14 solveCobraLP compatible
% Maria Pires Pacheco  27/01/15 Added a switch to select between COBRA code and the original code

if nargin < 3
   orig = 0;
end

[m,n] = size(model.S);

% objective
f = zeros(1,n);
f(J) = -1;

% equalities
Aeq = model.S;
beq = zeros(m,1);

% bounds
lb = model.lb;
ub = model.ub;

%
% Original Code From FastCore using CPLEX directly
if orig
   options = cplexoptimset('cplex');
   %options = cplexoptimset(options,'diagnostics','off');
   options.output.clonelog=0;
   options.workdir='~/tmp';
   x = cplexlp(f,[],[],Aeq,beq,lb,ub,options);
   if exist('clone1.log','file')
       delete('clone1.log')
   end
else
   %Setup the COBRA problem
   LPproblem.A=Aeq;
   LPproblem.b=beq;
   LPproblem.lb=lb;
   LPproblem.ub=ub;
   LPproblem.c=f;
   LPproblem.osense=1;%minimise
   LPproblem.csense(1:size(LPproblem.A,1))='E';
   solution = solveCobraLP(LPproblem);
   x=solution.full;
end
V = x;
