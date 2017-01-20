function solution = leakTest(model,params,printLevel)
% Solve the problem
% min   lambda*||v||_0 - delta*||s||_0
% s.t.  Sv + s = 0
%       l <= v <= u
%
% INPUT

% model                 (the following fields are required - others can be supplied)
%   S                   Stoichiometric matrix
%   lb                  Lower bounds
%   ub                  Upper bounds
%
% OUPUT
% solution          Structure containing the following fields
%       v                   n x 1 vector 
%       s                   m x 1 vector
%       stat                status
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
%                           -1=  Invalid input
% Hoai Minh Le	08/03/2016
%

% if ~exist('epsilon','var')
%     epsilon = 1e-6;
% end


[S,lb,ub] = deal(model.S,model.lb,model.ub);
[m,n]=size(S);

%Define the optimisation problem
cardPrb.p       = n;
cardPrb.q       = m;
cardPrb.r       = 0;
cardPrb.c       = zeros(cardPrb.p+cardPrb.q+cardPrb.r,1);
cardPrb.lambda  = 1;
cardPrb.delta   = 1;
cardPrb.A       = [S speye(m)];
cardPrb.b       = zeros(m,1);
cardPrb.csense  = repmat('E',m, 1);
cardPrb.lb      = [lb;-inf*ones(m,1)];
cardPrb.ub      = [ub;inf*ones(m,1)];

%Call the cardinality optimisation sovler
solutionCard = optimizeCardinality(cardPrb);

if solutionCard.stat == 1
    solution.stat   = 1;
    solution.v      = solutionCard.x;
    solution.s      = solutionCard.y;
    disp(strcat('||v||_0 = ',num2str(sum(abs(solution.v)>eps))));
    disp(strcat('||s||_0 = ',num2str(sum(abs(solution.s)>eps))));
    
    SConsistentRxnBool =~(abs(solution.v)>params.epsilon);
    SConsistentMetBool =(sum(model.S(:,SConsistentRxnBool)~=0,2)~=0);
    if printLevel>0
        [nMet,nRxn]=size(model.S);
        if printLevel>0
            fprintf('%u\t%s\n',nMet,' mets.')
            fprintf('%u\t%s\n',nRxn,' rxns.')
        end
        fprintf('%u\t%s\n',nnz(SConsistentMetBool),' stoich consistent mets, after leak test.')
        fprintf('%u\t%s\n',nnz(SConsistentRxnBool),' stoich consistent rxns, after leak test.')
    end
    
else
    solution.stat   = solutionCard.stat;
    solution.v      = [];
    solution.s      = [];
end



end