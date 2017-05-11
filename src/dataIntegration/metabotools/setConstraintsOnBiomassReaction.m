function [modelBM] = setConstraintsOnBiomassReaction(model,of,dT,tolerance)
% This function sets constrains biomass objective function in the model accoring to the condition specific doubling time.
%
% USAGE:
%
%    [modelBM] = setConstraintsOnBiomassReaction(model, of, dT, tolerance)
%
% INPUTS:
%    model:           Metabolic model (e.g., Recon)
%    of:              Objective funtion, e.g., `biomass_reaction`
%    dT:              Doubling time
%    tolerance:       Upper and lower limit of the growth rate are adjusted according to this tolerance value, e.g., 20 (%).
%
% OUTPUTS:
%    modelBM:         Model constrained with condition-specific growth rates
%
% .. Author: - Maike K. Aurich 13/02/15

ub = log(2)/dT*(1+(tolerance/100));
lb = log(2)/dT*(1-(tolerance/100));

model = changeRxnBounds(model,of,lb,'l');
modelBM = changeRxnBounds(model,of,ub,'u');

end
