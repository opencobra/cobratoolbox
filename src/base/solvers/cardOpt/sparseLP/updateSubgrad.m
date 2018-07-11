function x_bar = updateSubgrad(x,theta,p,epsilonP,alpha,approximation)
% Compute x_bar, which is the subgradient of the second DC component
% H.A.LeThietal./EuropeanJournalofOperationalResearch000(2014)
% Table 2, r_cap
% 
% x_bar = sparseLP_subgradient(x,theta,p,epsilonP,alpha,approximation);
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

n = length(x);

switch approximation
    case 'cappedL1'
        x(abs(x) < 1/theta) = 0;
        x_bar = sign(x)*theta;
    
    case 'exp'
        x_bar = theta*sign(x).*(1 - exp(-sign(x)*theta));
        
    case 'log'
        x_bar  = theta*theta*sign(x).*abs(x) ./ (log(1+theta) + (1 +theta*abs(x)));
        
    case 'SCAD'
        one_over_theta = 1/theta;
        alpha_over_theta = alpha/theta;
        
        x_bar  = zeros(n,1);
        for i=1:n
            if (abs(x(i)) > one_over_theta) && (abs(x(i)) < alpha_over_theta)
                x_bar(i) = sign(x(i))*2*theta*(theta*abs(x(i))-1) / (alpha*alpha-1);
            end
            if abs(x(i)) >= alpha_over_theta
                x_bar(i) = sign(x(i))*2*theta / (alpha+1);
            end
        end
        
    case 'lp-'
        x_bar  = -p*theta*sign(x) .* (1 - power((1+theta*abs(x)),p-1));
        
    case 'lp+'
        x_bar  = sign(x)/p .* (power(epsilonP,1/(p-1))*ones(n,1) - power(abs(x)+epsilonP,1/(p-1)));
        
    otherwise
        error('Approximation is not valid');
end