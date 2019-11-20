function z = implicitMidPoint(z, ham, opts)
% Perform the implicit mid point method
% This is 2-nd order symplectic method
% 
% options:
%  implicitIter - number of fix point iteration in the implicit step (default:1)

default.implicitIter = 1;
opts = setDefault(opts,default);

total_h = 0;
dz = ham.f(z);
while total_h < 0.9*opts.trajLength
    ham.GenerateJL();
    h = min([   opts.maxRelativeStepSize * ham.StepSize(z, dz), ...
                opts.maxStepSize, ...
                opts.trajLength - total_h]);
    
    for i = 1:opts.implicitIter
        dz = ham.f(z + 0.5 * h * dz);
    end
    
    z = z + h * dz;
    
    if h < opts.minStepSize
        z = NaN; return;
    end
    
    total_h = total_h + h;
end
end