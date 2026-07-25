function [model] = fixIrr(model)
% Convert irreversible backward reactions into irreversible forward reactions
%
% USAGE:
%
%    [model] = fixIrr(model)
%
% INPUTS:
%    model:             COBRA model structure with the following fields:
%
%                         * .S - `m x n` stoichiometric matrix
%                         * .lb - `n x 1` lower flux bounds
%                         * .ub - `n x 1` upper flux bounds
%                         * .rxns - `n x 1` cell array of reaction abbreviations
%
% OUTPUTS:
%    model:             model with corrected reversibilities, with fields:
%
%                         * .rev - `n x 1` reaction reversibility indicator (1 reversible, 0 irreversible)
%                         * .lb - updated `n x 1` lower flux bounds
%                         * .ub - updated `n x 1` upper flux bounds
%                         * .S - stoichiometric matrix with backward reactions flipped to forward
%
% .. Authors:
%       - Maria Pires Pacheco, Thomas Sauter, 2016, University of Luxembourg
%       - Maria Pires Pacheco, Thomas Sauter, 2022, adaptation of the code to the Cobra toolbox


% Initialize all reactions as irreversible (rev = 0 by default)
model.rev = zeros(numel(model.rxns),1);

% Mark reactions as reversible if they allow flux in both directions (lb < 0 and ub > 0)
model.rev(model.lb < 0 & model.ub > 0) = 1;

% Identify strictly irreversible reactions (only positive or only negative flux allowed)
irr = (model.lb >= 0 & model.ub > 0 | model.ub <= 0 & model.lb < 0);

% Ensure these reactions are labeled as irreversible
model.rev(irr) = 0;

% Identify reactions that only allow negative flux ("fake irreversible")
fakeIrr = model.ub <= 0 & model.lb < 0;

% Flip the sign of these reactions in the stoichiometric matrix
model.S(:, fakeIrr) = -model.S(:, fakeIrr);

% Convert their bounds to positive-only flux (standard irreversible format)
model.ub(fakeIrr) = -model.lb(fakeIrr);
model.lb(fakeIrr) = zeros(sum(fakeIrr), 1);

end