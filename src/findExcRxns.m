function [selExc,selUpt] = findExcRxns(model,inclObjFlag,irrevFlag)
%findExcRxns Find exchange and uptake rxns
%
% [selExc,selUpt] = findExcRxns(model,inclObjFlag,irrevFlag)
%
%INPUT
% model             COBRA model structure
%
%OPTIONAL INPUTS
% inclObjFlag       Include objective rxns in the exchange rxn set (1) or not (0)
%                   (Default = false)
% irrevFlag         Model is in irreversible format (1) or not
%                   (Default = false)
%
%OUTPUTS
% selExc            Boolean vector indicating whether each reaction in
%                   model is exchange or not 
% selUpt            Boolean vector indicating whether each reaction in
%                   model is nutrient uptake or not
%
% Exchange reactions only have one non-zero (+1/-1) element in the 
% corresponding column of the stoichiometric matrix. Uptake reactions are 
% exchange reactions are exchange reactions with negative lower bounds.
%
% 10/14/05 Markus Herrgard

if (nargin < 2)
    inclObjFlag = false;
end
if (nargin < 3)
    irrevFlag = false;
end

if (~irrevFlag)
    % Find exchange rxns
    selExc = full((sum(model.S==-1,1) ==1) & (sum(model.S~=0) == 1))' | full((sum(model.S==1,1) ==1) & (sum(model.S~=0) == 1))';

    if (isfield(model,'c'))
        % Remove obj rxns
        if (~inclObjFlag)
            selExc(model.c ~= 0) = false;
        else
            selExc(model.c ~= 0) = true;
        end
    end

    if (isfield(model,'lb'))
        % Find uptake rxns
        selUpt = full(model.lb < 0 & selExc);
    else
        selUpt = [];
    end
    
else
    
    % Find exchange rxns
    selExc = full((sum(abs(model.S)==1,1) ==1) & (sum(model.S~=0) == 1))';

    if (isfield(model,'c'))
    % Remove obj rxns
    if (~inclObjFlag)
        selExc(model.c ~= 0) = false;
    else
        selExc(model.c ~= 0) = true;
    end
    end

    % Find uptake rxns
    selUpt = full((sum(model.S==1,1) ==1) & (sum(model.S~=0) == 1))';

end
    