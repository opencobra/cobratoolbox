function [out] = goodInitialPoint(model, n)
% generates 4*length(model.lb) random points
% takes linear combinations of them so that all points are in the interior.
if nargin < 2
    n = 1;
end
xs = zeros(length(model.lb), 4*length(model.lb));

for i = 1:length(model.lb)
    model.c = zeros(size(model.lb));
    model.c(i) = 1;
    t1 = optimizeCbModel(model);
    xs(:,2*i-1) = t1.x;
    model.c = -model.c;
    t1 = optimizeCbModel(model);
    xs(:,2*i) = t1.x;
    if mod(i, 100) == 0
        i
    end
end
for i = 1:length(model.lb)
    model.c = randn(size(model.lb));
    model.c(i) = 1;
    t1 = optimizeCbModel(model);
    xs(:,2*length(model.lb)+2*i-1) = t1.x;
    model.c = -model.c;
    t1 = optimizeCbModel(model);
    xs(:,2*length(model.lb) + 2*i) = t1.x;
    if mod(i, 100) == 0
        i+length(model.lb)
    end
end

out = zeros(length(model.lb), n);
for i = 1:n
    t2 = rand(4*length(model.lb),1);
    t2 = t2/sum(t2);
    out(:,i) = xs*t2;
end