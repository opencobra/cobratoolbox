function c = updateObj(x_bar,theta,pNeg,pPos,epsilonP,alpha,approximation)
% Change the objective - variables (x,t)
% 
% c = sparseLP_updateObj(x_bar,theta,pNeg,pPos,epsilonP,alpha,approximation);
% 
% % .. Author: - Hoai Minh Le,	20/10/2015
%              Ronan Fleming,    2017

if ~exist('approximation','var') || isempty(approximation)
    approximation = 'cappedL1';
end
if ~exist('theta','var') || isempty(theta)
    theta = 0.5;
end
if ~exist('pNeg','var') || isempty(pNeg)
    pNeg = -1;
end
if ~exist('pPos','var') || isempty(pPos)
    pPos = 0.5;
end
if ~exist('epsilonP','var') || isempty(epsilonP)
    epsilonP = 10e-2;
end
if ~exist('alpha','var') || isempty(alpha)
    alpha = 3;
end

n = length(x_bar);

switch approximation
    case 'cappedL1'
        c = [-x_bar;theta*ones(n,1)];
    
    case 'exp'
        c = [-x_bar;theta*ones(n,1)];
        
    case 'log'
        c = [-x_bar;(theta/log(1+theta))*ones(n,1)];
        
    case 'SCAD'
        c = [-x_bar;(2*theta/(alpha+1))*ones(n,1)];
        
    case 'lp-'
        c = [-x_bar;(-pNeg*theta)*ones(n,1)];
        
    case 'lp+'
        c = [-x_bar;(power(epsilonP,1/(pPos-1))/pPos)*ones(n,1)];
        
    otherwise
        error('Approximation is not valid');
end