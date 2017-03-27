%% Example NLP script: general usage of solveCobraNLP

% Created by: Joshua Lerman 03/30/2010

% This example script will solve the problem:

%   min x1+x2
%   s.t.
%   10 = x1*y1
%   20 = x2*y2
%   y1 + y2 = 5000
%   x1, x2, y1, y2 >= 0

%   order of the variables, [y1;y2;x1;x2]

changeCobraSolver('tomlab_snopt', 'NLP');

A = [1 1 0 0];  % linear constraints only
lb = [0; 0; 0; 0];  % all variables
ub = [100000; 100000; 100000; 100000];  % all variables

b_L = [5000];  % linear constraints only
b_U = [5000];  % linear constraints only

d_L = [10; 20];  % nonlinear constraints only
d_U = [10; 20];  % nonlinear constraints only

NLPsolution = solveCobraNLP(struct('lb', lb, 'ub', ub, 'A', A, 'b_L', b_L, 'b_U', b_U, ...
                                   'd', 'docomputation', 'd_L', d_L, 'd_U', d_U, ...
                                   'x0', [1; 1; 1; 1], ...  % the default starting point will lead to an infeasible solution due to the way the gradient is computed (numerically)
                                   'objFunction', 'doobjective', 'userParams', struct('useparfor', false, 'intTol', 1e-4)));


%% these should be placed in separate MATLAB files in the same working directory, but are put here for
% the sake of having a complete example in one test script...

% function [out] = docomputation(x)
% out(1) = x(1)*x(3);
% out(2) = x(2)*x(4);
% end

% function [out] = doobjective(x)
% out = x(3)+x(4);
% end
