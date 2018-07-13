function c = updateObj(x,theta,pNeg,pPos,epsilonP,alpha,approximation)
% Update the linear objective - variables (x,t)
%
% c = updateObj(x,theta,pNeg,pPos,epsilonP,alpha,approximation);
% 
% INPUTS:
%   x:              current solution vector
%   theta, pNeg, pPos, epsilonP, alpha:
%                   parameters of the approximations
%   approximation:  appoximation type of zero-norm. Available approximations:
%
%                        * 'cappedL1' : Capped-L1 norm
%                        * 'exp'      : Exponential function
%                        * 'log'      : Logarithmic function
%                        * 'SCAD'     : SCAD function
%                        * 'lp-'      : `L_p` norm with `p < 0`
%                        * 'lp+'      : `L_p` norm with `0 < p < 1`
%                        * 'l1'       : L1 norm
% 
% OUTPUT:
%   c:    New objective function
%
% % .. Author: - Hoai Minh Le,	20/10/2015
%              Ronan Fleming,    2017

n = length(x);

switch approximation
    case 'cappedL1'
        % Compute x_bar, which is the subgradient of the second DC component
        % H.A.LeThietal./EuropeanJournalofOperationalResearch000(2014)
        % Table 2, r_cap
        x(abs(x) < 1/theta) = 0;
        x_bar = sign(x)*theta;
        c = [-x_bar;theta*ones(n,1)];
        
    case 'exp'
        x_bar = theta*sign(x).*(1 - exp(-abs(x)*theta));
        c = [-x_bar;theta*ones(n,1)];
        
    case 'log'
        x_bar  = theta*theta*sign(x).*abs(x) ./ (log(1+theta) * (1 +theta*abs(x)));
        c = [-x_bar;(theta/log(1+theta))*ones(n,1)];
        
    case 'SCAD'
        one_over_theta = 1/theta;
        alpha_over_theta = alpha/theta;
        
        x_bar  = zeros(n,1);
        for i=1:n
            if (abs(x(i)) > one_over_theta) && (abs(x(i)) < alpha_over_theta)
                x_bar(i) = sign(x(i))*2*theta*(theta*abs(x(i))+1) / (alpha*alpha-1);
            end
            if abs(x(i)) >= alpha_over_theta
                x_bar(i) = sign(x(i))*2*theta / (alpha+1);
            end
        end
        
        c = [-x_bar;(2*theta/(alpha+1))*ones(n,1)];
        
    case 'lp-'
        x_bar  = -pNeg*theta*sign(x) .* (1 - power((1+theta*abs(x)),pNeg-1));
        c = [-x_bar;(-pNeg*theta)*ones(n,1)];
        
    case 'lp+'
        x_bar  = sign(x)/pPos .* (power(epsilonP,1/(pPos-1))*ones(n,1) - power(abs(x)+epsilonP,1/(pPos-1)));
        c = [-x_bar;(power(epsilonP,1/(pPos-1))/pPos)*ones(n,1)];
        
    case 'l1'
        c = [zeros(n,1); ones(n,1)];
        
    otherwise
        error('Approximation is not valid');
end