function [P,C,vP,vC,s] = computeFluxSplits(model,mets,V, coeffSign)
% Compute relative contributions of fluxes (`V`) to the net production (`P`)
% and consumption (`C`) of a set of metabolites (`mets`)
%
% USAGE:
%
%    [P, C, vP, vC, s] = computeFluxSplits(model, mets, V, 0);
%
% INPUTS:
%    model:     a COBRA model structure with required fields
%
%               * .S:        the `m` x `n` stoichiometric matrix
%               * .mets:     an `m` x `1` cell array of metabolite identifiers
%    mets:      a list of metabolite identifiers from model.mets
%    V:         an `n` x `k` matrix of `k` flux distributions
%
% OPTIONAL INPUT:
%    coeffSign: only use the sign of the stoichiometric coefficient
%               (i.e. +1 or -1, Default = false)
%
% OUTPUTS:
%    P:     an `n` x `k` matrix of relative contributions to the production of mets
%    C:     an `n` x `k` matrix of relative contributions to the consumption of mets
%    vP:    an `n` x `k` matrix of net producing fluxes
%    vC:    an `n` x `k` matrix of net consuming fluxes
%    s:     net stoichiometry of reactions containing metabolites 
%
% Example: [P,C,vP,vC,s] = computeFluxSplits(model,mets,V,1);
%
% .. Author: - Hulda S. Haraldsdottir, December 2, 2016
%            - Modified by Diana El Assal 22/7/2017

if nargin <4;
    coeffSign = false; %default
end

if coeffSign
    s = sign(sum([model.S(ismember(model.mets,mets),:); sparse(1,size(model.S,2))],1))';
else
    s = sum([model.S(ismember(model.mets,mets),:); sparse(1,size(model.S,2))],1)'; % net stoichiometry. Zero if model.mets does not contain mets.
end

W = diag(s)*V; % stoichiometrically weighted flux
vP = max(W,0); % net production
vC = -min(W,0); % net consumption
P = vP*diag(1./sum(vP)); % relative production
C = vC*diag(1./sum(vC)); % relative consumption
