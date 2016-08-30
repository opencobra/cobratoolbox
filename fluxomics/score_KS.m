function [out] = score_KS(mdv, hilo, lambda)
%input:  mdv  structure as usual
%        hilo  (0's and 1's)  Ideally there will be a similar # of each.
%        lambda = weighting.  If the mean is less than lambda, the scores get weighted less.  (default = .02)

if nargin < 3
    lambda = .02;
end

[nvars, npoints] = size(mdv);
loset = mdv(:,hilo==0);
hiset = mdv(:,hilo==1);

weights = std(mdv,0,2);

scores = zeros(nvars, 1);
parfor i = 1:nvars
    
    [h, p] = kstest2(loset(i,:), hiset(i,:));
    scores(i) = max(log(p), -708); % log(realmin) to avoid scores of inf.
    
end

scores2 = scores .*(1-exp(-weights/lambda));
out = -sum(scores2);
