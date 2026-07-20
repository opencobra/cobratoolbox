function [output] = generateRandomSample(model, n)
% Draws a near-uniform random sample of flux vectors from the solution space
% of a model using the general-purpose sampler, warming up from interior
% points until the mixed fraction is small enough
%
% USAGE:
%
%    [output] = generateRandomSample(model, n)
%
% INPUTS:
%    model:     model structure, with fields:
%
%                 * .S - `m x n` stoichiometric matrix
%                 * .lb - `n x 1` lower flux bounds
%                 * .ub - `n x 1` upper flux bounds
%    n:         number of warm-up points to generate, default = 5000
%
% OUTPUT:
%    output:    structure with fields:
%
%                 * .point - array of sampled flux points (one column per sample)
%                 * .mf - final mixed fraction reported by the sampler

if (nargin < 1)
    error 'function [output] = generateRandomSample(model, n)';
end
if (nargin < 2)
    n = 5000;
end

m.A = model.S;
m.lb = model.lb;
m.ub = model.ub;
% sample until we have mixedfrac of .6 or less
m = gpSampler(m,10,[],0,0);
m.warmupPts = goodInitialPoint(model, n);
mf = 1;
while (mf > .52)
    [m,mf] = gpSampler(m,[],[],200,300);
    %mf
end
m.warmupPts = m.points;
m = rmfield(m, 'points');
mf = 1;
while (mf > .52)
    [m,mf] = gpSampler(m,[],[],200,300);
    %mf
end
m.warmupPts = m.points;
m = rmfield(m, 'points');
mf = 1;
while (mf > .52)
    [m,mf] = gpSampler(m,[],[],200,300);
    %mf
end

output.point = m.points;    
output.mf = mf; 

