function [model] = fixIrr(model)
% The function converts irreversible backwards reactions into irreversible forward reactions
%
% USAGE:
%
%   [model] = fixIrr(model)
%
% INPUTS:
%   model:             (the following fields are required - others can be supplied)
%                      * S  - `m x 1` Stoichiometric matrix
%                      * lb - `n x 1` Lower bounds
%                      * ub - `n x 1` Upper bounds
%                      * rxns   - `n x 1` cell array of reaction abbreviations
%
% OUTPUT:                 
%   model:             model with corrected reversibilties
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