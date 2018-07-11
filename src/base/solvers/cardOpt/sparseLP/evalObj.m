function obj = evalObj(x,theta,pNeg,pPos,epsilonP,alpha,approximation)
% Computes the value of the sparseLP objective function
%
% obj = sparseLP_obj(x,theta,pNeg,pPos,epsilonP,alpha,approximation);
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

n = length(x);

switch approximation
    case 'cappedL1'
        obj = ones(n,1)'*min(ones(n,1),theta*abs(x));
        
    case 'exp'
        obj = ones(n,1)'*((ones(n,1) - exp(-theta*abs(x))));
        
    case 'log'
        obj = ones(n,1)'*(log(1+theta*abs(x))/log(1+theta));
        
    case 'SCAD'
        one_over_theta = 1/theta;
        alpha_over_theta = alpha/theta;
        obj = 0;
        
        for i=1:n
            if abs(x(i)) <= one_over_theta
                obj = obj + 2*theta*abs(x(i)) / (alpha+1);
            end
            if (abs(x(i)) > one_over_theta) && (abs(x(i)) < alpha_over_theta)
                obj = obj + (-theta*theta*x(i)*x(i)+2*alpha*theta*abs(x(i))-1) / (alpha*alpha-1);
            end
            if abs(x(i)) >= alpha_over_theta
                obj = obj + 1;
            end
        end
        
    case 'lp-'
        obj = ones(n,1)'*(1 - power((1+theta*abs(x)),pNeg));
        
    case 'lp+'
        obj = ones(n,1)'*power(abs(x)+epsilonP*ones(n,1),1/pPos);
        
    case 'l1'
        obj = ones(n,1)'*abs(x);
        
    otherwise
        error('Approximation is not valid');
end