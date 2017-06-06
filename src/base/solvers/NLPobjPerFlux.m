function value = NLPobjPerFlux(fluxVector, Prob)
% Calculates the value of the objective - `(Prob.osense * Prob.user.model.c)/sum(v.^2)` based on
% a flux distribution
% This function is meant to be used with NLP solvers
%
% USAGE:
%
%    value = NLPobjPerFlux(fluxVector, Prob)
%
% INPUTS:
%    fluxVector:    Flux vector
%    Prob:          NLP problem structure
%
% OUTPUT:
%    value:         -Objective `flux / sum(v.^2)`
%
% .. Author:
%       - Markus Herrgard 12/7/07, c wasn't defined as written so added Prob as input to define c from the model
%       - model by Daniel Zielinski 3/19/10

c = Prob.user.model.c;

value = sum(c.*fluxVector)/sum(fluxVector.^2);
