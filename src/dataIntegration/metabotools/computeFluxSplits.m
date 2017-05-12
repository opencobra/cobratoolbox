function [P,C,vP,vC] = computeFluxSplits(model,mets,V)
% Compute relative contributions of fluxes (`V`) to the net production (`P`)
% and consumption (`C`) of a set of metabolites (`mets`)
%
% USAGE:
%
%    [P, C, vP, vC] = computeFluxSplits(model, mets, V);
%
% INPUTS:
%    model:     a COBRA model structure with required fields
%
%               * .S:        the `m` x `n` stoichiometric matrix
%               * .mets:     an `m` x `1` cell array of metabolite identifiers
%    mets:      a list of metabolite identifiers from model.mets
%    V:         an `n` x `k` matrix of `k` flux distributions
%
% OUTPUTS:
%    P:     an `n` x `k` matrix of relative contributions to the production of mets
%    C:     an `n` x `k` matrix of relative contributions to the consumption of mets
%    vP:    an `n` x `k` matrix of net producing fluxes
%    vC:    an `n` x `k` matrix of net consuming fluxes
%
% .. Author: - Hulda S. Haraldsdottir, December 2, 2016

s = sum([model.S(ismember(model.mets,mets),:); sparse(1,size(model.S,2))],1)'; % net stoichiometry. Zero if model.mets does not contain mets.
W = diag(s)*V; % stoichiometrically weighted flux
vP = max(W,0); % net production
vC = -min(W,0); % net consumption
P = vP*diag(1./sum(vP)); % relative production
C = vC*diag(1./sum(vC)); % relative consumption

