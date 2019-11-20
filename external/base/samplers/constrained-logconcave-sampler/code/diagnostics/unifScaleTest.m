function p_value = unifScaleTest(o, plan, opts)
%p_value = unifScaleTest(x, plan, opts)
%compute the p-value for the radial distribution of x
%
%Assumption: x follows uniform distribution on the interior of some convex set.
%
%Input:
% x - the samples object outputted by sample
% plan - outputted by prepare.
% opts - a structure for options with the following properties
%  toThin - extract independent samples from x (default: true)
%  toPlot - plot the radial distribution (to 1/(dim-1)) power
%
%Output:
% p_value - the p value of whether the empirical radial distribution follows the 
%           distribution r^(dim-1). We use Anderson-Darling test here.

n = plan.ham.n;
x = o.samplesFullDim;

if ~exist('opts', 'var'), opts = struct; end
defaults.toThin = true;
defaults.toPlot = false;
opts = setDefault(opts, defaults);

if opts.toThin, x = thinSamples(x);end

if size(x,2) < 6
    error('unifScaleTest:size', 'Sample size must be at least 6.');
end

if sum(abs(plan.ham.grad(plan.initial))) ~= 0
    warning('unifScaleTest:nonzero_grad', 'The density of the distribution should be uniform, namely, df = 0.');
end


p = mean(x,2);
dim = n - size(plan.domain.A,1);
K = size(x,2);

unif_vals = zeros(K,1);
for i=1:K
    this_x = x(:,i);
    u = this_x-p;
    upper = computeBoundaryPoints(plan.domain,p,u);
    
    unif_vals(i) = norm(this_x - p) / norm(upper-p);
    assert(unif_vals(i)<=1);
    unif_vals(i) = unif_vals(i)^dim;
end

if opts.toPlot
    figure;
    cdfplot(unif_vals);
    hold on;
    plot(0:0.01:1, 0:0.01:1, '.')
end

try
    [~,p_value] = adtest(norminv(unif_vals));
catch
    p_value = 0;
end

end

function [upper] = computeBoundaryPoints(domain, x, u)
    ub_coeff = (domain.ub-x)./u;
    lb_coeff = (domain.lb-x)./u;
    coeffs = [lb_coeff; ub_coeff];
    min_g0 = min(coeffs(coeffs>0));
    upper = min_g0*u + x;
end