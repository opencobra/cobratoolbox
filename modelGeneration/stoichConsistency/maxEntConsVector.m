function  [m,bool]=maxEntConsVector(SInt,printLevel)

%-----------------------------------------------------------------------
% pdco.m: Primal-Dual Barrier Method for Convex Objectives (28 Apr 2012)
%-----------------------------------------------------------------------
%        [x,y,z,inform,PDitns,CGitns,time] = ...
%   pdco(pdObj,pdMat,b,bl,bu,d1,d2,options,x0,y0,z0,xsize,zsize);
%
% solves optimization problems of the form
%
%    minimize    phi(x) + 1/2 norm(D1*x)^2 + 1/2 norm(r)^2
%      x,r
%    subject to  A*x + D2*r = b,   bl <= x <= bu,   r unconstrained,

[mlt,nlt]=size(SInt);

d1=1e-4;
d2=1;

%pdco parameters
options = pdcoSet;
if 0
    options.FeaTol    = 1e-6; %6 March 2010 medium FeaTol
    options.OptTol    = 1e-6; %6 March 2010 medium OptTol
    options.MaxIter   = 200;
    options.Method    = 1;    % 1=Chol  2=QR (more reliable)
    options.mu0       = 0;  % 0 lets pdco decide.  1 or 10 assumes good scaling
    options.StepTol   = 0.9;
    options.StepSame  = 1;
    options.Print     = printLevel-1;
    options.wait      = 0;
end

x0=ones(mlt,1);
y0=ones(nlt,1);
z0=ones(mlt,1);
xsize=1;
zsize=1;

alpha=1e-6;

[x,y,z,inform,PDitns,CGitns,time] = ...
    pdco(@(x) pdcoObj(x,alpha),SInt',zeros(nlt,1),zeros(mlt,1),inf*ones(mlt,1),d1,d2,options,x0,y0,z0,xsize,zsize);


m=x;
%boolean indicating metabolites involved in the maximal consistent vector
bool=m>0;
end

function [obj,grad,Hess]=pdcoObj(x,alpha)
obj  = alpha*(x'*(log(x) -x));
grad = alpha*log(x);
Hess = alpha./x;
end
