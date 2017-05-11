function [model,samples] = convRevSamples(model,samples)
% Converts signs for reactions that are only running in
% reverse direction
%
% USAGE:
%
%    [model, samples] = convRevSamples(model, samples)
%
% INPUT:
%    model:      Constraint-based model
%
% OPTIONAL INPUT:
%    samples:    Sample set
%
% OUTPUTS:
%    model:      COBRA model structure with negative-direction fluxes reversed
%    samples:    Sample set with negative-direction fluxes reversed
%
% .. Author: - Markus Herrgard 8/22/06

for i = 1:length(model.rxns)
  rxnName = model.rxns{i};
  lastInd = regexp(rxnName,'_r$');
  if (~isempty(lastInd))
    model.rxns{i} = rxnName(1:(lastInd-1));
    model.lb(i) = -model.ub(i);
    model.ub(i) = -model.lb(i);
    model.S(:,i) = -model.S(:,i);
    if nargin > 1
        samples(i,:) = -samples(i,:);
    end
  end
end

if nargin < 2
    samples = [];
end
