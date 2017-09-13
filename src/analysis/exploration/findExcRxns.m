function [selExc, selUpt] = findExcRxns(model, inclObjFlag, irrevFlag)
% Finds exchange and uptake `rxns`
%
% USAGE:
%
%    [selExc, selUpt] = findExcRxns(model, inclObjFlag, irrevFlag)
%
% INPUT:
%    model:          COBRA model structure
%
% OPTIONAL INPUTS:
%    inclObjFlag:    Include objective `rxns` in the exchange rxn set (1) or not (0)
%                    (Default = false)
%    irrevFlag:      Model is in irreversible format (1) or not
%                    (Default = false)
%
% OUTPUTS:
%    selExc:         Boolean vector indicating whether each reaction in
%                    model is exchange or not
%    selUpt:         Boolean vector indicating whether each reaction in
%                    model is nutrient uptake or not
%
% NOTE:
%
%    Exchange reactions only have one non-zero (+1 / -1) element in the
%    corresponding column of the stoichiometric matrix. Uptake reactions are
%    exchange reactions are exchange reactions with negative lower bounds.
%
% .. Author: - Markus Herrgard 10/14/05

if (nargin < 2)
    inclObjFlag = false;
end
if (nargin < 3)
    irrevFlag = false;
end

exp = full((sum(model.S ~= 0) == 1) & (sum(model.S < 0) == 1))';
upt = full((sum(model.S ~= 0) == 1) & (sum(model.S > 0) == 1))';

selExc = exp | upt;
%Default lb is 0, default ub is 1000;
if ~isfield(model,'lb')    
    model.lb = zeros(size(model.S,2),1);
end

if ~isfield(model,'ub')
    model.ub = 1000* ones(size(model.S,2),1);
end

selUpt = (exp & model.lb < 0) | (upt & model.ub > 0);

end
