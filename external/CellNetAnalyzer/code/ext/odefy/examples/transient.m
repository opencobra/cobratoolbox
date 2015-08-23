% Exported normalized hillcube ODE
% manually modified for a transient expression of species a
% check out cmdsim.m for the call of this function

% Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
% Free for non-commerical use, for more information: see LICENSE.txt
% http://cmb.helmholtz-muenchen.de/odefy
%
function ydot=transient(t,cvals,params)
cvals(cvals<0)=0;
cvals(cvals>1)=1;

% shortcuts
a=1;
b=2;
c=3;


% ODE
ydot = zeros(3,1);
ydot(a) = (t>=3&&t<=6) - cvals(a);
ydot(b) = (cvals(a)^params(2)/(cvals(a)^params(2)+params(3)^params(2))*(1+params(3)^params(2))-cvals(b)) / params(1);
ydot(c) = (cvals(a)^params(5)/(cvals(a)^params(5)+params(6)^params(5))*(1+params(6)^params(5))*(1-cvals(b)^params(7)/(cvals(b)^params(7)+params(8)^params(7))*(1+params(8)^params(7)))-cvals(c)) / params(4);
