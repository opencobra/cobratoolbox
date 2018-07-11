function c = updateObj(x_bar,theta,p,epsilonP,alpha,approximation)
% Change the objective - variables (x,t)
% 
% c = sparseLP_updateObj(x_bar,theta,p,epsilonP,alpha,approximation);
% 
% % .. Author: - Hoai Minh Le,	20/10/2015
%              Ronan Fleming,    2017

if ~exist('approximation','var') || isempty(approximation)
    approximation = 'cappedL1';
end
if ~exist('theta','var') || isempty(theta)
    theta = 0.5;
end
if ~exist('p','var') || isempty(p)
    p = -1;
    if strcmp(approximation,'lp+')
        p = 0.5;
    end
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
        c = [-x_bar;(-p*theta)*ones(n,1)];
        
    case 'lp+'
        c = [-x_bar;(power(epsilonP,1/(p-1))/p)*ones(n,1)];
        
    otherwise
        error('Approximation is not valid');
end