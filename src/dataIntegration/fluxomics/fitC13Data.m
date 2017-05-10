function [vout, rout] = fitC13Data(v0,expdata,model, majorIterationLimit)
% v0 is input v.  It will automatically be converted to alpha by solving N*alpha = v;
% if v0 is a matrix then it is assumed to be a multiple start situation and
% vout will also have this size.
%
% expdata is either a data structure or a cell array of structures, in
% which case it is assumed that you wan to fit the sum of the scores.
% model - standard model structure
% majorIterationLimit (optional) - max number of iterations solver is allowed to take.
%  Default = 1000;

if nargin < 4
    majorIterationLimit = 1000;
end
diffInterval = 1e-5;         %gradient step size.
method = 1; % 2 = in terms of v.  % 1 in terms of alpha
printLevel = 3; %3 prints every iteration.  1 does a summary.  0 = silent.

if method == 1
    if ~isfield(model, 'N')
       model.N = null(full(model.S));
       display('model.N should be defined');
       pause;
    end

    x0 = model.N\v0; % back substitute

    % safety check:
    if (max(abs(model.S*v0))> 1e-6)
        display('v0 not quite in null space');
        pause;
    end
    if(max(abs(model.N*x0 - v0)) > 1e-6)
        max(abs(model.N*x0 - v0))
        display('null basis is weird');
        pause;
    end

    % set up problem
    nalpha = size(model.N, 2);
    x_L = -1000*ones(nalpha,1);
    x_U = 1000*ones(nalpha,1);
    [A, b_L, b_U] = defineLinearConstraints(model, method);
elseif method == 2
    x0 = v0; % back substitute
    [A, x_L, x_U] = defineLinearConstraints(model, method);
    b_L = zeros(size(A,1),1);
    b_U = zeros(size(A,1),1);
else
    display('error'); pause;
end

numpoints = size(x0,2);
vout = zeros(size(v0));
rout = cell(numpoints, 1);

for k = 1:numpoints
    x_0 = x0(:,k);
    NLPproblem.objFunction = 'errorComputation2';
    NLPproblem.gradFunction = 'errorComputation2_grad';
    NLPproblem.lb = x_L;
    NLPproblem.ub = x_U;
    NLPproblem.name = 'c13fitting';
    NLPproblem.x0 = x_0;
    NLPproblem.A = A;
    NLPproblem.b_L = b_L;
    NLPproblem.b_U = b_U;
    NLPproblem.user.expdata = expdata;
    NLPproblem.user.model = model;
    NLPproblem.user.useparfor = true;
    NLPproblem.user.diff_interval = diffInterval;
    NLPproblem.osense = 1;
    
    NLPproblem.PriLevOpt = 1;
    cnan = ( method == 2);

    NLPsolution = solveCobraNLP(NLPproblem, 'checkNaN', cnan, 'printLevel', printLevel, 'iterationLimit', majorIterationLimit, 'logFile', 'minimize_SNOPT.txt');

    if method == 1
        vout(:,k) = model.N*NLPsolution.full;
    else
        vout(:,k) = NLPsolution.full;
    end
    rout{k} = NLPsolution;
end
return
