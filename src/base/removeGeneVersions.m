function [modelOut] = removeGeneVersions(model)
% This function removes gene versions from a model, updates model.genes, model.grRules, model.rules, model.rxnGeneMat
%
% USAGE:
%           modelOut = removeGeneVersions(model)
%
% INPUTS:
%   model - COBRA model structure with fields 'genes' and 'grRules'
%
% OUTPUTS:
%   modelOut - updated model without gene versions
%
% ...Author: Farid Zare, April 2025
%

if ~isfield(model, 'genes')
    error('Input model should have field genes')
end

% Initialise output as a copy of the input model
modelOut = model;

% Step 1: Strip version numbers from model.genes using regex
modelOut.genes = regexprep(model.genes, '\.\d+$', '');

% Step 2: Strip version numbers from model.grRules using a single regex pass
if isfield(model, 'grRules')
    modelOut.grRules = regexprep(model.grRules, '\.\d+', '');
else
    warning('The input model does not have grRules field');
end

% Step 3: Remove duplicate genes while preserving original order
[~, ia] = unique(modelOut.genes, 'stable');
modelOut.genes = modelOut.genes(sort(ia));

if isfield(modelOut, 'rules')
    % Remove old rules fild to generate new one
    modelOut = rmfield(modelOut, 'rules');
end

% Step 4: Rebuild rxnGeneMat using the updated gene list and grRules
modelOut = buildRxnGeneMat(modelOut);

% Get rational GPRs
parsedGPR = GPRparser(modelOut);

% Convert rational format to cell format
modelOut.grRules = buildGrRules(parsedGPR);

if isfield(modelOut, 'rules')
    % Remove old rules fild to generate new one
    modelOut = rmfield(modelOut, 'rules');
    modelOut = generateRules(modelOut);
end

end