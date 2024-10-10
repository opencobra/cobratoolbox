%BIG = 1000;
BIG = 1024;
printLevel=1;

LPproblem.A = [ -1;-10000;1;1];
LPproblem.b = zeros(4,1);
LPproblem.c = 0;
LPproblem.lb = -inf;
LPproblem.ub =  inf;
LPproblem.csense = 'E';

LPproblem_lifted = reformulate(LPproblem, BIG, printLevel);

format rational
disp(full(LPproblem_lifted.A))

% if 1
%     stp = 2^mode(ceil(log2(lrgnums)./dum));
% else
%     stp = mode(nthroot(lrgnums,dum+1));
% end
% Transforming 1 reactions with large coefficients with sequences of
% reactions with small coefficients. This may take a few minutes.
% Transforming 0 badly-scaled coupling constraints with sequences of
% well-scaled coupling constraints. This may take a few minutes.
%       -1              0       
%        0         -16384       
%        1              0       
%        1              0       
%     -625/1024         1  

LPproblem.A = [ 1,  -10000];
LPproblem.b = 0;
LPproblem.c = [0;0];
LPproblem.lb = -inf(2,1);
LPproblem.ub =  inf(2,1);
LPproblem.csense = 'L';

LPproblem_lifted = reformulate(LPproblem, BIG, printLevel);

format rational
disp(full(LPproblem_lifted.A))

% if 1
%     stp = 2^mode(ceil(log2(lrgnums)./dum));
% else
%     stp = mode(nthroot(lrgnums,dum+1));
% end

% Transforming 0 reactions with large coefficients with sequences of
% reactions with small coefficients. This may take a few minutes.
% Transforming 1 badly-scaled coupling constraints with sequences of
% well-scaled coupling constraints. This may take a few minutes.
%        1              0         -16384       
%        0           -625/1024         1       



% if 0
%     stp = 2^mode(ceil(log2(lrgnums)./dum));
% else
%     stp = mode(nthroot(lrgnums,dum+1));
% end
% Transforming 1 reactions with large coefficients with sequences of
% reactions with small coefficients. This may take a few minutes.
% Transforming 0 badly-scaled coupling constraints with sequences of
% well-scaled coupling constraints. This may take a few minutes.
%       -1              0       
%        0           -100       
%        1              0       
%        1              0       
%     -100              1       
% 
% Transforming 0 reactions with large coefficients with sequences of
% reactions with small coefficients. This may take a few minutes.
% Transforming 1 badly-scaled coupling constraints with sequences of
% well-scaled coupling constraints. This may take a few minutes.
%        1              0           -100       
%        0           -100              1       


%revert to normal format
format short