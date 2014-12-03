function [out] = score_ridge(mdv, hilo, lambda, crossval)
%input:  mdv  structure as usual
%        hilo  (0's and 1's)  Ideally there will be a similar # of each.
%        lambda = ridge parameter (optional)
%        crossval:  whether to do cross validation.  This severely slows
%        down the computation  (optional - default is no).

if nargin < 4
    crossval = 0;  % don't cross validate by default
end
if nargin < 3
    lambda = .01;
end

hilo(hilo ==0) = -1; % make 0's into ones.
[nvars, npoints] = size(mdv);
    
if crossval == 0
    ybar = mean(hilo);
    b = inv(mdv*mdv' + lambda*eye(nvars))*mdv*hilo;

    yhat = mdv'*b+ybar;
    out = sum(sign(yhat) == sign(hilo))/npoints;
else
    results = zeros(npoints,1);
    for i = 1:npoints
        hilot = hilo([1:i-1,i+1:npoints]);
        mdvt = mdv(:,[1:i-1,i+1:npoints]);
        
        ybart = mean(hilot);
        b = inv(mdvt*mdvt' + lambda*eye(nvars))*mdvt*hilot;
        
        yhat = mdv(:,i)'*b+ybart;
        results(i)  = sign(yhat) == sign(hilo(i));
    end
    out = sum(results)/npoints;
end    