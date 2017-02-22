function [output] = generateRandomSample(model, n)

if (nargin < 1)
    disp 'function [output] = generateRandomSample(model, n)';
    return;
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

