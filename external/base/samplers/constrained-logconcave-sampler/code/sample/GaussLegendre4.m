function z = GaussLegendre4(z, ham, opts)
% Perform the collocation method based on Gauss Legendre with 2 points
% This is 4-th order symplectic method
% 
% options:
%  implicitIter - number of fix point iteration in the implicit step (default:2)

default.implicitIter = 2;
opts = setDefault(opts,default);

total_h = 0;
dz = ham.f(z);
while total_h < 0.9*opts.trajLength
    ham.GenerateJL();
    h = min([   opts.maxRelativeStepSize * ham.StepSize(z, dz), ...
                opts.maxStepSize, ...
                opts.trajLength - total_h]);
    
    dz1 = dz; dz2 = dz;
    for i = 1:opts.implicitIter
        dz1 = ham.f(z + h * (0.25 * dz1 + (1/4-sqrt(3)/6) * dz2));
        dz2 = ham.f(z + h * ((1/4+sqrt(3)/6) * dz1 + 1/4 * dz2));
    end
    
    z = z + h * (dz1+dz2)/2;
    
    if h < opts.minStepSize, z = NaN; return; end
    total_h = total_h + h;
end
end