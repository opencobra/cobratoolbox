function leakingMets = testLeakingMetabolites(model)
% Finds metabolites that can be produced when no metabolites enter the
% model (produced from nothing).
%
% USAGE:
%
%    leakingMets = testLeakingMetabolites(model)
%
% INPUTS:
%    model:             COBRA model structure with fields:
%
%                         * .lb - Reaction lower bounds
%                         * .rxns - Reaction identifiers
%
% OUTPUTS:
%    leakingMets:       Cell array listing any metabolites that can be be
%                       produced from nothing.
%
% .. Author: - Stefania Magnusdottir, Nov 2017

% find exchanges and sinks

selExch = findExcRxns(model);

% remove positive values on lower bounds
model.lb(find(model.lb>0))=0;

% leak test
[leakingMets, ~, ~] = fastLeakTest(model, model.rxns(selExch), true);

% warn if model leaks metabolites
if ~isempty(leakingMets)
    warning(['Model leaks ', num2str(length(unique(leakingMets(:, 1)))), ' metabolites.'])
end
