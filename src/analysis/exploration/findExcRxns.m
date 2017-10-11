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
%    irrevFlag:      Deprecated.
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

if ~exist('inclObjFlag','var')
    inclObjFlag = false;
end

modelRes = findSExRxnInd(model);
selExc = modelRes.SExRxnOneCoeffBool;

if inclObjFlag
    selExc(model.c~=0) = true;
else
    selExc(model.c~=0) = false;
end

%This ignores the actual directionality, but it is, what the description
%says... 
selUpt = selExc & model.lb < 0;

end
