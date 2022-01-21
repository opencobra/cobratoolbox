function o = sample(plan, N)
% o = sample(plan, N)
%
%Input:
% plan - the sampling plan output by prepare.
% N - number of samples/steps
%
%Output:
% o - a structure continaing the following properties:
%   samples - a dim x N vector containing all the samples
%   samplesFullDim - a vector containing all the samples in the basis found
%   by the polytope class

%% Set default options
default.display = 0;
default.trajLength = 2;
default.minStepSize = 1e-4;
default.maxStepSize = 0.1;
default.maxRelativeStepSize = 0.2;
default.method = @implicitMidPoint;
opts = setDefault(plan.opts,default); % add default if not specified

%% Sample
o = struct;
o.samples = zeros(plan.ham.n,0);
x = plan.initial;
ham = plan.ham;
for i = 1:N
    if opts.display, fprintf('Iter %i\n', i); end
    
    for j = 1:3
        try
            z = ham.Generate(x);
            z = opts.method(z, ham, opts);
        catch
            z = NaN;
        end
        if ~isscalar(z), break; end
    end
    if isscalar(z), error('sample:ODEfailed', 'ODE solver failed'); end
    x = split2(z);
    
    % store the sample every few iterations
    if i > size(o.samples, 2)
        o.samples = [o.samples zeros(size(o.samples))];
    end
    o.samples(:,i) = x;
end
o.samples = o.samples(:,1:i);
o.samplesFullDim = o.samples;
o.samples = plan.domain.T * o.samplesFullDim + plan.domain.y;