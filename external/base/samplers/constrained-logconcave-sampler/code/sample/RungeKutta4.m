function z = RungeKutta4(z, ham, opts)
% Perform the classical Runge–Kutta method
% This is 4-th order method, not symplectic.

opts = setDefault(opts,default);

total_h = 0;
dz = ham.f(z);
while total_h < 0.9*opts.trajLength
    ham.GenerateJL();
    h = min([   opts.maxRelativeStepSize * ham.StepSize(z, dz), ...
                opts.maxStepSize, ...
                opts.trajLength - total_h]);
    
    dz1 = ham.f(z);
    dz2 = ham.f(z + h/2 * dz1);
    dz3 = ham.f(z + h/2 * dz2);
    dz4 = ham.f(z + h * dz3);
    dz = (dz1 + 2 * dz2 + 2 * dz3 + dz4) / 6;
    z = z + h * dz;
    
    if h < opts.minStepSize, z = NaN; return; end
    total_h = total_h + h;
end
end
