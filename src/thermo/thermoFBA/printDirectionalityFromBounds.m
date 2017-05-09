function directionality=printDirectionalityFromBounds(model,lb,ub)
%prints the directionality for each reaction depending on the bounds for
%each reaction. Defaults to using model.lb &  model.ub if none provided
%
% INPUT
% model
%
% OPTIONAL INPUT
% lb        flux lower bounds
% ub        flux upper bounds
%
% OUTPUT
% directionality    n x 1 cell array of strings with directionality for
%                   each reaction
%
%Ronan M. T. Fleming

[nMet,nRxn]=size(model.S);

if ~exist('lb','var')
    lb=model.lb;
end
if ~exist('ub','var')
    ub=model.ub;
end

directionality=cell(nRxn,1);

for n=1:nRxn
    if lb(n)<0
        if ub(n)>0
            directionality{n,1}='reversible';
        else
            directionality{n,1}='reverse';
        end
    else
        if ub(n)>0
            directionality{n,1}='forward only';
        else
            directionality{n,1}='closed';
        end
    end
end
            
            