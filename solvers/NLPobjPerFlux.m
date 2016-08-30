function value = NLPobjPerFlux(fluxVector,Prob)
%NLPobjPerFlux Calculates the value of the objective v_obj/sum(v.^2) based on
%a flux distribution
%  
%  value = NLPobjPerFlux(fluxVector,Prob)
%
% This function is meant to be used with NLP solvers
%
%INPUTS
% fluxVector    Flux vector
% Prob          NLP problem structure
%
%OUTPUT
% value         Objective flux / v.^2
%
% Markus Herrgard 12/7/07
%
% c wasn't defined as written so added Prob as input to define c from the
% model by Daniel Zielinski 3/19/10

model = Prob.user.model;

c = model.c == 1;

value = -sum(c.*fluxVector)/sum(fluxVector.^2);
