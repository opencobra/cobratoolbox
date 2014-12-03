% VALIDATETYPE
%
%   NUM=VALIDATETYPE(TYPE)
%  
%   Odefy-internal function

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function num=ValidateType(type)

if ~ischar(type)
    error('ODE type must be a string');
else
    if strcmp(type,'hillcube')
        num=2;
    elseif strcmp(type,'hillcubenorm')
        num=3;
    elseif strcmp(type,'boolcube')
        num=1;
    elseif strcmp(type,'boolsync')
        num=4;
    elseif strcmp(type,'boolasync')
        num=5;
    elseif strcmp(type,'boolrandom')
        num=6;
    else        
        error('Invalid ODE type: ''%s''', type);
    end
end

