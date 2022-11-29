function [model] = integrate_cVector_into_model(model)
% sintegrate_cVector_into_model incorporates the c vector directly into the
% model as the reaction 'obj_fun_rxn'.

% USAGE:
%
%    [model] = integrate_cVector_into_model(model)
%
% INPUTS:
%   model:  COBRA model structure with minimal fields:

% OUTPUT:
%   model:   Augmented COBRA model
%
%
% .. Authors: - Bronson R. Weston   2022

model=addMetabolite(model, 'obj_fun_met');
model.S(end,:)=model.c;
model = addMultipleReactions(model, {'obj_fun_rxn'}, {'obj_fun_met'}, [-1], 'lb', [-1e7], 'ub', [1e7]);

model.c=zeros(length(model.c),1);
model.c(end)=1;

end

