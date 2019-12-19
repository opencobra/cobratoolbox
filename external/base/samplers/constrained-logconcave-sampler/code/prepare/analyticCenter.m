function [x, C, d, output] = analyticCenter(A, b, f, opts, x)
%[x, C, d, output] = analyticCenter(A, b, f, opts, x)
%compute the analytic center for the domain {Ax=b} intersect the domain of f
%
%Input:
% A - a m x n constraint matrix. The domain of the problem is given by Ax=b.
% b - a m x 1 constraint vector.
% f - a barrier class (Currently, we only have TwoSidedBarrier)
%     We assume f is a self concordant barrier function.
% opts - a structure for options with the following properties
%  display - whether we output the information at each iteration (default: false)
%  maxIter - maximum number of iterations (default: 300)
%  dualTol - stop when ||A' * lambda - gradf(x)||_2 < dualTol (default: 1e-12)
%  gaussianTerm - how much we add the identity into the hess f(x) to avoid numerical error (default: 1e-12)
%  regularizerStep - how much we multiply the identity we added into hess f(x) when there is a numerical problem (default: 10)
%  detectTightConstraints - detect tight constraints (default: true)
%  distanceTol - ||grad f_i(x)|| > 1/distanceTol && ||dx||_x >= velocityTol implies the coordinate i is tight. (default: 1e-6)
%  velocityTol - default: 1e-1.
%  distanceTol2 - ||grad f_i(x)|| > 1/distanceTol2 implies the coordinate i is tight. (default: 1e-9)
%
%Output:
% x - It outputs the minimizer of min f(x) subjects to {Ax=b}
% C - detected constraint matrix
%     If the domain ({Ax=b} intersect dom(f)) is not full dimensional in {Ax=b}
%     because of the dom(f), the algorithm will detect the collapsed dimension
%     and output the detected constraint C x = d
% d - detected constraint vector
% output - text output information at each iteration

%% set the default value
defaults.display = 0;

% termination conditions
defaults.maxIter = 300;
defaults.dualTol = 1e-12;

% linear system
defaults.gaussianTerm = 1e-12;
defaults.regularizerStep = 10;

% detecting tight constraints
% tight = (dist < distTol && vel < velTol) || (dist < distTol2)
defaults.detectTightConstraints = true;
defaults.distanceTol = 1e-6;
defaults.velocityTol = 1e-1;
defaults.distanceTol2 = 1e-9;

if exist('opts', 'var') == 0, opts = struct; end
opts = setDefault(opts, defaults);

%% prepare the printout
print_opts = [];
print_opts.properties = {};
if opts.display == 1
    print_opts.properties{end+1} = struct('var', 'iter', 'title', 'Iter', 'format', '5i');
    print_opts.properties{end+1} = struct('var', 't', 'title', 'Step Size', 'format', '13.2e');
    print_opts.properties{end+1} = struct('var', 'pri_err', 'title', 'Primal Error', 'format', '13.2e');
    print_opts.properties{end+1} = struct('var', 'dual_err', 'title', 'Dual Error', 'format', '13.2e');
    print_opts.properties{end+1} = struct('var', 'note', 'title', '', 'format', 's');
end
output = {};
printTable([], print_opts);

%% initial conditions
so = LinearSystemSolver(A);
if exist('x', 'var') == 0
    x = f.center;
end
lambda = zeros(size(A,1),1);
eta_org = f.extraHessian;
eta = opts.gaussianTerm * ones(size(x));
iter = 1; fullStep = 0;
pri_err = Inf; dual_err = Inf; pri_err_best = Inf;
pri_factor = 1; dual_factor = 1 + norm(b);
f.SetExtraHessian(eta_org);
A_fixed = A; b_fixed = b;
DisabledIdx = zeros(size(f.GradientNorm(x)));
A_changed = 0;

%% find the central path
while (iter < opts.maxIter)
    % update the matrix
    if (A_changed)
        [A_, b_] = f.Boundary(x);
        A = [A_(DisabledIdx,:); A_fixed]; b = [b_(DisabledIdx); b_fixed];
        so = LinearSystemSolver(A);
        lambda = [zeros(size(A,1)-numel(lambda),1);lambda];
        idx = f.RepVector(DisabledIdx) == 1;
        dHinv = diag(Hinv);
        eta(idx) = 1e16/min(dHinv(~idx));
    end
    
    % compute the residual
    f.SetExtraHessian(eta_org+eta);
    rx = A' * lambda - (f.Gradient(x) + opts.gaussianTerm * x);
    rs = b - A * x;
    
    % compute the step direction
    Hinv = f.HessianInv(x);
    so.Prepare(Hinv);
    dr = so.Solve([A * (Hinv * rx) rs]);
    dx1 = Hinv * (rx - A' * dr(:,1));
    dx2 = Hinv * (A' * dr(:,2));
    
    % compute the step size
    dx = dx1 + dx2;
    t_grad = min(f.StepSize(x, dx),1);
    dx = t_grad * dx1 + dx2;
    t_const = min(0.99*f.StepSize(x, dx),1);
    t_grad = t_grad * t_const;
    x = x + t_const * dx;
    lambda = lambda - dr(:,1);
    
    % compute the residual
    rx = A' * lambda - (f.Gradient(x) + opts.gaussianTerm * x);
    rs = b - A * x;
    pri_err_best = min(pri_err,pri_err_best); pri_err = norm(rx)/pri_factor;
    dual_err_last = dual_err; dual_err = norm(rs)/dual_factor;
    
    note = '';
    % check stagnation
    if ((dual_err > (1-0.9*t_const)*dual_err_last) && (pri_err > 0.5 * pri_err_best))
        % tight constraints condition:
        % ||grad(x)||_2 > 1/distanceTol, (x is close boundary)
        % ||v||_hess(x) > velocityTol. (v is large)
        if opts.detectTightConstraints
            dist = 1./f.GradientNorm(x);
            vec = sqrt(f.HessianNorm(x, dx1));
            idx = ((dist < opts.distanceTol) & (vec > opts.velocityTol)) | (dist < opts.distanceTol2);
        end
        
        if opts.detectTightConstraints && any(idx & ~DisabledIdx)
            note = sprintf('fixed %i barriers', sum(idx & ~DisabledIdx));
            DisabledIdx = DisabledIdx | idx;
            f.DisableVariables(DisabledIdx);
            fullStep = 0;
            A_changed = 1;
        else
            eta = eta * opts.regularizerStep;
            note = sprintf('set eta = %5.2e', min(eta));
        end
    end
    
    % printout
    o = struct('iter', iter, 't', t_grad, 'pri_err', pri_err, 'dual_err', dual_err, 'eta', min(eta), 'note', note);
    printTable(o, print_opts);
    output{end+1} = o;
    
    % stopping criteria 
    if ~f.Feasible(x)
        break;
    end
    
    if (t_grad == 1)
        fullStep = fullStep + 1;
        if (fullStep > log(dual_err/opts.dualTol))
            break;
        end
    else
        fullStep = 0;
    end
    iter = iter + 1;
end

if (A_changed)
    [A_, b_] = f.Boundary(x);
    C = A_(DisabledIdx,:);
    d = b_(DisabledIdx);
else
    C = zeros(0, size(A,2));
    d = zeros(0, 1);
end

f.SetExtraHessian(eta_org);